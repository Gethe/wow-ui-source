
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
		PlaySound("UI_OrderHall_Talent_Select");
		C_Garrison.ResearchTalent(self.data);
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
	local _, className, classID = UnitClass("player");

	self.buttonPool = CreateFramePool("BUTTON", self, "GarrisonTalentButtonTemplate", OnTalentButtonReleased);
	self.choiceTexturePool = CreateTexturePool(self, "BACKGROUND", 1, "GarrisonTalentChoiceTemplate");
	self.arrowTexturePool = CreateTexturePool(self, "BACKGROUND", 2, "GarrisonTalentArrowTemplate");
	self.ClassBackground:SetAtlas("orderhalltalents-background-"..className);
	self.portrait:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
	self.portrait:SetTexture("INTERFACE\\ICONS\\crest_"..className);
	self.TitleText:SetText(ORDER_HALL_TALENT_TITLE);

	local primaryCurrency, _ = C_Garrison.GetCurrencyTypes(self.garrisonType);
	self.currency = primaryCurrency;
end

function OrderHallTalentFrameMixin:OnShow()
	self:RefreshAllData();
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("GARRISON_TALENT_UPDATE");
    self:RegisterEvent("GARRISON_TALENT_COMPLETE");
	self:RegisterEvent("GARRISON_TALENT_NPC_CLOSED");
	PlaySound("UI_OrderHall_TalentWindow_Open");
end

function OrderHallTalentFrameMixin:OnHide()
	self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:UnregisterEvent("GARRISON_TALENT_UPDATE");
    self:UnregisterEvent("GARRISON_TALENT_COMPLETE");
	self:UnregisterEvent("GARRISON_TALENT_NPC_CLOSED");

	self:ReleaseAllPools();
	StaticPopup_Hide("ORDER_HALL_TALENT_RESEARCH");
	C_Garrison.CloseTalentNPC();
	PlaySound("UI_OrderHall_TalentWindow_Close");
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

	 
function OrderHallTalentFrameMixin:RefreshAllData()
	self:ReleaseAllPools();

	self:RefreshCurrency();
	self.trees = C_Garrison.GetTalentTrees(self.garrisonType, select(3, UnitClass("player")));
	if not self.trees then
		return;
	end

	local borderX = 168;
	local borderY = -86;
	local treeSpacingX = 200;
	local buttonSizeX = 39;
	local buttonSizeY = 39;
	local buttonSpacingX = 59;
	local buttonSpacingY = 19;

	local choiceBackgroundOffsetX = 99;
	local choiceBackgroundOffsetY = 10;
	local arrowOffsetX = 10;
	local arrowOffsetY = 0;

	for treeIndex, tree in ipairs(self.trees) do
		-- count how many talents are in each tier
		local tierCount = {};
		local tierCanBeResearchedCount = {};
		for talentIndex, talent in ipairs(tree) do
			tierCount[talent.tier + 1] = (tierCount[talent.tier + 1] or 0) + 1;
			if (talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_AVAILABLE) then
				tierCanBeResearchedCount[talent.tier + 1] = (tierCanBeResearchedCount[talent.tier + 1] or 0) + 1;
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
				local xOffset = borderX + ((treeIndex - 1) * treeSpacingX) - (tierWidth / 2) - choiceBackgroundOffsetX;
				local yOffset = borderY - ((buttonSpacingY + buttonSizeY) * tier) + choiceBackgroundOffsetY;
				choiceBackground:SetPoint("TOP", xOffset, yOffset);
				choiceBackground:Show();
			end
		end

        local completeTalent = C_Garrison.GetCompleteTalent(self.garrisonType);
                        
		-- position talent buttons
		for talentIndex, talent in ipairs(tree) do
			local currentTierCount = tierCount[talent.tier + 1];
			local currentTierCanBeResearchedCount = tierCanBeResearchedCount[talent.tier + 1];
			local tierWidth = (currentTierCount * (buttonSizeX + buttonSpacingX)) - buttonSpacingX;
			local talentFrame = self.buttonPool:Acquire();
			talentFrame.Icon:SetTexture(talent.icon);
			local xOffset = borderX + (treeIndex - 1) * treeSpacingX - (tierWidth / 2) + (buttonSizeX + buttonSpacingX) * talent.uiOrder;
			local yOffset = borderY - (buttonSpacingY + buttonSizeY) * (talent.tier);

			talentFrame.talent = talent;

			if (talent.isBeingResearched) then
				talentFrame.Cooldown:SetCooldownUNIX(talent.researchStartTime, talent.researchDuration);
				talentFrame.Cooldown:Show();
				talentFrame.AlphaIconOverlay:Show();
				talentFrame.AlphaIconOverlay:SetAlpha(0.7);
				talentFrame.CooldownTimerBackground:Show();
				if (not talentFrame.timer) then
					talentFrame.timer = C_Timer.NewTicker(1, function() talentFrame:Refresh(); end);
				end
			end

			if (talent.selected) then
				talentFrame.Border:SetAtlas("orderhalltalents-spellborder-yellow");
			elseif (talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_AVAILABLE) then
				if (currentTierCanBeResearchedCount < currentTierCount) then
					talentFrame.AlphaIconOverlay:Show();
					talentFrame.AlphaIconOverlay:SetAlpha(0.5);
					talentFrame.Border:Hide();
				else
					talentFrame.Border:SetAtlas("orderhalltalents-spellborder-green");
				end
			else
				talentFrame.Border:SetAtlas("orderhalltalents-spellborder");
				talentFrame.Icon:SetDesaturated(true);
			end
			talentFrame:SetPoint("TOPLEFT", xOffset, yOffset);
			talentFrame:Show();

            if (talent.id == completeTalent) then
                if (talent.selected) then
					PlaySound("UI_OrderHall_Talent_Ready_Check");
					talentFrame.TalentDoneAnim:Play();
				end
                C_Garrison.ClearCompleteTalent(self.garrisonType);
            end
		end


	end

end


GarrisonTalentButtonMixin = { }

function GarrisonTalentButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local talent = self.talent;
	GameTooltip:AddLine(talent.name, 1, 1, 1);
	GameTooltip:AddLine(talent.description, nil, nil, nil, true);

	if talent.isBeingResearched then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(NORMAL_FONT_COLOR_CODE..TIME_REMAINING..FONT_COLOR_CODE_CLOSE.." "..SecondsToTime(talent.researchTimeRemaining), 1, 1, 1);
	elseif not talent.selected then
		GameTooltip:AddLine(" ");
		
		GameTooltip:AddLine(RESEARCH_TIME_LABEL.." "..HIGHLIGHT_FONT_COLOR_CODE..SecondsToTime(talent.researchDuration)..FONT_COLOR_CODE_CLOSE);
		if ((talent.researchCost and talent.researchCurrency) or talent.researchGoldCost) then
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

		if talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_AVAILABLE then
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
	if (self.talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_AVAILABLE) then
		local _, _, currencyTexture = GetCurrencyInfo(self:GetParent().currency);

		local str = string.format(ORDER_HALL_RESEARCH_CONFIRMATION, self.talent.name, BreakUpLargeNumbers(self.talent.researchCost), tostring(currencyTexture), SecondsToTime(self.talent.researchDuration, false, true));
		StaticPopup_Show("ORDER_HALL_TALENT_RESEARCH", str, nil, self.talent.id);
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