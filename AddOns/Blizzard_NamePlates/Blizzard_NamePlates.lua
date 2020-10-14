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

	self.pools = CreateFramePoolCollection();
	-- Forbidden dictated by namePlateFrameBase.
	self.pools:CreatePool("BUTTON", self, "ForbiddenNamePlateUnitFrameTemplate");
	self.pools:CreatePool("BUTTON", self, "NamePlateUnitFrameTemplate");

	self.namePlateSetupFunctions =
	{
		["player"] = DefaultCompactNamePlatePlayerFrameSetup,
		["friendly"] = DefaultCompactNamePlateFriendlyFrameSetup,
		["enemy"] = DefaultCompactNamePlateEnemyFrameSetup,
	};

	self.namePlateAnchorFunctions =
	{
		["player"] = DefaultCompactNamePlatePlayerFrameAnchor,
		["friendly"] = DefaultCompactNamePlateFrameAnchors,
		["enemy"] = DefaultCompactNamePlateFrameAnchors,
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
	self:OnNamePlateCreatedInternal(namePlateFrameBase, "NamePlateUnitFrameTemplate");
end

function NamePlateDriverMixin:OnForbiddenNamePlateCreated(namePlateFrameBase)
	self:OnNamePlateCreatedInternal(namePlateFrameBase, "ForbiddenNamePlateUnitFrameTemplate");
end

function NamePlateDriverMixin:OnNamePlateCreatedInternal(namePlateFrameBase, template)
	Mixin(namePlateFrameBase, NamePlateBaseMixin);
	namePlateFrameBase.template = template;
end

function NamePlateDriverMixin:AcquireUnitFrame(namePlateFrameBase)
	local pool = nil;
	if Commentator and C_Commentator.IsSpectating() then
		pool = self.pools:GetOrCreatePool("BUTTON", self, Commentator:GetNameplateTemplate());
	else
		pool = self.pools:GetPool(namePlateFrameBase.template);
	end

	local unitFrame = pool:Acquire();
	namePlateFrameBase.UnitFrame = unitFrame;

	unitFrame:SetParent(namePlateFrameBase);
	unitFrame:SetPoint("TOPLEFT", namePlateFrameBase, "TOPLEFT");
	unitFrame:EnableMouse(false);

	namePlateFrameBase:SetScript("OnSizeChanged", namePlateFrameBase.OnSizeChanged);
	namePlateFrameBase:OnSizeChanged();
end

function NamePlateDriverMixin:OnNamePlateAdded(namePlateUnitToken)
	local namePlateFrameBase = C_NamePlate.GetNamePlateForUnit(namePlateUnitToken, issecure());
	self:AcquireUnitFrame(namePlateFrameBase);

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

	local unitFrame = namePlateFrameBase.UnitFrame;
	if setupFn then
		CompactUnitFrame_SetUpFrame(unitFrame, setupFn);
	end

	if unitFrame.SetupOverride then
		unitFrame:SetupOverride();
	end

	namePlateFrameBase:OnOptionsUpdated();

	self:UpdateInsetsForType(namePlateType, namePlateFrameBase);
end

function NamePlateDriverMixin:GetOnSizeChangedFunction(namePlateUnitToken)
	local namePlateType = self:GetNamePlateTypeFromUnit(namePlateUnitToken);
	return self.namePlateAnchorFunctions[namePlateType];
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

	self.pools:Release(namePlateFrameBase.UnitFrame);
	namePlateFrameBase.UnitFrame = nil;
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

function NamePlateDriverMixin:OnNamePlateResized(namePlateFrame)
	if self.classNamePlateMechanicFrame and self.classNamePlateMechanicFrame:GetParent() == namePlateFrame then
		self.classNamePlateMechanicFrame:OnSizeChanged();
	end
	if self.classNamePlatePowerBar and self.classNamePlatePowerBar:GetParent() == namePlateFrame then
		self.classNamePlatePowerBar:OnSizeChanged();
	end
end

function NamePlateDriverMixin:SetupClassNameplateBars()
	local showMechanicOnTarget;
	if self.classNamePlateMechanicFrame and self.classNamePlateMechanicFrame.overrideTargetMode ~= nil then
		showMechanicOnTarget = self.classNamePlateMechanicFrame.overrideTargetMode;
	else
		showMechanicOnTarget = GetCVarBool("nameplateResourceOnTarget");
	end

	local anchorMechanicToPowerBar = false;
	if self.classNamePlatePowerBar then
		local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player", issecure());
		if namePlatePlayer then
			self.classNamePlatePowerBar:SetParent(namePlatePlayer);
			self.classNamePlatePowerBar:ClearAllPoints();
			self.classNamePlatePowerBar:SetPoint("TOPLEFT", namePlatePlayer.UnitFrame.healthBar, "BOTTOMLEFT", 0, 0);
			self.classNamePlatePowerBar:SetPoint("TOPRIGHT", namePlatePlayer.UnitFrame.healthBar, "BOTTOMRIGHT", 0, 0);
			self.classNamePlatePowerBar:Show();

			anchorMechanicToPowerBar = true;
		else
			self.classNamePlatePowerBar:Hide();
		end
	end

	if self.classNamePlateMechanicFrame then
		if showMechanicOnTarget then
			local namePlateTarget = C_NamePlate.GetNamePlateForUnit("target", issecure());
			if namePlateTarget then
				self.classNamePlateMechanicFrame:SetParent(namePlateTarget);
				self.classNamePlateMechanicFrame:ClearAllPoints();
				PixelUtil.SetPoint(self.classNamePlateMechanicFrame, "BOTTOM", namePlateTarget.UnitFrame.name, "TOP", 0, 4);
				self.classNamePlateMechanicFrame:Show();
			else
				self.classNamePlateMechanicFrame:Hide();
			end
		elseif anchorMechanicToPowerBar then
			local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player", issecure());
			self.classNamePlateMechanicFrame:SetParent(namePlatePlayer);
			self.classNamePlateMechanicFrame:ClearAllPoints();
			self.classNamePlateMechanicFrame:SetPoint("TOP", self.classNamePlatePowerBar, "BOTTOM", 0, self.classNamePlateMechanicFrame.paddingOverride or -4);
			self.classNamePlateMechanicFrame:Show();
		else
			local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player", issecure());
			if namePlatePlayer then
				self.classNamePlateMechanicFrame:SetParent(namePlatePlayer);
				self.classNamePlateMechanicFrame:ClearAllPoints();
				self.classNamePlateMechanicFrame:SetPoint("TOP", namePlatePlayer.UnitFrame.healthBar, "BOTTOM", 0, self.classNamePlateMechanicFrame.paddingOverride or -4);
				self.classNamePlateMechanicFrame:Show();
			else
				self.classNamePlateMechanicFrame:Hide();
			end
		end
	end

	if targetMode and self.classNamePlateMechanicFrame then
		local percentOffset = tonumber(GetCVar("nameplateClassResourceTopInset")) or 0;
		if self:IsUsingLargerNamePlateStyle() then
			percentOffset = percentOffset + .1;
		end
		C_NamePlate.SetTargetClampingInsets(percentOffset * UIParent:GetHeight(), 0.0);
	else
		C_NamePlate.SetTargetClampingInsets(0.0, 0.0);
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

	local personalNamePlateClickThrough = GetCVarBool("NameplatePersonalClickThrough");
	C_NamePlate.SetNamePlateSelfClickThrough(personalNamePlateClickThrough);

	local horizontalScale = tonumber(GetCVar("NamePlateHorizontalScale"));
	C_NamePlate.SetNamePlateFriendlySize(self.baseNamePlateWidth * horizontalScale, self.baseNamePlateHeight * Lerp(1.0, 1.25, zeroBasedScale));
	C_NamePlate.SetNamePlateEnemySize(self.baseNamePlateWidth * horizontalScale, self.baseNamePlateHeight * Lerp(1.0, 1.25, zeroBasedScale));
	C_NamePlate.SetNamePlateSelfSize(self.baseNamePlateWidth * horizontalScale * Lerp(1.1, 1.0, clampedZeroBasedScale), self.baseNamePlateHeight);

	local classificationScale = tonumber(GetCVar("NamePlateClassificationScale"));
	local maxClassificationScale = tonumber(GetCVar("NamePlateMaximumClassificationScale"));
	DefaultCompactNamePlateFrameSetUpOptions.classificationScale = classificationScale;
	DefaultCompactNamePlateFrameSetUpOptions.maxClassificationScale = maxClassificationScale;

	-- Clear the inset table, just update it from scratch since this will iterate all nameplates
	-- As each nameplate updates, it will handle updating preferred insets during its setup
	self.preferredInsets = {};

	for i, frame in ipairs(C_NamePlate.GetNamePlates(issecure())) do
		self:ApplyFrameOptions(frame, frame.namePlateUnitToken);
		CompactUnitFrame_SetUnit(frame.UnitFrame, frame.namePlateUnitToken);
	end

	if self.classNamePlateMechanicFrame then
		self.classNamePlateMechanicFrame:OnOptionsUpdated();
	end
	if self.classNamePlatePowerBar then
		self.classNamePlatePowerBar:OnOptionsUpdated();
	end
	self:SetupClassNameplateBars();
end

NamePlateBaseMixin = {};

function NamePlateBaseMixin:OnAdded(namePlateUnitToken, driverFrame)
	self.namePlateUnitToken = namePlateUnitToken;
	self.driverFrame = driverFrame;

	CompactUnitFrame_SetUnit(self.UnitFrame, namePlateUnitToken);

	self:ApplyOffsets();

	self.UnitFrame.BuffFrame:SetActive(not C_Commentator.IsSpectating());
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
		self.UnitFrame.BuffFrame:SetBaseYOffset(-3);
	else
		self.UnitFrame.BuffFrame:SetBaseYOffset(-3);
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

function NamePlateBaseMixin:OnSizeChanged()
	if self.namePlateUnitToken and self:IsVisible() then
		local anchorUpdateFunction = self.driverFrame:GetOnSizeChangedFunction(self.namePlateUnitToken);
		if anchorUpdateFunction then
			anchorUpdateFunction(self.UnitFrame);
		end

		-- Occurs after the anchor update function has been called, so any dependant points
		-- will have their points set.
		if self.SizeChangedOverride then
			self:SizeChangedOverride();
		end

		self.driverFrame:OnNamePlateResized(self);
	end
end

NamePlateClassificationFrameMixin = {};

function NamePlateClassificationFrameMixin:OnSizeChanged()
	self.classificationIndicator:SetScale(1.0);

	local effectiveScale = self:GetEffectiveScale();
	if self.maxScale and effectiveScale > self.maxScale then
		self.classificationIndicator:SetScale(self.maxScale / effectiveScale);
	end
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
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
end

function NameplateBuffContainerMixin:OnEvent(event, ...)
	if (event == "PLAYER_TARGET_CHANGED") then
		self:UpdateAnchor();
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
			else
				break;
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
		local index = 1;
		AuraUtil.ForEachAura(unit, filter, BUFF_MAX_DISPLAY, function(...)
			local name, texture, count, debuffType, duration, expirationTime, caster, _, nameplateShowPersonal, spellId, _, _, _, nameplateShowAll = ...;

			if (self:ShouldShowBuff(name, caster, nameplateShowPersonal, nameplateShowAll or showAll, duration)) then
				if (not self.buffList[buffIndex]) then
					self.buffList[buffIndex] = CreateFrame("Frame", nil, self, "NameplateBuffButtonTemplate");
					self.buffList[buffIndex]:SetMouseClickEnabled(false);
					self.buffList[buffIndex].layoutIndex = buffIndex;
				end
				local buff = self.buffList[buffIndex];
				buff:SetID(index);
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
			index = index + 1;
			return buffIndex > BUFF_MAX_DISPLAY;
		end);

		for i = buffIndex, BUFF_MAX_DISPLAY do
			if (self.buffList[i]) then
				self.buffList[i]:Hide();
			else
				break;
			end
		end
	end
	self:Layout();
end

NameplateBuffButtonTemplateMixin = {};

function NameplateBuffButtonTemplateMixin:OnEnter()
	NamePlateTooltip:SetOwner(self, "ANCHOR_LEFT");
	NamePlateTooltip:SetUnitAura(self:GetParent().unit, self:GetID(), self:GetParent().filter);

	self.UpdateTooltip = self.OnEnter;
end

function NameplateBuffButtonTemplateMixin:OnLeave()
	NamePlateTooltip:Hide();
end

NamePlateBorderTemplateMixin = {};

function NamePlateBorderTemplateMixin:SetVertexColor(r, g, b, a)
	for i, texture in ipairs(self.Textures) do
		texture:SetVertexColor(r, g, b, a);
	end
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