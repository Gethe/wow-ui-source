GUILD_REWARDS_BUTTON_OFFSET = 0;
GUILD_REWARDS_BUTTON_HEIGHT = 47;
local currentRewardsView = "";

function GuildRewardsFrame_OnLoad(self)
	GuildFrame_RegisterPanel(self);
	GuildRewardsContainer.update = GuildRewards_Update;
	HybridScrollFrame_CreateButtons(GuildRewardsContainer, "GuildRewardsButtonTemplate", 1, 0, "TOPLEFT", "TOPLEFT", 0, -GUILD_REWARDS_BUTTON_OFFSET, "TOP", "BOTTOM");

	--GuildRewards_Update();
end

function GuildRewards_Update()
	local scrollFrame = GuildRewardsContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local button, index
	local playerMoney = GetMoney();
	
	for i = 1, numButtons do
		button = buttons[i];
		index = offset + i;
		if ( _GuildRewards[index] ) then
			button.name:SetText(_GuildRewards[index].name);
			if ( _GuildRewards[index].rep == 1 ) then
				button.subText:SetText("Requires: "..NORMAL_FONT_COLOR_CODE.."Friendly");
			elseif ( _GuildRewards[index].rep == 2 ) then
				button.subText:SetText("Requires: "..NORMAL_FONT_COLOR_CODE.."Honored");
			elseif ( _GuildRewards[index].rep == 3 ) then
				button.subText:SetText("Requires: "..RED_FONT_COLOR_CODE.."Revered");
			elseif ( _GuildRewards[index].rep == 4 ) then
				button.subText:SetText("Requires: "..RED_FONT_COLOR_CODE.."Exalted");
			end
			button.icon:SetTexture(_GuildRewards[index].icon);
			button:Show();
			local moneyCost = _GuildRewards[index].cost;
			if ( moneyCost and moneyCost > 0 ) then
				MoneyFrame_Update(button.money:GetName(), moneyCost);
				if ( playerMoney >= moneyCost ) then
					SetMoneyFrameColor(button.money:GetName(), "white");
				else
					SetMoneyFrameColor(button.money:GetName(), "red");
					unavailable = true;
				end
			end
			if ( _GuildRewards[index].locked ) then
				button.disabledBG:Show();
				button.icon:SetDesaturated(1);
				button.name:SetFontObject(GameFontNormalLeftGrey);
				button.lock:Show();
			else
				button.disabledBG:Hide();
				button.icon:SetDesaturated(0);
				button.name:SetFontObject(GameFontNormal);
				button.lock:Hide();
			end
		else
			button:Hide();
		end
	end
	local totalHeight = #_GuildRewards * (GUILD_REWARDS_BUTTON_HEIGHT + GUILD_REWARDS_BUTTON_OFFSET);
	local displayedHeight = numButtons * (GUILD_REWARDS_BUTTON_HEIGHT + GUILD_REWARDS_BUTTON_OFFSET);
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
end

function GuildRewardsViewDropdown_OnLoad(self)
	UIDropDownMenu_Initialize(self, GuildRewardsViewDropdown_Initialize);
	UIDropDownMenu_SetWidth(GuildRewardsViewDropdown, 120);
end

function GuildRewardsViewDropdown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.func = GuildRewardsViewDropdown_OnClick;
	
	info.text = "All Rewards";
	info.value = "";
	UIDropDownMenu_AddButton(info);
	info.text = "Some Rewards";
	info.value = "some";
	UIDropDownMenu_AddButton(info);	
	info.text = "No Rewards";
	info.value = "none";
	UIDropDownMenu_AddButton(info);
	
	UIDropDownMenu_SetSelectedValue(GuildRewardsViewDropdown, currentRewardsView);
end

function GuildRewardsViewDropdown_OnClick(self)
	--GuildRewards_Update();
	currentRewardsView = self.value;
	UIDropDownMenu_SetSelectedValue(GuildRewardsViewDropdown, currentRewardsView);
end
