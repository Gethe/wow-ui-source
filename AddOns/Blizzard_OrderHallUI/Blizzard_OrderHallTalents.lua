
local TalentUnavailableReasons = {};
TalentUnavailableReasons[LE_GARRISON_TALENT_AVAILABILITY_UNAVAILABLE_ANOTHER_IS_RESEARCHING] = ORDER_HALL_TALENT_UNAVAILABLE_ANOTHER_IS_RESEARCHING;
TalentUnavailableReasons[LE_GARRISON_TALENT_AVAILABILITY_UNAVAILABLE_NOT_ENOUGH_RESOURCES] = ORDER_HALL_TALENT_UNAVAILABLE_NOT_ENOUGH_RESOURCES;
TalentUnavailableReasons[LE_GARRISON_TALENT_AVAILABILITY_UNAVAILABLE_NOT_ENOUGH_GOLD] = ORDER_HALL_TALENT_UNAVAILABLE_NOT_ENOUGH_GOLD;
TalentUnavailableReasons[LE_GARRISON_TALENT_AVAILABILITY_UNAVAILABLE_TIER_UNAVAILABLE] = ORDER_HALL_TALENT_UNAVAILABLE_TIER_UNAVAILABLE;

function OrderHallTalentFrame_ToggleFrame()
	if (not OrderHallTalentFrame:IsShown()) then
		ShowUIPanel(OrderHallTalentFrame);
	else
		HideUIPanel(OrderHallTalentFrame);
	end
end

StaticPopupDialogs["ORDER_HALL_TALENT_RESEARCH"] = {
	text = "%s";
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		PlaySound(SOUNDKIT.UI_ORDERHALL_TALENT_SELECT);
		C_Garrison.ResearchTalent(self.data.id);
		if (not self.data.hasTime) then
			self.data.button:GetParent():SetResearchingTalentID(self.data.id);
		end
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

OrderHallTalentFrameMixin = { }

local function OnTalentButtonReleased(pool, button)
	FramePool_HideAndClearAnchors(pool, button);
	button:OnReleased()
end

function OrderHallTalentFrameMixin:OnLoad()
	self.buttonPool = CreateFramePool("BUTTON", self, "GarrisonTalentButtonTemplate", OnTalentButtonReleased);
	self.choiceTexturePool = CreateTexturePool(self, "BACKGROUND", 1, "GarrisonTalentChoiceTemplate");
	self.arrowTexturePool = CreateTexturePool(self, "BACKGROUND", 2, "GarrisonTalentArrowTemplate");
	self.researchingTalentID = 0;

	local primaryCurrency, _ = C_Garrison.GetCurrencyTypes(self.garrisonType);
	self.currency = primaryCurrency;
end

function OrderHallTalentFrameMixin:OnShow()
	self:RefreshAllData();
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("GARRISON_TALENT_UPDATE");
    self:RegisterEvent("GARRISON_TALENT_COMPLETE");
	self:RegisterEvent("GARRISON_TALENT_NPC_CLOSED");
	PlaySound(SOUNDKIT.UI_ORDERHALL_TALENT_WINDOW_OPEN);
end

function OrderHallTalentFrameMixin:OnHide()
	self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:UnregisterEvent("GARRISON_TALENT_UPDATE");
    self:UnregisterEvent("GARRISON_TALENT_COMPLETE");
	self:UnregisterEvent("GARRISON_TALENT_NPC_CLOSED");

	self:ReleaseAllPools();
	StaticPopup_Hide("ORDER_HALL_TALENT_RESEARCH");
	C_Garrison.CloseTalentNPC();
	PlaySound(SOUNDKIT.UI_ORDERHALL_TALENT_WINDOW_CLOSE);
end

function OrderHallTalentFrameMixin:OnEvent(event, ...)
	if (event == "CURRENCY_DISPLAY_UPDATE" or event == "GARRISON_TALENT_UPDATE" or event == "GARRISON_TALENT_COMPLETE") then
		self:RefreshAllData();
	elseif (event == "GARRISON_TALENT_NPC_CLOSED") then
		self.CloseButton:Click();
	end
end

function OrderHallTalentFrameMixin:EscapePressed()
	if (self:IsVisible()) then
		self.CloseButton:Click();
		return true;
	end

	return false;
end

function OrderHallTalentFrameMixin:OnUpdate()
	if (self.triedRefreshing and not self.refreshing) then
		self:RefreshAllData();
	end
end

function OrderHallTalentFrameMixin:ReleaseAllPools()
	self.buttonPool:ReleaseAll();
	self.choiceTexturePool:ReleaseAll();
	self.arrowTexturePool:ReleaseAll();
end

function OrderHallTalentFrameMixin:RefreshCurrency()
	local currencyName, amount, currencyTexture = GetCurrencyInfo(self.currency);
	amount = BreakUpLargeNumbers(amount);
	self.Currency:SetText(amount);
	-- self.CurrencyIcon:SetTexture(currencyTexture);
end

local MAX_TIERS = 8;

function OrderHallTalentFrameMixin:RefreshAllData()
	if (self.refreshing) then
		if (not self.triedRefreshing) then
			self.triedRefreshing = true;
			self:SetScript("OnUpdate", self.OnUpdate);
		end
		return;
	end

	self.refreshing = true;
	self.triedRefreshing = false;
	self:SetScript("OnUpdate", nil);

	self:ReleaseAllPools();

	self:RefreshCurrency();
	local garrTalentTreeID = C_Garrison.GetCurrentGarrTalentTreeID();
	if (garrTalentTreeID == nil or garrTalentTreeID == 0) then
		local playerClass = select(3, UnitClass("player"));
		local treeIDs = C_Garrison.GetTalentTreeIDsByClassID(self.garrisonType, playerClass);
		if (treeIDs and #treeIDs > 0) then
			garrTalentTreeID = treeIDs[1];
		end
	end
	local uiTextureKit, classAgnostic, tree = C_Garrison.GetTalentTreeInfoForID(garrTalentTreeID);
	if not tree then
		self.refreshing = false;
		return;
	end
	
	-- Chromie is the original classAgnostic talent tree, and we added a back button to her talent frame
	-- as a small quality of life improvement (this may or may not be relevent to classAgnostic talent trees in the future).
	if (classAgnostic) then
		self.TitleText:SetText(UnitName("npc"));
		SetPortraitTexture(self.portrait, "npc");
		self.BackButton:Show();
	else
		self.TitleText:SetText(ORDER_HALL_TALENT_TITLE);
		self.BackButton:Hide();
	end

	local friendshipFactionID = C_Garrison.GetCurrentGarrTalentTreeFriendshipFactionID();
	if (friendshipFactionID and friendshipFactionID > 0) then
		NPCFriendshipStatusBar_Update(self, friendshipFactionID);
		self.Currency:Hide();
		self.CurrencyIcon:Hide();
		self.CurrencyHitTest:Hide();
		NPCFriendshipStatusBar:ClearAllPoints();
		NPCFriendshipStatusBar:SetPoint("TOPLEFT", 76, -39);
	else
		self.Currency:Show();
		self.CurrencyIcon:Show();
		self.CurrencyHitTest:Show();
	end

	if (uiTextureKit) then
		self.Background:SetAtlas(uiTextureKit.."-background");
	else
		local _, className, classID = UnitClass("player");

		self.Background:SetAtlas("orderhalltalents-background-"..className);
		if (not classAgnostic) then
			self.portrait:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
			self.portrait:SetTexture("INTERFACE\\ICONS\\crest_"..className);
		end
	end

	local borderX = 168;
	local borderY = -86;
	local buttonSizeX = 39;
	local buttonSizeY = 39;
	local buttonSpacingX = 59;
	local buttonSpacingY = 19;

	local choiceBackgroundOffsetX = 99;
	local choiceBackgroundOffsetY = 10;
	local arrowOffsetX = 10;
	local arrowOffsetY = 0;

	local researchingTalentID = self:GetResearchingTalentID();
	local researchingTalentTier = 0;

	-- count how many talents are in each tier
	local tierCount = {};
	local tierCanBeResearchedCount = {};
	for talentIndex, talent in ipairs(tree) do
		tierCount[talent.tier + 1] = (tierCount[talent.tier + 1] or 0) + 1;
		tierCanBeResearchedCount[talent.tier + 1] = tierCanBeResearchedCount[talent.tier + 1] or 0;
		if (talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_AVAILABLE) then
			tierCanBeResearchedCount[talent.tier + 1] = tierCanBeResearchedCount[talent.tier + 1] + 1;
		end
		talent.hasInstantResearch = talent.researchDuration == 0;
		if (talent.id == researchingTalentID and talent.hasInstantResearch) then
			if (not talent.selected) then
				talent.selected = true;
			end
			researchingTalentTier = talent.tier;
		end
	end

	-- position arrows and choice backgrounds
	for index = 1, #tierCount do
		local tier = index - 1;
		if (tierCount[index] == 2) then
			local choiceBackground = self.choiceTexturePool:Acquire();
			if (tierCanBeResearchedCount[index] == 2) then
				choiceBackground:SetAtlas("orderhalltalents-choice-background-on", true);
				choiceBackground:SetDesaturated(false);
				local pulsingArrows = self.arrowTexturePool:Acquire();
				pulsingArrows:SetPoint("CENTER", choiceBackground);
				pulsingArrows.Pulse:Play();
				pulsingArrows:Show();
			elseif (tierCanBeResearchedCount[index] == 1) then
				choiceBackground:SetAtlas("orderhalltalents-choice-background", true);
				choiceBackground:SetDesaturated(false);
			else
				choiceBackground:SetAtlas("orderhalltalents-choice-background", true);
				choiceBackground:SetDesaturated(true);
			end
			local tierWidth = (tierCount[index] * (buttonSizeX + buttonSpacingX)) - buttonSpacingX;
			local xOffset = borderX - (tierWidth / 2) - choiceBackgroundOffsetX;
			local yOffset = borderY - ((buttonSpacingY + buttonSizeY) * tier) + choiceBackgroundOffsetY;
			choiceBackground:SetPoint("TOP", xOffset, yOffset);
			choiceBackground:Show();
		end
		self["Tick"..index]:Show();
	end

	local height = 566;
	local insetheight = 504;
	local bgheight = 498;

	local change = 60;
	local changecount = 0;

	for index = #tierCount + 1, MAX_TIERS do
		self["Tick"..index]:Hide();
		changecount = changecount + 1;
	end

	local distance = change * changecount;
	self:SetHeight(height - distance);
	self.LeftInset:SetHeight(insetheight - distance);
	self.Background:SetHeight(bgheight - distance);

    local completeTalent = C_Garrison.GetCompleteTalent(self.garrisonType);

	-- position talent buttons
	for talentIndex, talent in ipairs(tree) do
		local currentTierCount = tierCount[talent.tier + 1];
		local currentTierCanBeResearchedCount = tierCanBeResearchedCount[talent.tier + 1];
		local tierWidth = (currentTierCount * (buttonSizeX + buttonSpacingX)) - buttonSpacingX;
		local talentFrame = self.buttonPool:Acquire();
		talentFrame.Icon:SetTexture(talent.icon);
		local xOffset = borderX - (tierWidth / 2) + (buttonSizeX + buttonSpacingX) * talent.uiOrder;
		local yOffset = borderY - (buttonSpacingY + buttonSizeY) * (talent.tier);

		talentFrame.talent = talent;
			
		if (talent.isBeingResearched and not talent.hasInstantResearch) then
			talentFrame.Cooldown:SetCooldownUNIX(talent.researchStartTime, talent.researchDuration);
			talentFrame.Cooldown:Show();
			talentFrame.AlphaIconOverlay:Show();
			talentFrame.AlphaIconOverlay:SetAlpha(0.7);
			talentFrame.CooldownTimerBackground:Show();
			if (not talentFrame.timer) then
				talentFrame.timer = C_Timer.NewTicker(1, function() talentFrame:Refresh(); end);
			end
		end

		local selectionAvailableInstantResearch = true;
		if (researchingTalentID ~= 0 and researchingTalentTier == talent.tier and researchingTalentID ~= talent.id) then
			selectionAvailableInstantResearch = false;
		end

		-- Show as selected: You have researched this talent.
		if (talent.selected and selectionAvailableInstantResearch) then
			if (talent.selected and talent.researched and talent.id == researchingTalentID) then
				self:ClearResearchingTalentID();
			end
			talentFrame.Border:SetAtlas("orderhalltalents-spellborder-yellow");
		else
			local isAvailable = talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_AVAILABLE;
				
			-- We check for LE_GARRISON_TALENT_AVAILABILITY_UNAVAILABLE_ALREADY_HAVE to avoid a bug with
			-- the Chromie UI (talents would flash grey when you switched to another talent in the same row).
			local canDisplayAsAvailable = talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_UNAVAILABLE_ANOTHER_IS_RESEARCHING or talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_UNAVAILABLE_ALREADY_HAVE;
			local shouldDisplayAsAvailable = canDisplayAsAvailable and talent.hasInstantResearch;
				
			-- Show as available: this is a new tier which you don't have any talents from or and old tier that you could change.
			-- Note: For instant talents, to support the Chromie UI, we display as available even when another talent is researching (Jeff wants it this way).
			if (isAvailable or shouldDisplayAsAvailable) then
				if ( currentTierCanBeResearchedCount < currentTierCount) then
					talentFrame.AlphaIconOverlay:Show();
					talentFrame.AlphaIconOverlay:SetAlpha(0.5);
					talentFrame.Border:Hide();
				else
					talentFrame.Border:SetAtlas("orderhalltalents-spellborder-green");
				end
					
			-- Show as unavailable: You have not unlocked this tier yet or you have unlocked it but another research is already in progress.
			else
				talentFrame.Border:SetAtlas("orderhalltalents-spellborder");
				talentFrame.Icon:SetDesaturated(true);
			end
		end
		talentFrame:SetPoint("TOPLEFT", xOffset, yOffset);
		talentFrame:Show();
			
        if (talent.id == completeTalent) then
            if (talent.selected and not talent.hasInstantResearch) then
				PlaySound(SOUNDKIT.UI_ORDERHALL_TALENT_READY_CHECK);
				talentFrame.TalentDoneAnim:Play();
			end
            C_Garrison.ClearCompleteTalent(self.garrisonType);
        end
	end
	self.refreshing = false;
end

function OrderHallTalentFrameMixin:SetResearchingTalentID(talentID)
	local oldResearchTalentID = self.researchingTalentID;
	self.researchingTalentID = talentID;
	if (oldResearchTalentID ~= talentID) then
		self:RefreshAllData();
	end
end

function OrderHallTalentFrameMixin:ClearResearchingTalentID()
	self.researchingTalentID = 0;
end

function OrderHallTalentFrameMixin:GetResearchingTalentID()
	return self.researchingTalentID;
end

GarrisonTalentButtonMixin = { }

function GarrisonTalentButtonMixin:OnEnter()
	local researchingTalentID = self:GetParent():GetResearchingTalentID();

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local talent = self.talent;
	GameTooltip:AddLine(talent.name, 1, 1, 1);
	GameTooltip:AddLine(talent.description, nil, nil, nil, true);

	if talent.isBeingResearched and not talent.hasInstantResearch then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(NORMAL_FONT_COLOR_CODE..TIME_REMAINING..FONT_COLOR_CODE_CLOSE.." "..SecondsToTime(talent.researchTimeRemaining), 1, 1, 1);
	elseif not talent.selected then
		GameTooltip:AddLine(" ");
		
		if (talent.researchDuration and talent.researchDuration > 0) then
			GameTooltip:AddLine(RESEARCH_TIME_LABEL.." "..HIGHLIGHT_FONT_COLOR_CODE..SecondsToTime(talent.researchDuration)..FONT_COLOR_CODE_CLOSE);
		end

		if ((talent.researchCost and talent.researchCost > 0 and talent.researchCurrency) or (talent.researchGoldCost and talent.researchGoldCost > 0)) then
			local str = NORMAL_FONT_COLOR_CODE..COSTS_LABEL..FONT_COLOR_CODE_CLOSE;
			
			if (talent.researchCost and talent.researchCurrency) then
				local _, _, currencyTexture = GetCurrencyInfo(talent.researchCurrency);
				str = str.." "..BreakUpLargeNumbers(talent.researchCost).."|T"..currencyTexture..":0:0:2:0|t";
			end
			if (talent.researchGoldCost ~= 0) then
				str = str.." "..talent.researchGoldCost.."|TINTERFACE\\MONEYFRAME\\UI-MoneyIcons.blp:16:16:2:0:64:16:0:16:0:16|t";
			end
			GameTooltip:AddLine(str, 1, 1, 1);
		end

		if talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_AVAILABLE or ((researchingTalentID and researchingTalentID ~= 0) and talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_UNAVAILABLE_ANOTHER_IS_RESEARCHING) then
			GameTooltip:AddLine(ORDER_HALL_TALENT_RESEARCH, 0, 1, 0);
			self.Highlight:Show();
		else
			if (talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_UNAVAILABLE_PLAYER_CONDITION and talent.playerConditionReason) then
				GameTooltip:AddLine(talent.playerConditionReason, 1, 0, 0);
			elseif (TalentUnavailableReasons[talent.talentAvailability]) then
				GameTooltip:AddLine(TalentUnavailableReasons[talent.talentAvailability], 1, 0, 0);
			end
			self.Highlight:Hide();
		end
	end
	self.tooltip = GameTooltip;
	GameTooltip:Show();
end

function GarrisonTalentButtonMixin:OnLeave()
	GameTooltip_Hide();
	self.Highlight:Hide();
	self.tooltip = nil;
end

function GarrisonTalentButtonMixin:OnClick()
	local researchingTalentID = self:GetParent():GetResearchingTalentID();
	if (researchingTalentID and researchingTalentID ~= 0 and researchingTalentID ~= self.talent.id) then
		UIErrorsFrame:AddMessage(ERR_CANT_DO_THAT_RIGHT_NOW, RED_FONT_COLOR:GetRGBA());
		--return;
	end
	if (self.talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_AVAILABLE) then
		local _, _, currencyTexture = GetCurrencyInfo(self:GetParent().currency);

		local hasCost = self.talent.researchCost and self.talent.researchCost > 0;
		local hasTime = self.talent.researchDuration and self.talent.researchDuration > 0;
		if (hasCost or hasTime) then
			local str;
			if (hasCost and hasTime) then
				str = string.format(ORDER_HALL_RESEARCH_CONFIRMATION, self.talent.name, BreakUpLargeNumbers(self.talent.researchCost), currencyTexture, SecondsToTime(self.talent.researchDuration, false, true));
			elseif (hasCost) then
				str = string.format(ORDER_HALL_RESEARCH_CONFIRMATION_NO_TIME, self.talent.name, BreakUpLargeNumbers(self.talent.researchCost), currencyTexture);
			elseif (hasTime) then
				str = string.format(ORDER_HALL_RESEARCH_CONFIRMATION_NO_COST, self.talent.name, SecondsToTime(self.talent.researchDuration, false, true));
			end
			StaticPopup_Show("ORDER_HALL_TALENT_RESEARCH", str, nil, { id = self.talent.id, hasTime = hasTime, button = self });
		else
			PlaySound(SOUNDKIT.UI_ORDERHALL_TALENT_SELECT);
			C_Garrison.ResearchTalent(self.talent.id);
			self:GetParent():SetResearchingTalentID(self.talent.id);
		end
	end
end

function GarrisonTalentButtonMixin:OnReleased()
	self.Cooldown:SetCooldownDuration(0);
	self.Cooldown:Hide();
	self.Border:Show();
	self.AlphaIconOverlay:Hide();
	self.CooldownTimerBackground:Hide();
	self.Icon:SetDesaturated(false);
	self.talent = nil;
	self.tooltip = nil;
	if (self.timer) then
		self.timer:Cancel();
		self.timer = nil;
	end
	self.TalentDoneAnim:Stop();
end

function GarrisonTalentButtonMixin:Refresh()
	if (self.talent and self.talent.id) then
	    self.talent = C_Garrison.GetTalent(self.talent.id);
	    if (self.tooltip) then
		    self:OnEnter();
	    end
	end
end