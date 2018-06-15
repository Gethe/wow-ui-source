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

	self:SetBaseNamePlateSize(110, 45);

	self.namePlateSetupFunctions =
	{
		["player"] = DefaultCompactNamePlatePlayerFrameSetup,
		["friendly"] = DefaultCompactNamePlateFriendlyFrameSetup,
		["enemy"] = DefaultCompactNamePlateEnemyFrameSetup,
	};

	self.namePlateSetInsetFunctions =
	{
		["player"] = C_NamePlate.SetNamePlateSelfPreferredClickInsets,
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
	self:SetupClassNameplateBars();

	self:OnUnitAuraUpdate(namePlateUnitToken);
	self:OnRaidTargetUpdate();
end

function NamePlateDriverMixin:GetNamePlateTypeFromUnit(unit)
	if UnitIsUnit("player", unit) then
		return "player";
	elseif UnitIsFriend("player", unit) then
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
	self:SetupClassNameplateBars();
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
	if (nameplate) then
		nameplate.UnitFrame.BuffFrame:UpdateBuffs(nameplate.namePlateUnitToken, filter, showAll);
	end
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

function NamePlateDriverMixin:SetupClassNameplateBar(onTarget, bar)
	if (not bar) then
		return;
	end

	bar:Hide();

	local showSelf = GetCVar("nameplateShowSelf");
	if (showSelf == "0") then
		return;
	end

	if (onTarget and NamePlateTargetResourceFrame) then
		local namePlateTarget = C_NamePlate.GetNamePlateForUnit("target", issecure());
		if (namePlateTarget) then
			bar:SetParent(NamePlateTargetResourceFrame);
			NamePlateTargetResourceFrame:SetParent(namePlateTarget.UnitFrame);
			NamePlateTargetResourceFrame:ClearAllPoints();
			NamePlateTargetResourceFrame:SetPoint("BOTTOM", namePlateTarget.UnitFrame.name, "TOP", 0, 4);
			bar:Show();
			NamePlateTargetResourceFrame:Layout();
		end
		NamePlateTargetResourceFrame:SetShown(namePlateTarget ~= nil);
	elseif (not onTarget and NamePlatePlayerResourceFrame) then
		local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player", issecure());
		if (namePlatePlayer) then
			bar:SetParent(NamePlatePlayerResourceFrame);
			NamePlatePlayerResourceFrame:SetParent(namePlatePlayer.UnitFrame);
			NamePlatePlayerResourceFrame:ClearAllPoints();
			NamePlatePlayerResourceFrame:SetPoint("TOP", namePlatePlayer.UnitFrame.healthBar, "BOTTOM", 0, -1);
			bar:Show();
			NamePlatePlayerResourceFrame:Layout();
		end
		NamePlatePlayerResourceFrame:SetShown(namePlatePlayer ~= nil);
	end
end

function NamePlateDriverMixin:SetupClassNameplateBars()
	local targetMode = GetCVarBool("nameplateResourceOnTarget");
	if (self.nameplateBar and self.nameplateBar.overrideTargetMode ~= nil) then
		targetMode = self.nameplateBar.overrideTargetMode;
	end
	self:SetupClassNameplateBar(targetMode, self.nameplateBar);
	self:SetupClassNameplateBar(false, self.nameplateManaBar);

	if targetMode and self.nameplateBar then
		local percentOffset = tonumber(GetCVar("nameplateClassResourceTopInset"));
		if self:IsUsingLargerNamePlateStyle() then
			percentOffset = percentOffset + .1;
		end
		C_NamePlate.SetTargetClampingInsets(percentOffset * UIParent:GetHeight(), 0.0);
	else
		C_NamePlate.SetTargetClampingInsets(0.0, 0.0);
	end
end

function NamePlateDriverMixin:SetClassNameplateBar(frame)
	self.nameplateBar = frame;
	self:SetupClassNameplateBars();
end

function NamePlateDriverMixin:GetClassNameplateBar()
	return self.nameplateBar;
end

function NamePlateDriverMixin:SetClassNameplateManaBar(frame)
	self.nameplateManaBar = frame;
	self:SetupClassNameplateBars();
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
	DefaultCompactNamePlateEnemyFrameOptions.playLoseAggroHighlight = GetCVarBool("ShowNamePlateLoseAggroFlash");

	local showOnlyNames = GetCVarBool("nameplateShowOnlyNames");
	DefaultCompactNamePlateFriendlyFrameOptions.useClassColors = GetCVarBool("ShowClassColorInFriendlyNameplate");
	DefaultCompactNamePlateFriendlyFrameOptions.hideHealthbar = showOnlyNames;
	DefaultCompactNamePlateFriendlyFrameOptions.hideCastbar = showOnlyNames;

	local namePlateVerticalScale = tonumber(GetCVar("NamePlateVerticalScale"));
	local zeroBasedScale = namePlateVerticalScale - 1.0;
	local clampedZeroBasedScale = Saturate(zeroBasedScale);
	DefaultCompactNamePlateFrameSetUpOptions.healthBarHeight = 4 * namePlateVerticalScale;
	DefaultCompactNamePlatePlayerFrameSetUpOptions.healthBarHeight = 4 * namePlateVerticalScale * Lerp(1.2, 1.0, clampedZeroBasedScale);

	DefaultCompactNamePlateFrameSetUpOptions.useLargeNameFont = clampedZeroBasedScale > .25;
	local screenWidth, screenHeight = GetPhysicalScreenSize();
	DefaultCompactNamePlateFrameSetUpOptions.useFixedSizeFont = screenHeight <= 1200;

	DefaultCompactNamePlateFrameSetUpOptions.castBarHeight = math.min(Lerp(12, 16, zeroBasedScale), DefaultCompactNamePlateFrameSetUpOptions.healthBarHeight * 2);
	DefaultCompactNamePlateFrameSetUpOptions.castBarFontHeight = Lerp(8, 12, clampedZeroBasedScale);

	DefaultCompactNamePlateFrameSetUpOptions.castBarShieldWidth = Lerp(10, 15, clampedZeroBasedScale);
	DefaultCompactNamePlateFrameSetUpOptions.castBarShieldHeight = Lerp(12, 18, clampedZeroBasedScale);

	DefaultCompactNamePlateFrameSetUpOptions.castIconWidth = Lerp(10, 15, clampedZeroBasedScale);
	DefaultCompactNamePlateFrameSetUpOptions.castIconHeight = Lerp(10, 15, clampedZeroBasedScale);

	DefaultCompactNamePlateFrameSetUpOptions.hideHealthbar = showOnlyNames;
	DefaultCompactNamePlateFrameSetUpOptions.hideCastbar = showOnlyNames;

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
	self:SetupClassNameplateBars();
end

NamePlateBaseMixin = {};

function NamePlateBaseMixin:OnAdded(namePlateUnitToken, driverFrame)
	self.namePlateUnitToken = namePlateUnitToken;
	self.driverFrame = driverFrame;

	CompactUnitFrame_SetUnit(self.UnitFrame, namePlateUnitToken);

	self:ApplyOffsets();
	
	if C_Commentator.IsSpectating() then
		self.UnitFrame.BuffFrame:SetActive(false);
		if self.UnitFrame.CommentatorDisplayInfo then
			self.UnitFrame.CommentatorDisplayInfo:Show();
		else
			CreateFrame("FRAME", nil, self.UnitFrame, "NamePlateCommentatorDisplayInfoTemplate");
		end
	else
		self.UnitFrame.BuffFrame:SetActive(true);
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
	if self.driverFrame:IsUsingLargerNamePlateStyle() then
		self.UnitFrame.BuffFrame:SetBaseYOffset(20);
	else
		self.UnitFrame.BuffFrame:SetBaseYOffset(0);
	end

	local targetMode = GetCVarBool("nameplateResourceOnTarget");
	if targetMode then
		self.UnitFrame.BuffFrame:SetTargetYOffset(18);
	else
		self.UnitFrame.BuffFrame:SetTargetYOffset(0);
	end
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

	local left = health:GetLeft() - frame:GetLeft();
	local right = frame:GetRight() - health:GetRight();
	local top = frame:GetTop() - health:GetTop();
	local bottom = health:GetBottom() - frame:GetBottom();

	-- Width probably won't be an issue, but if height is under a certain threshold, give the user a little more area to click on.
	local widthPadding, heightPadding = self:GetAdditionalInsetPadding(right - left, top - bottom);
	left = left - widthPadding;
	right = right - widthPadding;
	top = top - heightPadding;
	bottom = bottom - heightPadding;

	return left, right, top, bottom;
end

--------------------------------------------------------------------------------
--
-- Buffs
--
--------------------------------------------------------------------------------

NameplateBuffContainerMixin = {};

function NameplateBuffContainerMixin:OnLoad()
	self.buffList = {};
	self.targetYOffset = 0;
	self.baseYOffset = 0;
	self.BuffFrameUpdateTime = 0;
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
end

function NameplateBuffContainerMixin:OnEvent(event, ...)
	if (event == "PLAYER_TARGET_CHANGED") then
		self:UpdateAnchor();
	end
end

function NameplateBuffContainerMixin:OnUpdate(elapsed)
	if ( self.BuffFrameUpdateTime > 0 ) then
		self.BuffFrameUpdateTime = self.BuffFrameUpdateTime - elapsed;
	else
		self.BuffFrameUpdateTime = self.BuffFrameUpdateTime + TOOLTIP_UPDATE_TIME;
	end
end

function NameplateBuffContainerMixin:SetTargetYOffset(targetYOffset)
	self.targetYOffset = targetYOffset;
end

function NameplateBuffContainerMixin:GetTargetYOffset()
	return self.targetYOffset;
end

function NameplateBuffContainerMixin:SetBaseYOffset(baseYOffset)
	self.baseYOffset = baseYOffset;
end

function NameplateBuffContainerMixin:GetBaseYOffset()
	return self.baseYOffset;
end

function NameplateBuffContainerMixin:UpdateAnchor()
	local isTarget = self:GetParent().unit and UnitIsUnit(self:GetParent().unit, "target");
	local targetYOffset = self:GetBaseYOffset() + (isTarget and self:GetTargetYOffset() or 0.0);
	if (self:GetParent().unit and ShouldShowName(self:GetParent())) then
		self:SetPoint("BOTTOM", self:GetParent(), "TOP", 0, targetYOffset);
	else
		self:SetPoint("BOTTOM", self:GetParent().healthBar, "TOP", 0, 5 + targetYOffset);
	end
end

function NameplateBuffContainerMixin:ShouldShowBuff(name, caster, nameplateShowPersonal, nameplateShowAll, duration)
	if (not name) then
		return false;
	end
	return nameplateShowAll or
		   (nameplateShowPersonal and (caster == "player" or caster == "pet" or caster == "vehicle"));
end

function NameplateBuffContainerMixin:SetActive(isActive)
	self.isActive = isActive;
end

function NameplateBuffContainerMixin:UpdateBuffs(unit, filter, showAll)
	if not self.isActive then
		for i = 1, BUFF_MAX_DISPLAY do
			if (self.buffList[i]) then
				self.buffList[i]:Hide();
			end
		end
		
		return;
	end
	
	self.unit = unit;
	self.filter = filter;
	self:UpdateAnchor();

	if filter == "NONE" then
		for i, buff in ipairs(self.buffList) do
			buff:Hide();
		end
	else
		-- Some buffs may be filtered out, use this to create the buff frames.
		local buffIndex = 1;

		for i = 1, BUFF_MAX_DISPLAY do
			local name, texture, count, debuffType, duration, expirationTime, caster, _, nameplateShowPersonal, spellId, _, _, _, nameplateShowAll = UnitAura(unit, i, filter);

			if (self:ShouldShowBuff(name, caster, nameplateShowPersonal, nameplateShowAll or showAll, duration)) then
				if (not self.buffList[buffIndex]) then
					self.buffList[buffIndex] = CreateFrame("Frame", self:GetParent():GetName() .. "Buff" .. buffIndex, self, "NameplateBuffButtonTemplate");
					self.buffList[buffIndex]:SetMouseClickEnabled(false);
					self.buffList[buffIndex].layoutIndex = buffIndex;
				end
				local buff = self.buffList[buffIndex];
				buff:SetID(i);
				buff.Icon:SetTexture(texture);
				if (count > 1) then
					buff.CountFrame.Count:SetText(count);
					buff.CountFrame.Count:Show();
				else
					buff.CountFrame.Count:Hide();
				end

				CooldownFrame_Set(buff.Cooldown, expirationTime - duration, duration, duration > 0, true);

				buff:Show();
				buffIndex = buffIndex + 1;
			end
		end

		for i = buffIndex, BUFF_MAX_DISPLAY do
			if (self.buffList[i]) then
				self.buffList[i]:Hide();
			end
		end
	end
	self:Layout();
end

NameplateBuffButtonTemplateMixin = {};

function NameplateBuffButtonTemplateMixin:OnUpdate(elapsed)
	if (self:GetParent().BuffFrameUpdateTime > 0) then
		return;
	end

	if (GameTooltip:IsOwned(self)) then
		GameTooltip:SetUnitAura(self:GetParent().unit, self:GetID(), self:GetParent().filter);
	end
end

NamePlateBorderTemplateMixin = {};

function NamePlateBorderTemplateMixin:SetVertexColor(r, g, b, a)
	a = a / self.numLayers;
	for i, texture in ipairs(self.Textures) do
		texture:SetVertexColor(r, g, b, a);
	end
end