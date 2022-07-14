COMMUNITIES_GUILD_REWARDS_BUTTON_OFFSET = 0;
COMMUNITIES_GUILD_REWARDS_BUTTON_HEIGHT = 47;
COMMUNITIES_GUILD_REWARDS_ACHIEVEMENT_ICON = " |TInterface\\AchievementFrame\\UI-Achievement-Guild:18:16:0:1:512:512:324:344:67:85|t ";

function CommunitiesGuildRewardsFrame_OnLoad(self)
	self.RewardsContainer.update = function ()
		CommunitiesGuildRewards_Update(self);
	end;
	
	HybridScrollFrame_CreateButtons(self.RewardsContainer, "CommunitiesGuildRewardsButtonTemplate", 1, 0);
	self.RewardsContainer.scrollBar.doNotHide = true;
	self:RegisterEvent("GUILD_REWARDS_LIST");
end

function CommunitiesGuildRewardsFrame_OnShow(self)
	RequestGuildRewards();
end

function CommunitiesGuildRewardsFrame_OnHide(self)
	if ( self.DropDown.rewardIndex ) then
		CloseDropDownMenus();
	end
end

function CommunitiesGuildRewardsFrame_OnEvent(self, event)
	CommunitiesGuildRewards_Update(self);
end

function CommunitiesGuildRewards_Update(self)
	local scrollFrame = self.RewardsContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local button, index;
	local playerMoney = GetMoney();
	local numRewards = GetNumGuildRewards();
	local gender = UnitSex("player");
	local _, _, standingID = GetGuildFactionInfo();

	for i = 1, numButtons do
		button = buttons[i];
		index = offset + i;
		local achievementID, itemID, itemName, iconTexture, repLevel, moneyCost = GetGuildRewardInfo(index);
		if ( itemName ) then
			button.Name:SetText(itemName);
			button.Icon:SetTexture(iconTexture);
			button:Show();
			if ( moneyCost and moneyCost > 0 ) then
				MoneyFrame_Update(button.Money:GetName(), moneyCost);
				if ( playerMoney >= moneyCost ) then
					SetMoneyFrameColor(button.Money:GetName(), "white");
				else
					SetMoneyFrameColor(button.Money:GetName(), "red");
				end
				button.Money:Show();
			else
				button.Money:Hide();
			end
			if ( achievementID and achievementID > 0 ) then
				local id, name = GetAchievementInfo(achievementID)
				button.achievementID = achievementID;
				button.SubText:SetText(REQUIRES_LABEL..COMMUNITIES_GUILD_REWARDS_ACHIEVEMENT_ICON..YELLOW_FONT_COLOR_CODE..name..FONT_COLOR_CODE_CLOSE);
				button.SubText:Show();
				button.DisabledBG:Show();
				button.Icon:SetVertexColor(1, 1, 1);
				button.Icon:SetDesaturated(true);
				button.Name:SetFontObject(GameFontNormalLeftGrey);
				button.Lock:Show();
			else
				button.achievementID = nil;
				button.DisabledBG:Hide();
				button.Icon:SetDesaturated(false);
				button.Name:SetFontObject(GameFontNormal);
				button.Lock:Hide();
				if ( repLevel > standingID ) then
					local factionStandingtext = GetText("FACTION_STANDING_LABEL"..repLevel, gender);
					button.SubText:SetFormattedText(REQUIRES_GUILD_FACTION, factionStandingtext);
					button.SubText:Show();
					button.Icon:SetVertexColor(1, 0, 0);
				else
					button.SubText:Hide();
					button.Icon:SetVertexColor(1, 1, 1);
				end
			end
			button.index = index;
		else
			button:Hide();
		end
	end
	local totalHeight = numRewards * (COMMUNITIES_GUILD_REWARDS_BUTTON_HEIGHT + COMMUNITIES_GUILD_REWARDS_BUTTON_OFFSET);
	local displayedHeight = numButtons * (COMMUNITIES_GUILD_REWARDS_BUTTON_HEIGHT + COMMUNITIES_GUILD_REWARDS_BUTTON_OFFSET);
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
	
	-- hide dropdown menu
	if ( self.DropDown.rewardIndex ) then
		CloseDropDownMenus();
	end
	-- update tooltip
	if ( self.activeButton ) then
		CommunitiesGuildRewardsButton_OnEnter(self.activeButton);
	end	
end

function CommunitiesGuildRewardsButton_OnEnter(self)
	self:GetParent():GetParent():GetParent().activeButton = self;
	local achievementID, itemID, itemName, iconTexture, repLevel, moneyCost = GetGuildRewardInfo(self.index);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 28, 0);
	GameTooltip:SetHyperlink("item:"..itemID);
	if ( achievementID and achievementID > 0 ) then
		local id, name, _, _, _, _, _, description = GetAchievementInfo(achievementID)
		GameTooltip:AddLine(" ", 1, 0, 0, true);
		GameTooltip:AddLine(REQUIRES_GUILD_ACHIEVEMENT, 1, 0, 0, true);
		GameTooltip:AddLine(ACHIEVEMENT_COLOR_CODE..name..FONT_COLOR_CODE_CLOSE);
		GameTooltip:AddLine(description, 1, 1, 1, true);
	end
	local _, _, standingID = GetGuildFactionInfo();
	if ( repLevel > standingID ) then
		local gender = UnitSex("player");
		local factionStandingtext = GetText("FACTION_STANDING_LABEL"..repLevel, gender);
		GameTooltip:AddLine(" ", 1, 0, 0, true);
		GameTooltip:AddLine(string.format(REQUIRES_GUILD_FACTION_TOOLTIP, factionStandingtext), 1, 0, 0, true);
	end
	self.UpdateTooltip = CommunitiesGuildRewardsButton_OnEnter;
	GameTooltip:Show();
end

function CommunitiesGuildRewardsButton_OnLeave(self)
	GameTooltip:Hide();
	self:GetParent():GetParent():GetParent().activeButton = nil;
	self.UpdateTooltip = nil;
end

function CommunitiesGuildRewardsButton_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		local achievementID, itemID, itemName, iconTexture, repLevel, moneyCost = GetGuildRewardInfo(self.index);
		ChatEdit_LinkItem(itemID);
	elseif ( button == "RightButton" ) then
		local dropDown = self:GetParent():GetParent():GetParent().DropDown;
		if ( dropDown.rewardIndex ~= self.index ) then
			CloseDropDownMenus();
		end
		dropDown.rewardIndex = self.index;
		dropDown.onHide = function ()
			CommunitiesGuildRewardsDropDown_OnHide(dropDown);
		end;
		ToggleDropDownMenu(1, nil, dropDown, "cursor", 3, -3);
	end
end

--****** Dropdown **************************************************************

function CommunitiesGuildRewardsDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, CommunitiesGuildRewardsDropDown_Initialize, "MENU");
end

function CommunitiesGuildRewardsDropDown_Initialize(self)
	if ( not self.rewardIndex ) then
		return;
	end
	
	local achievementID, itemID, itemName, iconTexture, repLevel, moneyCost = GetGuildRewardInfo(self.rewardIndex);

	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = 1;
	info.isTitle = 1;
	info.text = itemName;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	info = UIDropDownMenu_CreateInfo();
	info.notCheckable = 1;

	info.func = function (button, ...) ChatEdit_LinkItem(...) end;
	info.text = GUILD_NEWS_LINK_ITEM;
	info.arg1 = itemID;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
		
	if ( achievementID and achievementID > 0 ) then
		info.func = function (button, ...) OpenAchievementFrameToAchievement(...); end;
		info.text = GUILD_NEWS_VIEW_ACHIEVEMENT;
		info.arg1 = achievementID;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	end
end

function CommunitiesGuildRewardsDropDown_OnHide(self)
	self.rewardIndex = nil;
end

CommunitiesGuildFactionBarMixin = {};

function CommunitiesGuildFactionBarMixin:OnShow()
	self:UpdateFaction();
	self:RegisterEvent("UPDATE_FACTION");
end

function CommunitiesGuildFactionBarMixin:OnHide()
	self:UnregisterEvent("UPDATE_FACTION");
end

function CommunitiesGuildFactionBarMixin:OnEnter()
	local name, description, standingID, barMin, barMax, barValue = GetGuildFactionInfo();
	
	--Normalize Values
	barMax = barMax - barMin;
	barValue = barValue - barMin;

	if barMax == 0 then
		barValue = 1;
		barMax = 1;
	end
	
	self.Label:SetText(GUILD_EXPERIENCE_LABEL:format(BreakUpLargeNumbers(barValue), BreakUpLargeNumbers(barMax)));
	
	local name, description = GetGuildFactionInfo();
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(GUILD_REPUTATION);
	GameTooltip:AddLine(description, 1, 1, 1, true);
	local percentTotal = math.ceil((barValue / barMax) * 100);
	GameTooltip:AddLine(GUILD_EXPERIENCE_CURRENT:format(BreakUpLargeNumbers(barValue), BreakUpLargeNumbers(barMax), percentTotal));
	GameTooltip:Show();
end

function CommunitiesGuildFactionBarMixin:OnLeave()
	local gender = UnitSex("player");
	local name, description, standingID, barMin, barMax, barValue = GetGuildFactionInfo();
	local factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID, gender);
	self.Label:SetText(factionStandingtext);
	GameTooltip:Hide();
end

function CommunitiesGuildFactionBarMixin:OnEvent(event)
	if event == "UPDATE_FACTION" then
		self:UpdateFaction();
	end
end

function CommunitiesGuildFactionBarMixin:UpdateFaction()
	local name, description, standingID, barMin, barMax, barValue = GetGuildFactionInfo();
	
	if not self:IsMouseOver() then
		local gender = UnitSex("player");
		local factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID, gender);
		self.Label:SetText(factionStandingtext);
	end
	
	--Normalize Values
	barMax = barMax - barMin;
	barValue = barValue - barMin;
	self:SetProgress(barValue, barMax);
end

function CommunitiesGuildFactionBarMixin:SetProgress(currentValue, maxValue)
	if maxValue == 0 then
		currentValue = 1;
		maxValue = 1;
	end

	local maxBarWidth = self:GetWidth() - 4;
	local progress = min(maxBarWidth * currentValue / maxValue, maxBarWidth);
	self.Progress:SetWidth(progress + 1);
	
	-- hide shadow on progress self near the right edge
	if progress > maxBarWidth - 4 then
		self.Shadow:Hide();
	else
		self.Shadow:Show();
	end
end

GuildAchievementPointDisplayMixin = {};

function GuildAchievementPointDisplayMixin:OnShow()
	self.SumText:SetText(BreakUpLargeNumbers(GetTotalAchievementPoints(true)));
	self:SetWidth(self.SumText:GetWidth() + self.Icon:GetWidth() + 20);
end

function GuildAchievementPointDisplayMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, GUILD_POINTS_TT);
	GameTooltip:Show();
end

function GuildAchievementPointDisplayMixin:OnMouseUp()
	if IsInGuild() and CanShowAchievementUI() then
		AchievementFrame_LoadUI();
		AchievementFrame_ToggleAchievementFrame(false, true);
	end
end
