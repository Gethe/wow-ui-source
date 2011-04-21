local GUILD_BUTTON_HEIGHT = 84;

local GUILD_EVENT_TEXTURES = {
	--[CALENDAR_EVENTTYPE_RAID]		= "Interface\\LFGFrame\\LFGIcon-",
	--[CALENDAR_EVENTTYPE_DUNGEON]	= "Interface\\LFGFrame\\LFGIcon-",
	[CALENDAR_EVENTTYPE_PVP]		= "Interface\\Calendar\\UI-Calendar-Event-PVP",
	[CALENDAR_EVENTTYPE_MEETING]	= "Interface\\Calendar\\MeetingIcon",
	[CALENDAR_EVENTTYPE_OTHER]		= "Interface\\Calendar\\UI-Calendar-Event-Other",
	--[CALENDAR_EVENTTYPE_HEROIC_DUNGEON]	= "Interface\\LFGFrame\\LFGIcon-",
};
local GUILD_EVENT_TEXTURE_PATH = "Interface\\LFGFrame\\LFGIcon-";

local CHALLENGE_SECTIONS = { "GuildInfoChallengesDungeon", "GuildInfoChallengesRaid", "GuildInfoChallengesRatedBG" };
local INTEREST_TYPES = {"QUEST", "DUNGEON", "RAID", "PVP", "RP"};

function GuildInfoFrame_OnLoad(self)
	GuildFrame_RegisterPanel(self);
	PanelTemplates_SetNumTabs(self, 3);

	self:RegisterEvent("GUILD_MOTD");
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("GUILD_RANKS_UPDATE");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
	self:RegisterEvent("LF_GUILD_POST_UPDATED");
	self:RegisterEvent("LF_GUILD_RECRUITS_UPDATED");
	self:RegisterEvent("LF_GUILD_RECRUIT_LIST_CHANGED");
	self:RegisterEvent("GUILD_CHALLENGE_UPDATED");
	
	RequestGuildRecruitmentSettings();
	RequestGuildChallengeInfo();
end

function GuildInfoFrame_OnEvent(self, event, arg1)
	if ( event == "GUILD_MOTD" ) then
		GuildInfoMOTD:SetText(arg1);
	elseif ( event == "GUILD_ROSTER_UPDATE" ) then
		GuildInfoFrame_UpdatePermissions();
		GuildInfoFrame_UpdateText();
	elseif ( event == "GUILD_RANKS_UPDATE" ) then
		GuildInfoFrame_UpdatePermissions();
	elseif ( event == "PLAYER_GUILD_UPDATE" ) then
		GuildInfoFrame_UpdatePermissions();
	elseif ( event == "LF_GUILD_POST_UPDATED" ) then
		local bQuest, bDungeon, bRaid, bPvP, bRP, bWeekdays, bWeekends, bTank, bHealer, bDamage, bAnyLevel, bMaxLevel, bListed = GetGuildRecruitmentSettings();
		-- interest
		GuildRecruitmentQuestButton:SetChecked(bQuest);
		GuildRecruitmentDungeonButton:SetChecked(bDungeon);
		GuildRecruitmentRaidButton:SetChecked(bRaid);
		GuildRecruitmentPvPButton:SetChecked(bPvP);
		GuildRecruitmentRPButton:SetChecked(bRP);
		-- availability
		GuildRecruitmentWeekdaysButton:SetChecked(bWeekdays);
		GuildRecruitmentWeekendsButton:SetChecked(bWeekends);
		-- roles
		GuildRecruitmentTankButton.checkButton:SetChecked(bTank);
		GuildRecruitmentHealerButton.checkButton:SetChecked(bHealer);
		GuildRecruitmentDamagerButton.checkButton:SetChecked(bDamage);
		-- level
		if ( bMaxLevel ) then
			GuildRecruitmentLevelButton_OnClick(2);
		else
			GuildRecruitmentLevelButton_OnClick(1);
		end
		-- comment
		GuildRecruitmentCommentEditBox:SetText(GetGuildRecruitmentComment());
		GuildRecruitmentListGuildButton_Update();
	elseif ( event == "LF_GUILD_RECRUITS_UPDATED" ) then
		GuildInfoFrameApplicants_Update();
	elseif ( event == "LF_GUILD_RECRUIT_LIST_CHANGED" ) then
		RequestGuildApplicantsList();
	elseif ( event == "GUILD_CHALLENGE_UPDATED" ) then
		GuildInfoFrame_UpdateChallenges();
	end
end

function GuildInfoFrame_OnShow(self)
	RequestGuildApplicantsList();
	RequestGuildChallengeInfo();
end

function GuildInfoFrame_Update()
	local selectedTab = PanelTemplates_GetSelectedTab(GuildInfoFrame);
	if ( selectedTab == 1 ) then
		GuildInfoFrameInfo:Show();
		GuildInfoFrameRecruitment:Hide();
		GuildInfoFrameApplicants:Hide();
	elseif ( selectedTab == 2 ) then
		GuildInfoFrameInfo:Hide();
		GuildInfoFrameRecruitment:Show();
		GuildInfoFrameApplicants:Hide();
	else
		GuildInfoFrameInfo:Hide();
		GuildInfoFrameRecruitment:Hide();
		GuildInfoFrameApplicants:Show();
	end
end

--*******************************************************************************
--   Info Tab
--*******************************************************************************

function GuildInfoFrameInfo_OnLoad(self)
	GuildInfoEventsContainer.update = GuildInfoEvents_Update;
	HybridScrollFrame_CreateButtons(GuildInfoEventsContainer, "GuildNewsButtonTemplate", 0, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM");
	local buttons = GuildInfoEventsContainer.buttons;
	for i = 1, #buttons do
		buttons[i].isEvent = true;
	end

	local fontString = GuildInfoEditMOTDButton:GetFontString();
	GuildInfoEditMOTDButton:SetHeight(fontString:GetHeight() + 4);
	GuildInfoEditMOTDButton:SetWidth(fontString:GetWidth() + 4);
	fontString = GuildInfoEditDetailsButton:GetFontString();
	GuildInfoEditDetailsButton:SetHeight(fontString:GetHeight() + 4);
	GuildInfoEditDetailsButton:SetWidth(fontString:GetWidth() + 4);	
	fontString = GuildInfoEditEventButton:GetFontString();
	GuildInfoEditEventButton:SetHeight(fontString:GetHeight() + 4);
	GuildInfoEditEventButton:SetWidth(fontString:GetWidth() + 4);
	
	-- faction icon
	if ( GetGuildFactionGroup() == 0 ) then  -- horde
		GUILD_EVENT_TEXTURES[CALENDAR_EVENTTYPE_PVP] = "Interface\\Calendar\\UI-Calendar-Event-PVP01";
	else  -- alliance
		GUILD_EVENT_TEXTURES[CALENDAR_EVENTTYPE_PVP] = "Interface\\Calendar\\UI-Calendar-Event-PVP02";
	end
end

function GuildInfoFrameInfo_OnShow(self)
	GuildInfoEvents_Update();
	GuildInfoFrame_UpdatePermissions();	
	GuildInfoFrame_UpdateText();
end

function GuildInfoFrame_UpdatePermissions()
	if ( CanEditMOTD() ) then
		GuildInfoEditMOTDButton:Show();
	else
		GuildInfoEditMOTDButton:Hide();
	end
	if ( CanEditGuildInfo() ) then
		GuildInfoEditDetailsButton:Show();
	else
		GuildInfoEditDetailsButton:Hide();
	end
	if ( CanEditGuildEvent() and not GuildInfoChallenges:IsShown() ) then
		GuildInfoEditEventButton:Show();
	else
		GuildInfoEditEventButton:Hide();
	end
	local guildInfoFrame = GuildInfoFrame;
	if ( IsGuildLeader() ) then
		GuildControlButton:Enable();
		GuildInfoFrameTab2:Show();
		GuildInfoFrameTab3:SetPoint("LEFT", GuildInfoFrameTab2, "RIGHT");
	else
		GuildControlButton:Disable();
		GuildInfoFrameTab2:Hide();
		GuildInfoFrameTab3:SetPoint("LEFT", GuildInfoFrameTab1, "RIGHT");
	end
	if ( CanGuildInvite() ) then
		GuildAddMemberButton:Enable();
		-- show the recruitment tabs
		if ( not guildInfoFrame.tabsShowing ) then
			guildInfoFrame.tabsShowing = true;
			GuildInfoFrameTab1:Show();
			GuildInfoFrameTab3:Show();
			GuildInfoFrameTab3:SetText(GUILDINFOTAB_APPLICANTS_NONE);
			PanelTemplates_SetTab(guildInfoFrame, 1);
			PanelTemplates_UpdateTabs(guildInfoFrame);
			RequestGuildApplicantsList();
		end
	else
		GuildAddMemberButton:Disable();
		-- hide the recruitment tabs
		if ( guildInfoFrame.tabsShowing ) then
			guildInfoFrame.tabsShowing = nil;
			GuildInfoFrameTab1:Hide();
			GuildInfoFrameTab3:Hide();
			if ( PanelTemplates_GetSelectedTab(guildInfoFrame) ~= 1 ) then
				PanelTemplates_SetTab(guildInfoFrame, 1);
				GuildInfoFrame_Update();
			end
		end
	end	
end

function GuildInfoFrame_UpdateText(infoText)
	GuildInfoMOTD:SetText(GetGuildRosterMOTD());
	if ( infoText ) then
		GuildInfoFrame.cachedInfoText = infoText;
		GuildInfoFrame.cacheExpiry = GetTime() + 10;
	else
		if ( not GuildInfoFrame.cacheExpiry or GetTime() > GuildInfoFrame.cacheExpiry ) then 
			GuildInfoFrame.cachedInfoText = GetGuildInfoText();
		end
	end
	GuildInfoDetails:SetText(GuildInfoFrame.cachedInfoText);
	GuildInfoDetailsFrame:SetVerticalScroll(0);
	GuildInfoDetailsFrameScrollBarScrollUpButton:Disable();
end

function GuildInfoEvents_Update()
	local scrollFrame = GuildInfoEventsContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local button, index;
	local numEvents = CalendarGetNumGuildEvents();
	
	if ( numEvents > 0 ) then
		GuildInfoNoEvents:Hide();
	else
		GuildInfoNoEvents:Show();
	end

	for i = 1, numButtons do
		button = buttons[i];
		index = offset + i;
		if ( index <= numEvents ) then
			GuildInfoEvents_SetButton(button, index);
			button:Show();
		else
			button:Hide();
		end
	end
	local totalHeight = numEvents * scrollFrame.buttonHeight;
	local displayedHeight = numButtons * scrollFrame.buttonHeight;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
	GuildFrame_UpdateScrollFrameWidth(scrollFrame);
end

local SIX_DAYS = 6 * 24 * 60 * 60		-- time in seconds
function GuildInfoEvents_SetButton(button, eventIndex)
	local today = date("*t");
	local month, day, weekday, hour, minute, eventType, title, calendarType, textureName = CalendarGetGuildEventInfo(eventIndex);
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
		local eventTime = time{year = year, month = month, day = day};
		if ( eventTime - time() < SIX_DAYS ) then
			displayDay = CALENDAR_WEEKDAY_NAMES[weekday];
		else
			displayDay = string.format(GUILD_NEWS_DATE, CALENDAR_WEEKDAY_NAMES[weekday], day, month);
		end
	end

	button.text:SetFormattedText(GUILD_EVENT_FORMAT, displayDay, displayTime, title);
	button.index = eventIndex;
	-- icon
	if ( button.icon.type ~= "event" ) then
		button.icon.type = "event"
		button.icon:SetTexCoord(0, 1, 0, 1);
		button.icon:SetWidth(14);
		button.icon:SetHeight(14);
	end
	if ( GUILD_EVENT_TEXTURES[eventType] ) then
		button.icon:SetTexture(GUILD_EVENT_TEXTURES[eventType]);
	else
		button.icon:SetTexture(GUILD_EVENT_TEXTURE_PATH..textureName);
	end	
end

function GuildInfoEventButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		if ( CalendarFrame and CalendarFrame:IsShown() ) then
			-- if the calendar is already open we need to do some work that's normally happening in CalendarFrame_OnShow
			local weekday, month, day, year = CalendarGetDate();
			CalendarSetAbsMonth(month, year);
		else
			ToggleCalendar();
		end
		local monthOffset, day, eventIndex = CalendarGetGuildEventSelectionInfo(self.index);
		CalendarSetMonth(monthOffset);
		-- need to highlight the proper day/event in calendar
		local _, _, _, firstDay = CalendarGetMonth();
		local buttonIndex = day + firstDay - CALENDAR_FIRST_WEEKDAY;
		if ( firstDay < CALENDAR_FIRST_WEEKDAY ) then
			buttonIndex = buttonIndex + 7;
		end
		local dayButton = _G["CalendarDayButton"..buttonIndex];
		CalendarDayButton_Click(dayButton);
		if ( eventIndex <= 4 ) then -- can only see 4 events per day
			local eventButton = _G["CalendarDayButton"..buttonIndex.."EventButton"..eventIndex];
			CalendarDayEventButton_Click(eventButton, true);	-- true to open the event
		else
			CalendarFrame_SetSelectedEvent();	-- clears any event highlights
			CalendarOpenEvent(0, day, eventIndex);
		end
	end
end

function GuildInfoFrame_UpdateChallenges()
	local numChallenges = GetNumGuildChallenges();
	if ( numChallenges == 0 ) then
		GuildInfoFrameInfoHeader1Label:SetText(EVENTS_LABEL);
		GuildInfoChallenges:Hide();
		GuildInfoEventsContainer:Show();
		GuildInfoChallenges:Hide();
		GuildInfoChallengesDungeonTexture:Hide();
		GuildInfoChallengesRaidTexture:Hide();
		GuildInfoChallengesRatedBGTexture:Hide();
		if ( CanEditGuildEvent() ) then
			GuildInfoEditEventButton:Show();
		end
	else
		-- if for some reason events were showing, switch
		if ( not GuildInfoChallenges:IsShown() ) then
			GuildInfoFrameInfoHeader1Label:SetText(GUILD_FRAME_CHALLENGES);
			GuildInfoChallenges:Show();
			GuildInfoEventsContainer:Hide();
			GuildInfoChallengesDungeonTexture:Show();
			GuildInfoChallengesRaidTexture:Show();
			GuildInfoChallengesRatedBGTexture:Show();
			GuildInfoEditEventButton:Hide();
		end
		for i = 1, numChallenges do
			local index, current, max = GetGuildChallengeInfo(i);
			if ( CHALLENGE_SECTIONS[index] ) then
				if ( current == max ) then
					SetDesaturation(_G[CHALLENGE_SECTIONS[index].."Texture"], true);
					_G[CHALLENGE_SECTIONS[index].."Count"]:Hide();
					_G[CHALLENGE_SECTIONS[index].."Check"]:Show();
					_G[CHALLENGE_SECTIONS[index].."Label"]:SetTextColor(0.1, 1, 0.1);
				else
					SetDesaturation(_G[CHALLENGE_SECTIONS[index].."Texture"], false);
					_G[CHALLENGE_SECTIONS[index].."Count"]:Show();
					_G[CHALLENGE_SECTIONS[index].."Count"]:SetFormattedText(GUILD_CHALLENGE_PROGRESS_FORMAT, current, max);
					_G[CHALLENGE_SECTIONS[index].."Check"]:Hide();
					_G[CHALLENGE_SECTIONS[index].."Label"]:SetTextColor(1, 1, 1);
				end
			end
		end
	end
end

--*******************************************************************************
--   Recruitment Tab
--*******************************************************************************

function GuildInfoFrameRecruitment_OnLoad(self)
	GuildRecruitmentInterestFrameText:SetText(GUILD_INTEREST);
	GuildRecruitmentInterestFrame:SetHeight(63);
	GuildRecruitmentAvailabilityFrameText:SetText(GUILD_AVAILABILITY);
	GuildRecruitmentAvailabilityFrame:SetHeight(43);
	GuildRecruitmentRolesFrameText:SetText(CLASS_ROLES);
	GuildRecruitmentRolesFrame:SetHeight(80);
	GuildRecruitmentLevelFrameText:SetText(GUILD_RECRUITMENT_LEVEL);
	GuildRecruitmentLevelFrame:SetHeight(43);
	GuildRecruitmentCommentFrame:SetHeight(72);
	
	-- defaults until data is retrieved
	GuildRecruitmentLevelAnyButton:SetChecked(1);
	GuildRecruitmentListGuildButton:Disable();
end

function GuildRecruitmentLevelButton_OnClick(index, userClick)
	local param;
	if ( index == 1 ) then
		GuildRecruitmentLevelAnyButton:SetChecked(1);
		GuildRecruitmentLevelMaxButton:SetChecked(nil);
		param = LFGUILD_PARAM_ANY_LEVEL;
	elseif ( index == 2 ) then
		GuildRecruitmentLevelAnyButton:SetChecked(nil);
		GuildRecruitmentLevelMaxButton:SetChecked(1);
		param = LFGUILD_PARAM_MAX_LEVEL;
	end
	if ( userClick ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
		SetGuildRecruitmentSettings(param, true);
	end	
end

function GuildRecruitmentRoleButton_OnClick(self)
	local checked = self:GetChecked();
	if ( self:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
	end
	SetGuildRecruitmentSettings(self:GetParent().param, checked);
	GuildRecruitmentListGuildButton_Update();
end

function GuildRecruitmentListGuildButton_Update()
	local bQuest, bDungeon, bRaid, bPvP, bRP, bWeekdays, bWeekends, bTank, bHealer, bDamage, bAnyLevel, bMaxLevel, bListed = GetGuildRecruitmentSettings();
	-- need to have at least 1 interest, 1 time, and 1 role checked to be able to list
	if ( bQuest or bDungeon or bRaid or bPvP or bRP ) and ( bWeekdays or bWeekends ) and ( bTank or bHealer or bDamage ) then
		GuildRecruitmentListGuildButton:Enable();
	else
		GuildRecruitmentListGuildButton:Disable();
		-- delist if already listed
		if ( bListed ) then
			bListed = false;
			SetGuildRecruitmentSettings(LFGUILD_PARAM_LOOKING, false);
		end
	end
	GuildRecruitmentListGuildButton_UpdateText(bListed);
end

function GuildRecruitmentListGuildButton_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	local bQuest, bDungeon, bRaid, bPvP, bRP, bWeekdays, bWeekends, bTank, bHealer, bDamage, bAnyLevel, bMaxLevel, bListed = GetGuildRecruitmentSettings();
	bListed = not bListed;
	if ( bListed and GuildRecruitmentCommentEditBox:HasFocus() ) then
		GuildRecruitmentComment_SaveText();
	end
	SetGuildRecruitmentSettings(LFGUILD_PARAM_LOOKING, bListed);
	GuildRecruitmentListGuildButton_UpdateText(bListed);
end

function GuildRecruitmentListGuildButton_UpdateText(listed)
	if ( listed ) then
		GuildRecruitmentListGuildButton:SetText(GUILD_CLOSE_RECRUITMENT);
	else
		GuildRecruitmentListGuildButton:SetText(GUILD_OPEN_RECRUITMENT);
	end
end

function GuildRecruitmentComment_SaveText(self)
	self = self or GuildRecruitmentCommentEditBox;
	SetGuildRecruitmentComment(self:GetText());
	self:ClearFocus();
end

function GuildRecruitmentCheckButton_OnEnter(self)
	local interestType = INTEREST_TYPES[self:GetID()];
	if ( interestType ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(_G["GUILD_INTEREST_"..interestType]);
		GameTooltip:AddLine(_G["GUILD_INTEREST_"..interestType.."_TOOLTIP"], 1, 1, 1, 1, 1);
		GameTooltip:Show();
	end
end

--*******************************************************************************
--   Applicants Tab
--*******************************************************************************

function GuildInfoFrameApplicants_OnLoad(self)
	GuildInfoFrameApplicantsContainer.update = GuildInfoFrameApplicants_Update;
	HybridScrollFrame_CreateButtons(GuildInfoFrameApplicantsContainer, "GuildRecruitmentApplicantTemplate", 0, 0);
	
	GuildInfoFrameApplicantsContainerScrollBar.Show = 
		function (self)
			GuildInfoFrameApplicantsContainer:SetWidth(304);
			for _, button in next, GuildInfoFrameApplicantsContainer.buttons do
				button:SetWidth(301);
			end
			getmetatable(self).__index.Show(self);
		end
	GuildInfoFrameApplicantsContainerScrollBar.Hide = 
		function (self)
			GuildInfoFrameApplicantsContainer:SetWidth(320);
			for _, button in next, GuildInfoFrameApplicantsContainer.buttons do
				button:SetWidth(320);
			end
			getmetatable(self).__index.Hide(self);
		end
end

function GuildInfoFrameApplicants_OnShow(self)
	GuildInfoFrameApplicants_Update();
end

function GuildInfoFrameApplicants_Update()
	local scrollFrame = GuildInfoFrameApplicantsContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local button, index;
	local numApplicants = GetNumGuildApplicants();
	local selection = GetGuildApplicantSelection();

	if ( numApplicants == 0 ) then
		GuildInfoFrameTab3:SetText(GUILDINFOTAB_APPLICANTS_NONE);
	else
		GuildInfoFrameTab3:SetFormattedText(GUILDINFOTAB_APPLICANTS, numApplicants);
	end
	PanelTemplates_TabResize(GuildInfoFrameTab3, 0);
	
	for i = 1, numButtons do
		button = buttons[i];
		index = offset + i;
		local name, level, class, _, _, _, _, _, _, _, isTank, isHealer, isDamage, comment, timeSince, timeLeft = GetGuildApplicantInfo(index);
		if ( name ) then
			button.name:SetText(name);
			button.level:SetText(level);
			button.comment:SetText(comment);
			button.class:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]));
			-- time left
			local daysLeft = floor(timeLeft / 86400); -- seconds in a day
			if ( daysLeft < 1 ) then
				button.timeLeft:SetText(GUILD_FINDER_LAST_DAY_LEFT);
			else
				button.timeLeft:SetFormattedText(GUILD_FINDER_DAYS_LEFT, daysLeft);
			end
			-- roles
			if ( isTank ) then
				button.tankTex:SetAlpha(1);
			else
				button.tankTex:SetAlpha(0.2);
			end
			if ( isHealer ) then
				button.healerTex:SetAlpha(1);
			else
				button.healerTex:SetAlpha(0.2);
			end
			if ( isDamage ) then
				button.damageTex:SetAlpha(1);
			else
				button.damageTex:SetAlpha(0.2);
			end
			-- selection
			if ( index == selection ) then
				button.selectedTex:Show();
			else
				button.selectedTex:Hide();
			end
			
			button:Show();
			button.index = index;
		else
			button:Hide();
		end
	end
	local totalHeight = numApplicants * GUILD_BUTTON_HEIGHT;
	local displayedHeight = numApplicants * GUILD_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
	
	if ( selection and selection > 0 ) then
		GuildRecruitmentInviteButton:Enable();
		GuildRecruitmentDeclineButton:Enable();
		GuildRecruitmentMessageButton:Enable();
	else
		GuildRecruitmentInviteButton:Disable();
		GuildRecruitmentDeclineButton:Disable();
		GuildRecruitmentMessageButton:Disable();
	end
end

function GuildRecruitmentApplicant_OnClick(self, button)
	if ( button == "LeftButton" ) then
		SetGuildApplicantSelection(self.index);
		GuildInfoFrameApplicants_Update();
	end
end

function GuildRecruitmentApplicant_ShowTooltip(self)
	local name, level, class, bQuest, bDungeon, bRaid, bPvP, bRP, bWeekdays, bWeekends, bTank, bHealer, bDamage, comment, timeSince, timeLeft = GetGuildApplicantInfo(self.index);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(name);
	local buf = "";
	-- interests
	if ( bQuest ) then buf = buf.."\n"..QUEST_DASH..GUILD_INTEREST_QUEST; end
	if ( bDungeon ) then buf = buf.."\n"..QUEST_DASH..GUILD_INTEREST_DUNGEON; end
	if ( bRaid ) then buf = buf.."\n"..QUEST_DASH..GUILD_INTEREST_RAID; end
	if ( bPvP ) then buf = buf.."\n"..QUEST_DASH..GUILD_INTEREST_PVP; end
	if ( bRP ) then buf = buf.."\n"..QUEST_DASH..GUILD_INTEREST_RP; end	
	GameTooltip:AddLine(GUILD_INTEREST..HIGHLIGHT_FONT_COLOR_CODE..buf);
	-- availability
	buf = "";
	if ( bWeekdays ) then buf = buf.."\n"..QUEST_DASH..GUILD_AVAILABILITY_WEEKDAYS; end
	if ( bWeekends ) then buf = buf.."\n"..QUEST_DASH..GUILD_AVAILABILITY_WEEKENDS; end
	GameTooltip:AddLine(GUILD_AVAILABILITY..HIGHLIGHT_FONT_COLOR_CODE..buf);
	
	GameTooltip:Show();
end

--*******************************************************************************
--   Popups
--*******************************************************************************

function GuildTextEditFrame_OnLoad(self)
	GuildFrame_RegisterPopup(self);
	GuildTextEditBox:SetTextInsets(4, 0, 4, 4);
	GuildTextEditBox:SetSpacing(2);
end

function GuildTextEditFrame_Show(editType)
	if ( editType == "motd" ) then
		GuildTextEditFrame:SetHeight(162);
		GuildTextEditBox:SetMaxLetters(128);
		GuildTextEditBox:SetText(GetGuildRosterMOTD());
		GuildTextEditFrameTitle:SetText(GUILD_MOTD_EDITLABEL);
		GuildTextEditBox:SetScript("OnEnterPressed", GuildTextEditFrame_OnAccept);
	elseif ( editType == "info" ) then
		GuildTextEditFrame:SetHeight(295);
		GuildTextEditBox:SetMaxLetters(500);
		GuildTextEditBox:SetText(GuildInfoFrame.cachedInfoText);
		GuildTextEditFrameTitle:SetText(GUILD_INFO_EDITLABEL);
		GuildTextEditBox:SetScript("OnEnterPressed", nil);
	end
	GuildTextEditFrame.type = editType;
	GuildFramePopup_Show(GuildTextEditFrame);
	GuildTextEditBox:SetCursorPosition(0);
	GuildTextEditBox:SetFocus();
	PlaySound("igMainMenuOptionCheckBoxOn");
end

function GuildTextEditFrame_OnAccept()
	if ( GuildTextEditFrame.type == "motd" ) then
		GuildSetMOTD(GuildTextEditBox:GetText());
	elseif ( GuildTextEditFrame.type == "info" ) then
		local infoText = GuildTextEditBox:GetText();
		GuildInfoFrame_UpdateText(infoText);
		SetGuildInfoText(infoText);
	end
	GuildTextEditFrame:Hide();
end

function GuildLogFrame_OnLoad(self)
	GuildFrame_RegisterPopup(self);
	GuildLogHTMLFrame:SetSpacing(2);
	ScrollBar_AdjustAnchors(GuildLogScrollFrameScrollBar, 0, -2);
	self:RegisterEvent("GUILD_EVENT_LOG_UPDATE");
end

function GuildLogFrame_Update()
	local numEvents = GetNumGuildEvents();
	local type, player1, player2, rank, year, month, day, hour;
	local msg;
	local buffer = "";
	for i = numEvents, 1, -1 do
		type, player1, player2, rank, year, month, day, hour = GetGuildEventInfo(i);
		if ( not player1 ) then
			player1 = UNKNOWN;
		end
		if ( not player2 ) then
			player2 = UNKNOWN;
		end
		if ( type == "invite" ) then
			msg = format(GUILDEVENT_TYPE_INVITE, player1, player2);
		elseif ( type == "join" ) then
			msg = format(GUILDEVENT_TYPE_JOIN, player1);
		elseif ( type == "promote" ) then
			msg = format(GUILDEVENT_TYPE_PROMOTE, player1, player2, rank);
		elseif ( type == "demote" ) then
			msg = format(GUILDEVENT_TYPE_DEMOTE, player1, player2, rank);
		elseif ( type == "remove" ) then
			msg = format(GUILDEVENT_TYPE_REMOVE, player1, player2);
		elseif ( type == "quit" ) then
			msg = format(GUILDEVENT_TYPE_QUIT, player1);
		end
		if ( msg ) then
			buffer = buffer..msg.."|cff009999   "..format(GUILD_BANK_LOG_TIME, RecentTimeDate(year, month, day, hour)).."|r|n";
		end
	end
	GuildLogHTMLFrame:SetText(buffer);
end