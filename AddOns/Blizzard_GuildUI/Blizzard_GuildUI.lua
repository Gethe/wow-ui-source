UIPanelWindows["GuildFrame"] = { area = "left", pushable = 1, xoffset = 16};

GUILDMEMBERS_TO_DISPLAY = 13;
FRIENDS_FRAME_GUILD_HEIGHT = 14;
CURRENT_GUILD_MOTD = "";
GUILD_DETAIL_NORM_HEIGHT = 195
GUILD_DETAIL_OFFICER_HEIGHT = 255
GUILDEVENT_TRANSACTION_HEIGHT = 13;
MAX_EVENTS_SHOWN = 25;

function GuildFrame_OnLoad(self)
	-- events
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
	self:RegisterEvent("GUILD_MOTD");
	-- tabs
	PanelTemplates_SetNumTabs(self, 6)
	GuildFrame_TabClicked(GuildFrameTab1);
	PVPFrame_TabClicked(GuildFrameTab1);	
	
	GuildFrame.notesToggle = 1;
	GuildFrame.selectedGuildMember = 0;
	SetGuildRosterSelection(0);
	CURRENT_GUILD_MOTD = GetGuildRosterMOTD();
	GuildFrameNotesText:SetText(CURRENT_GUILD_MOTD);
	GuildMemberDetailRankText:SetPoint("RIGHT", GuildFramePromoteButton, "LEFT");
end

function GuildFrame_OnShow(self)
	UpdateMicroButtons();
	GuildRoster();
end

function GuildFrame_OnHide(self)
	UpdateMicroButtons();
	SetGuildRosterSelection(0);
	GuildFrame.selectedGuildMember = 0;
	GuildFramePopup_HideAll();
end

function GuildFrame_Toggle()
	if ( GuildFrame:IsShown() ) then
		HideUIPanel(GuildFrame);
	else
		ShowUIPanel(GuildFrame);
	end
end

local GUILDFRAME_PANELS = { "GuildPanelGuild", "GuildDisplayFrame" };
function GuildFrame_RegisterPanel(frameName)
	tinsert(GUILDFRAME_PANELS, frameName);
end

function GuildFrame_ShowPanel(frameName)
	for index, value in pairs(GUILDFRAME_PANELS) do
		if ( value == frameName ) then
			_G[value]:Show()
		else
			_G[value]:Hide();
		end	
	end 
end

function GuildFrame_TabClicked(self)
	local tabIndex = self:GetID()	
	PanelTemplates_SetTab(self:GetParent(), tabIndex);
	self:GetParent().lastSelectedTab = self;
		
	if ( tabIndex == 1 ) then -- Guild
		ButtonFrameTemplate_HideButtonBar(GuildFrame);
		GuildFrame_ShowPanel("GuildPanelGuild");
		GuildFrameInset:SetPoint("TOPLEFT", 4, -65);
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 170);
		GuildFrameBottomInset:Show();
		GuildXPBar:Show();
		GuildPlayerXPBar:Show();
		GuildAddMemberButton:Hide();
		GuildControlButton:Hide();
		GuildViewLogButton:Hide();
	elseif ( tabIndex == 2 ) then -- Roster 
		ButtonFrameTemplate_HideButtonBar(GuildFrame);
		GuildFrame_ShowPanel("GuildRosterFrame");
		GuildFrameInset:SetPoint("TOPLEFT", 4, -90);
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 26);
		GuildFrameBottomInset:Hide();
		GuildXPBar:Hide();
		GuildPlayerXPBar:Hide();
		GuildAddMemberButton:Hide();
		GuildControlButton:Hide();
		GuildViewLogButton:Hide();
	elseif ( tabIndex == 3 ) then -- News
		ButtonFrameTemplate_HideButtonBar(GuildFrame);
		GuildFrame_ShowPanel("GuildNewsFrame");
		GuildFrameInset:SetPoint("TOPLEFT", 4, -65);
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 44);
		GuildFrameBottomInset:Hide();
		GuildXPBar:Show();
		GuildPlayerXPBar:Hide();
		GuildAddMemberButton:Hide();
		GuildControlButton:Hide();
		GuildViewLogButton:Hide();
	elseif ( tabIndex == 4 ) then -- Rewards
		ButtonFrameTemplate_HideButtonBar(GuildFrame);
		GuildFrame_ShowPanel("GuildRewardsFrame");
		GuildFrameInset:SetPoint("TOPLEFT", 4, -65);
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 44);
		GuildFrameBottomInset:Hide();
		GuildXPBar:Hide();
		GuildPlayerXPBar:Hide();
		GuildAddMemberButton:Hide();
		GuildControlButton:Hide();
		GuildViewLogButton:Hide();
	elseif ( tabIndex == 5 ) then -- Info
		ButtonFrameTemplate_ShowButtonBar(GuildFrame);
		GuildFrame_ShowPanel("GuildInfoFrame");
		GuildFrameInset:SetPoint("TOPLEFT", 4, -65);
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 26);
		GuildFrameBottomInset:Hide();
		GuildXPBar:Hide();
		GuildPlayerXPBar:Hide();
		GuildAddMemberButton:Show();
		GuildControlButton:Show();
		GuildViewLogButton:Show();
	elseif ( tabIndex == 6 ) then -- old stuff
		ButtonFrameTemplate_HideButtonBar(GuildFrame);
		GuildFrameInset:SetPoint("TOPLEFT", 4, -65);
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 40);
		GuildFrameBottomInset:Hide();
		GuildXPBar:Hide();
		GuildPlayerXPBar:Hide();
		GuildAddMemberButton:Hide();
		GuildControlButton:Hide();
		GuildViewLogButton:Hide();	
		GuildFrame_ShowPanel("GuildDisplayFrame");
	end
end

function GuildFrame_OnEvent(self, event, ...)
	if ( event == "GUILD_ROSTER_UPDATE" ) then
		GuildInfoFrame.cachedText = nil;
		if ( GuildFrame:IsShown() ) then
			local arg1 = ...;
			if ( arg1 ) then
				GuildRoster();
			end
			GuildStatus_Update();			
		end
	elseif ( event == "PLAYER_GUILD_UPDATE" ) then
		if ( GuildFrame:IsVisible() ) then
			InGuildCheck();
		end
		if ( not IsInGuild() ) then
			GuildControlPopupFrame.initialized = false;
		end
	elseif ( event == "GUILD_MOTD") then
		CURRENT_GUILD_MOTD = ...;
		GuildFrameNotesText:SetText(CURRENT_GUILD_MOTD);
	end
end

function GuildDisplayFrame_OnShow(self)
	GuildRoster();
	GuildFrame.selectedGuildMember = 0;
	SetGuildRosterSelection(0);
	InGuildCheck();
	GuildStatus_Update();
end

function GuildStatus_Update()
	if ( IsGuildLeader() ) then
		GuildFrameControlButton:Enable();
	else
		GuildFrameControlButton:Disable();
	end

	-- Number of players in the lowest rank
	FriendsFrame.playersInBotRank = 0;		-- used for Remove Rank option

	local numGuildMembers = GetNumGuildMembers();
	local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName;
	local guildName, guildRankName, guildRankIndex = GetGuildInfo("player");
	local maxRankIndex = GuildControlGetNumRanks() - 1;
	local button, buttonText, classTextColor;
	local onlinecount = 0;
	local guildIndex;

	-- Get selected guild member info
	name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(GetGuildRosterSelection());
	GuildFrame.selectedName = name;
	-- If there's a selected guildmember
	if ( GetGuildRosterSelection() > 0 ) then
		-- Update the guild member details frame
		GuildMemberDetailName:SetText(GuildFrame.selectedName);
		GuildMemberDetailLevel:SetFormattedText(FRIENDS_LEVEL_TEMPLATE, level, class);
		GuildMemberDetailZoneText:SetText(zone);
		GuildMemberDetailRankText:SetText(rank);
		if ( online ) then
			GuildMemberDetailOnlineText:SetText(GUILD_ONLINE_LABEL);
		else
			GuildMemberDetailOnlineText:SetText(GuildFrame_GetLastOnline(GetGuildRosterSelection()));
		end
		-- Update public note
		if ( CanEditPublicNote() ) then
			PersonalNoteText:SetTextColor(1.0, 1.0, 1.0);
			if ( (not note) or (note == "") ) then
				note = GUILD_NOTE_EDITLABEL;
			end
		else
			PersonalNoteText:SetTextColor(0.65, 0.65, 0.65);
		end
		GuildMemberNoteBackground:EnableMouse(CanEditPublicNote());
		PersonalNoteText:SetText(note);
		-- Update officer note
		if ( CanViewOfficerNote() ) then
			if ( CanEditOfficerNote() ) then
				if ( (not officernote) or (officernote == "") ) then
					officernote = GUILD_OFFICERNOTE_EDITLABEL;
				end
				OfficerNoteText:SetTextColor(1.0, 1.0, 1.0);
			else
				OfficerNoteText:SetTextColor(0.65, 0.65, 0.65);
			end
			GuildMemberOfficerNoteBackground:EnableMouse(CanEditOfficerNote());
			OfficerNoteText:SetText(officernote);

			-- Resize detail frame
			GuildMemberDetailOfficerNoteLabel:Show();
			GuildMemberOfficerNoteBackground:Show();
			GuildMemberDetailFrame:SetHeight(GUILD_DETAIL_OFFICER_HEIGHT);
		else
			GuildMemberDetailOfficerNoteLabel:Hide();
			GuildMemberOfficerNoteBackground:Hide();
			GuildMemberDetailFrame:SetHeight(GUILD_DETAIL_NORM_HEIGHT);
		end

		-- Manage guild member related buttons
		if ( CanGuildPromote() and ( rankIndex > 1 ) and ( rankIndex > (guildRankIndex + 1) ) ) then
			GuildFramePromoteButton:Enable();
		else 
			GuildFramePromoteButton:Disable();
		end
		if ( CanGuildDemote() and ( rankIndex >= 1 ) and ( rankIndex > guildRankIndex ) and ( rankIndex ~= maxRankIndex ) ) then
			GuildFrameDemoteButton:Enable();
		else
			GuildFrameDemoteButton:Disable();
		end
		-- Hide promote/demote buttons if both disabled
		if ( not GuildFrameDemoteButton:IsEnabled() and not GuildFramePromoteButton:IsEnabled() ) then
			GuildFramePromoteButton:Hide();
			GuildFrameDemoteButton:Hide();
		else
			GuildFramePromoteButton:Show();
			GuildFrameDemoteButton:Show();
		end
		if ( CanGuildRemove() and ( rankIndex >= 1 ) and ( rankIndex > guildRankIndex ) ) then
			GuildMemberRemoveButton:Enable();
		else
			GuildMemberRemoveButton:Disable();
		end
		if ( (UnitName("player") == name) or (not online) ) then
			GuildMemberGroupInviteButton:Disable();
		else
			GuildMemberGroupInviteButton:Enable();
		end

		GuildFrame.selectedName = GetGuildRosterInfo(GetGuildRosterSelection()); 
	else
		GuildMemberDetailFrame:Hide();
	end
	
	-- Message of the day stuff
	local guildMOTD = GetGuildRosterMOTD();
	if ( CanEditMOTD() ) then
		if ( (not guildMOTD) or (guildMOTD == "") ) then
			guildMOTD = GUILD_MOTD_EDITLABEL;
		end
		GuildFrameNotesText:SetTextColor(1.0, 1.0, 1.0);
		GuildMOTDEditButton:Enable();
	else
		GuildFrameNotesText:SetTextColor(0.65, 0.65, 0.65);
		GuildMOTDEditButton:Disable();
	end
	GuildFrameNotesText:SetText(CURRENT_GUILD_MOTD);

	-- Scrollbar stuff
	local showScrollBar = nil;
	if ( numGuildMembers > GUILDMEMBERS_TO_DISPLAY ) then
		showScrollBar = 1;
	end
	
	-- Get number of online members
	for i=1, numGuildMembers, 1 do
		name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(i);
		if ( online ) then
			onlinecount = onlinecount + 1;
		end
		if ( rankIndex == maxRankIndex ) then
			FriendsFrame.playersInBotRank = FriendsFrame.playersInBotRank + 1;
		end
	end
	GuildFrameTotals:SetFormattedText(GUILD_TOTAL, numGuildMembers);
	GuildFrameOnlineTotals:SetFormattedText(GUILD_TOTALONLINE, onlinecount);

	if ( CanGuildInvite() ) then
		GuildFrameAddMemberButton:Enable();
	else
		GuildFrameAddMemberButton:Disable();
	end

	if ( FriendsFrame.playerStatusFrame ) then
		-- Player specific info
		local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame);

		for i=1, GUILDMEMBERS_TO_DISPLAY, 1 do
			guildIndex = guildOffset + i;
			button = _G["GuildFrameButton"..i];
			button.guildIndex = guildIndex;
			name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName = GetGuildRosterInfo(guildIndex);

			if ( not online ) then
				buttonText = _G["GuildFrameButton"..i.."Name"];
				buttonText:SetText(name);
				buttonText:SetTextColor(0.5, 0.5, 0.5);
				buttonText = _G["GuildFrameButton"..i.."Zone"];
				buttonText:SetText(zone);
				buttonText:SetTextColor(0.5, 0.5, 0.5);
				buttonText = _G["GuildFrameButton"..i.."Level"];
				buttonText:SetText(level);
				buttonText:SetTextColor(0.5, 0.5, 0.5);
				buttonText = _G["GuildFrameButton"..i.."Class"];
				buttonText:SetText(class);
				buttonText:SetTextColor(0.5, 0.5, 0.5);
			else
				if ( classFileName ) then
					classTextColor = RAID_CLASS_COLORS[classFileName];
				else
					classTextColor = NORMAL_FONT_COLOR;
				end

				buttonText = _G["GuildFrameButton"..i.."Name"];
				buttonText:SetText(name);
				buttonText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				buttonText = _G["GuildFrameButton"..i.."Zone"];
				buttonText:SetText(zone);
				buttonText:SetTextColor(1.0, 1.0, 1.0);
				buttonText = _G["GuildFrameButton"..i.."Level"];
				buttonText:SetText(level);
				buttonText:SetTextColor(1.0, 1.0, 1.0);
				buttonText = _G["GuildFrameButton"..i.."Class"];
				buttonText:SetText(class);
				buttonText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);
			end

			-- If need scrollbar resize columns
			if ( showScrollBar ) then
				_G["GuildFrameButton"..i.."Zone"]:SetWidth(95);
			else
				_G["GuildFrameButton"..i.."Zone"]:SetWidth(110);
			end

			-- Highlight the correct who
			if ( GetGuildRosterSelection() == guildIndex ) then
				button:LockHighlight();
			else
				button:UnlockHighlight();
			end
			
			if ( guildIndex > numGuildMembers ) then
				button:Hide();
			else
				button:Show();
			end
		end
		
		GuildFrameGuildListToggleButton:SetText(PLAYER_STATUS);
		-- If need scrollbar resize column headers
		if ( showScrollBar ) then
			--WhoFrameColumn_SetWidth(GuildFrameColumnHeader2, 105);
			GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 284, -120);
		else
			--WhoFrameColumn_SetWidth(GuildFrameColumnHeader2, 120);
			GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 307, -120);
		end
		-- ScrollFrame update
		FauxScrollFrame_Update(GuildListScrollFrame, numGuildMembers, GUILDMEMBERS_TO_DISPLAY, FRIENDS_FRAME_GUILD_HEIGHT );
		
		GuildPlayerStatusFrame:Show();
		GuildStatusFrame:Hide();
	else
		-- Guild specific info
		local year, month, day, hour;
		local yearlabel, monthlabel, daylabel, hourlabel;
		local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame);
		local classFileName;
		
		for i=1, GUILDMEMBERS_TO_DISPLAY, 1 do
			guildIndex = guildOffset + i;
			button = _G["GuildFrameGuildStatusButton"..i];
			button.guildIndex = guildIndex;
			name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName = GetGuildRosterInfo(guildIndex);

			_G["GuildFrameGuildStatusButton"..i.."Name"]:SetText(name);
			_G["GuildFrameGuildStatusButton"..i.."Rank"]:SetText(rank);
			_G["GuildFrameGuildStatusButton"..i.."Note"]:SetText(note);

			if ( online ) then
				if ( status == "" ) then
					_G["GuildFrameGuildStatusButton"..i.."Online"]:SetText(GUILD_ONLINE_LABEL);
				else
					_G["GuildFrameGuildStatusButton"..i.."Online"]:SetText(status);
				end

				if ( classFileName ) then
					classTextColor = RAID_CLASS_COLORS[classFileName];
				else
					classTextColor = NORMAL_FONT_COLOR;
				end
				_G["GuildFrameGuildStatusButton"..i.."Name"]:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				_G["GuildFrameGuildStatusButton"..i.."Rank"]:SetTextColor(1.0, 1.0, 1.0);
				_G["GuildFrameGuildStatusButton"..i.."Note"]:SetTextColor(1.0, 1.0, 1.0);
				_G["GuildFrameGuildStatusButton"..i.."Online"]:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);
			else
				_G["GuildFrameGuildStatusButton"..i.."Online"]:SetText(GuildFrame_GetLastOnline(guildIndex));
				_G["GuildFrameGuildStatusButton"..i.."Name"]:SetTextColor(0.5, 0.5, 0.5);
				_G["GuildFrameGuildStatusButton"..i.."Rank"]:SetTextColor(0.5, 0.5, 0.5);
				_G["GuildFrameGuildStatusButton"..i.."Note"]:SetTextColor(0.5, 0.5, 0.5);
				_G["GuildFrameGuildStatusButton"..i.."Online"]:SetTextColor(0.5, 0.5, 0.5);
			end

			-- If need scrollbar resize columns
			if ( showScrollBar ) then
				_G["GuildFrameGuildStatusButton"..i.."Note"]:SetWidth(70);
			else
				_G["GuildFrameGuildStatusButton"..i.."Note"]:SetWidth(85);
			end

			-- Highlight the correct who
			if ( GetGuildRosterSelection() == guildIndex ) then
				button:LockHighlight();
			else
				button:UnlockHighlight();
			end

			if ( guildIndex > numGuildMembers ) then
				button:Hide();
			else
				button:Show();
			end
		end
		
		GuildFrameGuildListToggleButton:SetText(GUILD_STATUS);
		-- If need scrollbar resize columns
		if ( showScrollBar ) then
			WhoFrameColumn_SetWidth(GuildFrameGuildStatusColumnHeader3, 75);
			GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 284, -120);
		else
			WhoFrameColumn_SetWidth(GuildFrameGuildStatusColumnHeader3, 90);
			GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 307, -120);
		end
		
		-- ScrollFrame update
		FauxScrollFrame_Update(GuildListScrollFrame, numGuildMembers, GUILDMEMBERS_TO_DISPLAY, FRIENDS_FRAME_GUILD_HEIGHT );

		GuildPlayerStatusFrame:Hide();
		GuildStatusFrame:Show();
	end
end

function FriendsFrameGuildStatusButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		GuildFrame.previousSelectedGuildMember = GuildFrame.selectedGuildMember;
		GuildFrame.selectedGuildMember = self.guildIndex;
		GuildFrame.selectedName = _G[self:GetName().."Name"]:GetText();
		SetGuildRosterSelection(GuildFrame.selectedGuildMember);
		-- Toggle guild details frame
		if ( GuildMemberDetailFrame:IsShown() and (GuildFrame.previousSelectedGuildMember and (GuildFrame.previousSelectedGuildMember == GuildFrame.selectedGuildMember)) ) then
			GuildMemberDetailFrame:Hide();
			GuildFrame.selectedGuildMember = 0;
			SetGuildRosterSelection(0);
		else
			GuildFramePopup_Show(GuildMemberDetailFrame);
		end
		GuildStatus_Update();
	else
		local guildIndex = self.guildIndex;
		local name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(guildIndex);
		FriendsFrame_ShowDropdown(name, online);
	end
end

function InGuildCheck()
	--print("call to InGuildCheck")
	--[[
	if ( not IsInGuild() ) then
		PanelTemplates_DisableTab( FriendsFrame, 3 );
		if ( FriendsFrame.selectedTab == 3 ) then
			FriendsFrame.selectedTab = 1;
			FriendsFrame_Update();
		end
	else
		PanelTemplates_EnableTab( FriendsFrame, 3 );
		FriendsFrame_Update();
	end
	]]--
end

function GuildFrameGuildListToggleButton_OnClick()
	if ( FriendsFrame.playerStatusFrame ) then
		FriendsFrame.playerStatusFrame = nil;
	else
		FriendsFrame.playerStatusFrame = 1;		
	end
	GuildStatus_Update();
end

function GuildFrameControlButton_OnUpdate(self)
	if ( FriendsFrame.guildControlShow == 1 ) then
		GuildFrameControlButton:LockHighlight();		
	else
		GuildFrameControlButton:UnlockHighlight();
	end
	-- Janky way to make sure a change made to the guildroster will reflect in the guildroster call
	--if ( GuildControlPopupFrame.update == 1 ) then
	--	GuildControlPopupFrame.update = 2;
	--elseif ( GuildControlPopupFrame.update == 2 ) then
	--	GuildRoster();
	--	GuildControlPopupFrame.update = nil;
	--end
end

function GuildFrame_GetLastOnline(guildIndex)
	return RecentTimeDate( GetGuildRosterLastOnline(guildIndex) );
end

function ToggleGuildInfoFrame()
	if ( GuildInfoFrame2:IsShown() ) then
		GuildInfoFrame2:Hide();
	else
		GuildFramePopup_Show(GuildInfoFrame2);
	end
end

-- Guild event log functions
function ToggleGuildEventLog()
	if ( GuildEventLogFrame:IsShown() ) then
		GuildEventLogFrame:Hide();
	else
		GuildFramePopup_Show(GuildEventLogFrame);
--		QueryGuildEventLog();
	end
end

function GuildEventLog_Update()
	local numEvents = GetNumGuildEvents();
	local type, player1, player2, rank, year, month, day, hour;
	local msg;
	local buffer = "";
	local max = GuildEventMessage:GetFieldSize()
	local length = 0;
	for i=numEvents, 1, -1 do
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
			msg = msg.."|cff009999   "..format(GUILD_BANK_LOG_TIME, RecentTimeDate(year, month, day, hour)).."|r|n";
			length = length + msg:len();
			if(length>max) then
				i=0
			else
				buffer = buffer..msg
			end
		end
	end
	GuildEventMessage:SetText(buffer);
end

GUILDFRAME_POPUPS = {
	"GuildEventLogFrame",
	"GuildTextEditFrame",
	"GuildMemberDetailFrame",
};

function GuildFramePopup_Show(frame)
	local name = frame:GetName();
	for index, value in ipairs(GUILDFRAME_POPUPS) do
		if ( name ~= value ) then
			_G[value]:Hide();
		end
	end
	frame:Show();
end

function GuildFramePopup_HideAll()
	for index, value in ipairs(GUILDFRAME_POPUPS) do
		_G[value]:Hide();
	end
end

--===================================================================================================================================================================
function GuildXPBar_SetProgress(currentValue, maxValue, capValue)
	local MAX_BAR = GuildXPBar:GetWidth() - 4;
	local progress = MAX_BAR * currentValue / maxValue;
	
	GuildXPBarProgress:SetWidth(progress + 1);
	if ( capValue + currentValue > maxValue ) then
		capValue = maxValue - currentValue;
	end
	local capWidth = MAX_BAR * capValue / maxValue;
	if ( capWidth > 0 ) then
		GuildXPBarCap:SetWidth(capWidth);
		GuildXPBarCap:Show();
		GuildXPBarCapMarker:Show();
	else
		GuildXPBarCap:Hide();
		GuildXPBarCapMarker:Hide();
	end
end

function GuildXPBar_OnLoad()
	local MAX_BAR = GuildXPBar:GetWidth();
	local space = MAX_BAR / 5;
	local offset = space - 3;
	GuildXPBarDivider1:SetPoint("LEFT", GuildXPBarLeft, "LEFT", offset, 0);
	offset = offset + space;
	GuildXPBarDivider2:SetPoint("LEFT", GuildXPBarLeft, "LEFT", offset, 0);
	offset = offset + space - 1;
	GuildXPBarDivider3:SetPoint("LEFT", GuildXPBarLeft, "LEFT", offset, 0);
	offset = offset + space - 1;
	GuildXPBarDivider4:SetPoint("LEFT", GuildXPBarLeft, "LEFT", offset, 0);	
end

function GuildFrame_UpdateTabard()
	--Set the tabard images
	local tabardBackgroundUpper, tabardBackgroundLower, tabardEmblemUpper, tabardEmblemLower, tabardBorderUpper, tabardBorderLower = GetGuildTabardFileNames();
	if ( not tabardEmblemUpper ) then
		tabardBackgroundUpper = "Textures\\GuildEmblems\\Background_49_TU_U";
		tabardBackgroundLower = "Textures\\GuildEmblems\\Background_49_TL_U";
	end
	GuildFrameEmblemBackgroundUL:SetTexture(tabardBackgroundUpper);
	GuildFrameEmblemBackgroundUR:SetTexture(tabardBackgroundUpper);
	GuildFrameEmblemBackgroundBL:SetTexture(tabardBackgroundLower);
	GuildFrameEmblemBackgroundBR:SetTexture(tabardBackgroundLower);
	GuildFrameEmblemUL:SetTexture(tabardEmblemUpper);
	GuildFrameEmblemUR:SetTexture(tabardEmblemUpper);
	GuildFrameEmblemBL:SetTexture(tabardEmblemLower);
	GuildFrameEmblemBR:SetTexture(tabardEmblemLower);
end

function GuildMainFrame_OnLoad()
	GuildUpdatesDivider:ClearAllPoints();	-- doing it once here so I don't have to do it on every update
	GuildPerksContainer.update = GuildPerks_Update;
	HybridScrollFrame_CreateButtons(GuildPerksContainer, "GuildPerksButtonTemplate", 8, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM");

	GuildPerksContainerScrollBar:SetFrameLevel(100);
	GuildPerksContainerScrollBarTop:Hide();
	GuildPerksContainerScrollBarMiddle:Hide();
	GuildPerksContainerScrollBarBottom:Hide();
	
	-- fake stuff
	_SetupFakePerks();
	GuildPerks_Update();
	GuildMainFrame_SetUpdates(10, 10);
	GuildLatestPerkButtonIconTexture:SetTexture("Interface\\Icons\\Ability_CheapShot");
	GuildLatestPerkButtonName:SetText("The Quick and the Dead");
	GuildNextPerkButtonIconTexture:SetTexture("Interface\\Icons\\Ability_ThunderBolt");
	GuildNextPerkButtonIconTexture:SetDesaturated(1);
	GuildNextPerkButtonName:SetText("The Quick and the Dead 2");
end

function GuildMainFrame_SetUpdates(numNews, numEvents)
	local divider;
	local maxNews = max(1, numNews);
	local maxEvents = max(1, numEvents);
	if ( maxNews + maxEvents <= 7 ) then
		if ( maxNews <= 4 and maxEvents <= 4 ) then
			divider = 5;
		else
			divider = maxNews + 1;
		end
	else
		if ( maxEvents <= 4 ) then
			divider = 9 - maxEvents;
		else
			divider = min(4, maxNews) + 1;
		end
	end
	
	local button;
	-- news
	if ( numNews == 0 ) then
		GuildUpdatesNoNews:Show();
		GuildUpdatesNoNews:SetPoint("TOP", GuildUpdatesButton1);
		GuildUpdatesNoNews:SetHeight((divider - 1) * 18);
	else
		GuildUpdatesNoNews:Hide();
	end
	for i = 1, divider - 1 do
		button = _G["GuildUpdatesButton"..i];
		button:SetHeight(18);
		if ( i > numNews ) then
			button:Hide();
		else
			button.text:SetText("This is guild news #"..i);
			button:Show();
			button.icon:Hide();
		end
	end
	-- divider
	button = _G["GuildUpdatesButton"..divider];
	GuildUpdatesDivider:SetPoint("CENTER", button);
	button:Hide();
	button:SetHeight(11);
	-- events
	if ( numEvents == 0 ) then
		GuildUpdatesNoEvents:Show();
		GuildUpdatesNoEvents:SetPoint("TOP", _G["GuildUpdatesButton"..(divider + 1)]);
		GuildUpdatesNoEvents:SetHeight((9 - divider) * 18);
	else
		GuildUpdatesNoEvents:Hide();
	end
	for i = 1, 9 - divider do
		button = _G["GuildUpdatesButton"..(divider + i)];
		button:SetHeight(18);
		if ( i > numEvents ) then
			button:Hide();
		else
			button.text:SetText("This is guild event #"..i);
			button.icon:SetTexture("Interface\\LFGFrame\\LFGIcon-NAXXRAMAS");
			button.icon:Show();
			button:Show();
		end
	end
end

function GuildPerks_Update()
	local scrollFrame = GuildPerksContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local button, index;
	
	for i = 1, numButtons do
		button = buttons[i];
		index = offset + i;
		if ( _GuildPerks[index] ) then
			button.name:SetText(_GuildPerks[index].name);
			button.level:SetText("Level ".._GuildPerks[index].level);
			button.icon:SetTexture(_GuildPerks[index].icon);
			button:Show();
			if ( _GuildPerks[index].locked ) then
				button:EnableDrawLayer("BORDER");
				button:DisableDrawLayer("BACKGROUND");
				button.icon:SetDesaturated(1);
				button.name:SetFontObject(GameFontNormalLeftGrey);
				button.lock:Show();
				button.level:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			else
				button:EnableDrawLayer("BACKGROUND");
				button:DisableDrawLayer("BORDER");
				button.icon:SetDesaturated(0);
				button.name:SetFontObject(GameFontHighlight);
				button.lock:Hide();
				button.level:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			end
		else
			button:Hide();
		end
	end
	local totalHeight = #_GuildPerks * scrollFrame.buttonHeight;
	local displayedHeight = numButtons * scrollFrame.buttonHeight;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
end

function GuildPerksToggleButton_OnClick(self)
	if ( GuildPanelGuild.allPerks ) then
		GuildPanelGuild.allPerks = nil;
		GuildNewPerksFrame:Show();
		GuildAllPerksFrame:Hide();
		-- inset stuff
		GuildFrameBottomInset:Show();
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 170);
		GuildPerksToggleButton:SetPoint("TOPLEFT", GuildFrameBottomInset);
		GuildPerksToggleButtonRightText:SetText("[View All Guild Perks]");
		GuildPerksToggleButtonArrow:SetTexCoord(0.01562500, 0.20312500, 0.01562500, 0.20312500);
	else
		GuildPanelGuild.allPerks = true;
		GuildAllPerksFrame:Show();
		GuildNewPerksFrame:Hide();
		-- inset stuff
		GuildFrameBottomInset:Hide();
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 44);
		GuildPerksToggleButton:SetPoint("TOPLEFT", GuildFrameInset);
		GuildPerksToggleButtonRightText:SetText("[View New Guild Perks]");
		GuildPerksToggleButtonArrow:SetTexCoord(0.01562500, 0.20312500, 0.20312500, 0.01562500);
	end
end

function GuildTextEditFrame_OnLoad()
	GuildTextEditBox:SetTextInsets(4, 0, 4, 4);
	GuildTextEditBox:SetSpacing(2);
	GuildTextEditScrollFrameScrollBarScrollDownButton:SetPoint("TOP", GuildTextEditScrollFrameScrollBar, "BOTTOM", 0, 4);
	GuildTextEditScrollFrameScrollBarScrollUpButton:SetPoint("BOTTOM", GuildTextEditScrollFrameScrollBar, "TOP", 0, -4);
end

function GuildTextEditFrame_Show(editType)
	if ( editType == "motd" ) then
		GuildTextEditFrame:SetHeight(162);
		GuildTextEditBox:SetMaxLetters(128);
		GuildTextEditBox:SetText(GetGuildRosterMOTD());
		GuildTextEditFrameTitle:SetText("Message of the Day");
		GuildTextEditBox:SetScript("OnEnterPressed", GuildTextEditFrame_OnAccept);
	elseif ( editType == "info" ) then
		GuildTextEditFrame:SetHeight(295);
		GuildTextEditBox:SetMaxLetters(500);
		GuildTextEditBox:SetText(GetGuildInfoText());
		GuildTextEditFrameTitle:SetText("Guild Information");
		GuildTextEditBox:SetScript("OnEnterPressed", nil);
	end
	GuildTextEditFrame.type = editType;
	GuildTextEditBox:SetCursorPosition(0);
	GuildTextEditFrame:Show();
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

function CloseGuildMenus()
	if ( GuildTextEditFrame:IsShown() ) then
		GuildTextEditFrame:Hide();
		return true;
	end
end

--==================================================================================================================
local _GuildNames = { "Alpha", "Bravo", "Charlie", "The Quick and the Dead", "An Even Longer Guild Perk Name", "Foxtrot", "Golf", "Hotel", "India", "Juliet", "Kilo", "Lima", "Mike", "November", "Oscar", "Papa", "Quebec", "Romeo", "Sierra", "Tango", "Uniform", "Victor", "Whisky", "Xray", "Yankee", "Zulu" }
_GuildPerks = { };

function _SetupFakePerks()	
	for i = 1, #_GuildNames do
		local guildMember = { };
		guildMember["name"] = _GuildNames[i];
		guildMember["level"] = i;		
		guildMember["icon"] = GetMacroIconInfo(i);
		if ( i > 10 ) then
			guildMember["locked"] = true;
		end		
		table.insert(_GuildPerks, guildMember);
	end
end