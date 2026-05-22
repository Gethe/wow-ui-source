CVarCallbackRegistry:SetCVarCachable(NamePlateConstants.SOFT_TARGET_NAMEPLATE_SIZE_CVAR);
CVarCallbackRegistry:SetCVarCachable(NamePlateConstants.SOFT_TARGET_ICON_ENEMY_CVAR);
CVarCallbackRegistry:SetCVarCachable(NamePlateConstants.SOFT_TARGET_ICON_FRIEND_CVAR);
CVarCallbackRegistry:SetCVarCachable(NamePlateConstants.SOFT_TARGET_ICON_INTERACT_CVAR);
CVarCallbackRegistry:SetCVarCachable(NamePlateConstants.STYLE_CVAR);

-- Handles setup and management of nameplates, including event handling, frame pooling, and
-- applying configuration options for all nameplate types.
NamePlateDriverMixin = {};

function NamePlateDriverMixin:OnLoad()
	self:RegisterEvent("NAME_PLATE_CREATED");
	self:RegisterEvent("FORBIDDEN_NAME_PLATE_CREATED");
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED");
	self:RegisterEvent("FORBIDDEN_NAME_PLATE_UNIT_ADDED");
	self:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
	self:RegisterEvent("FORBIDDEN_NAME_PLATE_UNIT_REMOVED");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED");
	self:RegisterEvent("PLAYER_SOFT_FRIEND_CHANGED");
	self:RegisterEvent("PLAYER_SOFT_ENEMY_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("CVAR_UPDATE");

	CVarCallbackRegistry:RegisterCallback(NamePlateConstants.DEBUFF_PADDING_CVAR, self.OnDebuffPaddingCVarChanged, self);
	CVarCallbackRegistry:RegisterCallback(NamePlateConstants.AURA_SCALE_CVAR, self.OnAuraScaleCVarChanged, self);

	self.pools = CreateFramePoolCollection();

	local forbidden = true;
	self.pools:CreatePool("BUTTON", self, "ForbiddenNamePlateUnitFrameTemplate", nil, forbidden);
	self.pools:CreatePool("BUTTON", self, "NamePlateUnitFrameTemplate");

	self.scriptNamePlates = {};

	self.optionCVars =
	{
		["nameplateShowFriendlyClassColor"] = true,
		["nameplateShowClassColor"] = true,
		[NamePlateConstants.SIZE_CVAR] = true,
		[NamePlateConstants.STYLE_CVAR] = true,
	};
end

function NamePlateDriverMixin:OnEvent(event, ...)
	if event == "NAME_PLATE_CREATED" then
		local namePlateFrameBase = ...;
		self:OnNamePlateCreated(namePlateFrameBase);
	elseif event == "FORBIDDEN_NAME_PLATE_CREATED" then
		local namePlateFrameBase = ...;
		self:OnForbiddenNamePlateCreated(namePlateFrameBase);
	elseif event == "NAME_PLATE_UNIT_ADDED" or event == "FORBIDDEN_NAME_PLATE_UNIT_ADDED" then
		local namePlateUnitToken = ...;
		self:OnNamePlateAdded(namePlateUnitToken);
	elseif event == "NAME_PLATE_UNIT_REMOVED" or event == "FORBIDDEN_NAME_PLATE_UNIT_REMOVED" then
		local namePlateUnitToken = ...;
		self:OnNamePlateRemoved(namePlateUnitToken);
	elseif event == "PLAYER_TARGET_CHANGED" then
		self:OnTargetChanged();
	elseif ((event == "PLAYER_SOFT_INTERACT_CHANGED") or (event == "PLAYER_SOFT_FRIEND_CHANGED") or (event == "PLAYER_SOFT_ENEMY_CHANGED")) then
		self:OnSoftTargetUpdate();
	elseif event == "DISPLAY_SIZE_CHANGED" then
		self:UpdateNamePlateOptions();
	elseif event == "VARIABLES_LOADED" then
		self:UpdateNamePlateOptions();
	elseif event == "CVAR_UPDATE" then
		local name = ...;
		if self.optionCVars[name] then
			self:UpdateNamePlateOptions();
		end
	end
end

function NamePlateDriverMixin:OnDebuffPaddingCVarChanged()
	local namePlateStyle = CVarCallbackRegistry:GetCVarNumberOrDefault(NamePlateConstants.STYLE_CVAR);
	local namePlateScale = self:GetNamePlateScale(namePlateStyle);

	self:UpdateNamePlateSize(namePlateStyle, namePlateScale);
end

function NamePlateDriverMixin:OnAuraScaleCVarChanged()
	local namePlateStyle = CVarCallbackRegistry:GetCVarNumberOrDefault(NamePlateConstants.STYLE_CVAR);
	local namePlateScale = self:GetNamePlateScale(namePlateStyle);

	self:UpdateNamePlateSize(namePlateStyle, namePlateScale);
end

-- Enables the creation of nameplates beyond those managed by C++.
-- The namePlateUnitToken parameter can be different than the unit the nameplate displays if the explicitUnitToken member is set.
function NamePlateDriverMixin:RegisterScriptNamePlate(namePlateFrameBase, namePlateUnitToken)
	self.scriptNamePlates[namePlateUnitToken] = namePlateFrameBase;
end

function NamePlateDriverMixin:UnregisterScriptNamePlate(namePlateUnitToken)
	self.scriptNamePlates[namePlateUnitToken] = nil;
end

function NamePlateDriverMixin:IsScriptNamePlateRegistered(namePlateUnitToken)
	return self.scriptNamePlates[namePlateUnitToken] ~= nil;
end

function NamePlateDriverMixin:GetNamePlateForUnit(namePlateUnitToken)
	if self.scriptNamePlates then
		local scriptNamePlate = self.scriptNamePlates[namePlateUnitToken];
		if scriptNamePlate then
			return scriptNamePlate;
		end
	end

	local namePlateFrameBase = C_NamePlate.GetNamePlateForUnit(namePlateUnitToken, issecure());
	if namePlateFrameBase then
		return namePlateFrameBase;
	end

	return nil;
end

function NamePlateDriverMixin:ForEachScriptNamePlate(func)
	if self.scriptNamePlates then
		for _, namePlateFrameBase in pairs(self.scriptNamePlates) do
			func(namePlateFrameBase);
		end
	end
end

function NamePlateDriverMixin:ForEachNamePlate(func)
	for _, namePlateFrameBase in pairs(C_NamePlate.GetNamePlates(issecure())) do
		func(namePlateFrameBase);
	end

	self:ForEachScriptNamePlate(func);
end

function NamePlateDriverMixin:OnNamePlateCreated(namePlateFrameBase)
	self:OnNamePlateCreatedInternal(namePlateFrameBase, "NamePlateUnitFrameTemplate");
end

function NamePlateDriverMixin:OnForbiddenNamePlateCreated(namePlateFrameBase)
	self:OnNamePlateCreatedInternal(namePlateFrameBase, "ForbiddenNamePlateUnitFrameTemplate");
end

function NamePlateDriverMixin:OnNamePlateCreatedInternal(namePlateFrameBase, unitFrameTemplate)
	Mixin(namePlateFrameBase, NamePlateBaseMixin);
	namePlateFrameBase:Init(unitFrameTemplate, self);
end

function NamePlateDriverMixin:GetPool(unitFrameTemplate)
	if Commentator and C_Commentator.IsSpectating() then
		return self.pools:GetOrCreatePool("BUTTON", self, Commentator:GetNameplateTemplate());
	end

	return self.pools:GetPool(unitFrameTemplate);
end

function NamePlateDriverMixin:AcquireUnitFrame(namePlateFrameBase)
	local pool = self:GetPool(namePlateFrameBase:GetUnitFrameTemplate());
	return pool:Acquire();
end

function NamePlateDriverMixin:ReleaseUnitFrame(namePlateFrameBase)
	local pool = self:GetPool(namePlateFrameBase:GetUnitFrameTemplate());
	pool:Release(namePlateFrameBase.UnitFrame);
end

function NamePlateDriverMixin:OnNamePlateAdded(namePlateUnitToken)
	local namePlateFrameBase = self:GetNamePlateForUnit(namePlateUnitToken);
	namePlateFrameBase:AcquireUnitFrame();
	namePlateFrameBase:SetUnit(namePlateUnitToken);

	self:SetupClassNameplateBars();
	self:UpdateSoftTargetIcon(namePlateFrameBase);
end

function NamePlateDriverMixin:OnNamePlateRemoved(namePlateUnitToken)
	local namePlateFrameBase = self:GetNamePlateForUnit(namePlateUnitToken);
	namePlateFrameBase:ClearUnit();
	namePlateFrameBase:ReleaseUnitFrame();
end

function NamePlateDriverMixin:OnTargetChanged()
	self:SetupClassNameplateBars();
end

function NamePlateDriverMixin:UpdateSoftTargetIconInternal(frame, iconSize, doEnemyIcon, doFriendIcon, doInteractIcon)
	local icon = frame.UnitFrame.SoftTargetFrame.Icon;
	local checkCursorTexture = false;
	local hasCursorTexture = false;

	if iconSize > 0 then
		if doEnemyIcon and UnitIsUnit(frame:GetUnit(), "softenemy") then
			checkCursorTexture = true;
		elseif doFriendIcon and UnitIsUnit(frame:GetUnit(), "softfriend") then
			checkCursorTexture = true;
		elseif doInteractIcon and UnitIsUnit(frame:GetUnit(), "softinteract") then
			checkCursorTexture = true;
		end

		if checkCursorTexture then
			hasCursorTexture = SetUnitCursorTexture(icon, frame:GetUnit());
		end
	end

	if hasCursorTexture then
		icon:Show();
	else
		icon:Hide();
	end
end

function NamePlateDriverMixin:UpdateSoftTargetIcon(frame)
	local iconSize = CVarCallbackRegistry:GetCVarNumberOrDefault(NamePlateConstants.SOFT_TARGET_NAMEPLATE_SIZE_CVAR);
	local doEnemyIcon = CVarCallbackRegistry:GetCVarValueBool(NamePlateConstants.SOFT_TARGET_ICON_ENEMY_CVAR);
	local doFriendIcon = CVarCallbackRegistry:GetCVarValueBool(NamePlateConstants.SOFT_TARGET_ICON_FRIEND_CVAR);
	local doInteractIcon = CVarCallbackRegistry:GetCVarValueBool(NamePlateConstants.SOFT_TARGET_ICON_INTERACT_CVAR);
	self:UpdateSoftTargetIconInternal(frame, iconSize, doEnemyIcon, doFriendIcon, doInteractIcon);
end

function NamePlateDriverMixin:OnSoftTargetUpdate()
	local iconSize = CVarCallbackRegistry:GetCVarNumberOrDefault(NamePlateConstants.SOFT_TARGET_NAMEPLATE_SIZE_CVAR);
	local doEnemyIcon = CVarCallbackRegistry:GetCVarValueBool(NamePlateConstants.SOFT_TARGET_ICON_ENEMY_CVAR);
	local doFriendIcon = CVarCallbackRegistry:GetCVarValueBool(NamePlateConstants.SOFT_TARGET_ICON_FRIEND_CVAR);
	local doInteractIcon = CVarCallbackRegistry:GetCVarValueBool(NamePlateConstants.SOFT_TARGET_ICON_INTERACT_CVAR);
	self:ForEachNamePlate(function(frame)
		self:UpdateSoftTargetIconInternal(frame, iconSize, doEnemyIcon, doFriendIcon, doInteractIcon);
	end);
end

function NamePlateDriverMixin:OnNamePlateResized(namePlateFrame)
	if self.classNamePlateMechanicFrame and self.classNamePlateMechanicFrame:GetParent() == namePlateFrame then
		self.classNamePlateMechanicFrame:OnSizeChanged();
	end
	if self.classNamePlatePowerBar and self.classNamePlatePowerBar:GetParent() == namePlateFrame then
		self.classNamePlatePowerBar:OnSizeChanged();
	end
	if self.classNamePlateAlternatePowerBar and self.classNamePlateAlternatePowerBar:GetParent() == namePlateFrame then
		self.classNamePlateAlternatePowerBar:OnSizeChanged();
	end
end

function NamePlateDriverMixin:SetupClassNameplateBars()
	local bottomMostBar = nil;
	local namePlatePlayer = self:GetNamePlateForUnit("player");
	if namePlatePlayer then
		bottomMostBar = namePlatePlayer.UnitFrame.HealthBarsContainer;
	end

	if self.classNamePlatePowerBar then
		if namePlatePlayer then
			self.classNamePlatePowerBar:SetParent(namePlatePlayer);
			self.classNamePlatePowerBar:ClearAllPoints();
			self.classNamePlatePowerBar:SetPoint("TOPLEFT", namePlatePlayer.UnitFrame.HealthBarsContainer, "BOTTOMLEFT", 0, 0);
			self.classNamePlatePowerBar:SetPoint("TOPRIGHT", namePlatePlayer.UnitFrame.HealthBarsContainer, "BOTTOMRIGHT", 0, 0);
			self.classNamePlatePowerBar:SetShown(true);

			bottomMostBar = self.classNamePlatePowerBar;
		else
			self.classNamePlatePowerBar:Hide();
		end
	end

	if self.classNamePlateAlternatePowerBar then
		if namePlatePlayer then
			local powerBar = self.classNamePlatePowerBar;
			local attachTo = (powerBar and powerBar:IsShown() and powerBar) or namePlatePlayer.UnitFrame.HealthBarsContainer;
			self.classNamePlateAlternatePowerBar:SetParent(namePlatePlayer);
			self.classNamePlateAlternatePowerBar:ClearAllPoints();
			self.classNamePlateAlternatePowerBar:SetPoint("TOPLEFT", attachTo, "BOTTOMLEFT", 0, 0);
			self.classNamePlateAlternatePowerBar:SetPoint("TOPRIGHT", attachTo, "BOTTOMRIGHT", 0, 0);
			self.classNamePlateAlternatePowerBar:Show();

			bottomMostBar = self.classNamePlateAlternatePowerBar;
		else
			self.classNamePlateAlternatePowerBar:Hide();
		end
	end

	if self.classNamePlateMechanicFrame then
		if bottomMostBar then
			self.classNamePlateMechanicFrame:SetParent(namePlatePlayer);
			self.classNamePlateMechanicFrame:ClearAllPoints();
			self.classNamePlateMechanicFrame:SetPoint("TOP", bottomMostBar, "BOTTOM", 0, self.classNamePlateMechanicFrame.paddingOverride or -4);
			self.classNamePlateMechanicFrame:Show();
		else
			self.classNamePlateMechanicFrame:Hide();
		end
	end
end

function NamePlateDriverMixin:SetClassNameplateBar(frame)
	self.classNamePlateMechanicFrame = frame;
	self:SetupClassNameplateBars();
end

function NamePlateDriverMixin:GetClassNameplateBar()
	return self.classNamePlateMechanicFrame;
end

function NamePlateDriverMixin:GetClassNameplateManaBar()
	return self.classNamePlatePowerBar;
end

function NamePlateDriverMixin:SetClassNameplateManaBar(frame)
	self.classNamePlatePowerBar = frame;
	self:SetupClassNameplateBars();
end

function NamePlateDriverMixin:SetClassNameplateAlternatePowerBar(frame)
	self.classNamePlateAlternatePowerBar = frame;
	self:SetupClassNameplateBars();
end

function NamePlateDriverMixin:GetClassNameplateAlternatePowerBar()
	return self.classNamePlateAlternatePowerBar;
end

function NamePlateDriverMixin:SetBaseNamePlateSize(width, height)
	if self.baseNamePlateWidth ~= width or self.baseNamePlateHeight ~= height then
		self.baseNamePlateWidth = width;
		self.baseNamePlateHeight = height;

		self:UpdateNamePlateOptions();
	end
end

function NamePlateDriverMixin:GetBaseNamePlateWidth()
	return self.baseNamePlateWidth;
end

function NamePlateDriverMixin:GetBaseNamePlateHeight()
	return self.baseNamePlateHeight;
end

function NamePlateDriverMixin:IsUsingLargerNamePlateStyle()
	local namePlateSize = GetCVarNumberOrDefault(NamePlateConstants.SIZE_CVAR);
	return namePlateSize > Enum.NamePlateSize.Medium;
end

function NamePlateDriverMixin:GetNamePlateScale(namePlateStyle)
	local namePlateSize = GetCVarNumberOrDefault(NamePlateConstants.SIZE_CVAR);
	local scaleTable = namePlateStyle == Enum.NamePlateStyle.Classic and NamePlateConstants.NAME_PLATE_SCALES_CLASSIC_STYLE or NamePlateConstants.NAME_PLATE_SCALES;
	return scaleTable[namePlateSize] or scaleTable[Enum.NamePlateSize.Medium];
end

local function GetAuraFrameHeight(namePlateScale)
	-- This is intentionally not accounting for a potential second row of debuffs. A second row of
	-- debuffs can cause overlap when stacking nameplates.
	local auraScale = CVarCallbackRegistry:GetCVarNumberOrDefault(NamePlateConstants.AURA_SCALE_CVAR);
	return NamePlateConstants.AURA_ITEM_HEIGHT * auraScale * namePlateScale.aura;
end

local function GetHealthBarHeight(namePlateStyle, namePlateScale)
	if namePlateStyle == Enum.NamePlateStyle.Classic then
		local classicHealthBarHeight = NamePlateConstants.CLASSIC_HEALTH_BAR_HEIGHT;
		return classicHealthBarHeight * namePlateScale.vertical;
	elseif namePlateStyle == Enum.NamePlateStyle.Modern or namePlateStyle == Enum.NamePlateStyle.Block or namePlateStyle == Enum.NamePlateStyle.HealthFocus then
		local largeHealthBarHeight = NamePlateConstants.LARGE_HEALTH_BAR_HEIGHT;
		return largeHealthBarHeight * namePlateScale.vertical;
	end

	local smallHealthBarHeight = NamePlateConstants.SMALL_HEALTH_BAR_HEIGHT;
	return smallHealthBarHeight * namePlateScale.vertical;
end

local function GetHealthBarFontHeight(namePlateStyle, namePlateScale)
	if namePlateStyle == Enum.NamePlateStyle.Classic then
		return NamePlateConstants.CLASSIC_HEALTH_BAR_FONT_HEIGHT * namePlateScale.vertical;
	end

	return NamePlateConstants.HEALTH_BAR_FONT_HEIGHT * namePlateScale.vertical;
end

local function GetCastBarHeight(namePlateStyle, namePlateScale)
	if namePlateStyle == Enum.NamePlateStyle.Classic then
		local classicCastBarHeight = NamePlateConstants.CLASSIC_CAST_BAR_HEIGHT;
		return classicCastBarHeight * namePlateScale.vertical;
	elseif namePlateStyle == Enum.NamePlateStyle.CastFocus or namePlateStyle == Enum.NamePlateStyle.Block then
		local largeCastBarHeight = NamePlateConstants.LARGE_CAST_BAR_HEIGHT;
		return largeCastBarHeight * namePlateScale.vertical;
	end

	local smallCastBarHeight = NamePlateConstants.SMALL_CAST_BAR_HEIGHT;
	return smallCastBarHeight * namePlateScale.vertical;
end

local function GetCastBarFontHeight(namePlateScale)
	return NamePlateConstants.CAST_BAR_FONT_HEIGHT * namePlateScale.vertical;
end

local function GetCastBarIconHeight(namePlateStyle, namePlateScale)
	if namePlateStyle == Enum.NamePlateStyle.Classic then
		return NamePlateConstants.CLASSIC_CAST_BAR_ICON_HEIGHT * namePlateScale.vertical;
	end

	return NamePlateConstants.CAST_BAR_ICON_HEIGHT * namePlateScale.vertical;
end

local function ShouldUseClassicHealthBar(namePlateStyle)
	return namePlateStyle == Enum.NamePlateStyle.Classic;
end

local function ShouldUseClassicCastBar(namePlateStyle)
	return namePlateStyle == Enum.NamePlateStyle.Classic;
end

local function GetHealthBarToNameAboveSpacing(namePlateStyle, namePlateScale)
	if ShouldUseClassicHealthBar(namePlateStyle) then
		return NamePlateConstants.CLASSIC_HEALTH_BAR_TO_NAME_ABOVE_SPACING * namePlateScale.vertical;
	end
	return NamePlateConstants.HEALTH_BAR_TO_NAME_ABOVE_SPACING * namePlateScale.vertical;
end

local function GetCastBarToHealthBarSpacing(namePlateStyle, namePlateScale)
	if ShouldUseClassicCastBar(namePlateStyle) then
		return NamePlateConstants.CLASSIC_CAST_BAR_TO_HEALTH_BAR_SPACING * namePlateScale.vertical;
	end
	return NamePlateConstants.CAST_BAR_TO_HEALTH_BAR_SPACING * namePlateScale.vertical;
end

local function ShouldHideIconWhenNotInterruptible(namePlateStyle)
	return not ShouldUseClassicCastBar(namePlateStyle); -- Classic castbar should NOT hide the icon.
end

local function GetHealthBarBorderSize(namePlateStyle, namePlateScale)
	if ShouldUseClassicHealthBar(namePlateStyle) then
		return NamePlateConstants.CLASSIC_BORDER_WIDTH * namePlateScale.horizontal, NamePlateConstants.CLASSIC_BORDER_HEIGHT * namePlateScale.vertical;
	end

	return 0, 0;
end

local function GetCastBarBorderSize(namePlateStyle, namePlateScale)
	if ShouldUseClassicCastBar(namePlateStyle) then
		return NamePlateConstants.CLASSIC_BORDER_WIDTH * namePlateScale.horizontal, NamePlateConstants.CLASSIC_BORDER_HEIGHT * namePlateScale.vertical;
	end

	return 0, 0;
end

local function GetUnitNameAnchorStyle(namePlateStyle)
	if namePlateStyle == Enum.NamePlateStyle.Modern or namePlateStyle == Enum.NamePlateStyle.Block then
		return NamePlateConstants.NAME_ANCHOR_STYLES.InsideHealthBar;
	elseif namePlateStyle == Enum.NamePlateStyle.Classic then
		return NamePlateConstants.NAME_ANCHOR_STYLES.CenteredAboveHealthBar;
	else
		return NamePlateConstants.NAME_ANCHOR_STYLES.AboveHealthBar;
	end
end

local function GetUnitNameMouseoverColor(namePlateStyle)
	if ShouldUseClassicCastBar(namePlateStyle) then
		return YELLOW_FONT_COLOR;
	end

	return nil; -- No override color.
end

local function ShouldColorHealthWithExtendedColors(namePlateStyle)
	return not ShouldUseClassicCastBar(namePlateStyle); -- Modern uses extended colors; Classic does not.
end

local function ShouldDisplaySelectionHighlight(namePlateStyle)
	return ShouldUseClassicCastBar(namePlateStyle); -- When targeted, brighten health for Classic Style health bar.
end

local function IsUnitNameInsideHealthBar(namePlateStyle)
	return GetUnitNameAnchorStyle(namePlateStyle) == NamePlateConstants.NAME_ANCHOR_STYLES.InsideHealthBar;
end

local function IsUnitNameColored(namePlateStyle)
	if namePlateStyle == Enum.NamePlateStyle.Legacy then
		return true;
	end

	return false;
end

local function IsSpellNameInsideCastBar(namePlateStyle)
	if namePlateStyle == Enum.NamePlateStyle.Block or namePlateStyle == Enum.NamePlateStyle.CastFocus or namePlateStyle == Enum.NamePlateStyle.Classic then
		return true;
	end

	return false;
end

local function ShouldShowLevel(namePlateStyle)
	return ShouldUseClassicHealthBar(namePlateStyle); -- Classic health bar border has a space for level.
end

local function GetLevelFontHeight(namePlateScale)
	return NamePlateConstants.LEVEL_FONT_HEIGHT * namePlateScale.vertical;
end

local function GetLevelIconSize(namePlateScale)
	return NamePlateConstants.LEVEL_ICON_WIDTH * namePlateScale.horizontal, NamePlateConstants.LEVEL_ICON_HEIGHT * namePlateScale.vertical;
end

function NamePlateDriverMixin:GetNamePlateHeight(namePlateStyle, namePlateScale)
	if self.baseNamePlateHeight then
		return self.baseNamePlateHeight;
	end

	-- This logic needs to be kept in sync with the actual layout of nameplates which is handled
	-- mostly in NamePlateUnitFrameMixin:UpdateAnchors.

	local height = 0;

	height = height + GetAuraFrameHeight(namePlateScale);

	height = height + CVarCallbackRegistry:GetCVarNumberOrDefault(NamePlateConstants.DEBUFF_PADDING_CVAR);

	if not IsUnitNameInsideHealthBar(namePlateStyle) then
		height = height + GetHealthBarFontHeight(namePlateStyle, namePlateScale);
	end

	height = height + GetHealthBarHeight(namePlateStyle, namePlateScale);
	height = height + GetCastBarHeight(namePlateStyle, namePlateScale);

	if not IsSpellNameInsideCastBar(namePlateStyle) then
		height = height + GetCastBarFontHeight(namePlateScale);
	end

	return height;
end

function NamePlateDriverMixin:GetNamePlateWidth(namePlateStyle, namePlateScale)
	if self.baseNamePlateWidth then
		return self.baseNamePlateWidth;
	end

	if namePlateStyle == Enum.NamePlateStyle.Classic then
		return NamePlateConstants.CLASSIC_NAMEPLATE_WIDTH * namePlateScale.horizontal;
	else
		return NamePlateConstants.NAMEPLATE_WIDTH * namePlateScale.horizontal;
	end
end

function NamePlateDriverMixin:UpdateNamePlateOptions()
	local namePlateStyle = CVarCallbackRegistry:GetCVarNumberOrDefault(NamePlateConstants.STYLE_CVAR);
	local namePlateScale = self:GetNamePlateScale(namePlateStyle);

	-- Options for all nameplates.
	NamePlateSetupOptions.horizontalScale = namePlateScale.horizontal;
	NamePlateSetupOptions.verticalScale = namePlateScale.vertical;

	NamePlateSetupOptions.healthBarHeight = GetHealthBarHeight(namePlateStyle, namePlateScale);
	NamePlateSetupOptions.healthBarFontHeight =  GetHealthBarFontHeight(namePlateStyle, namePlateScale);
	NamePlateSetupOptions.useClassicHealthBar = ShouldUseClassicHealthBar(namePlateStyle);
	NamePlateSetupOptions.healthBarToNameAboveSpacing = GetHealthBarToNameAboveSpacing(namePlateStyle, namePlateScale);

	NamePlateSetupOptions.castBarHeight =  GetCastBarHeight(namePlateStyle, namePlateScale);
	NamePlateSetupOptions.castBarFontHeight = GetCastBarFontHeight(namePlateScale);
	NamePlateSetupOptions.useClassicCastBar = ShouldUseClassicCastBar(namePlateStyle);
	NamePlateSetupOptions.castBarToHealthBarSpacing = GetCastBarToHealthBarSpacing(namePlateStyle, namePlateScale);

	NamePlateSetupOptions.castBarShieldWidth = 10 * namePlateScale.vertical;
	NamePlateSetupOptions.castBarShieldHeight = 12 * namePlateScale.vertical;

	NamePlateSetupOptions.castIconWidth = GetCastBarIconHeight(namePlateStyle, namePlateScale);
	NamePlateSetupOptions.castIconHeight = GetCastBarIconHeight(namePlateStyle, namePlateScale);
	NamePlateSetupOptions.hideIconWhenNotInterruptible = ShouldHideIconWhenNotInterruptible(namePlateStyle);

	NamePlateSetupOptions.unitNameAnchorStyle = GetUnitNameAnchorStyle(namePlateStyle);
	NamePlateSetupOptions.spellNameInsideCastBar = IsSpellNameInsideCastBar(namePlateStyle);

	NamePlateSetupOptions.classificationScale = namePlateScale.classification;

	NamePlateSetupOptions.levelFontHeight = GetLevelFontHeight(namePlateScale);
	NamePlateSetupOptions.levelIconWidth, NamePlateSetupOptions.levelIconHeight = GetLevelIconSize(namePlateScale);

	NamePlateSetupOptions.insetWidth = NamePlateConstants.HORIZONTAL_INSET * namePlateScale.horizontal;

	-- Border option is used by Classic Style.
	NamePlateSetupOptions.healthBarBorderWidth, NamePlateSetupOptions.healthBarBorderHeight = GetHealthBarBorderSize(namePlateStyle, namePlateScale);
	NamePlateSetupOptions.castBarBorderWidth, NamePlateSetupOptions.castBarBorderHeight = GetCastBarBorderSize(namePlateStyle, namePlateScale);

	-- Options specific to Enemy nameplates.
	NamePlateEnemyFrameOptions.useClassColors = GetCVarBool("nameplateShowClassColor");
	NamePlateEnemyFrameOptions.colorNameBySelection = IsUnitNameColored(namePlateStyle);
	NamePlateEnemyFrameOptions.nameMouseoverColor = GetUnitNameMouseoverColor(namePlateStyle);
	NamePlateEnemyFrameOptions.showLevel = ShouldShowLevel(namePlateStyle);
	NamePlateEnemyFrameOptions.colorHealthWithExtendedColors = ShouldColorHealthWithExtendedColors(namePlateStyle);
	NamePlateEnemyFrameOptions.displaySelectionHighlight = ShouldDisplaySelectionHighlight(namePlateStyle);
	NamePlateEnemyFrameOptions.displaySelectionHighlightOnMouseover = ShouldDisplaySelectionHighlight(namePlateStyle);
	

	-- Options specific to Friendly nameplates.
	NamePlateFriendlyFrameOptions.useClassColors = GetCVarBool("nameplateShowFriendlyClassColor");
	NamePlateFriendlyFrameOptions.colorNameBySelection = IsUnitNameColored(namePlateStyle);
	NamePlateFriendlyFrameOptions.nameMouseoverColor = GetUnitNameMouseoverColor(namePlateStyle);
	NamePlateFriendlyFrameOptions.showLevel = ShouldShowLevel(namePlateStyle);
	NamePlateFriendlyFrameOptions.colorHealthWithExtendedColors = ShouldColorHealthWithExtendedColors(namePlateStyle);
	NamePlateFriendlyFrameOptions.displaySelectionHighlight = ShouldDisplaySelectionHighlight(namePlateStyle);
	NamePlateFriendlyFrameOptions.displaySelectionHighlightOnMouseover = ShouldDisplaySelectionHighlight(namePlateStyle);

	self:UpdateNamePlateSize(namePlateStyle, namePlateScale);

	self:ForEachNamePlate(function(frame)
		frame:ApplyFrameOptions();
	end);

	if self.classNamePlateMechanicFrame then
		self.classNamePlateMechanicFrame:OnOptionsUpdated();
	end
	if self.classNamePlatePowerBar then
		self.classNamePlatePowerBar:OnOptionsUpdated();
	end
	if self.classNamePlateAlternatePowerBar then
		self.classNamePlateAlternatePowerBar:OnOptionsUpdated();
	end

	self:SetupClassNameplateBars();
end

function NamePlateDriverMixin:UpdateNamePlateSize(namePlateStyle, namePlateScale)
	local namePlateHeight = self:GetNamePlateHeight(namePlateStyle, namePlateScale);
	local namePlateWidth = self:GetNamePlateWidth(namePlateStyle, namePlateScale);

	-- C++ needs to know the size of the nameplates, which depends on the values of various options that can affect size and layout.
	C_NamePlate.SetNamePlateSize(namePlateWidth, namePlateHeight);

	-- Lua nameplates are not affected by the C_NamePlate size functions and need to have their size explicitly set.
	self:ForEachScriptNamePlate(function(frame)
		frame:SetSize(namePlateWidth, namePlateHeight);
	end);
end

NamePlateBorderTemplateMixin = {};

function NamePlateBorderTemplateMixin:SetVertexColor(r, g, b, a)
	for i, texture in ipairs(self.Textures) do
		texture:SetVertexColor(r, g, b, a);
	end
end

function NamePlateBorderTemplateMixin:SetUnderlineColor(r, g, b, a)
	if self.Top == nil then
		return;
	end
	self.Top:SetVertexColor(0, 0, 0, 0);
	self.Bottom:SetVertexColor(r, g, b, a);
	self.Left:SetGradient("VERTICAL", CreateColor(r, g, b, a), CreateColor(r, g, b, 0));
	self.Right:SetGradient("VERTICAL", CreateColor(r, g, b, a), CreateColor(r, g, b, 0));
end

function NamePlateBorderTemplateMixin:SetBorderSizes(borderSize, borderSizeMinPixels, upwardExtendHeightPixels, upwardExtendHeightMinPixels)
	self.borderSize = borderSize;
	self.borderSizeMinPixels = borderSizeMinPixels;
	self.upwardExtendHeightPixels = upwardExtendHeightPixels;
	self.upwardExtendHeightMinPixels = upwardExtendHeightMinPixels;
end

function NamePlateBorderTemplateMixin:UpdateSizes()
	local borderSize = self.borderSize or 1;
	local minPixels = self.borderSizeMinPixels or 2;

	local upwardExtendHeightPixels = self.upwardExtendHeightPixels or borderSize;
	local upwardExtendHeightMinPixels = self.upwardExtendHeightMinPixels or minPixels;

	PixelUtil.SetWidth(self.Left, borderSize, minPixels);
	PixelUtil.SetPoint(self.Left, "TOPRIGHT", self, "TOPLEFT", 0, upwardExtendHeightPixels, 0, upwardExtendHeightMinPixels);
	PixelUtil.SetPoint(self.Left, "BOTTOMRIGHT", self, "BOTTOMLEFT", 0, -borderSize, 0, minPixels);

	PixelUtil.SetWidth(self.Right, borderSize, minPixels);
	PixelUtil.SetPoint(self.Right, "TOPLEFT", self, "TOPRIGHT", 0, upwardExtendHeightPixels, 0, upwardExtendHeightMinPixels);
	PixelUtil.SetPoint(self.Right, "BOTTOMLEFT", self, "BOTTOMRIGHT", 0, -borderSize, 0, minPixels);

	PixelUtil.SetHeight(self.Bottom, borderSize, minPixels);
	PixelUtil.SetPoint(self.Bottom, "TOPLEFT", self, "BOTTOMLEFT", 0, 0);
	PixelUtil.SetPoint(self.Bottom, "TOPRIGHT", self, "BOTTOMRIGHT", 0, 0);

	if self.Top then
		PixelUtil.SetHeight(self.Top, borderSize, minPixels);
		PixelUtil.SetPoint(self.Top, "BOTTOMLEFT", self, "TOPLEFT", 0, 0);
		PixelUtil.SetPoint(self.Top, "BOTTOMRIGHT", self, "TOPRIGHT", 0, 0);
	end
end

NamePlateScriptBaseMixin = {};

function NamePlateScriptBaseMixin:CanChangeHitTestPoints()
	return true;
end

function NamePlateScriptBaseMixin:ClearAllHitTestPoints()
end

function NamePlateScriptBaseMixin:GetHitTestPoints()
	return {};
end

function NamePlateScriptBaseMixin:SetHitTestPoints(_points)
end

function NamePlateScriptBaseMixin:SetAllHitTestPoints(_relativeTo)
end

function NamePlateScriptBaseMixin:SetStackingBoundsFrame(_frame)
end
