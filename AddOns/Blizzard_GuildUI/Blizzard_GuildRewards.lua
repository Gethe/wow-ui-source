local GUILD_REWARDS_BUTTON_OFFSET = 0;
local GUILD_REWARDS_BUTTON_HEIGHT = 47;

function GuildRewardsFrame_OnLoad(self)
	GuildFrame_RegisterPanel(self);
	GuildRewardsContainer.update = GuildRewards_Update;
	HybridScrollFrame_CreateButtons(GuildRewardsContainer, "GuildRewardsButtonTemplate", 1, 0);
	GuildRewardsContainerScrollBar.doNotHide = true;
	self:RegisterEvent("GUILD_REWARDS_LIST");
end

function GuildRewardsFrame_OnShow(self)
	RequestGuildRewards();
end

function GuildRewardsFrame_OnHide(self)
	if ( GuildRewardsDropDown.rewardIndex ) then
		CloseDropDownMenus();
	end
end

function GuildRewardsFrame_OnEvent(self, event)
	GuildRewards_Update();
end

function GuildRewards_Update()
	local scrollFrame = GuildRewardsContainer;
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
			button.name:SetText(itemName);
			button.icon:SetTexture(iconTexture);
			button:Show();
			if ( moneyCost and moneyCost > 0 ) then
				MoneyFrame_Update(button.money:GetName(), moneyCost);
				if ( playerMoney >= moneyCost ) then
					SetMoneyFrameColor(button.money:GetName(), "white");
				else
					SetMoneyFrameColor(button.money:GetName(), "red");
				end
			end
			if ( achievementID and achievementID > 0 ) then
				local id, name = GetAchievementInfo(achievementID)
				button.achievement:Show();
				button.achievementID = achievementID;
				button.achievement.text:SetText(name);
				button.disabledBG:Show();
				button.icon:SetVertexColor(1, 1, 1);
				button.icon:SetDesaturated(1);
				button.name:SetFontObject(GameFontNormalLeftGrey);
				button.lock:Show();
				button.subText:Hide();
			else
				button.achievement:Hide();
				button.achievementID = nil;
				button.disabledBG:Hide();
				button.icon:SetDesaturated(0);
				button.name:SetFontObject(GameFontNormal);
				button.lock:Hide();
				if ( repLevel > standingID ) then
					local factionStandingtext = GetText("FACTION_STANDING_LABEL"..repLevel, gender);
					button.subText:SetFormattedText(REQUIRES_GUILD_FACTION, factionStandingtext);
					button.subText:Show();
					button.icon:SetVertexColor(1, 0, 0);
				else
					button.subText:Hide();
					button.icon:SetVertexColor(1, 1, 1);
				end
			end
			button.index = index;
		else
			button:Hide();
		end
	end
	local totalHeight = numRewards * (GUILD_REWARDS_BUTTON_HEIGHT + GUILD_REWARDS_BUTTON_OFFSET);
	local displayedHeight = numButtons * (GUILD_REWARDS_BUTTON_HEIGHT + GUILD_REWARDS_BUTTON_OFFSET);
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
	
	-- hide dropdown menu
	if ( GuildRewardsDropDown.rewardIndex ) then
		CloseDropDownMenus();
	end
	-- update tooltip
	if ( GuildRewardsFrame.activeButton ) then
		GuildRewardsButton_OnEnter(GuildRewardsFrame.activeButton);
	end	
end

function GuildRewardsButton_OnEnter(self)
	GuildRewardsFrame.activeButton = self;
	local achievementID, itemID, itemName, iconTexture, repLevel, moneyCost = GetGuildRewardInfo(self.index);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 28, 0);
	GameTooltip:SetHyperlink("item:"..itemID);
	if ( achievementID and achievementID > 0 ) then
		local id, name, _, _, _, _, _, description = GetAchievementInfo(achievementID)
		GameTooltip:AddLine(" ", 1, 0, 0, 1);
		GameTooltip:AddLine(REQUIRES_GUILD_ACHIEVEMENT, 1, 0, 0, 1);
		GameTooltip:AddLine(ACHIEVEMENT_COLOR_CODE..name);
		GameTooltip:AddLine(description, 1, 1, 1, 1);
	end
	GameTooltip:Show();
end

function GuildRewardsButton_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		local achievementID, itemID, itemName, iconTexture, repLevel, moneyCost = GetGuildRewardInfo(self.index);
		GuildFrame_LinkItem(_, itemID);
	elseif ( button == "RightButton" ) then
		local dropDown = GuildRewardsDropDown;
		if ( dropDown.rewardIndex ~= self.index ) then
			CloseDropDownMenus();
		end
		dropDown.rewardIndex = self.index;
		dropDown.onHide = GuildRewardsDropDown_OnHide;
		ToggleDropDownMenu(1, nil, dropDown, "cursor", 3, -3);
	end
end

--****** Dropdown **************************************************************

function GuildRewardsDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, GuildRewardsDropDown_Initialize, "MENU");
end

function GuildRewardsDropDown_Initialize(self)
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

	info.func = GuildFrame_LinkItem;
	info.text = GUILD_NEWS_LINK_ITEM;
	info.arg1 = itemID;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
		
	if ( achievementID and achievementID > 0 ) then
		info.func = GuildFrame_OpenAchievement;
		info.text = GUILD_NEWS_VIEW_ACHIEVEMENT;
		info.arg1 = achievementID;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	end
end

function GuildRewardsDropDown_OnHide(self)
	GuildRewardsDropDown.rewardIndex = nil;
end