local function IsLootNews(newsType)
	return newsType == NEWS_ITEM_LOOTED or newsType == NEWS_ITEM_CRAFTED or newsType == NEWS_ITEM_PURCHASED or newsType == NEWS_LEGENDARY_LOOTED;
end

CommunitiesGuildNewsButtonMixin = {};

function CommunitiesGuildNewsButtonMixin:Init(elementData)
	self.newsInfo = nil;
	self.icon:Hide();
	self.dash:Hide();
	self.header:Hide();
	self:Enable();

	if elementData.motd then
		GuildNewsButton_SetMOTD(self, elementData.motd);
	elseif elementData.event then
		CommunitiesGuildNewsButton_SetEvent(self, elementData.index);
	elseif elementData.news then
		GuildNewsButton_SetNews(self, elementData.index);
	end
end

function CommunitiesGuildNewsFrame_OnLoad(self)
	QueryGuildNews();
	self:RegisterEvent("GUILD_NEWS_UPDATE");
	self:RegisterEvent("GUILD_MOTD");
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	local fontString = self.SetFiltersButton:GetFontString();
	self.SetFiltersButton:SetHeight(fontString:GetHeight() + 4);
	self.SetFiltersButton:SetWidth(fontString:GetWidth() + 4);

	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("CommunitiesGuildNewsButtonTemplate", function(button, elementData)
		button:Init(elementData);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	if ( GetGuildFactionGroup() == 0 ) then  -- horde
		GUILD_EVENT_TEXTURES[Enum.CalendarEventType.PvP] = "Interface\\Calendar\\UI-Calendar-Event-PVP01";
	else  -- alliance
		GUILD_EVENT_TEXTURES[Enum.CalendarEventType.PvP] = "Interface\\Calendar\\UI-Calendar-Event-PVP02";
	end
end

function CommunitiesGuildNewsFrame_OnShow(self)
	GuildNewsSort(0);	-- normal sort, taking into account filters and stickies
end

function CommunitiesGuildNewsFrame_OnEvent(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		QueryGuildNews();
	else
		if ( self:IsShown() ) then
			CommunitiesGuildNews_Update(self);
		end
	end
end

function CommunitiesGuildNews_Update(self)
	-- check to display impeach frame
	if ( CanReplaceGuildMaster() ) then
		self.GMImpeachButton:Show();
		self.ScrollBox:SetPoint("TOPLEFT", self.GMImpeachButton, "BOTTOMLEFT", 0, 0);
		self.ScrollBox:SetHeight(290);
	else
		self.GMImpeachButton:Hide();
		self.ScrollBox:SetPoint("TOPLEFT", self.Header, "BOTTOMLEFT", 0, 0);
		self.ScrollBox:SetHeight(306);
	end
	
	local dataProvider = CreateDataProvider();
	local motd = GetGuildRosterMOTD();
	if motd ~= "" then
		dataProvider:Insert({motd=motd});
	end

	local events = C_Calendar.GetNumGuildEvents();
	for index = 1, math.min(7, events) do
		dataProvider:Insert({index=index, event=true});
	end

	for index = 1, GetNumGuildNews() do
		dataProvider:Insert({index=index, news=true});
	end
	self.ScrollBox:SetDataProvider(dataProvider);

	-- update tooltip
	if ( self.activeButton ) then
		CommunitiesGuildNewsButton_OnEnter(self.activeButton);
	end

	if ( numNews == 0 and haveMOTD == 0 and numEvents == 0 ) then
		self.NoNews:Show();
	else
		self.NoNews:Hide();
	end
end

local SIX_DAYS = 6 * 24 * 60 * 60		-- time in seconds
function CommunitiesGuildNewsButton_SetEvent( button, event_id )
	local today = date("*t");
	local guildEventInfo  = C_Calendar.GetGuildEventInfo(event_id);
	local day = guildEventInfo.monthDay;
	local month = guildEventInfo.month;
	local weekday = guildEventInfo.weekday;
	local hour = guildEventInfo.hour;
	local minute = guildEventInfo.minute;
	local title = guildEventInfo.title;
	local texture = guildEventInfo.texture;

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

function CommunitiesGuildNewsButton_OnEnter(self)
	if not self.newsInfo then
		return;
	end

	local guildNewsFrame = self:GetParent():GetParent():GetParent();
	local bossModel = guildNewsFrame.BossModel;
	self.activeButton = self;
	bossModel:Hide();
	GameTooltip:Hide();
	local newsType = self.newsType;
	self.UpdateTooltip = nil;
	if ( IsLootNews(newsType) ) then
		CommunitiesGuildNewsButton_AnchorTooltip(self);
		GameTooltip:SetHyperlink(self.newsInfo.whatText);
		self.UpdateTooltip = CommunitiesGuildNewsButton_OnEnter;
	elseif ( newsType == NEWS_PLAYER_ACHIEVEMENT or newsType == NEWS_GUILD_ACHIEVEMENT ) then
		local achievementId = self.id;
		local _, name, _, _, _, _, _, description = GetAchievementInfo(achievementId);
		CommunitiesGuildNewsButton_AnchorTooltip(self);
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
			bossModel:Show();
			bossModel:SetDisplayInfo(self.newsInfo.data[2]);
			bossModel.BossName:SetText(self.newsInfo.whatText);
			bossModel.TextFrame.BossLocationText:SetText(zone);
		else
			CommunitiesGuildNewsButton_AnchorTooltip(self);
			GameTooltip:SetText(self.newsInfo.whatText);
			GameTooltip:AddLine(zone, 1, 1, 1);
			GameTooltip:Show();
		end
	elseif ( newsType == NEWS_MOTD ) then
		if ( self.text:IsTruncated() ) then
			CommunitiesGuildNewsButton_AnchorTooltip(self);
			GameTooltip:SetText(GUILD_MOTD_LABEL);
			GameTooltip:AddLine(GetGuildRosterMOTD(), 1, 1, 1, true);
			GameTooltip:Show();
		end
	end
end

function CommunitiesGuildNewsButton_AnchorTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
end

function CommunitiesGuildEventButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		if ( CalendarFrame ) then
			CalendarFrame_OpenToGuildEventIndex(self.index);
		else
			ToggleCalendar();
			CalendarFrame_OpenToGuildEventIndex(self.index);
		end
	end
end

function CommunitiesGuildNewsButton_OnClick(self, button)
	if ( button == "RightButton" ) then
		-- we don't have any options for these combinations
		local newsType = self.newsInfo.newsType;
		if (newsType == NEWS_DUNGEON_ENCOUNTER) or (newsType == NEWS_GUILD_LEVEL) or (newsType == NEWS_GUILD_CREATE) and (not CanEditMOTD()) then
			return;
		end

		MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
			rootDescription:SetTag("MENU_GUILD_NEWS");

			local titleText = (newsType == NEWS_GUILD_CREATE) and GUILD_CREATION or self.newsInfo.whatText;
			rootDescription:CreateTitle(titleText);

			if (newsType == NEWS_PLAYER_ACHIEVEMENT) or (newsType == NEWS_GUILD_ACHIEVEMENT) then
				rootDescription:CreateButton(GUILD_NEWS_VIEW_ACHIEVEMENT, function()
					OpenAchievementFrameToAchievement(self.newsInfo.newsDataID);
				end);
			elseif IsLootNews(newsType) then
				rootDescription:CreateButton(GUILD_NEWS_VIEW_ACHIEVEMENT, function()
					-- whatText has the hyperlink text
					ChatEdit_LinkItem(self.newsInfo.newsDataID, self.newsInfo.whatText);
				end);
			end

			if CanEditMOTD() then
				if self.newsInfo.isSticky then
					rootDescription:CreateButton(GUILD_NEWS_REMOVE_STICKY, function()
						GuildNewsSetSticky(self.index, 0);
					end);
				else
					rootDescription:CreateButton(GUILD_NEWS_MAKE_STICKY, function()
						GuildNewsSetSticky(self.index, 1);
					end);
				end
			end
		end);
	end
end

function CommunitiesGuildNewsButton_OnLeave(self)
	self.activeButton = nil;
	GameTooltip:Hide();

	local guildNewsFrame = self:GetParent():GetParent():GetParent();
	guildNewsFrame.BossModel:Hide();
end

--****** Popup *****************************************************************

function CommunitiesGuildNewsFiltersFrame_OnLoad(self)
	for _, filterButton in ipairs(self.GuildNewsFilterButtons) do
		filterButton.Text:SetText(_G["GUILD_NEWS_FILTER"..filterButton:GetID()]);
	end
end

function CommunitiesGuildNewsFiltersFrame_OnShow(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	local filters = { GetGuildNewsFilters() };
	for i, checkbox in ipairs(self.GuildNewsFilterButtons) do
		if ( filters[checkbox:GetID()] ) then
			checkbox:SetChecked(true);
		else
			checkbox:SetChecked(false);
		end
	end

	CommunitiesGuildNewsFiltersFrame_HideInvalidFilters(self);
end

function CommunitiesGuildNewsFilter_OnClick(self)
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

function CommunitiesGuildNewsFiltersFrame_HideInvalidFilters(self)
	if not C_AchievementInfo.AreGuildAchievementsEnabled() then
		self.GuildAchievement:Hide();
	end

	if not CanShowAchievementUI() then
		self.Achievement:Hide();
	end

	if not C_GuildInfo.IsEncounterGuildNewsEnabled() then
		self.DungeonEncounter:Hide();
	end

end