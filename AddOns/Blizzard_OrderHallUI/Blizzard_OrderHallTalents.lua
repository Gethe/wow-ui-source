

function OrderHallTalentFrame_ToggleFrame()
	if (not OrderHallTalentFrame:IsShown()) then
		ShowUIPanel(OrderHallTalentFrame);
	else
		HideUIPanel(OrderHallTalentFrame);
	end
end

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
	self.TitleText:SetText(_G["ORDER_HALL_"..className]);

	local primaryCurrency, _ = C_Garrison.GetCurrencyTypes(LE_GARRISON_TYPE_7_0);
	self.currency = primaryCurrency;
end

function OrderHallTalentFrameMixin:OnShow()
	self:RefreshAllData();
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("GARRISON_TALENT_UPDATE");
	self:RegisterEvent("GARRISON_TALENT_NPC_CLOSED");
end

function OrderHallTalentFrameMixin:OnHide()
	self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:UnregisterEvent("GARRISON_TALENT_UPDATE");
	self:UnregisterEvent("GARRISON_TALENT_NPC_CLOSED");

	self:ReleaseAllPools();

	C_Garrison.CloseTalentNPC();
end

function OrderHallTalentFrameMixin:OnEvent(event, ...)
	if (event == "CURRENCY_DISPLAY_UPDATE") then
		self:RefreshCurrency();
	elseif (event == "GARRISON_TALENT_UPDATE") then
		local garrType = ...;
		if (garrType == self.garrisonType) then
			self:RefreshAllData();
		end
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
	self.CurrencyIcon:SetTexture(currencyTexture);
end

	 
function OrderHallTalentFrameMixin:RefreshAllData()
	self:ReleaseAllPools();

	self:RefreshCurrency();
	self.trees = C_Garrison.GetTalentTrees(LE_GARRISON_TYPE_7_0, select(3, UnitClass("player")));
	if not self.trees then
		return;
	end

	local borderX = 165;
	local borderY = -85;
	local treeSpacingX = 200;
	local buttonSizeX = 40;
	local buttonSizeY = 40;
	local buttonSpacingX = 58;
	local buttonSpacingY = 19;

	local choiceBackgroundOffsetX = 14;
	local choiceBackgroundOffsetY = 9;
	local arrowOffsetX = 10;
	local arrowOffsetY = 0;

	for treeIndex, tree in ipairs(self.trees) do
		-- count how many talents are in each tier
		local tierCount = {};
		local tierCanBeResearchedCount = {};
		for talentIndex, talent in ipairs(tree) do
			tierCount[talent.tier + 1] = (tierCount[talent.tier + 1] or 0) + 1;
			if (talent.canBeResearched) then
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
				choiceBackground:SetPoint("TOPLEFT", xOffset, yOffset);
				choiceBackground:Show();
			end
		end

		-- position talent buttons
		for talentIndex, talent in ipairs(tree) do
			local currentTierCount = tierCount[talent.tier + 1];
			local tierWidth = (currentTierCount * (buttonSizeX + buttonSpacingX)) - buttonSpacingX;
			local talentFrame = self.buttonPool:Acquire();
			talentFrame.Icon:SetTexture(talent.icon);
			local xOffset = borderX + (treeIndex - 1) * treeSpacingX - (tierWidth / 2) + (buttonSizeX + buttonSpacingX) * talent.uiOrder;
			local yOffset = borderY - (buttonSpacingY + buttonSizeY) * (talent.tier);

			talentFrame.talent = talent;

			if (talent.isBeingResearched) then
				talentFrame.Cooldown:SetCooldownUNIX(talent.researchStartTime, talent.researchDuration);
				talentFrame.Cooldown:Show();
				talentFrame.CooldownBackground:Show();
				talentFrame.CooldownTimerBackground:Show();
				if (not talentFrame.timer) then
					talentFrame.timer = C_Timer.NewTicker(1, function() talentFrame:Refresh(); end);
				end
			end

			if (talent.selected) then
				talentFrame.Border:SetAtlas("orderhalltalents-spellborder-yellow");
				if (arrowTexture) then
					arrowTexture:SetAtlas("orderhalltalents-arrow-on");
				end
			elseif (talent.canBeResearched) then
				talentFrame.Border:SetAtlas("orderhalltalents-spellborder-green");
				if (arrowTexture) then
					arrowTexture:SetAtlas("orderhalltalents-arrow-on");
				end
			else
				talentFrame.Border:SetAtlas("orderhalltalents-spellborder");
				talentFrame.Icon:SetDesaturated(true);
			end
			talentFrame:SetPoint("TOPLEFT", xOffset, yOffset);
			talentFrame:Show();
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
		
		GameTooltip:AddLine(RESEARCH_TIME_LABEL..SecondsToTime(talent.researchDuration));
		if ((talent.researchCost and talent.researchCurrency) or talent.researchGoldCost) then
			local str = NORMAL_FONT_COLOR_CODE..COSTS_LABEL..FONT_COLOR_CODE_CLOSE;
			
			if (talent.researchCost and talent.researchCurrency) then
				local _, _, currencyTexture = GetCurrencyInfo(talent.researchCurrency);
				str = str.." "..talent.researchCost.."|T"..currencyTexture..":0:0:2:0|t";
			end
			if (talent.researchGoldCost ~= 0) then
				str = str.." "..talent.researchGoldCost.."|TINTERFACE\\MONEYFRAME\\UI-MoneyIcons.blp:16:16:2:0:64:16:0:16:0:16|t";
			end
			GameTooltip:AddLine(str, 1, 1, 1);
		end

		if talent.canBeResearched then
			GameTooltip:AddLine(TOOLTIP_TALENT_LEARN, 0, 1, 0);
		end
	end
	self.tooltip = GameTooltip;
	GameTooltip:Show();
end

function GarrisonTalentButtonMixin:OnLeave()
	GameTooltip_Hide();
	self.tooltip = nil;
end

function GarrisonTalentButtonMixin:OnClick()
	if (self.talent.canBeResearched) then
		C_Garrison.ResearchTalent(self.talent.id);
	end
end

function GarrisonTalentButtonMixin:OnReleased()
	self.Cooldown:SetCooldownDuration(0);
	self.Cooldown:Hide();
	self.CooldownBackground:Hide();
	self.CooldownTimerBackground:Hide();
	self.Icon:SetDesaturated(false);
	self.talent = nil;
	self.tooltip = nil;
	if (self.timer) then
		self.timer:Cancel();
		self.timer = nil;
	end
end

function GarrisonTalentButtonMixin:Refresh()
	if (self.talent and self.talent.id) then
	    self.talent = C_Garrison.GetTalent(self.talent.id);
	    if (self.tooltip) then
		    self:OnEnter();
	    end
	end
end