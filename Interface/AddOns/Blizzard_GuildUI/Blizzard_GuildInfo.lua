local GUILD_BUTTON_HEIGHT = 84;
local GUILD_COMMENT_HEIGHT = 50;
local GUILD_COMMENT_BORDER = 10;

function GuildInfoFrame_OnLoad(self)
	GuildFrame_RegisterPanel(self);
	PanelTemplates_SetNumTabs(self, 1);

	self:RegisterEvent("GUILD_MOTD");
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("GUILD_RANKS_UPDATE");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
	self:RegisterEvent("GUILD_CHALLENGE_UPDATED");
	
	RequestGuildChallengeInfo();
end

function GuildInfoFrame_OnEvent(self, event, arg1)
	if ( event == "GUILD_MOTD" ) then
		GuildInfoMOTD:SetText(arg1, true);	--Ignores markup.
	elseif ( event == "GUILD_ROSTER_UPDATE" ) then
		GuildInfoFrame_UpdatePermissions();
		GuildInfoFrame_UpdateText();
	elseif ( event == "GUILD_RANKS_UPDATE" ) then
		GuildInfoFrame_UpdatePermissions();
	elseif ( event == "PLAYER_GUILD_UPDATE" ) then
		GuildInfoFrame_UpdatePermissions();
	elseif ( event == "GUILD_CHALLENGE_UPDATED" ) then
		GuildInfoFrame_UpdateChallenges();
	end
end

function GuildInfoFrame_OnShow(self)
	RequestGuildChallengeInfo();
end

function GuildInfoFrame_Update()
	local selectedTab = PanelTemplates_GetSelectedTab(GuildInfoFrame);
	if ( selectedTab == 1 ) then
		GuildInfoFrameInfo:Show();
	end
end

--*******************************************************************************
--   Info Tab
--*******************************************************************************

function GuildInfoFrameInfo_OnLoad(self)
	local fontString = GuildInfoEditMOTDButton:GetFontString();
	GuildInfoEditMOTDButton:SetHeight(fontString:GetHeight() + 4);
	GuildInfoEditMOTDButton:SetWidth(fontString:GetWidth() + 4);
	fontString = GuildInfoEditDetailsButton:GetFontString();
	GuildInfoEditDetailsButton:SetHeight(fontString:GetHeight() + 4);
	GuildInfoEditDetailsButton:SetWidth(fontString:GetWidth() + 4);	
end

function GuildInfoFrameInfo_OnShow(self)
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
	local guildInfoFrame = GuildInfoFrame;
	if ( IsGuildLeader() ) then
		GuildControlButton:Enable();
	else
		GuildControlButton:Disable();
	end
	if ( CanGuildInvite() ) then
		GuildAddMemberButton:Enable();
		-- show the recruitment tabs
		if ( not guildInfoFrame.tabsShowing ) then
			guildInfoFrame.tabsShowing = true;
			GuildInfoFrameTab1:Show();
			PanelTemplates_SetTab(guildInfoFrame, 1);
			PanelTemplates_UpdateTabs(guildInfoFrame);
		end
	else
		GuildAddMemberButton:Disable();
		-- hide the recruitment tabs
		if ( guildInfoFrame.tabsShowing ) then
			guildInfoFrame.tabsShowing = nil;
			GuildInfoFrameTab1:Hide();
			if ( PanelTemplates_GetSelectedTab(guildInfoFrame) ~= 1 ) then
				PanelTemplates_SetTab(guildInfoFrame, 1);
				GuildInfoFrame_Update();
			end
		end
	end	
end

function GuildInfoFrame_UpdateText(infoText)
	GuildInfoMOTD:SetText(GetGuildRosterMOTD(), true); --Extra argument ignores markup.
	GuildInfoDetails:SetText(infoText or GetGuildInfoText());
	GuildInfoDetailsFrame:SetVerticalScroll(0);
	GuildInfoDetailsFrameScrollBarScrollUpButton:Disable();
end

function GuildInfoFrame_UpdateChallenges()
	local numChallenges = GetNumGuildChallenges();
	for i = 1, numChallenges do
		local index, current, max = GetGuildChallengeInfo(i);
		local frame = _G["GuildInfoFrameInfoChallenge"..index];
		if ( frame ) then
			frame.dataIndex = i;
			if ( current == max ) then
				frame.count:Hide();
				frame.check:Show();
				frame.label:SetTextColor(0.1, 1, 0.1);
			else
				frame.count:Show();
				frame.count:SetFormattedText(GUILD_CHALLENGE_PROGRESS_FORMAT, current, max);
				frame.check:Hide();
				frame.label:SetTextColor(1, 1, 1);
			end
		end
	end
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
		GuildTextEditBox:SetText(GetGuildInfoText());
		GuildTextEditFrameTitle:SetText(GUILD_INFO_EDITLABEL);
		GuildTextEditBox:SetScript("OnEnterPressed", nil);
	end
	GuildTextEditFrame.type = editType;
	GuildFramePopup_Show(GuildTextEditFrame);
	GuildTextEditBox:SetCursorPosition(0);
	GuildTextEditBox:SetFocus();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function GuildTextEditFrame_OnAccept()
	if ( GuildTextEditFrame.type == "motd" ) then
		GuildSetMOTD(GuildTextEditBox:GetText());
	elseif ( GuildTextEditFrame.type == "info" ) then
		local infoText = GuildTextEditBox:GetText();
		SetGuildInfoText(infoText);
		GuildInfoFrame_UpdateText(infoText);
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
			buffer = buffer..msg..GUILD_BANK_LOG_TIME:format(RecentTimeDate(year, month, day, hour)).."|n";
		end
	end
	GuildLogHTMLFrame:SetText(buffer);
end