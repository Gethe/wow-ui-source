BUFF_WARNING_TIME = 31;
BUFF_DURATION_WARNING_TIME = 60;
BUFF_MAX_DISPLAY = 32;
DEBUFF_MAX_DISPLAY = 16;
DEFAULT_AURA_DURATION_FONT = "GameFontNormalSmall";

--Aubrie TODO move these.. to something else
DebuffTypeColor = { };
DebuffTypeColor["none"]	= { r = 0.80, g = 0, b = 0 };
DebuffTypeColor["Magic"]	= { r = 0.20, g = 0.60, b = 1.00 };
DebuffTypeColor["Curse"]	= { r = 0.60, g = 0.00, b = 1.00 };
DebuffTypeColor["Disease"]	= { r = 0.60, g = 0.40, b = 0 };
DebuffTypeColor["Poison"]	= { r = 0.00, g = 0.60, b = 0 };
DebuffTypeColor[""]	= DebuffTypeColor["none"];

DebuffTypeSymbol = { };
DebuffTypeSymbol["Magic"] = DEBUFF_SYMBOL_MAGIC;
DebuffTypeSymbol["Curse"] = DEBUFF_SYMBOL_CURSE;
DebuffTypeSymbol["Disease"] = DEBUFF_SYMBOL_DISEASE;
DebuffTypeSymbol["Poison"] = DEBUFF_SYMBOL_POISON;

CVarCallbackRegistry:SetCVarCachable("buffDurations");

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


AuraContainerMixin = {};

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

	if doNotAnchorDisabledFrames then
		auras = tFilter(auras, function(f) return f.hasValidInfo or f.isExample or f.isAuraAnchor; end, true);
	end

	for index, aura in ipairs(auras) do
		aura:SetScale(self.iconScale or 1);
		aura:SetSize(auraWidth, auraHeight);

		aura.Icon:ClearAllPoints();
		aura.Icon:SetPoint(iconPoint, aura, iconPoint);

		aura.Duration:ClearAllPoints();
		aura.Duration:SetPoint(durationPoint, aura.Icon, durationRelativePoint);
	end
	self:GetParent():UpdateSize(auraWidth, auraHeight, newLayoutInfo.iconStride or 1, newLayoutInfo.iconPadding or 0, self.iconScale or 1, newLayoutInfo.isHorizontal)

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
	self:RegisterUnitEvent("UNIT_AURA", "player", "vehicle");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");

	-- Create aura buttons
	self.auraFrames = {};
	for i = 1, self.maxAuras, 1 do
		local auraFrame = CreateFrame("BUTTON", nil, self.AuraContainer, "AuraButtonTemplate");
		table.insert(self.auraFrames, auraFrame);
	end
	for _, anchorframe in ipairs(self.PrivateAuraAnchors or {}) do
		table.insert(self.auraFrames, anchorframe);
	end
	self:UpdateGridLayout();
end

function AuraFrameMixin:AuraFrame_OnEvent(event, ...)
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
	end
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
	if self:TryEditModeUpdateAuraButtons() then
		return;
	end

	local isExpanded = self:IsExpanded();
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
					if isExpanded or not potentialAuraInfo.hideUnlessExpanded then
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

function AuraFrameMixin:TryEditModeUpdateAuraButtons()
	if self.isInEditMode then
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

function AuraFrameMixin:UpdateGridLayout()
	self.AuraContainer:UpdateGridLayout(self.auraFrames, self.doNotAnchorDisabledFrames);
	self:UpdateAuraContainerAnchor();
end

function AuraFrameMixin:UpdateAuraContainerAnchor()
	-- Override this as necessary
end

function AuraFrameMixin:UpdateSize(auraWidth, auraHeight, perRow, iconPadding, scale, isHorizontal)
	local totalRows = math.ceil(self.maxAuras / perRow);
	local frameWidth = (auraWidth + iconPadding) * (isHorizontal and perRow or totalRows);
	local frameHeight = (auraHeight + iconPadding) * (isHorizontal and (totalRows) or perRow);

	local expandButtonWidth = self.CollapseAndExpandButton and self.CollapseAndExpandButton:GetWidth() or 0;
	local expandButtonHeight = self.CollapseAndExpandButton and  self.CollapseAndExpandButton:GetHeight() or 0;
	local totalWidth = isHorizontal and frameWidth + expandButtonWidth or frameWidth;
	local totalHeight = not isHorizontal and frameHeight + expandButtonHeight or frameHeight;
	self:SetSize(totalWidth * scale, totalHeight * scale);
end

BuffFrameMixin = { };

function BuffFrameMixin:OnLoad()
	self:RegisterEvent("WEAPON_ENCHANT_CHANGED");
	self:RegisterEvent("WEAPON_SLOT_CHANGED");

	self.isExpanded = true;
end

function BuffFrameMixin:OnEvent(event, ...)
	if event == "WEAPON_ENCHANT_CHANGED" or event == "WEAPON_SLOT_CHANGED" then
		self:Update();
	end
end

function BuffFrameMixin:UpdateAuraContainerAnchor()
	self.AuraContainer:ClearAllPoints();
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
	AuraFrameMixin.Update(self);

	self:RefreshCollapseExpandButtonState();
end

function BuffFrameMixin:IsExpanded()
	return self.isExpanded;
end

function BuffFrameMixin:RefreshCollapseExpandButtonState()
	self.CollapseAndExpandButton:SetShown(self.numHideableBuffs > 0);
	self.CollapseAndExpandButton:SetChecked(self.isExpanded);
	self.CollapseAndExpandButton:UpdateOrientation();
end

function BuffFrameMixin:UpdateAuraButtons()
	AuraFrameMixin.UpdateAuraButtons(self);

	if self.isInEditMode then
		self.CollapseAndExpandButton:SetShown(true);
		self.CollapseAndExpandButton:SetChecked(true);
		self.CollapseAndExpandButton:UpdateOrientation();
	else
		self:RefreshCollapseExpandButtonState();
	end
end

function BuffFrameMixin:UpdatePlayerBuffs()
	self.numHideableBuffs = 0;

	AuraUtil.ForEachAura(PlayerFrame.unit, "HELPFUL", self.maxAuras, function(...)
		local _, texture, count, debuffType, duration, expirationTime, _, _, _, _, _, _, _, _, timeMod = ...;
		local timeLeft = (expirationTime - GetTime());
		local hideUnlessExpanded = (duration == 0) or (expirationTime == 0) or ((timeLeft) > BUFF_DURATION_WARNING_TIME); --Aubrie TODO filter with a flag on the aura.

		if hideUnlessExpanded then
			self.numHideableBuffs = self.numHideableBuffs + 1;
		end

		local index = #self.auraInfo + 1;
		self.auraInfo[index] = {index = index, texture = texture, count = count, debuffType = debuffType, duration = duration,  expirationTime = expirationTime, timeMod = timeMod, hideUnlessExpanded = hideUnlessExpanded, auraType = "Buff"};

		return #self.auraInfo > self.maxAuras;
	end);
end

--AubrieTODO: Figure out how we want to refactor this function to include non-weapon enchants..
function BuffFrameMixin:UpdateTemporaryEnchantments(...)
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

			local aura = { isTempEnchant = true, textureName = GetInventoryItemTexture("player", textureMapping[itemIndex]), ID = textureMapping[itemIndex], count = enchantCharges, expirationTime = expirationTime, hideUnlessExpanded = hideUnlessExpanded, auraType = "TempEnchant" };
			table.insert(self.auraInfo, aura);
		end
	end
end

function BuffFrameMixin:UpdateAuras()
	AuraFrameMixin.UpdateAuras(self);

	self:UpdatePlayerBuffs();
	self:UpdateTemporaryEnchantments(GetWeaponEnchantInfo());
end

function BuffFrameMixin:SetBuffsExpandedState(expanded)
	self.isExpanded = expanded;
	self:Update();
end

DebuffFrameMixin = { };

function DebuffFrameMixin:OnLoad()
	self.maxAuras = DEBUFF_MAX_DISPLAY;
end

function DebuffFrameMixin:Update() -- Override
	AuraFrameMixin.Update(self);
	local unit = PlayerFrame.unit;
	if unit ~= self.unit then
		for _, anchor in ipairs(self.PrivateAuraAnchors) do
			anchor:SetUnit(unit);
		end
	end
	self.unit = unit;
end

function DebuffFrameMixin:UpdateAuraButtons()  -- Override
	AuraFrameMixin.UpdateAuraButtons(self);
	self:UpdateGridLayout();
end

function DebuffFrameMixin:UpdateAuras()
	AuraFrameMixin.UpdateAuras(self);

	self.deadlyDebuffInfo = {};

	AuraUtil.ForEachAura(PlayerFrame.unit, "HARMFUL", self.maxAuras, function(auraData)
		local index = #self.auraInfo + 1;
		-- TODO:: Rename usages in this file to match packed auraData names, then just use packed aura everywhere
		self.auraInfo[index] = {index = index, texture = auraData.icon, count = auraData.applications, debuffType = auraData.dispelName, duration =  auraData.duration, expirationTime =  auraData.expirationTime, timeMod =  auraData.timeMod, auraType = "Debuff" };

		local deadlyDebuffInfo = C_SpellBook.GetDeadlyDebuffInfo(auraData.spellId);
		if(deadlyDebuffInfo) then
			local deadlyDebuff = {
				spellID = auraData.spellId,
				auraType = "DeadlyDebuff",
				texture = auraData.icon,
				count = auraData.applications,
				debuffType = auraData.dispelName,
				duration = auraData.duration,
				expirationTime = auraData.expirationTime,
				timeMod = auraData.timeMod,
				warningText = deadlyDebuffInfo.warningText,
				soundKitID = deadlyDebuffInfo.soundKitID,
				priority = deadlyDebuffInfo.priority,
				criticalTimeRemainingMs = deadlyDebuffInfo.criticalTimeRemainingMs,
				criticalStacks = deadlyDebuffInfo.criticalStacks,
				auraInstanceID =  auraData.auraInstanceID,
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

		local criticalTimeS = info.criticalTimeRemainingMs and (info.criticalTimeRemainingMs / 1000);
		if criticalTimeS and criticalTimeS >= (info.expirationTime - currentTime) then
			return true;
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
		elseif RaidWarningFrame and RaidWarningFrame:IsShown() then
			DeadlyDebuffFrame:SetPoint("TOP", RaidWarningFrame, "BOTTOM");
		else
			DeadlyDebuffFrame:SetPoint("TOP", UIErrorsFrame, "BOTTOM");
		end
	else
		DeadlyDebuffFrame:Hide();
	end
end

function DebuffFrameMixin:UpdateAuraContainerAnchor()
	self.AuraContainer:ClearAllPoints();

	if self.AuraContainer.addIconsToRight then
		if self.AuraContainer.addIconsToTop then
			self.AuraContainer:SetPoint("BOTTOMLEFT", self.AuraContainer:GetParent(), "BOTTOMLEFT");
		else
			self.AuraContainer:SetPoint("TOPLEFT", self.AuraContainer:GetParent(), "TOPLEFT");
		end
	else
		if self.AuraContainer.addIconsToTop then
			self.AuraContainer:SetPoint("BOTTOMRIGHT", self.AuraContainer:GetParent(), "BOTTOMRIGHT");
		else
			self.AuraContainer:SetPoint("TOPRIGHT", self.AuraContainer:GetParent(), "TOPRIGHT");
		end
	end
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

function AuraButtonMixin:OnUpdate()
	if self.isExample then
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

	local index = self.buttonInfo.index;
	if self.timeLeft and self.timeLeft < BUFF_WARNING_TIME then
		self:SetAlpha(1.0);
	else
		self:SetAlpha(1.0);
	end

	-- Update duration
	securecall(self.UpdateDuration, self, self.timeLeft); -- Taint issue with SecondsToTimeAbbrev 

	-- Update our timeLeft
	local timeLeft = self.buttonInfo.expirationTime - GetTime();
	if self.buttonInfo.timeMod and self.buttonInfo.timeMod > 0 then
		timeLeft = timeLeft / self.buttonInfo.timeMod;
	end
	self.timeLeft = max( timeLeft, 0 );
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
			else
				GameTooltip:SetUnitAura(PlayerFrame.unit, index, self:GetFilter());
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
		self.DebuffBorder:SetVertexColor(color.r, color.g, color.b);
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
		self.Icon:SetTexture(self.buttonInfo.textureName);
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
		self.DebuffBorder:SetVertexColor(color.r, color.g, color.b);
	end

	self:UpdateExpirationTime(buttonInfo);
	self.Icon:SetTexture(buttonInfo.texture);

	if buttonInfo.count > 1 then
		self.Count:SetText(buttonInfo.count);
		self.Count:Show();
	else
		self.Count:Hide();
	end

	if GameTooltip:IsOwned(self) then
		if self.deadlyInstanceID then
			GameTooltip:SetUnitDebuffByAuraInstanceID(self.unit, self.deadlyInstanceID, self:GetFilter());
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

	if timeLeft and CVarCallbackRegistry:GetCVarValueBool("buffDurations") then
		self.Duration:SetFormattedText(SecondsToTimeAbbrev(timeLeft));
		if timeLeft < BUFF_DURATION_WARNING_TIME then
			self.Duration:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		else
			self.Duration:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end
		self.Duration:Show();
	else
		self.Duration:Hide();
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