BUFF_WARNING_TIME = 31;
BUFF_DURATION_WARNING_TIME = 60;
BUFF_MAX_DISPLAY = 32;
DEBUFF_MAX_DISPLAY = 16
DEBUFF_CRITICAL_TIME_REMAINING = 15;
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

function AuraContainerMixin:UpdateGridLayout(auras)
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

	for index, aura in ipairs(auras) do
		aura:SetSize(auraWidth, auraHeight);

		aura.Icon:ClearAllPoints();
		aura.Icon:SetPoint(iconPoint, aura, iconPoint);

		aura.duration:ClearAllPoints();
		aura.duration:SetPoint(durationPoint, aura.Icon, durationRelativePoint);
	end
	self:GetParent():UpdateSize(auraWidth, auraHeight, newLayoutInfo.iconStride or 1, newLayoutInfo.iconPadding or 0, self.iconScale or 1, newLayoutInfo.isHorizontal)

    -- Apply the layout and then update our size
	GridLayoutUtil.ApplyGridLayout(
		auras,
		newLayoutInfo.anchor,
		newLayoutInfo.layout);

	self:Layout();

	-- Cache the new grid layout info so we know what needs to be update in future calls
	self.currentGridLayoutInfo = newLayoutInfo;
end

AuraFrameMixin = {};

function AuraFrameMixin:AuraFrame_OnLoad()
	self.auraFrames = {};

	self:RegisterUnitEvent("UNIT_AURA", "player", "vehicle");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");

	self.auraPool = CreateFramePoolCollection();
	self.auraPool:CreatePool("BUTTON", self.AuraContainer, self.auraTemplate);
	self.auraPool:CreatePool("Frame", self.AuraContainer, self.exampleAuraTemplate);
end

function AuraFrameMixin:AuraFrame_OnEvent(event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		self:Update();
	elseif event == "UNIT_AURA" then
		local unit = ...;
		if unit == PlayerFrame.unit then
			self:Update();
		end
	elseif event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_SPECIALIZATION_CHANGED" then
		self:Update();
	end
end

-- Override this in frames which inherit AuraFrameMixin
function AuraFrameMixin:UpdateAuras()
end

-- Override this in frames which inherit AuraFrameMixin if needed
function AuraFrameMixin:IsExpanded()
	return true;
end

function AuraFrameMixin:UpdateAuraButtons()
	if not self.isInitialized then
		return;
	end

	self.auraPool:ReleaseAllByTemplate(self.auraTemplate);
	self.auraPool:ReleaseAllByTemplate("TempEnchantButtonTemplate");
	self.auraFrames = {};

	if self.isInEditMode then
		-- Decide num example auras to show
		local maxExampleAuras;
		if self.ShowFull then
			maxExampleAuras = self.maxAuras;
		else
			maxExampleAuras = math.min(self.maxAuras, self.AuraContainer.iconStride + 3);
		end

		-- Show example auras
		for index, exampleAuraFrame in ipairs(self.exampleAuraFrames) do
			if index <= maxExampleAuras then
				exampleAuraFrame:SetScale(self.AuraContainer.iconScale or 1);
				exampleAuraFrame:Show();
				table.insert(self.auraFrames, exampleAuraFrame);
			else
				exampleAuraFrame:Hide();
			end
		end
	else
		-- Hide example auras
		if self.exampleAuraFrames then
			for index, exampleAuraFrame in ipairs(self.exampleAuraFrames) do
				exampleAuraFrame:Hide();
			end
		end

		-- Setup and show normal auras
		local isExpanded = self:IsExpanded();

		for index, aura in ipairs(self.auraInfo) do
			if not aura.hideUnlessExpanded or isExpanded then
				local auraFrame;
				if aura.isTempEnchant then
					auraFrame = self.auraPool:Acquire("TempEnchantButtonTemplate");
				else
					auraFrame = self.auraPool:Acquire(self.auraTemplate);
				end
				auraFrame:SetScale(self.AuraContainer.iconScale or 1);
				auraFrame:Update(aura, isExpanded);
				table.insert(self.auraFrames, auraFrame);
			end
		end
	end
end

function AuraFrameMixin:UpdateGridLayout()
	self.AuraContainer:UpdateGridLayout(self.auraFrames);
end

function AuraFrameMixin:Update()
	self.isInitialized = true;
	self.auraInfo = {};
	self:UpdateAuras();
	self:UpdateAuraButtons();
	self:UpdateGridLayout();
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
	self.maxAuras = BUFF_MAX_DISPLAY;

	self.auraPool:CreatePool("Button", self.AuraContainer, "TempEnchantButtonTemplate");
end

function BuffFrameMixin:OnEvent(event, ...)
	if event == "WEAPON_ENCHANT_CHANGED" or event == "WEAPON_SLOT_CHANGED" then
		self:Update();
	end
end

function BuffFrameMixin:UpdateCollapseAndExpandButtonAnchor()
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

function BuffFrameMixin:UpdateGridLayout()
	self.AuraContainer:UpdateGridLayout(self.auraFrames);
	self:UpdateCollapseAndExpandButtonAnchor();
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
	if not self.isInitialized then
		return;
	end

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
		self.auraInfo[index] = {index = index, texture = texture, count = count, debuffType = debuffType, duration = duration,  expirationTime = expirationTime, timeMod = timeMod, hideUnlessExpanded = hideUnlessExpanded};

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

			local aura = { isTempEnchant = true, textureName = GetInventoryItemTexture("player", textureMapping[itemIndex]), ID = textureMapping[itemIndex], count = enchantCharges, expirationTime = expirationTime, hideUnlessExpanded = hideUnlessExpanded };
			table.insert(self.auraInfo, aura);
		end
	end
end

function BuffFrameMixin:UpdateAuras()
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

	self.auraPool:CreatePool("BUTTON", self.AuraContainer, "DeadlyDebuffButtonTemplate");
end

function DebuffFrameMixin:UpdateAuras()
	self.deadlyDebuffInfo = {};

	AuraUtil.ForEachAura(PlayerFrame.unit, "HARMFUL", self.maxAuras, function(...)
		local _, texture, count, debuffType, duration, expirationTime, _, _, _, spellID, _, _, _, _, timeMod = ...;

		local deadlyDebuffInfo = C_SpellBook.GetDeadlyDebuffInfo(spellID);
		if(deadlyDebuffInfo) then
			local deadlyDebuff = { index = 0, texture = texture, count = count, debuffType = debuffType, duration = duration, expirationTime = expirationTime, timeMod = timeMod, warningText = deadlyDebuffInfo.warningText, soundKitID = deadlyDebuffInfo.soundKitID, priority = deadlyDebuffInfo.priority, criticalTimeRemaining = deadlyDebuffInfo.overrideCriticalTimeRemaining };
			table.insert(self.deadlyDebuffInfo, deadlyDebuff);
		else
			local index = #self.auraInfo + 1;
			self.auraInfo[index] = {index = index, texture = texture, count = count, debuffType = debuffType, duration = duration, expirationTime = expirationTime, timeMod = timeMod, }
		end

		return (#self.auraInfo + #self.deadlyDebuffInfo) > self.maxAuras;
	end);
	self:SetupDeadlyDebuffs();
end

function DebuffFrameMixin:SetupDeadlyDebuffs()
	-- Setup DeadlyDebuffFrame
	local mostCriticalDebuffIndex = nil;

	for i = 1, #self.deadlyDebuffInfo do
		if(not mostCriticalDebuffIndex) then
			mostCriticalDebuffIndex = i;
		else
			local currentTime = GetTime();
			local timeRemaining1 = self.deadlyDebuffInfo[i].expirationTime - currentTime;
			local timeRemaining2 = self.deadlyDebuffInfo[mostCriticalDebuffIndex].expirationTime - currentTime;

			local priority1 = self.deadlyDebuffInfo[i].priority;
			local priority2 = self.deadlyDebuffInfo[mostCriticalDebuffIndex].priority;

			--If the deadly debuff has an override critical time, use that to determine the critical state, if not.. use the default
			local isInCriticalTimeRemaining1 = (self.deadlyDebuffInfo[i].overrideCriticalTimeRemaining) and (self.deadlyDebuffInfo[i].overrideCriticalTimeRemaining <= timeRemaining1) or (DEBUFF_CRITICAL_TIME_REMAINING >= timeRemaining1)
			local isInCriticalTimeRemaining2 = (self.deadlyDebuffInfo[mostCriticalDebuffIndex].overrideCriticalTimeRemaining) and (self.deadlyDebuffInfo[mostCriticalDebuffIndex].overrideCriticalTimeRemaining <= timeRemaining2)

			--If the debuffs are both in their critical state, prioritize the one with the highest priority, if they have the same priority, use the time remaining. 
			if (isInCriticalTimeRemaining1 and isInCriticalTimeRemaining2) then
				if (priority1 > priority2) then 
					mostCriticalDebuffIndex = i;
				elseif (timeRemaining1 < timeRemaining2) then
					mostCriticalDebuffIndex = i;
				end 
			-- If 1 is in critical time remaining.. use that. 
			elseif (isInCriticalTimeRemaining1) then 
				mostCriticalDebuffIndex = i;
			else
				--Keep using the mostCriticalDebuffIndex unless the current debuff info is a higher priorty or has less time remaining. 
				--If the previous compared debuff is in the critical state, show that instead since it's more critical
				if (not isInCriticalTimeRemaining2) then 
					if (priority1 > priority2) then
						mostCriticalDebuffIndex = i;
					elseif (timeRemaining1 < timeRemaining2) then
						mostCriticalDebuffIndex = i;
					end
				end 
			end
		end
	end

	if mostCriticalDebuffIndex then
		DeadlyDebuffFrame:Setup(self.deadlyDebuffInfo[mostCriticalDebuffIndex]);

		if (RaidBossEmoteFrame and RaidBossEmoteFrame:IsShown()) then
			DeadlyDebuffFrame:SetPoint("TOP", RaidBossEmoteFrame, "BOTTOM");
		elseif (RaidWarningFrame and RaidWarningFrame:IsShown()) then
			DeadlyDebuffFrame:SetPoint("TOP", RaidWarningFrame, "BOTTOM");
		else
			DeadlyDebuffFrame:SetPoint("TOP", UIErrorsFrame, "BOTTOM");
		end
		-- Remove deadly debuff which is being shown in DeadlyDebuffFrame so it only appears in one place
		table.remove(self.deadlyDebuffInfo, mostCriticalDebuffIndex);
	end

	-- Add remaining deadly debuffs onto end of aura list so they appear at the end
	for index, deadlyDebuff in ipairs(self.deadlyDebuffInfo) do
		deadlyDebuff.index = #self.auraInfo + 1;
		self.auraInfo[deadlyDebuff.index] = deadlyDebuff;
	end
end

AuraButtonMixin = { };

function AuraButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetFrameLevel(self:GetFrameLevel() + 2);
	GameTooltip:SetUnitAura(PlayerFrame.unit, self.buttonInfo.index, self:GetFilter());
end

function AuraButtonMixin:OnLeave()
	GameTooltip:Hide();
end

function AuraButtonMixin:UpdateExpirationTime(buttonInfo)
	if ( buttonInfo.expirationTime and buttonInfo.expirationTime > 0 ) then
		self.duration:SetShown(CVarCallbackRegistry:GetCVarValueBool("buffDurations"));

		local timeLeft = (buttonInfo.expirationTime - GetTime());
		if( buttonInfo.timeMod and buttonInfo.timeMod > 0) then
			self.timeMod = buttonInfo.timeMod;
			timeLeft = timeLeft / buttonInfo.timeMod;
		end

		if ( not self.timeLeft ) then
			self.timeLeft = timeLeft;
			self:SetScript("OnUpdate", self.OnUpdate);
		else
			self.timeLeft = timeLeft;
		end
	else
		self.duration:Hide();
		self:SetScript("OnUpdate", nil);
		self.timeLeft = nil;
	end
end

function AuraButtonMixin:Update(buttonInfo, expanded)
	if(not buttonInfo) then
		return; 
	end 
	local helpful = (self:GetFilter() == "HELPFUL");
	self.unit = PlayerFrame.unit;
	self.buttonInfo = buttonInfo;

	local canShow = (not buttonInfo.hideUnlessExpanded) or expanded;
	self:SetShown(canShow);
	if ( not helpful ) then
		if ( self.Border ) then
			local color;
			if ( buttonInfo.debuffType ) then
				color = DebuffTypeColor[buttonInfo.debuffType];
				if ( ENABLE_COLORBLIND_MODE == "1" ) then
					self.symbol:Show();
					self.symbol:SetText(DebuffTypeSymbol[buttonInfo.debuffType] or "");
				else
					self.symbol:Hide();
				end
			else
				self.symbol:Hide();
				color = DebuffTypeColor["none"];
			end
			self.Border:SetVertexColor(color.r, color.g, color.b);
		end
	end

	self:UpdateExpirationTime(buttonInfo); 
	self.Icon:SetTexture(buttonInfo.texture);

	if ( buttonInfo.count > 1 ) then
		self.count:SetText(buttonInfo.count);
		self.count:Show();
	else
		self.count:Hide();
	end

	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:SetUnitAura(self.unit, buttonInfo.index, self:GetFilter());
	end
end

function AuraButtonMixin:OnUpdate()
	local index = self.buttonInfo.index;
	if ( self.timeLeft and self.timeLeft < BUFF_WARNING_TIME ) then
		self:SetAlpha(1.0);
	else
		self:SetAlpha(1.0);
	end

	-- Update duration
	securecall(self.UpdateDuration, self, self.timeLeft); -- Taint issue with SecondsToTimeAbbrev 

	-- Update our timeLeft
	local timeLeft = self.buttonInfo.expirationTime - GetTime();
	if ( self.buttonInfo.timeMod and self.buttonInfo.timeMod > 0 ) then
		timeLeft = timeLeft / self.buttonInfo.timeMod;
	end
	self.timeLeft = max( timeLeft, 0 );
	if ( SMALLER_AURA_DURATION_FONT_MIN_THRESHOLD ) then
		local aboveMinThreshold = self.timeLeft > SMALLER_AURA_DURATION_FONT_MIN_THRESHOLD;
		local belowMaxThreshold = not SMALLER_AURA_DURATION_FONT_MAX_THRESHOLD or self.timeLeft < SMALLER_AURA_DURATION_FONT_MAX_THRESHOLD;
		if ( aboveMinThreshold and belowMaxThreshold ) then
			self.duration:SetFontObject(SMALLER_AURA_DURATION_FONT);
			self.duration:SetPoint("TOP", self, "BOTTOM", 0, SMALLER_AURA_DURATION_OFFSET_Y);
		else
			self.duration:SetFontObject(DEFAULT_AURA_DURATION_FONT);
			self.duration:SetPoint("TOP", self, "BOTTOM");
		end
	end

	if ( GameTooltip:IsOwned(self) and not self:GetID() ) then
		GameTooltip:SetUnitAura(PlayerFrame.unit, index, self:GetFilter());
	end

	if (self.isDeadlyDebuff and self.timeLeft <= 0) then 
		DeadlyDebuffFrame:Hide() 
	elseif ((self.buttonInfo.criticalTimeRemaining and self.buttonInfo.criticalTimeRemaining > 0) and timeLeft <= self.buttonInfo.criticalTimeRemaining) then
		DebuffFrame:SetupDeadlyDebuffs(); 
	end
end

function AuraButtonMixin:GetID()
	return self.buttonInfo.ID;
end

function AuraButtonMixin:UpdateDuration(timeLeft)
	local duration = self.duration;
	if ( timeLeft and CVarCallbackRegistry:GetCVarValueBool("buffDurations") ) then
		duration:SetFormattedText(SecondsToTimeAbbrev(timeLeft));
		if ( timeLeft < BUFF_DURATION_WARNING_TIME ) then
			duration:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		else
			duration:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end
		duration:Show();
	else
		duration:Hide();
	end
end

BuffButtonMixin = CreateFromMixins(AuraButtonMixin);
function BuffButtonMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function BuffButtonMixin:GetFilter()
	return "HELPFUL";
end

function BuffButtonMixin:OnClick(button)
    EventRegistry:TriggerEvent("BuffButton.OnClick", self, button);

    if(button == "RightButton") then
        CancelUnitBuff(PlayerFrame.unit, self.buttonInfo.index, self:GetFilter());
    end
end

DebuffButtonMixin = CreateFromMixins(AuraButtonMixin);
function DebuffButtonMixin:GetFilter()
	 return "HARMFUL";
end

function DebuffButtonMixin:OnClick(button)
    EventRegistry:TriggerEvent("BuffButton.OnClick", self, button);
end


function DebuffButtonMixin:OnLoad()
	self.duration:SetPoint("TOP", self, "BOTTOM", 0, -1);
end

TempEnchantButtonMixin = CreateFromMixins(AuraButtonMixin);

function TempEnchantButtonMixin:OnLoad()
	self:RegisterForClicks("RightButtonUp");
end

function TempEnchantButtonMixin:OnUpdate(elapsed)
	-- Update duration
	if( not PlayerFrame.unit or PlayerFrame.unit ~= "player") then
		self:Hide();
		return;
	end

	if ( GameTooltip:IsOwned(self) ) then
		self:OnEnter();
	end

	AuraButtonMixin.OnUpdate(self, elapsed);
end

function TempEnchantButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetInventoryItem("player", self:GetID());
end

function TempEnchantButtonMixin:GetID()
	return self.buttonInfo.ID;
end

function TempEnchantButtonMixin:Update(buttonInfo, expanded)
	if (not buttonInfo) then
		return;
	end

	self.buttonInfo = buttonInfo; 
	self.Icon:SetTexture(self.buttonInfo.textureName);
	self:UpdateExpirationTime(buttonInfo);

	if (buttonInfo.count > 1) then
		self.count:SetText(buttonInfo.count);
		self.count:Show();
	else
		self.count:Hide();
	end

	local canShow = (not buttonInfo.hideUnlessExpanded) or expanded;
	self:SetShown(canShow);
end

--AubrieTODO: Figure out what we want to do with temp item enchants. 
function TempEnchantButtonMixin:OnClick()
	if ( self:GetID() == 16 ) then
		CancelItemTempEnchantment(1);
	elseif ( self:GetID() == 17 ) then
		CancelItemTempEnchantment(2);
	elseif ( self:GetID() == 18 ) then
		CancelItemTempEnchantment(3);
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

DeadlyDebuffFrameMixin = { };
function DeadlyDebuffFrameMixin:OnShow()
	self:RegisterEvent("CHAT_MSG_RAID_WARNING");
	self:RegisterEvent("RAID_BOSS_EMOTE");
end

function DeadlyDebuffFrameMixin:OnEvent(event, ...)
	if (event == "RAID_BOSS_EMOTE") then
		DeadlyDebuffFrame:SetPoint("TOP", RaidBossEmoteFrame, "BOTTOM");
	elseif (event == "CHAT_MSG_RAID_WARNING") then
		DeadlyDebuffFrame:SetPoint("TOP", RaidWarningFrame, "BOTTOM");
	end
end

function DeadlyDebuffFrameMixin:OnHide()
	self:UnregisterEvent("CHAT_MSG_RAID_WARNING");
	self:UnregisterEvent("RAID_BOSS_EMOTE");
end

function DeadlyDebuffFrameMixin:Setup(deadlyDebuffInfo)
	self.Debuff:Update(deadlyDebuffInfo);
	self.WarningText:SetText(deadlyDebuffInfo.warningText)
	if(deadlyDebuffInfo.soundKitID) then 
		PlaySound(deadlyDebuffInfo.soundKitID);
	end
	self:Show(); 
end 

ExampleDebuffMixin = {};

function ExampleDebuffMixin:Setup()
	local color = DebuffTypeColor["none"];
	self.Border:SetVertexColor(color.r, color.g, color.b)
end