NamePlateDriverMixin = {};

function NamePlateDriverMixin:OnLoad()
	self:RegisterEvent("NAME_PLATE_CREATED");
	self:RegisterEvent("FORBIDDEN_NAME_PLATE_CREATED");
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED");
	self:RegisterEvent("FORBIDDEN_NAME_PLATE_UNIT_ADDED");
	self:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
	self:RegisterEvent("FORBIDDEN_NAME_PLATE_UNIT_REMOVED");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("RAID_TARGET_UPDATE");
	self:RegisterEvent("UNIT_FACTION");
	self:RegisterEvent("COMMENTATOR_PLAYER_UPDATE");

	self:SetBaseNamePlateSize(128, 32);

	self.namePlateSetupFunctions =
	{
		["friendly"] = DefaultCompactNamePlateFriendlyFrameSetup,
		["enemy"] = DefaultCompactNamePlateEnemyFrameSetup,
	};

	self.namePlateSetInsetFunctions =
	{
		["friendly"] =  C_NamePlate.SetNamePlateFriendlyPreferredClickInsets,
		["enemy"] = C_NamePlate.SetNamePlateEnemyPreferredClickInsets,
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
	elseif event == "DISPLAY_SIZE_CHANGED" then
		self:UpdateNamePlateOptions();
	elseif event == "UNIT_AURA" then
		self:OnUnitAuraUpdate(...);
	elseif event == "VARIABLES_LOADED" then
		self:UpdateNamePlateOptions();
	elseif event == "CVAR_UPDATE" then
		local name = ...;
		if name == "SHOW_CLASS_COLOR_IN_V_KEY" or name == "SHOW_NAMEPLATE_LOSE_AGGRO_FLASH" or name == "UNIT_NAMEPLATES_SHOW_FRIENDLY_CLASS_COLORS" then
			self:UpdateNamePlateOptions();
		end
	elseif event == "RAID_TARGET_UPDATE" then
		self:OnRaidTargetUpdate();
	elseif ( event == "UNIT_FACTION" ) then
		self:OnUnitFactionChanged(...);
	elseif event == "COMMENTATOR_PLAYER_UPDATE" then
		self:UpdateAllNames();
		self:UpdateAllHealthColor();
	end
end

function NamePlateDriverMixin:OnNamePlateCreated(namePlateFrameBase)
	Mixin(namePlateFrameBase, NamePlateBaseMixin);

	CreateFrame("BUTTON", "$parentUnitFrame", namePlateFrameBase, "NamePlateUnitFrameTemplate");
	namePlateFrameBase.UnitFrame:EnableMouse(false);
end

function NamePlateDriverMixin:OnForbiddenNamePlateCreated(namePlateFrameBase)
	Mixin(namePlateFrameBase, NamePlateBaseMixin);

	CreateFrame("BUTTON", "$parentUnitFrame", namePlateFrameBase, "ForbiddenNamePlateUnitFrameTemplate");
	namePlateFrameBase.UnitFrame:EnableMouse(false);
end

function NamePlateDriverMixin:OnNamePlateAdded(namePlateUnitToken)
	local namePlateFrameBase = C_NamePlate.GetNamePlateForUnit(namePlateUnitToken, issecure());
	self:ApplyFrameOptions(namePlateFrameBase, namePlateUnitToken);

	namePlateFrameBase:OnAdded(namePlateUnitToken, self);

	self:OnUnitAuraUpdate(namePlateUnitToken);
	self:OnRaidTargetUpdate();
end

function NamePlateDriverMixin:GetNamePlateTypeFromUnit(unit)
	if UnitIsFriend("player", unit) then
		return "friendly";
	else
		return "enemy";
	end
end

function NamePlateDriverMixin:ApplyFrameOptions(namePlateFrameBase, namePlateUnitToken)
	local namePlateType = self:GetNamePlateTypeFromUnit(namePlateUnitToken);
	local setupFn = self.namePlateSetupFunctions[namePlateType];

	if setupFn then
		CompactUnitFrame_SetUpFrame(namePlateFrameBase.UnitFrame, setupFn);
	end

	namePlateFrameBase:OnOptionsUpdated();

	self:UpdateInsetsForType(namePlateType, namePlateFrameBase);
end

function NamePlateDriverMixin:UpdateInsetsForType(namePlateType, namePlateFrameBase)
	-- Only update the options for each nameplate type once, these can change at run time
	-- depending on any options that change where pieces of the nameplate are positioned (scale is the main one)
	if not self.preferredInsets[namePlateType] then
		local setInsetFn = self.namePlateSetInsetFunctions[namePlateType];
		if setInsetFn then
			-- NOTE: Insets should push in from the edge, but avoid using abs in case they actually push outside, it will be handled properly.
			self.preferredInsets[namePlateType] = true;
			setInsetFn(namePlateFrameBase:GetPreferredInsets());
		end
	end
end

function NamePlateDriverMixin:OnNamePlateRemoved(namePlateUnitToken)
	local namePlateFrameBase = C_NamePlate.GetNamePlateForUnit(namePlateUnitToken, issecure());

	namePlateFrameBase:OnRemoved();
end

function NamePlateDriverMixin:OnTargetChanged()
	self:OnUnitAuraUpdate("target");
end

function NamePlateDriverMixin:OnUnitAuraUpdate(unit)
	local filter;
	local showAll = false;
	if UnitIsUnit("player", unit) then
		filter = "HELPFUL|INCLUDE_NAME_PLATE_ONLY";
	else
		local reaction = UnitReaction("player", unit);
		if reaction and reaction <= 4 then
		-- Reaction 4 is neutral and less than 4 becomes increasingly more hostile
			filter = "HARMFUL|INCLUDE_NAME_PLATE_ONLY";
		else
			local showDebuffsOnFriendly = GetCVarBool("nameplateShowDebuffsOnFriendly");
			if (showDebuffsOnFriendly) then
				-- dispellable debuffs
				filter = "HARMFUL|RAID";
				showAll = true;
			else
				filter = "NONE";
			end
		end
	end

	local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure());
end

function NamePlateDriverMixin:OnRaidTargetUpdate()
	for _, frame in pairs(C_NamePlate.GetNamePlates(issecure())) do
		local icon = frame.UnitFrame.RaidTargetFrame.RaidTargetIcon;
		local index = GetRaidTargetIndex(frame.namePlateUnitToken);
		if ( index and not UnitIsUnit("player", frame.namePlateUnitToken) ) then
			SetRaidTargetIconTexture(icon, index);
			icon:Show();
		else
			icon:Hide();
		end
	end

end

function NamePlateDriverMixin:OnUnitFactionChanged(unit)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure());
	if (nameplate) then
		CompactUnitFrame_UpdateName(nameplate.UnitFrame);
		CompactUnitFrame_UpdateHealthColor(nameplate.UnitFrame);
	end
end

function NamePlateDriverMixin:UpdateAllNames()
	for _, frame in pairs(C_NamePlate.GetNamePlates(issecure())) do
		CompactUnitFrame_UpdateName(frame.UnitFrame);
	end
end

function NamePlateDriverMixin:UpdateAllHealthColor()
	for _, frame in pairs(C_NamePlate.GetNamePlates(issecure())) do
		CompactUnitFrame_UpdateHealthColor(frame.UnitFrame);
	end
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
	local namePlateVerticalScale = tonumber(GetCVar("NamePlateVerticalScale"));
	return namePlateVerticalScale > 1.0;
end

function NamePlateDriverMixin:UpdateNamePlateOptions()
	DefaultCompactNamePlateEnemyFrameOptions.useClassColors = GetCVarBool("ShowClassColorInNameplate");

	local showOnlyNames = GetCVarBool("nameplateShowOnlyNames");
	DefaultCompactNamePlateFriendlyFrameOptions.useClassColors = GetCVarBool("ShowClassColorInFriendlyNameplate");
	DefaultCompactNamePlateFriendlyFrameOptions.hideHealthbar = showOnlyNames;

	local colorNamePlateNameBySelection = GetCVarBool("ColorNameplateNameBySelection");
	DefaultCompactNamePlateFriendlyFrameOptions.colorNameBySelection = colorNamePlateNameBySelection;
	DefaultCompactNamePlateEnemyFrameOptions.colorNameBySelection = colorNamePlateNameBySelection;

	local namePlateVerticalScale = tonumber(GetCVar("NamePlateVerticalScale"));
	local zeroBasedScale = namePlateVerticalScale - 1.0;
	local clampedZeroBasedScale = Saturate(zeroBasedScale);
	DefaultCompactNamePlateFrameSetUpOptions.healthBarHeight = 10 * namePlateVerticalScale;

	DefaultCompactNamePlateFrameSetUpOptions.useLargeNameFont = clampedZeroBasedScale > .25;
	local screenWidth, screenHeight = GetPhysicalScreenSize();
	--DefaultCompactNamePlateFrameSetUpOptions.useFixedSizeFont = screenHeight <= 1200;
	DefaultCompactNamePlateFrameSetUpOptions.useLargeNameFont = true;

	DefaultCompactNamePlateFrameSetUpOptions.hideHealthbar = showOnlyNames;

	local horizontalScale = tonumber(GetCVar("NamePlateHorizontalScale"));
	C_NamePlate.SetNamePlateFriendlySize(self.baseNamePlateWidth * horizontalScale, self.baseNamePlateHeight * Lerp(1.0, 1.25, zeroBasedScale));
	C_NamePlate.SetNamePlateEnemySize(self.baseNamePlateWidth * horizontalScale, self.baseNamePlateHeight * Lerp(1.0, 1.25, zeroBasedScale));
	C_NamePlate.SetNamePlateSelfSize(self.baseNamePlateWidth * horizontalScale * Lerp(1.1, 1.0, clampedZeroBasedScale), self.baseNamePlateHeight);

	-- Clear the inset table, just update it from scratch since this will iterate all nameplates
	-- As each nameplate updates, it will handle updating preferred insets during its setup
	self.preferredInsets = {};

	for i, frame in ipairs(C_NamePlate.GetNamePlates(issecure())) do
		self:ApplyFrameOptions(frame, frame.namePlateUnitToken);
		CompactUnitFrame_SetUnit(frame.UnitFrame, frame.namePlateUnitToken);
	end

	if self.nameplateBar then
		self.nameplateBar:OnOptionsUpdated();
	end
	if self.nameplateManaBar then
		self.nameplateManaBar:OnOptionsUpdated();
	end
end

NamePlateBaseMixin = {};

function NamePlateBaseMixin:OnAdded(namePlateUnitToken, driverFrame)
	self.namePlateUnitToken = namePlateUnitToken;
	self.driverFrame = driverFrame;

	CompactUnitFrame_SetUnit(self.UnitFrame, namePlateUnitToken);

	self:ApplyOffsets();
	
	if C_Commentator.IsSpectating() then
		if self.UnitFrame.CommentatorDisplayInfo then
			self.UnitFrame.CommentatorDisplayInfo:Show();
		else
			CreateFrame("FRAME", nil, self.UnitFrame, "NamePlateCommentatorDisplayInfoTemplate");
		end
	else
		if self.CommentatorDisplayInfo then
			self.CommentatorDisplayInfo:Hide();
		end
	end
end

function NamePlateBaseMixin:OnRemoved()
	self.namePlateUnitToken = nil;
	self.driverFrame = nil;

	CompactUnitFrame_SetUnit(self.UnitFrame, nil);
end

function NamePlateBaseMixin:OnOptionsUpdated()
	if self.driverFrame then
		self:ApplyOffsets();
	end
end

function NamePlateBaseMixin:ApplyOffsets()
	-- Nothing to do in Classic.
end

NAMEPLATE_MINIMUM_INSET_HEIGHT_THRESHOLD = 10;
NAMEPLATE_ADDITIONAL_INSET_HEIGHT_PADDING = 2;

function NamePlateBaseMixin:GetAdditionalInsetPadding(insetWidth, insetHeight)
	local heightPadding = 0;
	local widthPadding = 0; -- No change to width is necessary yet.

	if (insetHeight < NAMEPLATE_MINIMUM_INSET_HEIGHT_THRESHOLD) then
		heightPadding = NAMEPLATE_ADDITIONAL_INSET_HEIGHT_PADDING;
	end

	return widthPadding, heightPadding;
end

function NamePlateBaseMixin:GetPreferredInsets()
	local frame = self.UnitFrame;
	local health = frame.healthBar;
	local border = health.border;

	local healthLeft = min(health:GetLeft(), border:GetLeft());
	local healthRight = max(health:GetRight(), border:GetRight());
	local healthTop = max(health:GetTop(), border:GetTop());
	local healthBottom = min(health:GetBottom(), border:GetBottom());

	local left = healthLeft - frame:GetLeft();
	local right = frame:GetRight() - healthRight;
	local top = frame:GetTop() - healthTop;
	local bottom = healthBottom - frame:GetBottom();

	-- Width probably won't be an issue, but if height is under a certain threshold, give the user a little more area to click on.
	local widthPadding, heightPadding = self:GetAdditionalInsetPadding(right - left, top - bottom);
	left = left - widthPadding;
	right = right - widthPadding;
	top = top - heightPadding;
	bottom = bottom - heightPadding;

	return left, right, top, bottom;
end

NamePlateBorderTemplateMixin = {};

function NamePlateBorderTemplateMixin:SetVertexColor(r, g, b, a)
	-- Nothing to do in Classic.
end