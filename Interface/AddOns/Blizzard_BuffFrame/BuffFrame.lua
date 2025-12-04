BUFF_WARNING_TIME = 31;
BUFF_MAX_DISPLAY = 32;
DEBUFF_MAX_DISPLAY = 16;

CVarCallbackRegistry:SetCVarCachable("buffDurations");
CVarCallbackRegistry:SetCVarCachable("consolidateBuffs");
CVarCallbackRegistry:SetCVarCachable("collapseExpandBuffs");

local s_spellIDToHelpTipInfo = {
	-- Pandaria remix Timerunner's Advantage
	[440393] = {
		text = TIMERUNNING_TIMERUNNERS_ADVANTAGE_TUTORIAL,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedInfoFramesAccountWide",
		bitfieldFlag = Enum.FrameTutorialAccount.TimerunnersAdvantage,
		targetPoint = HelpTip.Point.BottomEdge,
		alignment = HelpTip.Alignment.Center,
	},
};


--AubrieTODO: These texture mappings are sort of bad so for temp enchantments we are only showing temp enchants for weapon..
--Which just seems wrong, so I still have to talk to designers and see if we want to invest in a system to show temp enchants other than weapon
local textureMapping = {
	[1] = 16,	--Main hand
	[2] = 17,	--Off-hand
	[3] = 18,	--Ranged
};

local CollapseAndExpandButton_Orientation_Horizontal = 0;
local CollapseAndExpandButton_Orientation_Vertical = 1;
local CollapseAndExpandButton_ExpandDirection_Left = 0;
local CollapseAndExpandButton_ExpandDirection_Right = 1;
local CollapseAndExpandButton_ExpandDirection_Down = CollapseAndExpandButton_ExpandDirection_Left;
local CollapseAndExpandButton_ExpandDirection_Up = CollapseAndExpandButton_ExpandDirection_Right;

AuraContainerWarningFaderMixin = {};

function AuraContainerWarningFaderMixin:Init(period, minAlpha, maxAlpha)
	self.period = period;
	self.minAlpha = minAlpha;
	self.maxAlpha = maxAlpha;

	self.Animation:SetDuration(self.period / 2);
	self:Play();
end

function AuraContainerWarningFaderMixin:GetSmoothAlpha()
	return Lerp(self.minAlpha, self.maxAlpha, self.Animation:GetSmoothProgress());
end

AuraContainerMixin = {};

function AuraContainerMixin:OnLoad()
	self.WarningFader:Init(self.auraWarningFlashPeriod, self.auraWarningMinAlpha, self.auraWarningMaxAlpha);
end

function AuraContainerMixin:GetAuraWarningAlphaForDuration(duration)
	if (duration and duration < BUFF_WARNING_TIME) then
		return self.WarningFader:GetSmoothAlpha();
	else
		return self.auraWarningMaxAlpha;
	end
end

function AuraContainerMixin:UpdateGridLayout(auras, doNotAnchorDisabledFrames)
	local newLayoutInfo = {
		isHorizontal = self.isHorizontal;
		iconStride = self.iconStride;
		iconPadding = self.iconPadding;
		addIconsToRight = self.addIconsToRight;
		addIconsToTop = self.addIconsToTop;
	};

	-- Check whether we need to update the icon's anchor point
	local updateAnchor = not self.currentGridLayoutInfo
					or self.currentGridLayoutInfo.addIconsToRight ~= newLayoutInfo.addIconsToRight
					or self.currentGridLayoutInfo.addIconsToTop ~= newLayoutInfo.addIconsToTop;

	if updateAnchor then
		-- Need to change where the icons anchor based on how the container grows
		local anchorPoint = "TOPRIGHT";
		if newLayoutInfo.addIconsToTop then
			if newLayoutInfo.addIconsToRight then
				anchorPoint = "BOTTOMLEFT";
			else
				anchorPoint = "BOTTOMRIGHT";
			end
		else
			if newLayoutInfo.addIconsToRight then
				anchorPoint = "TOPLEFT";
			end
		end
		newLayoutInfo.anchor = AnchorUtil.CreateAnchor(anchorPoint, self, anchorPoint);
	else
		-- If we didn't need to update the anchor then use the old one
		newLayoutInfo.anchor = self.currentGridLayoutInfo.anchor;
	end

	-- Check whether we need to update the grid's layout
	local updateLayout = updateAnchor
					or self.currentGridLayoutInfo.isHorizontal ~= newLayoutInfo.isHorizontal
					or self.currentGridLayoutInfo.iconStride ~= newLayoutInfo.iconStride
					or self.currentGridLayoutInfo.iconPadding ~= newLayoutInfo.iconPadding;

	if updateLayout then
		-- Multipliers determine the direction the bar grows for grid layouts
		-- Positive means right/up
		-- Negative means left/down
		local xMultiplier = newLayoutInfo.addIconsToRight and 1 or -1;
		local yMultiplier = newLayoutInfo.addIconsToTop and 1 or -1;

		-- Create the grid layout according to whether we are horizontal or vertical
		if newLayoutInfo.isHorizontal then
			newLayoutInfo.layout = GridLayoutUtil.CreateStandardGridLayout(
				newLayoutInfo.iconStride,
				newLayoutInfo.iconPadding, newLayoutInfo.iconPadding,
				xMultiplier, yMultiplier);
		else
			newLayoutInfo.layout = GridLayoutUtil.CreateVerticalGridLayout(
				newLayoutInfo.iconStride,
				newLayoutInfo.iconPadding, newLayoutInfo.iconPadding,
				xMultiplier, yMultiplier);
		end
	else
		-- If we didn't need to update the layout then use the old one
		newLayoutInfo.layout = self.currentGridLayoutInfo.layout;
	end

	-- Update aura icon and duration anchors
	-- Also resize aura accordingly
	local auraWidth, auraHeight, durationPoint, durationRelativePoint, iconPoint;
	if newLayoutInfo.isHorizontal then
		auraWidth = 30;
		auraHeight = 40;

		durationPoint = newLayoutInfo.addIconsToTop and "BOTTOM" or "TOP";
		durationRelativePoint = newLayoutInfo.addIconsToTop and "TOP" or "BOTTOM";

		iconPoint = newLayoutInfo.addIconsToTop and "BOTTOM" or "TOP";
	else
		auraWidth = 60;
		auraHeight = 30;

		durationPoint = newLayoutInfo.addIconsToRight and "LEFT" or "RIGHT";
		durationRelativePoint = newLayoutInfo.addIconsToRight and "RIGHT" or "LEFT";

		iconPoint = newLayoutInfo.addIconsToRight and "LEFT" or "RIGHT";
	end

	local enabledAuras = tFilter(auras, function(f) return f.hasValidInfo or f.isExample or f.isAuraAnchor; end, true);
	if doNotAnchorDisabledFrames then
		auras = enabledAuras;
	end

	for index, aura in ipairs(auras) do
		aura:SetScale(self.iconScale or 1);
		aura:SetSize(auraWidth, auraHeight);

		aura.Icon:ClearAllPoints();
		aura.Icon:SetPoint(iconPoint, aura, iconPoint);

		aura.Duration:ClearAllPoints();
		aura.Duration:SetPoint(durationPoint, aura.Icon, durationRelativePoint);
	end
	self:GetParent():UpdateSize(auraWidth, auraHeight, newLayoutInfo.iconStride or 1, newLayoutInfo.iconPadding or 0, self.iconScale or 1, newLayoutInfo.isHorizontal, #enabledAuras)

    -- Apply the layout and then update our size
	GridLayoutUtil.ApplyGridLayout(
		auras,
		newLayoutInfo.anchor,
		newLayoutInfo.layout);

	-- Cache the new grid layout info so we know what needs to be update in future calls
	self.currentGridLayoutInfo = newLayoutInfo;
end

AuraFrameMixin = {};

function AuraFrameMixin:AuraFrame_OnLoad()
	-- Create aura buttons
	self.auraFrames = {};

	for i = 1, self.maxAuras do
		local auraFrame = CreateFrame("BUTTON", nil, self.AuraContainer, "AuraButtonTemplate");
		table.insert(self.auraFrames, auraFrame);
	end

	for _, anchorframe in ipairs(self.PrivateAuraAnchors or {}) do
		table.insert(self.auraFrames, anchorframe);
	end

	self:UpdateGridLayout();
end

-- Override this in frames which inherit AuraFrameMixin if needed
function AuraFrameMixin:IsExpanded()
	return true;
end

function AuraFrameMixin:Update()
	self:UpdateAuras();
	self:UpdateAuraButtons();
end

-- Override this in frames which inherit AuraFrameMixin
function AuraFrameMixin:UpdateAuras()
	self.auraInfo = {};
end

function AuraFrameMixin:UpdateAuraButtons()
	local nextAuraInfoIndex = 1;
	for _, auraFrame in ipairs(self.auraFrames) do
		if not auraFrame.isAuraAnchor then
			auraFrame.isExample = false;

			auraFrame.hasValidInfo = false;
			if not self.auraInfo then
				auraFrame:Hide();
			else
				-- Get the auraInfo for the next showable aura
				local auraInfo;
				while nextAuraInfoIndex <= #self.auraInfo do
					local potentialAuraInfo = self.auraInfo[nextAuraInfoIndex];
					nextAuraInfoIndex = nextAuraInfoIndex + 1;

					-- Aura is only showable if we're expanded or the aura isn't hidden when collapsed
					if (self:ShouldShowAura(potentialAuraInfo)) then
						auraInfo = potentialAuraInfo;
						break;
					end
				end

				-- If we found a showable aura then set the button to that aura and show it, otherwise hide the button
				auraFrame:SetShown(auraInfo ~= nil);
				if auraInfo then
					auraFrame.hasValidInfo = true;
					auraFrame:Update(auraInfo);
				end
			end
		end
	end
end

function AuraFrameMixin:ShouldShowAura(potentialAuraInfo)
	-- Aura is only showable if we're expanded or the aura isn't hidden when collapsed
	return self:IsExpanded() or not potentialAuraInfo.hideUnlessExpanded;
end

function AuraFrameMixin:UpdateGridLayout()
	self.AuraContainer:UpdateGridLayout(self.auraFrames, self.doNotAnchorDisabledFrames);
	self:UpdateAuraContainerAnchor();
end

function AuraFrameMixin:UpdateAuraContainerAnchor()
	-- Override this as necessary
	self.AuraContainer:ClearAllPoints();
end

function AuraFrameMixin:UpdateSize(auraWidth, auraHeight, perRow, iconPadding, scale, isHorizontal, numEnabledAuras)
	local numAuraIconsHorizontal, numAuraIconsVertical;
	if (self.ignoreDisabledAurasForSize) then
		-- Count only icons that have a visible aura.
		numAuraIconsHorizontal = math.min(perRow, numEnabledAuras);
		numAuraIconsVertical = math.ceil(numEnabledAuras / perRow);
	else
		-- Count ALL icons, even if they do not have a visible aura.
		numAuraIconsHorizontal = perRow;
		numAuraIconsVertical = math.ceil(self.maxAuras / perRow);
	end

	local frameWidth = (auraWidth + iconPadding) * (isHorizontal and numAuraIconsHorizontal or numAuraIconsVertical);
	local frameHeight = (auraHeight + iconPadding) * (isHorizontal and (numAuraIconsVertical) or numAuraIconsHorizontal);

	local expandButtonWidth = self.CollapseAndExpandButton and self.CollapseAndExpandButton:GetWidth() or 0;
	local expandButtonHeight = self.CollapseAndExpandButton and  self.CollapseAndExpandButton:GetHeight() or 0;
	local totalWidth = isHorizontal and frameWidth + expandButtonWidth or frameWidth;
	local totalHeight = not isHorizontal and frameHeight + expandButtonHeight or frameHeight;
	self:SetSize(totalWidth * scale, totalHeight * scale);
end

AuraFrameEventListenerMixin = {};

function AuraFrameEventListenerMixin:AuraFrameEventListener_OnLoad()
	self:RegisterUnitEvent("UNIT_AURA", "player", "vehicle");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_IN_COMBAT_CHANGED");
end

function AuraFrameEventListenerMixin:AuraFrameEventListener_OnEvent(event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		self:Update();
	elseif event == "UNIT_AURA" then
		local unit, unitAuraUpdateInfo = ...;
		local hasAurasToUpdate = unitAuraUpdateInfo ~= nil
							and (unitAuraUpdateInfo.isFullUpdate
								or (unitAuraUpdateInfo.addedAuras ~= nil and #unitAuraUpdateInfo.addedAuras > 0)
								or (unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil and #unitAuraUpdateInfo.removedAuraInstanceIDs > 0)
								or (unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil and #unitAuraUpdateInfo.updatedAuraInstanceIDs > 0));

		if unit == PlayerFrame.unit and hasAurasToUpdate then
			self:Update();
		end
	elseif event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_SPECIALIZATION_CHANGED" then
		self:Update();
	elseif event == "PLAYER_IN_COMBAT_CHANGED" then
		self:UpdateShownState();
	end
end

AuraFrameEditModeMixin = CreateFromMixins(AuraFrameMixin);

function AuraFrameEditModeMixin:SetIsEditing(isEditing)
	if self.isInEditMode ~= isEditing then
		self.isInEditMode = isEditing;
		self:UpdateShownState();
	end
end

function AuraFrameEditModeMixin:IsEditing()
	return self.isInEditMode;
end

function AuraFrameEditModeMixin:UpdateAuraButtons()
	if self:TryEditModeUpdateAuraButtons() then
		return;
	end

	AuraFrameMixin.UpdateAuraButtons(self);
end

function AuraFrameEditModeMixin:ShouldBeShown()
	-- Override as needed
	if self:IsEditing() then
		return true;
	end

	if self.visibleSetting then
		if self.visibleSetting == Enum.CooldownViewerVisibleSetting.Always then
			return true;
		elseif self.visibleSetting == Enum.CooldownViewerVisibleSetting.InCombat then
			local isInCombat = UnitAffectingCombat("player");
			return isInCombat;
		elseif self.visibleSetting == Enum.CooldownViewerVisibleSetting.Hidden then
			return false;
		else
			assertsafe(false, "Unknown value for visible setting: %s", tostring(self.visibleSetting));
		end
	end

	return true;
end

function AuraFrameEditModeMixin:UpdateShownState()
	-- Override as needed
	local shouldBeShown = self:ShouldBeShown();
	if shouldBeShown ~= self:IsShown() then
		self:SetShown(shouldBeShown);
		if shouldBeShown then
			self:Update();
		end
	end
end

function AuraFrameEditModeMixin:TryEditModeUpdateAuraButtons()
	if self:IsEditing() then
		if not self.hasInitializedForEditMode then
			if not self.iconDataProvider then
				local spellIconsOnly = true;
				self.iconDataProvider = CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.Spellbook, spellIconsOnly);
			end

			local iconDataProviderNumIcons = self.iconDataProvider:GetNumIcons();

			for index, auraFrame in ipairs(self.auraFrames) do
				if auraFrame.isAuraAnchor then
					auraFrame:Hide();
				else
					auraFrame.isExample = true;
					auraFrame:UpdateAuraType(self.exampleAuraType);
					auraFrame.Duration:SetFontObject(DEFAULT_AURA_DURATION_FONT);
					auraFrame.Duration:SetFormattedText(SecondsToTimeAbbrev(index * 60));
					auraFrame.Duration:Show();
					auraFrame.Icon:SetTexture(self.iconDataProvider:GetIconByIndex(math.random(1, iconDataProviderNumIcons)));
					auraFrame:Show();
				end
			end

			self.hasInitializedForEditMode = true;
		end
	else
		if self.hasInitializedForEditMode then
			for _, auraFrame in ipairs(self.PrivateAuraAnchors or {}) do
				auraFrame:Show();
			end
		end
		self.hasInitializedForEditMode = false;
	end
	return self.hasInitializedForEditMode;
end

BaseAuraFrameMixin = {};

function BaseAuraFrameMixin:GetIconLimitSettingEnum()
	return Enum.EditModeAuraFrameSetting.IconLimitBuffFrame;
end

function BaseAuraFrameMixin:UpdateAuraContainerAnchor()
	AuraFrameMixin.UpdateAuraContainerAnchor(self);

	if self.AuraContainer.addIconsToRight then
		if self.AuraContainer.addIconsToTop then
			self.AuraContainer:SetPoint("BOTTOMLEFT");
		else
			self.AuraContainer:SetPoint("TOPLEFT");
		end
	else
		if self.AuraContainer.addIconsToTop then
			self.AuraContainer:SetPoint("BOTTOMRIGHT");
		else
			self.AuraContainer:SetPoint("TOPRIGHT");
		end
	end
end

function BaseAuraFrameMixin:UpdateGridLayout(icons)
	icons = icons or self.auraFrames;
	self.AuraContainer:UpdateGridLayout(icons, self.doNotAnchorDisabledFrames);
	self:UpdateAuraContainerAnchor();
end

BuffFrameMixin = CreateFromMixins(BaseAuraFrameMixin);

function BuffFrameMixin:OnLoad()
	self:RegisterEvent("WEAPON_ENCHANT_CHANGED");
	self:RegisterEvent("WEAPON_SLOT_CHANGED");

	CVarCallbackRegistry:RegisterCallback("consolidateBuffs", self.OnConsolidationSettingsChanged, self);
	CVarCallbackRegistry:RegisterCallback("collapseExpandBuffs", self.OnConsolidationSettingsChanged, self);

	self.isExpanded = true;
	self.numHideableBuffs = 0;

	-- Throttle for OnUpdate when checking when buffs should "fall out" of the collapsed/consolidated container.
	self.hiddenBuffUpdateTimer = 0;
	self.hiddenBuffUpdatePeriod = 0.2;
end

function BuffFrameMixin:OnEvent(event, ...)
	if event == "WEAPON_ENCHANT_CHANGED" or event == "WEAPON_SLOT_CHANGED" then
		self:Update();
	end
end

-- Only registered when we have hidden buffs.
function BuffFrameMixin:OnUpdate(elapsed)
	self.hiddenBuffUpdateTimer = self.hiddenBuffUpdateTimer - elapsed;
	if (self.hiddenBuffUpdateTimer > 0) then
		-- Maybe next time...
		return;
	end

	-- Loop over our auraInfos and check if they should still be hideUnlessExpanded.
	local needsAuraUpdate = false;
	for _, auraInfo in ipairs(self.auraInfo) do
		if (auraInfo.hideUnlessExpanded and (auraInfo.expirationTime and auraInfo.expirationTime > 0)) then
			local timeLeft = (auraInfo.expirationTime - GetTime());
			if (timeLeft <= BUFF_DURATION_WARNING_TIME) then
				auraInfo.hideUnlessExpanded = false;
				self.numHideableBuffs = self.numHideableBuffs - 1;
				needsAuraUpdate = true;
			end
		end
	end

	-- If any auraInfos changed state, process those updates.
	if (needsAuraUpdate) then
		self:SyncToConsolidatedBuffs();
		self:UpdateAuraButtons();
	end

	-- Cancel the OnUpdate if we no longer need it.
	if (not self:HasHiddenBuffs()) then
		self:SetScript("OnUpdate", nil);
	end

	-- Don't forget to reset the timer!
	self:ResetHiddenBuffUpdateTimer();
end

function BuffFrameMixin:ResetHiddenBuffUpdateTimer()
	self.hiddenBuffUpdateTimer = self.hiddenBuffUpdatePeriod;
end

function BuffFrameMixin:OnConsolidationSettingsChanged()
	self:UpdateGridLayout();
	self:Update();
end

function BuffFrameMixin:UpdateGridLayout()
	local layoutAuraIcons = self.auraFrames;
	if (self.ConsolidatedBuffs:ShouldShow()) then
		-- If we're using the consolidateBuffs functionality, start with
		-- the buff consolidation icon and then append all auraFrames after it.
		layoutAuraIcons = { self.ConsolidatedBuffs };
		tAppendAll(layoutAuraIcons, self.auraFrames);
	end

	BaseAuraFrameMixin.UpdateGridLayout(self, layoutAuraIcons);
end

function BuffFrameMixin:UpdateAuraContainerAnchor()
	AuraFrameMixin.UpdateAuraContainerAnchor(self);

	self.CollapseAndExpandButton:ClearAllPoints();

	if self.AuraContainer.isHorizontal then
		self.CollapseAndExpandButton.orientation = CollapseAndExpandButton_Orientation_Horizontal;
		self.CollapseAndExpandButton.expandDirection = self.AuraContainer.addIconsToRight
														and CollapseAndExpandButton_ExpandDirection_Right
														or CollapseAndExpandButton_ExpandDirection_Left;

		if self.AuraContainer.addIconsToRight then
			if self.AuraContainer.addIconsToTop then
				-- Put CollapseAndExpandButton in bottom left, facing right
				self.AuraContainer:SetPoint("BOTTOMLEFT", self.CollapseAndExpandButton, "BOTTOMRIGHT");
				self.CollapseAndExpandButton:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT");
			else
				-- Put CollapseAndExpandButton in top left, facing right
				self.AuraContainer:SetPoint("TOPLEFT", self.CollapseAndExpandButton, "TOPRIGHT");
				self.CollapseAndExpandButton:SetPoint("TOPLEFT", self, "TOPLEFT");
			end
		else
			if self.AuraContainer.addIconsToTop then
				-- Put CollapseAndExpandButton in bottom right, facing left
				self.AuraContainer:SetPoint("BOTTOMRIGHT", self.CollapseAndExpandButton, "BOTTOMLEFT");
				self.CollapseAndExpandButton:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT");
			else
				-- Put CollapseAndExpandButton in top right, facing left
				self.AuraContainer:SetPoint("TOPRIGHT", self.CollapseAndExpandButton, "TOPLEFT");
				self.CollapseAndExpandButton:SetPoint("TOPRIGHT", self, "TOPRIGHT");
			end
		end
	else
		self.CollapseAndExpandButton.orientation = CollapseAndExpandButton_Orientation_Vertical;
		self.CollapseAndExpandButton.expandDirection = self.AuraContainer.addIconsToTop
														and CollapseAndExpandButton_ExpandDirection_Up
														or CollapseAndExpandButton_ExpandDirection_Down;

		if self.AuraContainer.addIconsToRight then
			if self.AuraContainer.addIconsToTop then
				-- Put CollapseAndExpandButton in bottom left, facing up
				self.AuraContainer:SetPoint("BOTTOMLEFT", self.CollapseAndExpandButton, "TOPLEFT");
				self.CollapseAndExpandButton:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT");
			else
				-- Put CollapseAndExpandButton in top left, facing down
				self.AuraContainer:SetPoint("TOPLEFT", self.CollapseAndExpandButton, "BOTTOMLEFT");
				self.CollapseAndExpandButton:SetPoint("TOPLEFT", self, "TOPLEFT");
			end
		else
			if self.AuraContainer.addIconsToTop then
				-- Put CollapseAndExpandButton in bottom right, facing up
				self.AuraContainer:SetPoint("BOTTOMRIGHT", self.CollapseAndExpandButton, "TOPRIGHT");
				self.CollapseAndExpandButton:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT");
			else
				-- Put CollapseAndExpandButton in top right, facing down
				self.AuraContainer:SetPoint("TOPRIGHT", self.CollapseAndExpandButton, "BOTTOMRIGHT");
				self.CollapseAndExpandButton:SetPoint("TOPRIGHT", self, "TOPRIGHT");
			end
		end
	end
	self.CollapseAndExpandButton:SetScale(self.AuraContainer.iconScale or 1);
	self.CollapseAndExpandButton:UpdateOrientation();
end

function BuffFrameMixin:Update()
	AuraFrameEditModeMixin.Update(self);

	self:RefreshConsolidationFrameVisibility();
end

function BuffFrameMixin:IsExpanded()
	if (self.CollapseAndExpandButton:IsEnabled()) then
		return self.isExpanded;
	elseif (self.ConsolidatedBuffs:IsEnabled()) then
		-- If we have ConsolidatedBuffs enabled, we're always collapsed.
		return false;
	else
		-- If neither CollapseAndExpand nor ConsolidatedBuffs is enabled,
		-- we're just a normal buff frame! Always expanded.
		return true;
	end
end

function BuffFrameMixin:HasHiddenBuffs()
	return not self:IsExpanded() and self.numHideableBuffs > 0;
end

function BuffFrameMixin:RefreshConsolidationFrameVisibility()
	self.ConsolidatedBuffs:SetShown(self.ConsolidatedBuffs:ShouldShow());
	self.CollapseAndExpandButton:SetShown(self.numHideableBuffs > 0 and self.CollapseAndExpandButton:IsEnabled());

	if (self.CollapseAndExpandButton:IsEnabled()) then
		self.CollapseAndExpandButton:SetChecked(self.isExpanded);
		self.CollapseAndExpandButton:UpdateOrientation();
	end
end

function BuffFrameMixin:UpdateAuraButtons()
	AuraFrameEditModeMixin.UpdateAuraButtons(self);

	if self:IsEditing() then
		self.CollapseAndExpandButton:SetShown(self.CollapseAndExpandButton:IsEnabled());
		self.CollapseAndExpandButton:SetChecked(true);
		self.CollapseAndExpandButton:UpdateOrientation();
	else
		self:RefreshConsolidationFrameVisibility();
	end
end

function BuffFrameMixin:UpdatePlayerBuffs()
	local usePackedAura = true;
	local auraIndex = 0;
	AuraUtil.ForEachAura(PlayerFrame.unit, "HELPFUL", self.maxAuras, function(auraData)
		local timeLeft = (auraData.expirationTime - GetTime());
		local hideUnlessExpanded = (auraData.duration == 0) or (auraData.expirationTime == 0) or ((timeLeft) > BUFF_DURATION_WARNING_TIME); --Aubrie TODO filter with a flag on the aura.

		if hideUnlessExpanded then
			self.numHideableBuffs = self.numHideableBuffs + 1;
		end

		local helpTipInfo = s_spellIDToHelpTipInfo[auraData.spellId];
		local auraInfoIndex = #self.auraInfo + 1; -- Note that if we started with auras in self.auraInfo (e.g., Weapon Enchants), this may be offset from auraIndex.
		auraIndex = auraIndex + 1;

		self.auraInfo[auraInfoIndex] = {
			auraType = "Buff",
			debuffType = auraData.dispelName,
			index = auraIndex,
			texture = auraData.icon,
			count = auraData.applications,
			hideUnlessExpanded = hideUnlessExpanded,
			duration = auraData.duration,
			expirationTime = auraData.expirationTime,
			timeMod = auraData.timeMod,
			helpTipInfo = helpTipInfo
		};

		return #self.auraInfo > self.maxAuras;
	end, usePackedAura);
end

--AubrieTODO: Figure out how we want to refactor this function to include non-weapon enchants..
function BuffFrameMixin:UpdateTemporaryEnchantmentBuffs(...)
	local RETURNS_PER_ITEM = 4;
	local numVals = select("#", ...);
	local numItems = numVals / RETURNS_PER_ITEM;

	if numItems == 0 then
		return;
	end

	for itemIndex = numItems, 1, -1 do	--Loop through the items from the back.
		-- If we can't display any more buffs then stop
		if #self.auraInfo > self.maxAuras then
			break;
		end

		local hasEnchant, enchantExpiration, enchantCharges = select(RETURNS_PER_ITEM * (itemIndex - 1) + 1, ...);
		if hasEnchant and enchantExpiration then
			-- Show buff durations if necessary
			if enchantExpiration then
				enchantExpiration = enchantExpiration / 1000;
			end
			local expirationTime =  GetTime() + enchantExpiration;

			local hideUnlessExpanded = enchantExpiration > BUFF_DURATION_WARNING_TIME;
			if hideUnlessExpanded then
				self.numHideableBuffs = self.numHideableBuffs + 1;
			end

			local aura = {
				auraType = "TempEnchant",
				texture = GetInventoryItemTexture("player", textureMapping[itemIndex]),
				count = enchantCharges,
				hideUnlessExpanded = hideUnlessExpanded,
				expirationTime = expirationTime,
				ID = textureMapping[itemIndex]
			};
			table.insert(self.auraInfo, aura);
		end
	end
end

function BuffFrameMixin:UpdateAuras()
	AuraFrameEditModeMixin.UpdateAuras(self);

	-- Update our auraInfo.
	self.numHideableBuffs = 0;
	self:UpdateTemporaryEnchantmentBuffs(GetWeaponEnchantInfo());
	self:UpdatePlayerBuffs();

	-- Sync to ConsolidatedBuffs frame, if needed.
	self:SyncToConsolidatedBuffs();

	-- If we have any hidden buffs, start a periodic OnUpdate script so that we can know when they "fall out" of the hidden state.
	local onUpdateScript = self:HasHiddenBuffs() and self.OnUpdate or nil;
	self:SetScript("OnUpdate", onUpdateScript);
	self:ResetHiddenBuffUpdateTimer();
end

function BuffFrameMixin:SetBuffsExpandedState(expanded)
	self.isExpanded = expanded;
	self:Update();
end

function BuffFrameMixin:SyncToConsolidatedBuffs()
	if (self.ConsolidatedBuffs:IsEnabled()) then
		local shownStatusChanged = self.ConsolidatedBuffs:UpdateConsolidatedAuraCount(self.numHideableBuffs);
		if (shownStatusChanged) then
			self:UpdateGridLayout();
		end
		self.ConsolidatedBuffs:UpdateConsolidatedAuras(self.auraInfo);
	end
end

DebuffFrameMixin = { };

function DebuffFrameMixin:OnLoad()
	self.maxAuras = DEBUFF_MAX_DISPLAY;
end

function DebuffFrameMixin:Update() -- Override
	AuraFrameEditModeMixin.Update(self);
	local unit = PlayerFrame.unit;
	if unit ~= self.unit then
		for _, anchor in ipairs(self.PrivateAuraAnchors) do
			anchor:SetUnit(unit);
		end
	end
	self.unit = unit;
end

function DebuffFrameMixin:UpdateAuraButtons()  -- Override
	AuraFrameEditModeMixin.UpdateAuraButtons(self);
	self:UpdateGridLayout();
end

function DebuffFrameMixin:UpdateAuras()
	AuraFrameEditModeMixin.UpdateAuras(self);

	self.deadlyDebuffInfo = {};

	AuraUtil.ForEachAura(PlayerFrame.unit, "HARMFUL", self.maxAuras, function(auraData)
		local index = #self.auraInfo + 1;
		-- TODO:: Rename usages in this file to match packed auraData names, then just use packed aura everywhere
		self.auraInfo[index] = {
			auraType = "Debuff",
			debuffType = auraData.dispelName,
			index = index,
			texture = auraData.icon,
			count = auraData.applications,
			duration = auraData.duration,
			expirationTime = auraData.expirationTime,
			timeMod = auraData.timeMod,
		};

		local deadlyDebuffInfo = C_Spell.GetDeadlyDebuffInfo and C_Spell.GetDeadlyDebuffInfo(auraData.spellId);
		if(deadlyDebuffInfo) then
			local deadlyDebuff = {
				auraType = "DeadlyDebuff",
				debuffType = auraData.dispelName,
				texture = auraData.icon,
				count = auraData.applications,
				duration = auraData.duration,
				expirationTime = auraData.expirationTime,
				timeMod = auraData.timeMod,
				spellID = auraData.spellId,
				soundKitID = deadlyDebuffInfo.soundKitID,
				auraInstanceID = auraData.auraInstanceID,
				warningText = deadlyDebuffInfo.warningText,
				priority = deadlyDebuffInfo.priority,
				criticalTimeRemainingMs = deadlyDebuffInfo.criticalTimeRemainingMs,
				criticalStacks = deadlyDebuffInfo.criticalStacks
			};
			table.insert(self.deadlyDebuffInfo, deadlyDebuff);
		end
	end, true);
	self:UpdateDeadlyDebuffs();
	local onUpdateScript = #self.deadlyDebuffInfo > 0 and self.UpdateDeadlyDebuffs or nil;
	self:SetScript("OnUpdate", onUpdateScript);
end

function DebuffFrameMixin:UpdateDeadlyDebuffs()
	local mostCriticalDebuffIndex = nil;

	local currentTime = GetTime();
	local function IsCritical(index)
		local info = self.deadlyDebuffInfo[index];

		if not info.criticalTimeRemainingMs and not info.criticalStacks then
			return true; -- No critical period specified is always critical
		end

		local hasValidDurationInfo = info.duration > 0 and info.expirationTime > 0;
		if hasValidDurationInfo then
			local criticalTimeS = info.criticalTimeRemainingMs and (info.criticalTimeRemainingMs / 1000);
			if criticalTimeS and criticalTimeS >= (info.expirationTime - currentTime) then
				return true;
			end
		end

		if info.criticalStacks and info.criticalStacks <= info.count then
			return true;
		end

		return false;
	end

	for i = 1, #self.deadlyDebuffInfo do
		if IsCritical(i) then
			if not mostCriticalDebuffIndex then
				mostCriticalDebuffIndex = i;
			else
				local timeRemaining1 = self.deadlyDebuffInfo[i].expirationTime - currentTime;
				local timeRemaining2 = self.deadlyDebuffInfo[mostCriticalDebuffIndex].expirationTime - currentTime;

				local priority1 = self.deadlyDebuffInfo[i].priority;
				local priority2 = self.deadlyDebuffInfo[mostCriticalDebuffIndex].priority;

				if priority1 < priority2 then
					mostCriticalDebuffIndex = i;
				elseif timeRemaining1 < timeRemaining2 then
					mostCriticalDebuffIndex = i;
				end
			end
		end
	end

	if mostCriticalDebuffIndex then
		DeadlyDebuffFrame:Setup(self.deadlyDebuffInfo[mostCriticalDebuffIndex]);

		if RaidBossEmoteFrame and RaidBossEmoteFrame:IsShown() then
			DeadlyDebuffFrame:SetPoint("TOP", RaidBossEmoteFrame, "BOTTOM");
		elseif RaidWarningFrame then
			DeadlyDebuffFrame:SetPoint("TOP", RaidWarningFrame, "BOTTOM");
		else
			-- Fallback location only if RaidWarningFrame doesn't exist. We
			-- want to anchor to RaidWarningFrame even if it's hidden to
			-- make some room for the default position of Boss Warning text
			-- displays.
			DeadlyDebuffFrame:SetPoint("TOP", UIErrorsFrame, "BOTTOM");
		end
	else
		DeadlyDebuffFrame:Hide();
	end
end

function DebuffFrameMixin:GetIconLimitSettingEnum()
	return Enum.EditModeAuraFrameSetting.IconLimitDebuffFrame;
end

-- If you make changes to this, consider making the same changes to PrivateAuraMixin
AuraButtonMixin = { };

function AuraButtonMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:UpdateAuraType(nil);
end

function AuraButtonMixin:OnClick(button)
	if self.isExample then
		return;
	end

	if self.auraType == "Buff" then
		EventRegistry:TriggerEvent("BuffButton.OnClick", self, button);

		if button == "RightButton" then
			CancelUnitBuff(PlayerFrame.unit, self.buttonInfo.index, self:GetFilter());
		end
	elseif self.auraType == "Debuff" or self.auraType == "DeadlyDebuff" then
		EventRegistry:TriggerEvent("BuffButton.OnClick", self, button);
	elseif self.auraType == "TempEnchant" then
		if button == "RightButton" then
			--AubrieTODO: Figure out what we want to do with temp item enchants.
			if self:GetID() == 16 then
				CancelItemTempEnchantment(1);
			elseif self:GetID() == 17 then
				CancelItemTempEnchantment(2);
			elseif self:GetID() == 18 then
				CancelItemTempEnchantment(3);
			end
		end
	end
end

function AuraButtonMixin:OnEnter()
	if self.isExample then
		return;
	end

	if self.auraType == "TempEnchant" then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
		GameTooltip:SetInventoryItem("player", self:GetID());
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetFrameLevel(self:GetFrameLevel() + 2);

	if self.deadlyInstanceID then
		GameTooltip:SetUnitDebuffByAuraInstanceID(PlayerFrame.unit, self.deadlyInstanceID, self:GetFilter());
	elseif self.buttonInfo.auraInstanceID then
		GameTooltip:SetUnitAuraByAuraInstanceID(PlayerFrame.unit, self.buttonInfo.auraInstanceID);
	else
		GameTooltip:SetUnitAura(PlayerFrame.unit, self.buttonInfo.index, self:GetFilter());
	end
end

function AuraButtonMixin:OnLeave()
	if self.isExample then
		return;
	end

	GameTooltip:Hide();
end

function AuraButtonMixin:CalculateTimeLeft(elapsed)
	local expirationTime = self.buttonInfo.expirationTime or 0;
	local timeMod = self.buttonInfo.timeMod or 0;
	local timeLeft = expirationTime - GetTime();

	if timeMod > 0 then
		timeLeft = timeLeft / timeMod;
	end

	self.timeLeft = math.max(timeLeft, 0);
end

function AuraButtonMixin:OnUpdate(elapsed)
	if self.isExample then
		return;
	end

	if not self.buttonInfo then
		return;
	end

	if self.auraType == "TempEnchant" then
		-- Update duration
		if not PlayerFrame.unit or PlayerFrame.unit ~= "player" then
			self:Hide();
			return;
		end

		if GameTooltip:IsOwned(self) then
			self:OnEnter();
		end
	end

	-- Update the warning flash alpha.
	local containerFrame = self:GetParent();
	if (containerFrame and containerFrame.GetAuraWarningAlphaForDuration) then
		local auraWarningAlpha = containerFrame:GetAuraWarningAlphaForDuration(self.timeLeft);
		self:SetAlpha(auraWarningAlpha);
	end

	-- Update duration
	self:CalculateTimeLeft();
	securecall(self.UpdateDuration, self, self.timeLeft); -- Taint issue with SecondsToTimeAbbrev

	if SMALLER_AURA_DURATION_FONT_MIN_THRESHOLD then
		local aboveMinThreshold = self.timeLeft > SMALLER_AURA_DURATION_FONT_MIN_THRESHOLD;
		local belowMaxThreshold = not SMALLER_AURA_DURATION_FONT_MAX_THRESHOLD or self.timeLeft < SMALLER_AURA_DURATION_FONT_MAX_THRESHOLD;
		if aboveMinThreshold and belowMaxThreshold then
			self.Duration:SetFontObject(SMALLER_AURA_DURATION_FONT);
			self.Duration:SetPoint("TOP", self, "BOTTOM", 0, SMALLER_AURA_DURATION_OFFSET_Y);
		else
			self.Duration:SetFontObject(DEFAULT_AURA_DURATION_FONT);
			self.Duration:SetPoint("TOP", self, "BOTTOM");
		end
	end

	if GameTooltip:IsOwned(self) and not self:GetID() then
		if GameTooltip:IsOwned(self) then
			if self.deadlyInstanceID then
				GameTooltip:SetUnitDebuffByAuraInstanceID(PlayerFrame.unit, self.deadlyInstanceID, self:GetFilter());
			elseif self.buttonInfo.auraInstanceID then
				GameTooltip:SetUnitAuraByAuraInstanceID(PlayerFrame.unit, self.buttonInfo.auraInstanceID);
			else
				GameTooltip:SetUnitAura(PlayerFrame.unit, self.buttonInfo.index, self:GetFilter());
			end
		end
	end
end

function AuraButtonMixin:UpdateAuraType(auraType)
	self.auraType = auraType;

	self.Symbol:Hide();

	if self.auraType == "Buff" then
		self.DebuffBorder:Hide();
		self.TempEnchantBorder:Hide();
	elseif self.auraType == "Debuff" or self.auraType == "DeadlyDebuff" then
		local color = DebuffTypeColor["none"];
		self.DebuffBorder:SetVertexColor(color.r, color.g, color.b, color.a);
		self.DebuffBorder:Show();
		self.TempEnchantBorder:Hide();
	elseif self.auraType == "TempEnchant" then
		self.DebuffBorder:Hide();
		self.TempEnchantBorder:Show();
	end
end

function AuraButtonMixin:GetFilter()
	if self.isExample then
		return nil;
	end

	if self.auraType == "Buff" or self.auraType == "TempEnchant" then
		return "HELPFUL";
	elseif self.auraType == "Debuff" or self.auraType == "DeadlyDebuff" then
		return "HARMFUL";
	end

	return nil;
end

function AuraButtonMixin:UpdateExpirationTime(buttonInfo)
	if self.isExample then
		return;
	end

	if buttonInfo.expirationTime and buttonInfo.expirationTime > 0 then
		self.Duration:SetShown(CVarCallbackRegistry:GetCVarValueBool("buffDurations"));

		local timeLeft = (buttonInfo.expirationTime - GetTime());
		if buttonInfo.timeMod and buttonInfo.timeMod > 0 then
			self.timeMod = buttonInfo.timeMod;
			timeLeft = timeLeft / buttonInfo.timeMod;
		end

		if not self.timeLeft then
			self.timeLeft = timeLeft;
			self:SetScript("OnUpdate", self.OnUpdate);
		else
			self.timeLeft = timeLeft;
		end
	else
		self.Duration:Hide();
		self:SetScript("OnUpdate", nil);
		self.timeLeft = nil;
		self:SetAlpha(1.0);
	end
end

function AuraButtonMixin:Update(buttonInfo)
	if self.isExample then
		return;
	end

	self:UpdateAuraType(buttonInfo.auraType);

	self.buttonInfo = buttonInfo;
	self.unit = PlayerFrame.unit;

	if self.auraType == "TempEnchant" then
		self.Icon:SetTexture(self.buttonInfo.texture);
		self:UpdateExpirationTime(buttonInfo);

		if buttonInfo.count > 1 then
			self.Count:SetText(buttonInfo.count);
			self.Count:Show();
		else
			self.Count:Hide();
		end

		return;
	end

	if self:GetFilter() == "HARMFUL" then
		local color;
		if buttonInfo.debuffType then
			color = DebuffTypeColor[buttonInfo.debuffType];
			if CVarCallbackRegistry:GetCVarValueBool("colorblindMode") then
				self.Symbol:Show();
				self.Symbol:SetText(DebuffTypeSymbol[buttonInfo.debuffType] or "");
			else
				self.Symbol:Hide();
			end
		else
			self.Symbol:Hide();
			color = DebuffTypeColor["none"];
		end
		self.DebuffBorder:SetVertexColor(color.r, color.g, color.b, color.a);
	end

	self:UpdateExpirationTime(buttonInfo);
	self.Icon:SetTexture(buttonInfo.texture);

	if buttonInfo.count > 1 then
		self.Count:SetText(buttonInfo.count);
		self.Count:Show();
	else
		self.Count:Hide();
	end

	local helpTipInfo = buttonInfo.helpTipInfo;
	if helpTipInfo and not GetCVarBitfield(helpTipInfo.cvarBitfield, helpTipInfo.bitfieldFlag) then
		HelpTip:Show(self, buttonInfo.helpTipInfo, self);
	end

	if GameTooltip:IsOwned(self) then
		if self.deadlyInstanceID then
			GameTooltip:SetUnitDebuffByAuraInstanceID(self.unit, self.deadlyInstanceID, self:GetFilter());
		elseif buttonInfo.auraInstanceID then
			GameTooltip:SetUnitAuraByAuraInstanceID(PlayerFrame.unit, buttonInfo.auraInstanceID);
		else
			GameTooltip:SetUnitAura(self.unit, buttonInfo.index, self:GetFilter());
		end
	end
end

function AuraButtonMixin:GetID()
	if self.isExample then
		return nil;
	end

	return self.buttonInfo.ID;
end

function AuraButtonMixin:UpdateDuration(timeLeft)
	if self.isExample then
		return;
	end

	local show = timeLeft and CVarCallbackRegistry:GetCVarValueBool("buffDurations");
	self.Duration:SetShown(show);

	if show then
		self.Duration:SetFormattedText(SecondsToTimeAbbrev(timeLeft));

		local color = (timeLeft < BUFF_DURATION_WARNING_TIME) and HIGHLIGHT_FONT_COLOR or NORMAL_FONT_COLOR;
		self.Duration:SetVertexColor(color.r, color.g, color.b);
	end
end

CollapseAndExpandButtonMixin = { };

function CollapseAndExpandButtonMixin:OnLoad()
	self.orientation = CollapseAndExpandButton_Orientation_Horizontal;
	self.expandDirection = CollapseAndExpandButton_ExpandDirection_Left;

	self:SetChecked(true);
	self:UpdateOrientation();
end

function CollapseAndExpandButtonMixin:OnClick()
	self:GetParent():SetBuffsExpandedState(self:GetChecked());
	self:UpdateOrientation();
end

function CollapseAndExpandButtonMixin:IsEnabled()
	-- Treat these options as mutually exclusive.
	return CVarCallbackRegistry:GetCVarValueBool("collapseExpandBuffs") and not CVarCallbackRegistry:GetCVarValueBool("consolidateBuffs");
end

function CollapseAndExpandButtonMixin:UpdateOrientation()
	local isChecked = self:GetChecked();
	local rotation;

	if self.orientation == CollapseAndExpandButton_Orientation_Horizontal then
		local leftRotation = math.pi;
		local rightRotation = 0;
		if self.expandDirection == CollapseAndExpandButton_ExpandDirection_Left then
			rotation = isChecked and leftRotation or rightRotation;
		else
			rotation = isChecked and rightRotation or leftRotation;
		end

		self:SetSize(15, 30);
	else
		local downRotation = 3 * math.pi / 2;
		local upRotation = math.pi / 2;
		if self.expandDirection == CollapseAndExpandButton_ExpandDirection_Down then
			rotation = isChecked and downRotation or upRotation;
		else
			rotation = isChecked and upRotation or downRotation;
		end

		self:SetSize(30, 15);
	end

	self:GetNormalTexture():SetRotation(rotation);
	self:GetHighlightTexture():SetRotation(rotation);
	self:GetPushedTexture():SetRotation(rotation);
end

DeadlyDebuffFrameMixin = {};

function DeadlyDebuffFrameMixin:OnShow()
	self:RegisterEvent("CHAT_MSG_RAID_WARNING");
	self:RegisterEvent("RAID_BOSS_EMOTE");
end

function DeadlyDebuffFrameMixin:OnEvent(event, ...)
	if event == "RAID_BOSS_EMOTE" then
		DeadlyDebuffFrame:SetPoint("TOP", RaidBossEmoteFrame, "BOTTOM");
	elseif event == "CHAT_MSG_RAID_WARNING" then
		DeadlyDebuffFrame:SetPoint("TOP", RaidWarningFrame, "BOTTOM");
	end
end

function DeadlyDebuffFrameMixin:OnHide()
	self:UnregisterEvent("CHAT_MSG_RAID_WARNING");
	self:UnregisterEvent("RAID_BOSS_EMOTE");

	self.lastSpellID = nil;
end

function DeadlyDebuffFrameMixin:Setup(deadlyDebuffInfo)
	self.Debuff.deadlyInstanceID = deadlyDebuffInfo.auraInstanceID;
	self.Debuff:Update(deadlyDebuffInfo);
	self.WarningText:SetText(deadlyDebuffInfo.warningText)

	if deadlyDebuffInfo.soundKitID and deadlyDebuffInfo.spellID ~= self.lastSpellID then
		PlaySound(deadlyDebuffInfo.soundKitID);
	end

	self.lastSpellID = deadlyDebuffInfo.spellID;

	self:Show();
end

BuffFramePrivateAuraAnchorMixin = {};

function BuffFramePrivateAuraAnchorMixin:SetUnit(unit)
	if unit == self.unit then
		return;
	end
	self.unit = unit;

	if self.anchorID then
		C_UnitAuras.RemovePrivateAuraAnchor(self.anchorID);
		self.anchorID = nil;
	end

	if unit then
		local iconAnchor =
		{
			point = "CENTER",
			relativeTo = self.Icon,
			relativePoint = "CENTER",
			offsetX = 0,
			offsetY = 0,
		};
		local durationAnchor =
		{
			point = "CENTER",
			relativeTo = self.Duration,
			relativePoint = "CENTER",
			offsetX = 0,
			offsetY = 0,
		};

		local privateAnchorArgs = {};
		privateAnchorArgs.unitToken = unit;
		privateAnchorArgs.auraIndex = self.auraIndex;
		privateAnchorArgs.parent = self;
		privateAnchorArgs.showCountdownFrame = false;
		privateAnchorArgs.showCountdownNumbers = false;
		privateAnchorArgs.iconInfo =
		{
			iconAnchor = iconAnchor,
			iconWidth = self.Icon:GetWidth(),
			iconHeight = self.Icon:GetHeight(),
		};
		privateAnchorArgs.durationAnchor = durationAnchor;

		self.anchorID = C_UnitAuras.AddPrivateAuraAnchor(privateAnchorArgs);
	end
end

ConsolidatedBuffsMixin = {};

function ConsolidatedBuffsMixin:OnLoad()
	self:UpdateAuraType("Buff");
	self.Icon:SetTexture("Interface\\Buttons\\BuffConsolidation");
	self.Icon:SetTexCoord(0.109375, 0.390625, 0.21875, 0.78125);

	self.consolidatedAuraCount = 0;
end

function ConsolidatedBuffsMixin:OnEnter()
	self.Tooltip.Auras:UpdateAuraButtons();
	self.Tooltip.Auras:UpdateGridLayout();
	self.Tooltip:Show();
end

function ConsolidatedBuffsMixin:OnHide()
	self.Tooltip:Hide();
end

function ConsolidatedBuffsMixin:UpdateConsolidatedAuraCount(numConsolidatedAuras)
	self.consolidatedAuraCount = numConsolidatedAuras;
	self.Count:SetText(self.consolidatedAuraCount);

	local newShownStatus = self:ShouldShow();
	self:SetShown(newShownStatus);

	-- Return whether our shown status has changed.
	return prevShownStatus ~= newShownStatus;
end

function ConsolidatedBuffsMixin:UpdateConsolidatedAuras(auraInfo)
	local prevShownStatus = self:ShouldShow();
	self.Tooltip.Auras.auraInfo = auraInfo;
	self.Tooltip:UpdateAurasAndLayout();
end

function ConsolidatedBuffsMixin:IsEnabled()
	return CVarCallbackRegistry:GetCVarValueBool("consolidateBuffs");
end

function ConsolidatedBuffsMixin:ShouldShow()
	return self:IsEnabled() and self.consolidatedAuraCount > 0;
end

ConsolidatedBuffsTooltipMixin = {};

function ConsolidatedBuffsTooltipMixin:OnLoad()
	TooltipBackdropTemplateMixin.TooltipBackdropOnLoad(self);

	self.Auras:SetScale(0.8);
	self.mouseOverMargin = 10; -- Extra margin for how far away the mouse has to move before we hide the tooltip.

	self:UpdateAurasAndLayout();
end

function ConsolidatedBuffsTooltipMixin:OnUpdate()
	if ( not self:IsMouseOver(self.mouseOverMargin, -self.mouseOverMargin, -self.mouseOverMargin, self.mouseOverMargin) and
		 not self:GetParent():IsMouseOver(self.mouseOverMargin, -self.mouseOverMargin, -self.mouseOverMargin, self.mouseOverMargin) ) then
		self:Hide();
	end
end

function ConsolidatedBuffsTooltipMixin:UpdateAurasAndLayout()
	self.Auras:Update();
	self:Layout(); -- Resize tooltip to auras.
end

ConsolidatedBuffsTooltipAurasMixin = {};

function ConsolidatedBuffsTooltipAurasMixin:OnLoad()
	self.AuraContainer.addIconsToRight = true;
	self.AuraContainer.iconStride = 5;
	self.AuraContainer:ClearAllPoints();
	self.AuraContainer:SetPoint("TOPLEFT");

	self.auraInfo = {};
end

function ConsolidatedBuffsTooltipAurasMixin:ShouldShowAura(potentialAuraInfo)
	-- For ConsolidatedBuffs, we only show auras that are flagged to be hidden/collapsed.
	return potentialAuraInfo.hideUnlessExpanded;
end

function ConsolidatedBuffsTooltipAurasMixin:Update()
	self:UpdateAuraButtons();
	self:UpdateGridLayout();
end
