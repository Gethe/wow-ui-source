local GUILD_INFO_BUTTON_HEIGHT = 18;

function GuildInfoFrame_OnLoad(self)
	GuildFrame_RegisterPanel("GuildInfoFrame");
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
	
	-- temp setup
	GuildInfoMOTD:SetText("This is a lot of text for the guild message of the day, also known as MOTD or GMOTD. It has a limit of 127 characters. It can go for as long as three lines before it will get cut off with ellipses.")
	GuildInfoDetails:SetText("This is guild information line 1\nThis is guild information line 2\nThis is guild information line 3\nThis is guild information line 4\nThis is guild information line 5\nThis is guild information line 6\nThis is guild information line 7\nThis is guild information line 8\nThis is guild information line 9\nThis is guild information line 10");
	ScrollFrame_OnScrollRangeChanged(GuildInfoDetailsFrame);
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

function GuildInfoEventsFrameScrollBar_OnValueChanged(self, value)
	GuildInfoEventsFrame:SetScrollOffset(value);
	if ( value == 0 ) then
		GuildInfoEventsFrameScrollBarScrollUpButton:Disable();
		GuildInfoEventsFrameScrollBarScrollDownButton:Enable();
	elseif ( value == eventsOffset ) then
		GuildInfoEventsFrameScrollBarScrollUpButton:Enable();
		GuildInfoEventsFrameScrollBarScrollDownButton:Disable();
	else
		GuildInfoEventsFrameScrollBarScrollUpButton:Enable();
		GuildInfoEventsFrameScrollBarScrollDownButton:Enable();	
	end
end

function GuildInfoFrame_UpdateText()
	GuildInfoMOTD:SetText(GetGuildRosterMOTD());
	GuildInfoDetails:SetText(GetGuildInfoText());
	GuildInfoDetailsFrame:SetVerticalScroll(0);
	GuildInfoDetailsFrameScrollBarScrollUpButton:Disable();
end

function GuildInfoEvents_Update()
	local scrollFrame = GuildInfoEventsContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local button, index;
	
	for i = 1, numButtons do
		button = buttons[i];
		index = offset + i;
		if ( _GuildEvents[index] ) then
			button.text:SetText(_GuildEvents[index].text);
			button.icon:SetTexture(_GuildEvents[index].icon);
			if ( _GuildEvents[index].new ) then
				button.text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			else
				button.text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			end
			button:Show();
		else
			button:Hide();
		end
	end
	local totalHeight = #_GuildEvents * GUILD_INFO_BUTTON_HEIGHT;
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

--====================================================================================================
_GuildEvents = {
	[1] = { text = NORMAL_FONT_COLOR_CODE.."TODAY|r 7:00 pm: ICC 25 Raid", icon = "Interface\\LFGFrame\\LFGIcon-NAXXRAMAS", new = 1 },
	[2] = { text = "Friday 9:30 pm: ICC 25 Raid", icon = "Interface\\LFGFrame\\LFGIcon-AZJOLNERUB", new = 1 },
	[3] = { text = "Tuesday 5/15 7:00 pm: ICC 10 Raid", icon = "Interface\\LFGFrame\\LFGIcon-AZJOLNERUB" },
	[4] = { text = "Friday 5/17 9:30 pm: ICC 10 Raid", icon = "Interface\\LFGFrame\\LFGIcon-AZJOLNERUB" },
	[5] = { text = "Monday 5/21 10:00 pm: Lvl 1 Hogger Raid!!!", icon = "Interface\\LFGFrame\\LFGIcon-AZJOLNERUB" },
	[6] = { text = "Tuesday 5/22 8:15 pm: random raid", icon = "Interface\\LFGFrame\\LFGIcon-AZJOLNERUB" },
	[7] = { text = "Wednesday 5/23 8:15 pm: random raid", icon = "Interface\\LFGFrame\\LFGIcon-AZJOLNERUB" },
	[8] = { text = "Thursday 5/24 8:15 pm: random raid with a lot of text", icon = "Interface\\LFGFrame\\LFGIcon-MoltenCore" },
	[9] = { text = "Friday 5/25 8:15 pm: random raid", icon = "Interface\\LFGFrame\\LFGIcon-AZJOLNERUB" },
	[10] = { text = "Saturday 5/26 8:15 pm: random raid", icon = "Interface\\LFGFrame\\LFGIcon-AZJOLNERUB" }
 };

