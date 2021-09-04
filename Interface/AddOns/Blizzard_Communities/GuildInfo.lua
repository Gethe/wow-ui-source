local GUILD_BUTTON_HEIGHT = 84;
local GUILD_COMMENT_HEIGHT = 50;
local GUILD_COMMENT_BORDER = 10;

local INTEREST_TYPES = {"QUEST", "DUNGEON", "RAID", "PVP", "RP"};

function CommunitiesGuildInfoFrame_OnLoad(self)
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

function CommunitiesGuildInfoFrame_OnEvent(self, event, arg1)
	if ( event == "GUILD_MOTD" ) then
		self.MOTDScrollFrame.MOTD:SetText(arg1, true);	--Ignores markup.
	elseif ( event == "GUILD_ROSTER_UPDATE" ) then
		CommunitiesGuildInfoFrame_UpdatePermissions(self);
		CommunitiesGuildInfoFrame_UpdateText(self);
	elseif ( event == "GUILD_RANKS_UPDATE" ) then
		CommunitiesGuildInfoFrame_UpdatePermissions(self);
	elseif ( event == "PLAYER_GUILD_UPDATE" ) then
		CommunitiesGuildInfoFrame_UpdatePermissions(self);
	elseif ( event == "GUILD_CHALLENGE_UPDATED" ) then
		CommunitiesGuildInfoFrame_UpdateChallenges(self);
	end
end

function CommunitiesGuildInfoFrame_OnShow(self)
	C_GuildInfo.GuildRoster();
	CommunitiesGuildInfoFrame_UpdatePermissions(self);	
	CommunitiesGuildInfoFrame_UpdateText(self);
	RequestGuildChallengeInfo();
end

function CommunitiesGuildInfoFrame_UpdatePermissions(self)
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

function CommunitiesGuildInfoFrame_UpdateText(self, infoText)
	self.MOTDScrollFrame.MOTD:SetText(GetGuildRosterMOTD(), true); --Extra argument ignores markup.
	self.DetailsFrame:GetScrollChild().Details:SetText(infoText or GetGuildInfoText());
	self.DetailsFrame:SetVerticalScroll(0);
	self.DetailsFrame.ScrollBar.ScrollUpButton:Disable();
end

local CHALLENGE_ORDER = { 1, 4, 2, 3, };
function CommunitiesGuildInfoFrame_UpdateChallenges(self)
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
	CommunitiesGuildTextEditFrame_SetType(CommunitiesGuildTextEditFrame, self.editType, self:GetParent());
	if not CommunitiesGuildTextEditFrame:IsShown() then
		local toggled = CallMethodOnNearestAncestor(self, "ToggleSubPanel", CommunitiesGuildTextEditFrame);
		if not toggled then
			ToggleFrame(CommunitiesGuildTextEditFrame);
		end
	end
end

--*******************************************************************************
--   Popups
--*******************************************************************************

function CommunitiesGuildTextEditFrame_OnLoad(self)
	self.Container.ScrollFrame.EditBox:SetTextInsets(4, 0, 4, 4);
	self.Container.ScrollFrame.EditBox:SetSpacing(2);
end

function CommunitiesGuildTextEditFrame_SetType(self, editType, guildInfoFrame)
	if ( editType == "motd" ) then
		self:SetHeight(162);
		self.Container.ScrollFrame.EditBox:SetMaxLetters(255);
		self.Container.ScrollFrame.EditBox:SetText(GetGuildRosterMOTD());
		self.Title:SetText(GUILD_MOTD_EDITLABEL);
		self.Container.ScrollFrame.EditBox:SetScript("OnEnterPressed", CommunitiesGuildTextEditFrame_OnAccept);
	elseif ( editType == "info" ) then
		self:SetHeight(295);
		self.Container.ScrollFrame.EditBox:SetMaxLetters(499);
		self.Container.ScrollFrame.EditBox:SetText(GetGuildInfoText());
		self.Title:SetText(GUILD_INFO_EDITLABEL);
		self.Container.ScrollFrame.EditBox:SetScript("OnEnterPressed", nil);
	end
	self.type = editType;
	self.guildInfoFrame = guildInfoFrame;
	self.Container.ScrollFrame.EditBox:SetCursorPosition(0);
	self.Container.ScrollFrame.EditBox:SetFocus();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function CommunitiesGuildTextEditFrame_OnAccept()
	if ( CommunitiesGuildTextEditFrame.type == "motd" ) then
		GuildSetMOTD(CommunitiesGuildTextEditFrame.Container.ScrollFrame.EditBox:GetText());
	elseif ( CommunitiesGuildTextEditFrame.type == "info" ) then
		local infoText = CommunitiesGuildTextEditFrame.Container.ScrollFrame.EditBox:GetText();
		SetGuildInfoText(infoText);
		CommunitiesGuildInfoFrame_UpdateText(CommunitiesGuildTextEditFrame.guildInfoFrame, infoText);
	end
	HideUIPanel(CommunitiesGuildTextEditFrame);
end

function CommunitiesGuildLogFrame_OnLoad(self)
	self.Container.ScrollFrame.Child.HTMLFrame:SetSpacing(2);
	ScrollBar_AdjustAnchors(self.Container.ScrollFrame.ScrollBar, 0, -2);
	self:RegisterEvent("GUILD_EVENT_LOG_UPDATE");
end

function CommunitiesGuildLogFrame_Update(self)
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
	self.Container.ScrollFrame.Child.HTMLFrame:SetText(buffer);
end