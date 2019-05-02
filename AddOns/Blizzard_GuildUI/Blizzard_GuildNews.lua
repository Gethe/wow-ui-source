function GuildNewsFrame_OnLoad(self)
	GuildFrame_RegisterPanel(self);
	self:RegisterEvent("GUILD_NEWS_UPDATE");
	self:RegisterEvent("GUILD_MOTD");
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	local fontString = GuildNewsSetFiltersButton:GetFontString();
	GuildNewsSetFiltersButton:SetHeight(fontString:GetHeight() + 4);
	GuildNewsSetFiltersButton:SetWidth(fontString:GetWidth() + 4);
	GuildNewsContainer.update = GuildNews_Update;
	HybridScrollFrame_CreateButtons(GuildNewsContainer, "GuildNewsButtonTemplate", 0, 0);
	
	if ( GetGuildFactionGroup() == 0 ) then  -- horde
		GUILD_EVENT_TEXTURES[CALENDAR_EVENTTYPE_PVP] = "Interface\\Calendar\\UI-Calendar-Event-PVP01";
	else  -- alliance
		GUILD_EVENT_TEXTURES[CALENDAR_EVENTTYPE_PVP] = "Interface\\Calendar\\UI-Calendar-Event-PVP02";
	end
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

function GuildNews_Update()
	-- check to display impeach frame
	if ( CanReplaceGuildMaster() ) then
		GuildGMImpeachButton:Show();
		GuildNewsContainer:SetPoint("TOPLEFT", GuildGMImpeachButton, "BOTTOMLEFT", 0, 0);
		GuildNewsContainer:SetHeight(277);
	else
		GuildGMImpeachButton:Hide();
		GuildNewsContainer:SetPoint("TOPLEFT", GuildNewsFrameHeader, "BOTTOMLEFT", 0, 0);
		GuildNewsContainer:SetHeight(287);
	end
	
	local motd = GetGuildRosterMOTD();
	local scrollFrame = GuildNewsContainer;
	local haveMOTD = motd ~= "" and 1 or 0;	
	local buttons = scrollFrame.buttons;
	local button, index;
	
	local numEvents = math.min(7, C_Calendar.GetNumGuildEvents());
	local numNews = GetNumGuildNews();
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local numButtons = #buttons;
	for i = 1, numButtons do
		button = buttons[i];
		button.icon:Hide();
		button.dash:Hide();
		button.header:Hide();
		button:Show();
		button:Enable();
		button.newsInfo = nil;
		index = offset + i;
		if( index == haveMOTD ) then
			GuildNewsButton_SetMOTD(button, motd);
		elseif( index <= numEvents + haveMOTD ) then
			GuildNewsButton_SetEvent(button, index - haveMOTD);
		elseif( index <= numEvents + haveMOTD + numNews  ) then
			GuildNewsButton_SetNews( button, index - haveMOTD - numEvents  );
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
	
	if ( numNews == 0 and haveMOTD == 0 and numEvents == 0 ) then
		GuildNewsFrameNoNews:Show();
	else
		GuildNewsFrameNoNews:Hide();
	end
	local totalHeight = (numNews + haveMOTD + numEvents) * scrollFrame.buttonHeight;
	local displayedHeight = numButtons * scrollFrame.buttonHeight;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
	GuildFrame_UpdateScrollFrameWidth(scrollFrame);
end

local SIX_DAYS = 6 * 24 * 60 * 60		-- time in seconds
function GuildNewsButton_SetEvent( button, event_id )
	local today = date("*t");
	local info = C_Calendar.GetGuildEventInfo(event_id);
	local month = info.month;
	local day = info.monthDay;
	local weekday = info.weekday;
	local hour = info.hour;
	local minute = info.minute;
	local eventType = info.eventType;
	local title = info.title;
	local calendarType = info.calendarType;
	local texture = info.texture;
	local displayTime = GameTime_GetFormattedTime(hour, minute, true);
	local displayDay;
	
	if ( today["day"] == day and today["month"] == month ) then
		displayDay = NORMAL_FONT_COLOR_CODE..GUILD_EVENT_TODAY..FONT_COLOR_CODE_CLOSE;
	else
		local year = today["year"];
		-- if in December and looking at an event in January
		if ( month < today["month"] ) then
			year = year + 1;
		end
		-- display the day or the date
		local eventTime = time{year = year, month = month, day = day};
		if ( eventTime - time() < SIX_DAYS ) then
			displayDay = CALENDAR_WEEKDAY_NAMES[weekday];
		else
			displayDay = string.format(GUILD_NEWS_DATE, CALENDAR_WEEKDAY_NAMES[weekday], day, month);
		end
	end
	GuildNewsButton_SetText(button, HIGHLIGHT_FONT_COLOR, GUILD_EVENT_FORMAT, displayDay, displayTime, title);
	
	button.text:SetPoint("LEFT", 24, 0);
	GuildNewsButton_SetIcon( button, texture);	
	button.index = event_id;
	button.newsType = NEWS_GUILD_EVENT;

	button.isEvent = true;
end

function GuildNewsButton_OnEnter(self)
	if not self.newsInfo then
		return;
	end

	GuildNewsFrame.activeButton = self;
	GuildNewsBossModel:Hide();
	GameTooltip:Hide();
	local newsType = self.newsType;
	self.UpdateTooltip = nil;
	if ( newsType == NEWS_ITEM_LOOTED or newsType == NEWS_ITEM_CRAFTED or newsType == NEWS_ITEM_PURCHASED or newsType == NEWS_LEGENDARY_LOOTED ) then
		GuildNewsButton_AnchorTooltip(self);
		GameTooltip:SetHyperlink(self.newsInfo.whatText);
		self.UpdateTooltip = GuildNewsButton_OnEnter;
	elseif ( newsType == NEWS_PLAYER_ACHIEVEMENT or newsType == NEWS_GUILD_ACHIEVEMENT ) then
		local achievementId = self.id;
		local _, name, _, _, _, _, _, description = GetAchievementInfo(achievementId);
		GuildNewsButton_AnchorTooltip(self);
		GameTooltip:SetText(ACHIEVEMENT_COLOR_CODE..name..FONT_COLOR_CODE_CLOSE);
		GameTooltip:AddLine(description, 1, 1, 1, true);
		local firstCriteria = true;
		local leftCriteria;
		for i = 1, GetAchievementNumCriteria(achievementId) do
			local criteriaString, _, _, _, _, _, flags = GetAchievementCriteriaInfo(achievementId, i);
			-- skip progress bars
			if ( bit.band(flags, EVALUATION_TREE_FLAG_PROGRESS_BAR) ~= EVALUATION_TREE_FLAG_PROGRESS_BAR ) then
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
		local zone = GetRealZoneText(self.newsInfo.data[1]);
		if ( self.newsInfo.data[2] and self.newsInfo.data[2] > 0 ) then
			GuildNewsBossModel:Show();
			GuildNewsBossModel:SetDisplayInfo(self.newsInfo.data[2]);
			GuildNewsBossNameText:SetText(self.newsInfo.whatText);
			GuildNewsBossLocationText:SetText(zone);
		else
			GuildNewsButton_AnchorTooltip(self);
			GameTooltip:SetText(self.newsInfo.whatText);
			GameTooltip:AddLine(zone, 1, 1, 1);
			GameTooltip:Show();
		end
	elseif ( newsType == NEWS_MOTD ) then
		if ( self.text:IsTruncated() ) then
			GuildNewsButton_AnchorTooltip(self);
			GameTooltip:SetText(GUILD_MOTD_LABEL);
			GameTooltip:AddLine(GetGuildRosterMOTD(), 1, 1, 1, true);
			GameTooltip:Show();
		end
	end
end

function GuildNewsButton_AnchorTooltip(self)
	if ( GuildNewsContainer.wideButtons ) then
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
	if not self.newsInfo then
		return;
	end
	
	-- we don't have any options for these combinations
	if ( ( self.newsInfo.newsType == NEWS_DUNGEON_ENCOUNTER or self.newsInfo.newsType == NEWS_GUILD_LEVEL or self.newsInfo.newsType == NEWS_GUILD_CREATE ) and not CanEditMOTD() ) then
		return;
	end

	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = 1;
	info.isTitle = 1;
	if ( self.newsInfo.newsType == NEWS_GUILD_CREATE ) then
		info.text = GUILD_CREATION;
	else
		info.text = self.newsInfo.whatText;
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);	
	info = UIDropDownMenu_CreateInfo();
	info.notCheckable = 1;

	if ( self.newsInfo.newsType == NEWS_PLAYER_ACHIEVEMENT or self.newsInfo.newsType == NEWS_GUILD_ACHIEVEMENT ) then
		info.func = GuildFrame_OpenAchievement;
		info.text = GUILD_NEWS_VIEW_ACHIEVEMENT;
		info.arg1 = self.newsInfo.newsDataID;	
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	elseif ( self.newsInfo.newsType == NEWS_ITEM_LOOTED or self.newsInfo.newsType == NEWS_ITEM_CRAFTED or self.newsInfo.newsType == NEWS_ITEM_PURCHASED ) then
		info.func = GuildFrame_LinkItem;
		info.text = GUILD_NEWS_LINK_ITEM;
		info.arg1 = self.newsInfo.newsDataID;
		info.arg2 = self.newsInfo.whatText;	-- whatText has the hyperlink text
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	end
	if ( CanEditMOTD() ) then
		info.arg1 = self.newsIndex;
		if ( self.newsInfo.isSticky ) then
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
	GuildNewsDropDown.newsInfo = nil;
end

function GuildNewsDropDown_SetSticky(button, newsIndex, value)
	GuildNewsSetSticky(newsIndex, value);
end

--****** Popup *****************************************************************

function GuildNewsFiltersFrame_OnLoad(self)
	GuildFrame_RegisterPopup(self);
	for _, filterButton in ipairs(self.GuildNewsFilterButtons) do
		filterButton.Text:SetText(_G["GUILD_NEWS_FILTER"..filterButton:GetID()]);
	end
end

function GuildNewsFiltersFrame_OnShow(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	local filters = { GetGuildNewsFilters() };
	for i = 1, #filters do
		-- skip 8th flag - guild creation
		local checkbox = self.GuildNewsFilterButtons[i];
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
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		setting = 1;
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		setting = 0;
	end
	SetGuildNewsFilter(self:GetID(), setting);
end