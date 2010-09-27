local NEWS_MOTD = -1;				-- pseudo category
local NEWS_GUILD_ACHIEVEMENT = 0;
local NEWS_PLAYER_ACHIEVEMENT = 1;
local NEWS_DUNGEON_ENCOUNTER = 2;
local NEWS_ITEM_LOOTED = 3;
local NEWS_ITEM_CRAFTED = 4;
local NEWS_ITEM_PURCHASED = 5;
local NEWS_GUILD_LEVEL = 6;
local NEWS_GUILD_CREATE = 7;

function GuildNewsFrame_OnLoad(self)
	GuildFrame_RegisterPanel(self);
	self:RegisterEvent("GUILD_NEWS_UPDATE");
	self:RegisterEvent("GUILD_MOTD");
	local fontString = GuildNewsSetFiltersButton:GetFontString();
	GuildNewsSetFiltersButton:SetHeight(fontString:GetHeight() + 4);
	GuildNewsSetFiltersButton:SetWidth(fontString:GetWidth() + 4);
	GuildNewsContainer.update = GuildNews_Update;
	HybridScrollFrame_CreateButtons(GuildNewsContainer, "GuildNewsButtonTemplate", 0, 0);
end

function GuildNewsFrame_OnShow(self)
	GuildNewsSort(0);	-- normal sort, taking into account filters and stickies
end

function GuildNewsFrame_OnHide(self)
	if ( GuildNewsDropDown.newsIndex ) then
		CloseDropDownMenus();
	end
end

function GuildNewsFrame_OnEvent(self, event)
	if ( self:IsShown() ) then
		GuildNews_Update();
	end
end

function GuildNews_Update(frontPage, numButtons)
	local scrollFrame, offset, buttons, button, index;
	local numGuildNews = GetNumGuildNews();
	
	if ( frontPage ) then
		buttons = GuildMainFrame.buttons;
		offset = 0;
	else
		scrollFrame = GuildNewsContainer;
		offset = HybridScrollFrame_GetOffset(scrollFrame);
		buttons = scrollFrame.buttons;
		numButtons = #buttons;
	end

	-- motd is a fake sticky, will always be displayed at the very top of the list
	local haveMOTD = 0;
	local motd = GetGuildRosterMOTD();
	if ( motd ~= "" ) then
		haveMOTD = 1;
	end

	for i = 1, numButtons do
		button = buttons[i];
		-- adjust index (used for making GetGuildNewsInfo calls) for motd
		index = offset + i - haveMOTD;
		-- index 0 can only happen if we're at the top of the list and have motd 
		if ( index == 0 ) then
			button.text:SetPoint("LEFT", 24, 0);
			button.icon:Show();
			if ( button.icon.type ~= "motd" ) then
				button.icon.type = "motd";
				button.icon:SetWidth(16);
				button.icon:SetHeight(11);
				button.icon:SetTexture("Interface\\GuildFrame\\GuildExtra");
				button.icon:SetTexCoord(0.56640625, 0.59765625, 0.86718750, 0.95312500);
			end
			button.text:SetFormattedText(GUILD_NEWS_MOTD, motd);
			button.text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			button.dash:Hide();
			button.header:Hide();
			button.index = nil;
			button.newsType = NEWS_MOTD;
			button:Show();
		elseif ( index <= numGuildNews ) then
			local isSticky, isHeader, newsType, text1, text2, id, data, data2, weekday, day, month, year = GetGuildNewsInfo(index);
			if ( isHeader ) then
				-- TODO: remove once cheats are not needed
				if ( weekday == 0 ) then
					weekday = 7;
				end
				button.text:SetPoint("LEFT", 14, 0);
				button.text:SetFormattedText(GUILD_NEWS_DATE, CALENDAR_WEEKDAY_NAMES[weekday + 1], day + 1, month + 1);
				button.text:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				button.header:Show();
				button.icon:Hide();
				button.dash:Hide();
				button:Disable();
			else
				button.text:SetPoint("LEFT", 24, 0);
				if ( isSticky ) then
					button.icon:Show();
					if ( button.icon.type ~= "news" ) then
						button.icon.type = "news";
						button.icon:SetWidth(13);
						button.icon:SetHeight(11);
						button.icon:SetTexture("Interface\\GuildFrame\\GuildFrame");
						button.icon:SetTexCoord(0.41406250, 0.42675781, 0.96875000, 0.99023438);
					end
					button.dash:Hide();
				else
					button.icon:Hide();
					button.dash:Show();
				end
				text1 = text1 or UNKNOWN;
				button.index = index;
				button.newsType = newsType;
				button.id = id;
				if ( text2 and text2 ~= UNKNOWN ) then
					if ( newsType == NEWS_ITEM_LOOTED or newsType == NEWS_ITEM_CRAFTED or newsType == NEWS_ITEM_PURCHASED ) then
						local _, itemLink = GetItemInfo(id);
						if ( itemLink ) then
							text2 = itemLink;
						end
					elseif ( newsType == NEWS_PLAYER_ACHIEVEMENT ) then
						text2 = ACHIEVEMENT_COLOR_CODE.."["..text2.."]|r";
					elseif ( newsType == NEWS_GUILD_ACHIEVEMENT ) then
						text1 = ACHIEVEMENT_COLOR_CODE.."["..text2.."]|r";	-- only using achievement name
					elseif ( newsType == NEWS_DUNGEON_ENCOUNTER ) then
						text2 = "|cffd10000["..text2.."]|r";
					end
				elseif ( newsType ~= NEWS_GUILD_CREATE ) then
					-- no right-click menu or tooltip for unresolved news items
					button.index = nil;
					button.newsType = nil;
					text2 = UNKNOWN;
					if ( newsType == NEWS_GUILD_ACHIEVEMENT ) then
						text1 = text2;	-- only using achievement name
					end
				end
				button.text:SetFormattedText(_G["GUILD_NEWS_FORMAT"..newsType], text1, text2);
				button.text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				button.header:Hide();
				button:Enable();
			end
			button:Show();
		else
			button:Hide();
		end
	end
	
	-- update tooltip
	if ( GuildNewsFrame.activeButton ) then
		GuildNewsButton_OnEnter(GuildNewsFrame.activeButton);
	end

	-- hide dropdown menu
	if ( GuildNewsDropDown.newsIndex ) then
		CloseDropDownMenus();
	end
	
	if ( not frontPage ) then
		if ( numGuildNews == 0 and haveMOTD == 0 ) then
			GuildNewsFrameNoNews:Show();
		else
			GuildNewsFrameNoNews:Hide();
		end
		local totalHeight = (numGuildNews + haveMOTD) * scrollFrame.buttonHeight;
		local displayedHeight = numButtons * scrollFrame.buttonHeight;
		HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
		GuildFrame_UpdateScrollFrameWidth(scrollFrame);
	end
end

function GuildNewsButton_OnEnter(self)
	GuildNewsFrame.activeButton = self;
	GuildNewsBossModel:Hide();
	GameTooltip:Hide();
	local newsType = self.newsType;	
	if ( newsType == NEWS_ITEM_LOOTED or newsType == NEWS_ITEM_CRAFTED or newsType == NEWS_ITEM_PURCHASED ) then
		GuildNewsButton_AnchorTooltip(self);
		GameTooltip:SetHyperlink("item:"..self.id);
	elseif ( newsType == NEWS_PLAYER_ACHIEVEMENT or newsType == NEWS_GUILD_ACHIEVEMENT ) then
		local achievementId = self.id;
		local _, name, _, _, _, _, _, description = GetAchievementInfo(achievementId);
		GuildNewsButton_AnchorTooltip(self);
		GameTooltip:SetText(ACHIEVEMENT_COLOR_CODE..name);
		GameTooltip:AddLine(description, 1, 1, 1, 1);
		local firstCriteria = true;
		local leftCriteria;
		for i = 1, GetAchievementNumCriteria(achievementId) do
			local criteriaString, _, _, _, _, _, flags = GetAchievementCriteriaInfo(achievementId, i);
			-- skip progress bars
			if ( bit.band(flags, ACHIEVEMENT_CRITERIA_PROGRESS_BAR) ~= ACHIEVEMENT_CRITERIA_PROGRESS_BAR ) then
				if ( leftCriteria ) then
					if ( firstCriteria ) then
						GameTooltip:AddLine(" ");
						firstCriteria = false;
					end
					GameTooltip:AddDoubleLine(leftCriteria, criteriaString, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8);
					leftCriteria = nil;
				else
					leftCriteria = criteriaString;
				end
			end
		end
		-- check for leftover criteria
		if ( leftCriteria ) then
			if ( firstCriteria ) then
				GameTooltip:AddLine(" ");
			end	
			GameTooltip:AddLine(leftCriteria, 0.8, 0.8, 0.8);
		end
		GameTooltip:Show();
	elseif ( newsType == NEWS_DUNGEON_ENCOUNTER ) then
		local isSticky, isHeader, newsType, text1, text2, id, data1, data2 = GetGuildNewsInfo(self.index);
		local zone = GetRealZoneText(data1);
		if ( data2 and data2 > 0 ) then
			GuildNewsBossModel:Show();
			GuildNewsBossModel:SetDisplayInfo(data2);
			GuildNewsBossNameText:SetText(text2);
			GuildNewsBossLocationText:SetText(zone);
		else
			GuildNewsButton_AnchorTooltip(self);
			GameTooltip:SetText(text2);
			GameTooltip:AddLine(zone, 1, 1, 1);
			GameTooltip:Show();
		end
	elseif ( newsType == NEWS_MOTD ) then
		if ( self.text:IsTruncated() ) then
			GuildNewsButton_AnchorTooltip(self);
			GameTooltip:SetText(GUILD_MOTD_LABEL);
			GameTooltip:AddLine(GetGuildRosterMOTD(), 1, 1, 1, 1);
			GameTooltip:Show();
		end
	end
end

function GuildNewsButton_AnchorTooltip(self)
	if ( GuildNewsContainer.wideButtons or GuildMainFrame:IsShown() ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 8, 0);
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 30, 0);
	end
end

function GuildNewsButton_OnClick(self, button)
	if ( button == "RightButton" ) then
		local dropDown = GuildNewsDropDown;
		if ( dropDown.newsIndex ~= self.index ) then
			CloseDropDownMenus();
		end
		dropDown.newsIndex = self.index;
		dropDown.onHide = GuildNewsDropDown_OnHide;
		ToggleDropDownMenu(1, nil, dropDown, "cursor", 3, -3);
	end
end

function GuildNewsButton_OnLeave(self)
	GuildNewsFrame.activeButton = nil;
	GameTooltip:Hide();
	GuildNewsBossModel:Hide();
end

--****** Dropdown **************************************************************

function GuildNewsDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, GuildNewsDropDown_Initialize, "MENU");
end

function GuildNewsDropDown_Initialize(self)
	if ( not self.newsIndex ) then
		return;
	end
	
	local isSticky, isHeader, newsType, text1, text2, id, data, data2, weekday, day, month, year = GetGuildNewsInfo(self.newsIndex);
	-- we don't have any options for these combinations
	if ( ( newsType == NEWS_DUNGEON_ENCOUNTER or newsType == NEWS_GUILD_LEVEL or newsType == NEWS_GUILD_CREATE ) and not CanEditMOTD() ) then
		return;
	end

	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = 1;
	info.isTitle = 1;
	if ( newsType == NEWS_GUILD_LEVEL ) then
		info.text = string.format(GUILD_LEVEL, text2);
	elseif ( newsType == NEWS_GUILD_CREATE ) then
		info.text = GUILD_CREATION;
	else
		info.text = text2;
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);	
	info = UIDropDownMenu_CreateInfo();
	info.notCheckable = 1;

	if ( newsType == NEWS_PLAYER_ACHIEVEMENT or newsType == NEWS_GUILD_ACHIEVEMENT ) then
		info.func = GuildFrame_OpenAchievement;
		info.text = GUILD_NEWS_VIEW_ACHIEVEMENT;
		info.arg1 = id;	
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	elseif ( newsType == NEWS_ITEM_LOOTED or newsType == NEWS_ITEM_CRAFTED or newsType == NEWS_ITEM_PURCHASED ) then
		info.func = GuildFrame_LinkItem;
		info.text = GUILD_NEWS_LINK_ITEM;
		info.arg1 = id;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	end
	if ( CanEditMOTD() ) then
		info.arg1 = self.newsIndex;
		if ( isSticky ) then
			info.text = GUILD_NEWS_REMOVE_STICKY;
			info.arg2 = 0;
		else
			info.text = GUILD_NEWS_MAKE_STICKY;
			info.arg2 = 1;
		end
		info.func = GuildNewsDropDown_SetSticky;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	end
end

function GuildNewsDropDown_OnHide(self)
	GuildNewsDropDown.newsIndex = nil;
end

function GuildNewsDropDown_SetSticky(button, newsIndex, value)
	GuildNewsSetSticky(newsIndex, value);
end

--****** Popup *****************************************************************

function GuildNewsFiltersFrame_OnLoad(self)
	GuildFrame_RegisterPopup(self);
	for i = 1, 7 do
		_G["GuildNewsFilterButton"..i.."Text"]:SetText(_G["GUILD_NEWS_FILTER"..i]);
	end
end

function GuildNewsFiltersFrame_OnShow(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	local filters = { GetGuildNewsFilters() };
	for i = 1, #filters do
		-- skip 8th flag - guild creation
		local checkbox = _G["GuildNewsFilterButton"..i];
		if ( checkbox ) then
			if ( filters[i] ) then
				checkbox:SetChecked(true);
			else
				checkbox:SetChecked(false);
			end
		end
	end
end

function GuildNewsFilter_OnClick(self)
	local setting;
	if ( self:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
		setting = 1;
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
		setting = 0;
	end
	SetGuildNewsFilter(self:GetID(), setting);
end