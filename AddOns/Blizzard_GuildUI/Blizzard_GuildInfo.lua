local GUILD_INFO_BUTTON_HEIGHT = 18;

function GuildInfoFrame_OnLoad(self)
	GuildFrame_RegisterPanel(self);
	GuildInfoEventsContainer.update = GuildInfoEvents_Update;
	HybridScrollFrame_CreateButtons(GuildInfoEventsContainer, "GuildInfoButtonTemplate", 0, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM");
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

	-- moving the events scrollbar onto the scrollframe to obscure button highlights because I'm not resizing the buttons when hiding the scrollbar
	GuildInfoEventsContainerScrollBar:SetFrameLevel(100);
	ScrollBar_AdjustAnchors(GuildInfoEventsContainerScrollBar, 1, -1, -22);
	
	GuildInfoEvents_Update();
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

function GuildInfoFrame_UpdateText()
	GuildInfoMOTD:SetText(GetGuildRosterMOTD());
	GuildInfoDetails:SetText(GetGuildInfoText());
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
	
	for i = 1, numButtons do
		button = buttons[i];
		index = offset + i;
		button:Hide();
		-- waiting on API
		--button.text:SetText();
		--button.icon:SetTexture();
		--button.text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		--button.text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
	local totalHeight = 0 * GUILD_INFO_BUTTON_HEIGHT;
	local displayedHeight = numButtons * GUILD_INFO_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
end

function GuildInfoFrame_AddEvent(event)
	local messageFrame = GuildInfoEventsFrame;
	messageFrame:AddMessage(event);
	if ( messageFrame:AtTop() and messageFrame:AtBottom() ) then
		GuildInfoEventsFrameScrollBar:Hide();
	else
		local scrollBar = GuildInfoEventsFrameScrollBar;
		scrollBar:Show();
		eventsOffset = messageFrame:GetNumMessages() - messageFrame:GetNumLinesDisplayed();
		scrollBar:SetMinMaxValues(0, eventsOffset);
		scrollBar:SetValue(0);
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
		GuildTextEditBox:SetText(GetGuildInfoText());
		GuildTextEditFrameTitle:SetText(GUILD_INFO_EDITLABEL);
		GuildTextEditBox:SetScript("OnEnterPressed", nil);
	end
	GuildTextEditFrame.type = editType;
	GuildFramePopup_Show(GuildTextEditFrame);
	GuildTextEditBox:SetCursorPosition(0);
	GuildTextEditBox:SetFocus();
end

function GuildTextEditFrame_OnAccept()
	if ( GuildTextEditFrame.type == "motd" ) then
		GuildSetMOTD(GuildTextEditBox:GetText());
	elseif ( GuildTextEditFrame.type == "info" ) then
		SetGuildInfoText(GuildTextEditBox:GetText());
		GuildRoster();
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
