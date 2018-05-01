local GUILD_BUTTON_HEIGHT = 84;
local GUILD_COMMENT_HEIGHT = 50;
local GUILD_COMMENT_BORDER = 10;

local INTEREST_TYPES = {"QUEST", "DUNGEON", "RAID", "PVP", "RP"};

function GuildInfoFrame_OnLoad(self)
	local fontString = self.EditMOTDButton:GetFontString();
	self.EditMOTDButton:SetHeight(fontString:GetHeight() + 4);
	self.EditMOTDButton:SetWidth(fontString:GetWidth() + 4);
	fontString = self.EditDetailsButton:GetFontString();
	self.EditDetailsButton:SetHeight(fontString:GetHeight() + 4);
	self.EditDetailsButton:SetWidth(fontString:GetWidth() + 4);	

	self:RegisterEvent("GUILD_MOTD");
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("GUILD_RANKS_UPDATE");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
	self:RegisterEvent("GUILD_CHALLENGE_UPDATED");
	
	RequestGuildChallengeInfo();
end

function GuildInfoFrame_OnEvent(self, event, arg1)
	if ( event == "GUILD_MOTD" ) then
		self.MOTDScrollFrame.MOTD:SetText(arg1, true);	--Ignores markup.
	elseif ( event == "GUILD_ROSTER_UPDATE" ) then
		GuildInfoFrame_UpdatePermissions(self);
		GuildInfoFrame_UpdateText(self);
	elseif ( event == "GUILD_RANKS_UPDATE" ) then
		GuildInfoFrame_UpdatePermissions(self);
	elseif ( event == "PLAYER_GUILD_UPDATE" ) then
		GuildInfoFrame_UpdatePermissions(self);
	elseif ( event == "GUILD_CHALLENGE_UPDATED" ) then
		GuildInfoFrame_UpdateChallenges(self);
	end
end

function GuildInfoFrame_OnShow(self)
	GuildInfoFrame_UpdatePermissions(self);	
	GuildInfoFrame_UpdateText(self);
	RequestGuildChallengeInfo();
end

function GuildInfoFrame_UpdatePermissions(self)
	if ( CanEditMOTD() ) then
		self.EditMOTDButton:Show();
	else
		self.EditMOTDButton:Hide();
	end
	if ( CanEditGuildInfo() ) then
		self.EditDetailsButton:Show();
	else
		self.EditDetailsButton:Hide();
	end
end

function GuildInfoFrame_UpdateText(self, infoText)
	self.MOTDScrollFrame.MOTD:SetText(GetGuildRosterMOTD(), true); --Extra argument ignores markup.
	self.DetailsFrame:GetScrollChild().Details:SetText(infoText or GetGuildInfoText());
	self.DetailsFrame:SetVerticalScroll(0);
	self.DetailsFrame.ScrollBar.ScrollUpButton:Disable();
end

local CHALLENGE_ORDER = { 1, 4, 2, 3, };
function GuildInfoFrame_UpdateChallenges(self)
	local numChallenges = GetNumGuildChallenges();
	for i = 1, numChallenges do
		local orderIndex = CHALLENGE_ORDER[i];
		local _, current, max = GetGuildChallengeInfo(orderIndex);
		local frame = self.Challenges[i];
		if ( frame ) then
			frame.orderIndex = orderIndex;
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

function TextEditButton_OnClick(self)
	GuildTextEditFrame_SetType(self.editType);
	local toggled = CallMethodOnNearestAncestor(self, "ToggleSubPanel", GuildTextEditFrame);
	if not toggled then
		ToggleFrame(GuildTextEditFrame);
	end
end

--*******************************************************************************
--   Popups
--*******************************************************************************

function GuildTextEditFrame_OnLoad(self)
	GuildTextEditBox:SetTextInsets(4, 0, 4, 4);
	GuildTextEditBox:SetSpacing(2);
end

function GuildTextEditFrame_SetType(editType)
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
	GuildTextEditBox:SetCursorPosition(0);
	GuildTextEditBox:SetFocus();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function GuildTextEditFrame_OnAccept(self)
	if ( GuildTextEditFrame.type == "motd" ) then
		GuildSetMOTD(GuildTextEditBox:GetText());
	elseif ( GuildTextEditFrame.type == "info" ) then
		local infoText = GuildTextEditBox:GetText();
		SetGuildInfoText(infoText);
	end
	HideUIPanel(GuildTextEditFrame);
end

function GuildLogFrame_OnLoad(self)
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