local GUILD_EVENT_TEXTURES = {
	--[CALENDAR_EVENTTYPE_RAID]		= "Interface\\LFGFrame\\LFGIcon-",
	--[CALENDAR_EVENTTYPE_DUNGEON]	= "Interface\\LFGFrame\\LFGIcon-",
	[CALENDAR_EVENTTYPE_PVP]		= "Interface\\Calendar\\UI-Calendar-Event-PVP",
	[CALENDAR_EVENTTYPE_MEETING]	= "Interface\\Calendar\\MeetingIcon",
	[CALENDAR_EVENTTYPE_OTHER]		= "Interface\\Calendar\\UI-Calendar-Event-Other",
};
local GUILD_EVENT_TEXTURE_PATH = "Interface\\LFGFrame\\LFGIcon-";

function GuildInfoFrame_OnLoad(self)
	GuildFrame_RegisterPanel(self);
	GuildInfoEventsContainer.update = GuildInfoEvents_Update;
	HybridScrollFrame_CreateButtons(GuildInfoEventsContainer, "GuildNewsButtonTemplate", 0, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM");
	local buttons = GuildInfoEventsContainer.buttons;
	for i = 1, #buttons do
		buttons[i].isEvent = true;
	end
	self:RegisterEvent("GUILD_MOTD");
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	GuildInfoFrame_UpdateText();

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

function GuildInfoFrame_OnEvent(self, event, arg1)
	if ( event == "GUILD_MOTD" ) then
		GuildInfoMOTD:SetText(arg1);
	elseif ( event == "GUILD_ROSTER_UPDATE" ) then
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
		if ( CanEditGuildEvent() ) then
			GuildInfoEditEventButton:Show();
		else
			GuildInfoEditEventButton:Hide();
		end
		GuildInfoFrame_UpdateText();
	end
end

function GuildInfoFrame_OnShow()
	GuildInfoEvents_Update();
end

function GuildInfoFrame_UpdateText(infoText)
	GuildInfoMOTD:SetText(GetGuildRosterMOTD());
	if ( infoText ) then
		GuildInfoFrame.cachedInfoText = infoText;
	else
		GuildInfoFrame.cachedInfoText = GetGuildInfoText();
	end
	GuildInfoDetails:SetText(GuildInfoFrame.cachedInfoText);
	GuildInfoDetailsFrame:SetVerticalScroll(0);
	GuildInfoDetailsFrameScrollBarScrollUpButton:Disable();
end

--****** Events *****************************************************************

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

function GuildInfoEvents_SetButton(button, eventIndex)
	local today = date("*t");
	local month, day, weekday, hour, minute, eventType, title, calendarType, textureName = CalendarGetGuildEventInfo(eventIndex);
	local displayTime = GameTime_GetFormattedTime(hour, minute, true);
	local displayDay;
	
	if ( today["day"] == day and today["month"] == month ) then
		displayDay = NORMAL_FONT_COLOR_CODE..GUILD_EVENT_TODAY..FONT_COLOR_CODE_CLOSE;
	elseif ( abs(today["day"] - day) > 6 ) then		-- good-enough calculation of next week
		displayDay = string.format(GUILD_NEWS_DATE, CALENDAR_WEEKDAY_NAMES[weekday], day, month);
	else
		displayDay = CALENDAR_WEEKDAY_NAMES[weekday];
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
		local buttonIndex = day + firstDay - 1;
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

--****** Popups *****************************************************************

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
