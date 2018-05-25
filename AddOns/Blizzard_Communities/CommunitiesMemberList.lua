
local COMMUNITIES_MEMBER_LIST_EVENTS = {
	"CLUB_MEMBER_ADDED",
	"CLUB_MEMBER_REMOVED",
	"CLUB_MEMBER_UPDATED",
	"VOICE_CHAT_CHANNEL_ACTIVATED",
	"VOICE_CHAT_CHANNEL_DEACTIVATED",
	"VOICE_CHAT_CHANNEL_JOINED",
	"VOICE_CHAT_CHANNEL_REMOVED",
	"VOICE_CHAT_CHANNEL_MEMBER_ADDED",
	"CLUB_INVITATIONS_RECEIVED_FOR_CLUB",
};

local COMMUNITIES_MEMBER_LIST_ENTRY_EVENTS = {
	"CLUB_MEMBER_PRESENCE_UPDATED",
	"CLUB_MEMBER_ROLE_UPDATED",
	"VOICE_CHAT_CHANNEL_MEMBER_ACTIVE_STATE_CHANGED",
	"PLAYER_GUILD_UPDATE",
};

COMMUNITY_MEMBER_ROLE_NAMES = {
	[Enum.ClubRoleIdentifier.Owner] = COMMUNITY_MEMBER_ROLE_NAME_OWNER,
	[Enum.ClubRoleIdentifier.Leader] = COMMUNITY_MEMBER_ROLE_NAME_LEADER,
	[Enum.ClubRoleIdentifier.Moderator] = COMMUNITY_MEMBER_ROLE_NAME_MODERATOR,
	[Enum.ClubRoleIdentifier.Member] = COMMUNITY_MEMBER_ROLE_NAME_MEMBER,
};

local BNET_COLUMN_INFO = {
	[1] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_NAME,
		width = 145,
		attribute = "name",
	},
	
	[2] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_RANK,
		width = 85,
		attribute = "role",
	},
	
	[3] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_NOTE,
		width = 0,
		attribute = "memberNote",
	},
};

local CHARACTER_COLUMN_INFO = {
	[1] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_LEVEL,
		width = 40,
		attribute = "level",
	},
	
	[2] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_CLASS,
		width = 30,
		attribute = "classID",
	},
	
	[3] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_NAME,
		width = 100,
		attribute = "name",
	},
	
	[4] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_ZONE,
		width = 100,
		attribute = "zone",
	},
	
	[5] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_RANK,
		width = 85,
		attribute = "role",
	},
	
	[6] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_NOTE,
		width = 0,
		attribute = "memberNote",
	},
};

local EXTRA_GUILD_COLUMN_ACHIEVEMENT = 1;
local EXTRA_GUILD_COLUMN_PROFESSION = 2;
local EXTRA_GUILD_COLUMNS = {
	[EXTRA_GUILD_COLUMN_ACHIEVEMENT] = {
		dropdownText = GUILLD_ROSTER_DROPDOWN_ACHIEVEMENT_POINTS or "Achievement Points",
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_ACHIEVEMENT or "Achievement Points",
		width = 130,
	};

	[EXTRA_GUILD_COLUMN_PROFESSION] = {
		dropdownText = GUILLD_ROSTER_DROPDOWN_PROFESSION or "Profession",
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_PROFESSION or "Skill",
		width = 130,
	};
};

CommunitiesMemberListMixin = {};

function CommunitiesMemberListMixin:OnClubSelected(clubId)
	self.activeColumnSortIndex = nil;
	self:Update();
end

function CommunitiesMemberListMixin:SetVoiceChannel(voiceChannel)
	self.linkedVoiceChannel = voiceChannel;
end

function CommunitiesMemberListMixin:GetVoiceChannel(voiceChannel)
	local hideVoiceChannel = self.expandedDisplay;
	return not hideVoiceChannel and self.linkedVoiceChannel or nil;
end

function CommunitiesMemberListMixin:GetVoiceChannelID()
	if self.linkedVoiceChannel then
		return self.linkedVoiceChannel.channelID;
	end

	return nil;
end

function CommunitiesMemberListMixin:UpdateVoiceChannel()
	local clubId = self:GetSelectedClubId();
	local streamId = self:GetSelectedStreamId();
	if clubId and streamId then
		self:SetVoiceChannel(C_VoiceChat.GetChannelForCommunityStream(clubId, streamId));
	else
		self:SetVoiceChannel(nil);
	end
end

function CommunitiesMemberListMixin:RefreshListDisplay()
	local scrollFrame = self.ListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	
	local usedHeight = 0;
	local height = buttons[1]:GetHeight();
	local memberList = self.sortedMemberList;
	local invitations = self.invitations;
	for i = 1, #buttons do
		local displayIndex = i + offset;
		local button = buttons[i];
		if displayIndex <= #memberList then
			local memberInfo = memberList[displayIndex];
			button:SetMember(memberInfo);
			button:Show();
			usedHeight = usedHeight + height;
		else
			displayIndex = (displayIndex - #memberList) - 1;
			if displayIndex == 0 then
				-- Leave an extra space between the member list and invitations.
				button:SetMember(nil);
				button:Hide();
				usedHeight = usedHeight + height;
			elseif self.expandedDisplay and displayIndex <= #invitations then
				button:SetMember(invitations[displayIndex].invitee, true);
				button:Show();
				usedHeight = usedHeight + height;
			else
				button:SetMember(nil);
				button:Hide();
			end
		end
	end
	HybridScrollFrame_Update(scrollFrame, height * #memberList, usedHeight);
end

function CommunitiesMemberListMixin:Update()
	local clubId = self:GetSelectedClubId();
	local streamId;

	-- If we are showing the expandedDisplay, leave streamId as nil, so we show the roster of the whole club instead of just the current stream
	if not self.expandedDisplay then
		streamId = self:GetSelectedStreamId();
	end

	self:UpdateVoiceChannel();

	self.sortedMemberList = CommunitiesUtil.GetAndSortMemberInfo(clubId, streamId);
	if self.activeColumnSortIndex then
		self:SortByColumnIndex(self.activeColumnSortIndex);
	end
	
	self:RefreshListDisplay();
end

function CommunitiesMemberListMixin:SortList()
	CommunitiesUtil.SortMemberInfo(self.sortedMemberList);
	self:RefreshListDisplay();
end

function CommunitiesMemberListMixin:OnLoad()
	self.ListScrollFrame.update = function()
		self:Update(); 
	end;
	
	self.invitations = {};
	
	self.ListScrollFrame.scrollBar.doNotHide = true;
	self.ListScrollFrame.scrollBar:SetValue(0);
	
	self:SetExpandedDisplay(false);
	self:SetGuildColumnIndex(EXTRA_GUILD_COLUMN_ACHIEVEMENT);
end
	
function CommunitiesMemberListMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_MEMBER_LIST_EVENTS);
	
	self:Update();

	local function StreamSelectedCallback(event, streamId)
		self:Update();
	end

	self.streamSelectedCallback = StreamSelectedCallback;
	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.StreamSelected, self.streamSelectedCallback);

	local function CommunitiesDisplayModeChangedCallback(event, displayMode)
		local expandedDisplay = displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER;
		self:SetExpandedDisplay(expandedDisplay);
	end
	
	self.displayModeChangedCallback = CommunitiesDisplayModeChangedCallback;
	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.DisplayModeChanged, self.displayModeChangedCallback);
end

function CommunitiesMemberListMixin:UpdateInvitations()
	local clubId = self:GetCommunitiesFrame():GetSelectedClubId();
	if self:GetCommunitiesFrame():GetPrivilegesForClub(clubId).canGetInvitation then
		C_Club.RequestInvitationsForClub(clubId);
	end
end

function CommunitiesMemberListMixin:OnInvitationsUpdated()
	self.invitations = C_Club.GetInvitationsForClub(self:GetCommunitiesFrame():GetSelectedClubId());
	self:RefreshListDisplay();
end

function CommunitiesMemberListMixin:SetExpandedDisplay(expandedDisplay)
	if expandedDisplay then
		self:UpdateInvitations();
	end
	
	self.expandedDisplay = expandedDisplay;
	self:RefreshLayout();
end

function CommunitiesMemberListMixin:RefreshLayout()
	if self.expandedDisplay then
		self:SetPoint("TOPLEFT", self:GetCommunitiesFrame().CommunitiesList, "TOPRIGHT", 26, -60);
	else
		self:SetPoint("TOPLEFT", self:GetCommunitiesFrame(), "TOPRIGHT", -165, -63);
	end
	
	HybridScrollFrame_CreateButtons(self.ListScrollFrame, "CommunitiesMemberListEntryTemplate", 0, 0);
	
	self.ColumnDisplay:Hide();
	local guildColumnIndex = nil;
	if self.expandedDisplay then
		local clubId = self:GetCommunitiesFrame():GetSelectedClubId();
		if clubId then
			local clubInfo = C_Club.GetClubInfo(clubId);
			if clubInfo then
				if clubInfo.clubType == Enum.ClubType.Guild then
					guildColumnIndex = self:GetGuildColumnIndex();
					self.columnInfo = CHARACTER_COLUMN_INFO;
					self.ColumnDisplay:LayoutColumns(CHARACTER_COLUMN_INFO, EXTRA_GUILD_COLUMNS[guildColumnIndex]);
				elseif clubInfo.clubType == Enum.ClubType.Character then
					self.columnInfo = CHARACTER_COLUMN_INFO;
					self.ColumnDisplay:LayoutColumns(CHARACTER_COLUMN_INFO);
				else
					self.columnInfo = BNET_COLUMN_INFO;
					self.ColumnDisplay:LayoutColumns(BNET_COLUMN_INFO);
				end
				
				self.ColumnDisplay:Show();
			end
		end
	end
	
	for i, button in ipairs(self.ListScrollFrame.buttons or {}) do
		button:SetExpanded(self.expandedDisplay);
		button:SetGuildColumnIndex(guildColumnIndex);
	end
end

function CommunitiesMemberListMixin:OnEvent(event, ...)
	if event == "CLUB_MEMBER_ADDED" or event == "CLUB_MEMBER_REMOVED" or event == "CLUB_MEMBER_UPDATED" or event == "VOICE_CHAT_CHANNEL_JOINED" or event == "VOICE_CHAT_CHANNEL_REMOVED" then
		self:Update();
		
		local clubId, memberId = ...;
		if event == "CLUB_MEMBER_ADDED" and clubId == self:GetSelectedClubId() then
			self:RemoveInvitation(memberId);
		end
	elseif event == "VOICE_CHAT_CHANNEL_ACTIVATED" or event == "VOICE_CHAT_CHANNEL_DEACTIVATED" then
		local voiceChannelID = ...;
		if voiceChannelID == self:GetVoiceChannelID() then
			self:Update();
		end
	elseif event == "VOICE_CHAT_CHANNEL_MEMBER_ADDED" then
		local _, _, voiceChannelID = ...;
		if voiceChannelID == self:GetVoiceChannelID() then
			self:Update();
		end
	elseif event == "CLUB_INVITATIONS_RECEIVED_FOR_CLUB" then
		local clubId = ...;
		if self.expandedDisplay and clubId == self:GetCommunitiesFrame():GetSelectedClubId() then
			self:OnInvitationsUpdated();
		end
	end
end

function CommunitiesMemberListMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, COMMUNITIES_MEMBER_LIST_EVENTS);
	self:GetCommunitiesFrame():UnregisterCallback(CommunitiesFrameMixin.Event.DisplayModeChanged, self.displayModeChangedCallback);
end

function CommunitiesMemberListMixin:GetCommunitiesFrame()
	return self:GetParent();
end

function CommunitiesMemberListMixin:RemoveInvitation(memberId)
	for i, invitation in ipairs(self.invitations) do
		if invitation.invitee.memberId == memberId then
			table.remove(self.invitations, i);
			break;
		end
	end
	
	self:RefreshListDisplay();
end

function CommunitiesMemberListMixin:CancelInvitation(memberId)
	C_Club.RevokeInvitation(self:GetSelectedClubId(), memberId);
	self:RemoveInvitation(memberId);
end

function CommunitiesMemberListMixin:OnClubMemberButtonClicked(entry, button)
	if button == "RightButton" then
		self.selectedEntry = entry;
		ToggleDropDownMenu(1, nil, self.DropDown, entry, 0, 0);
	end
end

function CommunitiesMemberListMixin:GetSelectedEntry()
	return self.selectedEntry;
end

function CommunitiesMemberListMixin:OnDropDownClosed()
	self.selectedEntry = nil;
end

function CommunitiesMemberListMixin:GetSelectedClubId()
	return self:GetCommunitiesFrame():GetSelectedClubId();
end

function CommunitiesMemberListMixin:GetSelectedStreamId()
	return self:GetCommunitiesFrame():GetSelectedStreamId();
end

function CommunitiesMemberListMixin:SetGuildColumnIndex(extraGuildColumnIndex)
	self.extraGuildColumnIndex = extraGuildColumnIndex;
	if self.expandedDisplay then
		self:RefreshLayout();
	end
end

function CommunitiesMemberListMixin:GetGuildColumnIndex()
	return self.extraGuildColumnIndex;
end

local function CompareMembersByAttribute(lhsMemberInfo, rhsMemberInfo, attribute)
	local lhsAttribute = lhsMemberInfo[attribute];
	local rhsAttribute = rhsMemberInfo[attribute];
	if lhsAttribute == nil and rhsAttribute == nil then
		return nil;
	elseif lhsAttribute == nil then
		return false;
	elseif rhsAttribute == nil then
		return true;
	-- TODO:: Support sorting k-strings.
	elseif type(lhsAttribute) == "string" then
		local compareResult = strcmputf8i(lhsAttribute, rhsAttribute);
		if compareResult == 0 then
			return nil;
		else
			return compareResult < 0;
		end
	elseif attribute == "role" then
		return lhsAttribute > rhsAttribute;
	elseif type(attribute) == "number" then
		return lhsAttribute < rhsAttribute;
	end
end

function CommunitiesMemberListMixin:SortByColumnIndex(columnIndex)
	-- TODO:: Support sorting based on the extra guild column.
	if not self.columnInfo or columnIndex > #self.columnInfo then
		return;
	end
	
	self.reverseActiveColumnSort = columnIndex ~= self.activeColumnSortIndex and false or not self.reverseActiveColumnSort;
	self.activeColumnSortIndex = columnIndex;
	CommunitiesUtil.SortMemberInfoWithOverride(self.sortedMemberList, function(lhsMemberInfo, rhsMemberInfo)
		local attributeResult = CompareMembersByAttribute(lhsMemberInfo, rhsMemberInfo, self.columnInfo[columnIndex].attribute);
		if attributeResult == nil then
			return nil;
		else
			return self.reverseActiveColumnSort and not attributeResult or attributeResult;
		end
	end);
end

function CommunitiesMemberListColumnDisplay_OnClick(self, columnIndex)
	self:GetParent():SortByColumnIndex(columnIndex);
	self:GetParent():RefreshListDisplay();
end

CommunitiesMemberListEntryMixin = {};

function CommunitiesMemberListEntryMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_MEMBER_LIST_ENTRY_EVENTS);
end

function CommunitiesMemberListEntryMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, COMMUNITIES_MEMBER_LIST_ENTRY_EVENTS);
end

function CommunitiesMemberListEntryMixin:OnEvent(event, ...)
	if event == "CLUB_MEMBER_ROLE_UPDATED" then
		local clubId, memberId, roleId = ...;
		local thisClubId = self:GetMemberList():GetSelectedClubId();
		local thisMemberId = self:GetMemberId();
		if clubId == thisClubId and memberId == thisMemberId then
			self.memberInfo.role = roleId;
			self:UpdateRank();
			self:UpdateNameFrame();
		end
	elseif event == "CLUB_MEMBER_PRESENCE_UPDATED" then
		local clubId, memberId, presence = ...;
		local thisClubId = self:GetMemberList():GetSelectedClubId();
		local thisMemberId = self:GetMemberId();
		if clubId == thisClubId and memberId == thisMemberId then
			self.memberInfo.presence = presence;
			self:UpdatePresence();
			self:UpdateNameFrame();
			self:GetMemberList():SortList();
		end
	elseif event == "VOICE_CHAT_CHANNEL_MEMBER_ACTIVE_STATE_CHANGED" then
		local voiceMemberId, voiceChannelId, isActive = ...;
		if voiceChannelId == self:GetVoiceChannelID() and voiceMemberId == self:GetVoiceMemberID() then
			self:SetVoiceActive(isActive);
			self:UpdateVoiceButtons();
			self:UpdateNameFrame();
		end
	elseif event == "PLAYER_GUILD_UPDATE" then
		local clubId = self:GetMemberList():GetSelectedClubId();
		local clubInfo = C_Club.GetClubInfo(clubId);
		if clubInfo and clubInfo.clubType == Enum.ClubType.Guild then
			self:RefreshExpandedColumns();
		end
	end
end

function CommunitiesMemberListEntryMixin:GetMemberList()
	return self:GetParent():GetParent():GetParent();
end

function CommunitiesMemberListEntryMixin:UpdateRank()
	if self.isInvitation then
		self.NameFrame.RankIcon:SetAtlas("communities-icon-invitemail", false);
		self.NameFrame.RankIcon:Show();
		return;
	end
	
	local memberInfo = self:GetMemberInfo();
	if memberInfo then
		self.NameFrame.RankIcon:Show();

		if memberInfo.role == Enum.ClubRoleIdentifier.Owner or memberInfo.role == Enum.ClubRoleIdentifier.Leader then
			self.NameFrame.RankIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
		elseif memberInfo.role == Enum.ClubRoleIdentifier.Moderator then
			self.NameFrame.RankIcon:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon");
		else
			self.NameFrame.RankIcon:Hide();
		end
	else
		self.NameFrame.RankIcon:Hide();
	end
end

function CommunitiesMemberListEntryMixin:UpdatePresence()
	self.NameFrame.PresenceIcon:Show();
	
	local memberInfo = self:GetMemberInfo();
	if memberInfo then
		if memberInfo.classID then
			local classInfo = C_CreatureInfo.GetClassInfo(memberInfo.classID);
			local color = (classInfo and RAID_CLASS_COLORS[classInfo.classFile]) or NORMAL_FONT_COLOR;
			self.NameFrame.Name:SetTextColor(color.r, color.g, color.b);
		else
			self.NameFrame.Name:SetTextColor(BATTLENET_FONT_COLOR:GetRGB());
		end

		if memberInfo.presence == Enum.ClubMemberPresence.Away then
			self.NameFrame.PresenceIcon:SetTexture(FRIENDS_TEXTURE_AFK);
		elseif memberInfo.presence == Enum.ClubMemberPresence.Busy then
			self.NameFrame.PresenceIcon:SetTexture(FRIENDS_TEXTURE_DND);
		else
			self.NameFrame.PresenceIcon:Hide();
			if memberInfo.presence == Enum.ClubMemberPresence.Offline then
				self.NameFrame.Name:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
			end
		end
	else
		self.NameFrame.PresenceIcon:Hide();
		self.NameFrame.Name:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
	end
end

function CommunitiesMemberListEntryMixin:SetMember(memberInfo, isInvitation)
	self.isInvitation = isInvitation;
	
	if memberInfo then
		self.memberInfo = memberInfo;
		self:SetMemberPlayerLocationFromGuid(memberInfo.guid);
		self.NameFrame.Name:SetText(memberInfo.name or "");
		self:UpdateRank();
		self:UpdatePresence();
		self:RefreshExpandedColumns();
	else
		self.memberInfo = nil;
		self:SetMemberPlayerLocationFromGuid(nil);
		self.NameFrame.Name:SetText(nil);
		self:UpdateRank();
		self:UpdatePresence();
	end

	self.CancelInvitationButton:SetShown(isInvitation);
	self:UpdateVoiceMemberInfo(self:GetMemberList():GetVoiceChannelID());
	self:UpdateVoiceButtons();
	self:UpdateNameFrame();
end

function CommunitiesMemberListEntryMixin:UpdateVoiceMemberInfo(voiceChannelID)
	self.voiceChannelID = voiceChannelID;

	if voiceChannelID and self.memberInfo and self.memberInfo.guid then
		self.voiceMemberID = C_VoiceChat.GetMemberID(voiceChannelID, self.memberInfo.guid);
		self.voiceMemberInfo = self.voiceMemberID and C_VoiceChat.GetMemberInfo(self.voiceMemberID, voiceChannelID);
		if self.voiceMemberInfo then
			self:SetVoiceActive(self.voiceMemberInfo.isActive);
		else
			self:SetVoiceActive(false);
		end
	else
		self.voiceMemberID = nil;
		self.voiceMemberInfo = nil;
		self:SetVoiceActive(false);
	end
end

function CommunitiesMemberListEntryMixin:UpdateVoiceButtons()
	self.SelfDeafenButton:UpdateVisibleState();
	self.SelfMuteButton:UpdateVisibleState();
	self.MemberMuteButton:UpdateVisibleState();

	self:UpdateVoiceActivityNotification();
end

function CommunitiesMemberListEntryMixin:GetMemberInfo()
	return self.memberInfo;
end

function CommunitiesMemberListEntryMixin:GetMemberId()
	return self.memberInfo and self.memberInfo.memberId or nil;
end

function CommunitiesMemberListEntryMixin:OnEnter()
	if self.expanded then
		if not self.NameFrame.Name:IsTruncated() and not self.Rank:IsTruncated() and not self.Note:IsTruncated() and not self.Zone:IsTruncated() then
			return;
		end
	end
	
	local memberInfo = self:GetMemberInfo();
	if memberInfo then
		GameTooltip:SetOwner(self);
		GameTooltip:AddLine(memberInfo.name);
		
		local clubId = self:GetMemberList():GetSelectedClubId();
		local clubInfo = C_Club.GetClubInfo(clubId);
		if not clubInfo or clubInfo.clubType == Enum.ClubType.Guild then
			GameTooltip:AddLine(memberInfo.guildRank or "");
		else
			local memberRoleId = memberInfo.role;
			if memberRoleId then
				GameTooltip:AddLine(COMMUNITY_MEMBER_ROLE_NAMES[memberRoleId], HIGHLIGHT_FONT_COLOR:GetRGB());
			end
		end
		
		if memberInfo.level and memberInfo.race and memberInfo.classID then
			local raceInfo = C_CreatureInfo.GetRaceInfo(memberInfo.race);
			local classInfo = C_CreatureInfo.GetClassInfo(memberInfo.classID);
			if raceInfo and classInfo then
				GameTooltip:AddLine(COMMUNITY_MEMBER_CHARACTER_INFO_FORMAT:format(memberInfo.level, raceInfo.raceName, classInfo.className), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
			end
		end
		
		if memberInfo.zone then
			GameTooltip:AddLine(memberInfo.zone, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
		end
		
		if memberInfo.memberNote then
			GameTooltip:AddLine(COMMUNITY_MEMBER_NOTE_FORMAT:format(memberInfo.memberNote), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		end
		
		GameTooltip:Show();
	end
end

function CommunitiesMemberListEntryMixin:OnLeave()
	GameTooltip:Hide();
end

function CommunitiesMemberListEntryMixin:CancelInvitation()
	if self.isInvitation then
		local memberInfo = self:GetMemberInfo();
		if memberInfo then
			self:GetMemberList():CancelInvitation(memberInfo.memberId);
		end
	end
end

function CommunitiesMemberListEntryMixin:OnClick(button)
	self:GetMemberList():OnClubMemberButtonClicked(self, button);
end

function CommunitiesMemberListEntryMixin:RefreshExpandedColumns()
	if not self.expanded then
		return;
	end

	local memberInfo = self:GetMemberInfo();
	if memberInfo then
		local clubId = self:GetMemberList():GetSelectedClubId();
		local clubInfo = C_Club.GetClubInfo(clubId);
		if not clubInfo then
			return;
		end
		
		if clubInfo.clubType == Enum.ClubType.BattleNet then
			self.Level:Hide();
			self.Class:Hide();
			self.Zone:Hide();
			
			self.Rank:SetSize(75, 0);
			self.Rank:ClearAllPoints();
			self.Rank:SetPoint("LEFT", self.NameFrame, "RIGHT", 10, 0);
		else
			if memberInfo.level then
				self.Level:SetText(memberInfo.level);
			else
				self.Level:SetText("");
			end
			
			self.Class:Hide();
			if memberInfo.classID then
				local classInfo = C_CreatureInfo.GetClassInfo(memberInfo.classID);
				if classInfo then
					self.Class:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classInfo.classFile]));
					self.Class:Show();
				end
			end
			
			if memberInfo.zone then
				self.Zone:SetText(memberInfo.zone);
			else
				self.Zone:SetText("");
			end
			
			self.Rank:SetSize(75, 0);
			self.Rank:ClearAllPoints();
			self.Rank:SetPoint("LEFT", self.Zone, "RIGHT", 7, 0);
		end
		
		local memberRoleId = memberInfo.role;
		if self.isInvitation then
			self.Rank:SetText(COMMUNITY_MEMBER_ROLE_NAME_INVITED);
		elseif clubInfo.clubType == Enum.ClubType.Guild then
			self.Rank:SetText(memberInfo.guildRank or "");
		elseif memberRoleId then
			self.Rank:SetText(COMMUNITY_MEMBER_ROLE_NAMES[memberRoleId]);
		else
			self.Rank:SetText("");
		end
		self.Note:SetText(memberInfo.memberNote or "");
		
		-- TODO:: Replace these hardcoded strings with proper accessors.
		if self.guildColumnIndex == EXTRA_GUILD_COLUMN_ACHIEVEMENT then
			self.GuildInfo:SetText("PH achievement points");
		elseif self.guildColumnIndex == EXTRA_GUILD_COLUMN_PROFESSION then
			self.GuildInfo:SetText("PH profession skill");
		end
	end
end

function CommunitiesMemberListEntryMixin:SetExpanded(expanded)
	self.expanded = expanded;
	self:SetWidth(self:GetMemberList():GetWidth());
	self.Level:SetShown(expanded);
	self.Class:SetShown(expanded);
	self.Zone:SetShown(expanded);
	self.Rank:SetShown(expanded);
	self.Note:SetShown(expanded);
	self:RefreshExpandedColumns();
	self:UpdateNameFrame();
end

function CommunitiesMemberListEntryMixin:SetGuildColumnIndex(guildColumnIndex)
	if self.guildColumnIndex == guildColumnIndex then
		return;
	end
	
	self.guildColumnIndex = guildColumnIndex;
	self.Note:ClearAllPoints();
	self.Note:SetPoint("LEFT", self.Rank, "RIGHT", 8, 0);
	if self.expanded and guildColumnIndex ~= nil then
		self.GuildInfo:Show();
		self.Note:SetWidth(93);
	else
		self.Note:SetPoint("RIGHT", self, "RIGHT", -4, 0);
		self.GuildInfo:Hide();
	end
	
	self:RefreshExpandedColumns();
end

function CommunitiesMemberListEntryMixin:UpdateNameFrame()
	local nameFrame = self.NameFrame;

	local frameWidth;
	local iconsWidth = 0;
	local nameOffset = 0;

	if self.expanded then
		-- we are in the roster
		if self.Class:IsShown() then
			frameWidth = 95;
		else
			frameWidth = 140;
		end
	else
		frameWidth = 130;
		if self.SelfMuteButton:IsShown() then
			iconsWidth = 40;
		elseif self.MemberMuteButton:IsShown() then
			iconsWidth = 20;
		end
	end

	local voiceButtonShown = iconsWidth > 0;
	local presenceShown = nameFrame.PresenceIcon:IsShown();

	nameFrame.Name:ClearAllPoints();
	if presenceShown then
		iconsWidth = iconsWidth + 20;

		nameFrame.Name:SetPoint("LEFT", nameFrame.PresenceIcon, "RIGHT");
		nameOffset = nameFrame.PresenceIcon:GetWidth();
	else
		nameFrame.Name:SetPoint("LEFT", nameFrame, "LEFT", 0, 0);
	end

	if nameFrame.RankIcon:IsShown() then
		if voiceButtonShown and presenceShown  then
			iconsWidth = iconsWidth + 15;
		elseif voiceButtonShown or presenceShown then
			iconsWidth = iconsWidth + 20;
		else
			iconsWidth = iconsWidth + 25;
		end
	end

	local nameWidth = frameWidth - iconsWidth;
	nameFrame.Name:SetWidth(nameWidth);

	nameFrame:ClearAllPoints();
	if self.Class:IsShown() then
		nameFrame:SetPoint("LEFT", self.Class, "RIGHT", 8, 0);
	else
		nameFrame:SetPoint("LEFT", 4, 0);
	end
	nameFrame:SetWidth(frameWidth);

	local nameStringWidth = nameFrame.Name:GetStringWidth();
	local rankOffset = (nameFrame.Name:IsTruncated() and nameWidth or nameStringWidth) + nameOffset;
	nameFrame.RankIcon:ClearAllPoints();
	nameFrame.RankIcon:SetPoint("LEFT", nameFrame, "LEFT", rankOffset, 0);
end

function CommunitiesMemberListEntryMixin:IsLocalPlayer()
	return self.memberInfo and self.memberInfo.isSelf or false;
end

function CommunitiesMemberListEntryMixin:GetVoiceMemberID()
	return self.voiceMemberID;
end

function CommunitiesMemberListEntryMixin:GetVoiceChannelID()
	return self.voiceChannelID;
end

function CommunitiesMemberListEntryMixin:GetMemberPlayerLocation()
	return self.playerLocation;
end

function CommunitiesMemberListEntryMixin:SetMemberPlayerLocationFromGuid(memberGuid)
	if memberGuid then
		if not self.playerLocation then
			self.playerLocation = PlayerLocation:CreateFromGUID(memberGuid);
		else
			self.playerLocation:SetGUID(memberGuid);
		end
	else
		self.playerLocation = nil
	end
end

function CommunitiesMemberListEntryMixin:IsChannelActive()
	local voiceChannel = self:GetMemberList():GetVoiceChannel();
	if voiceChannel then
		return voiceChannel.isActive;
	else
		return false;
	end
end

function CommunitiesMemberListEntryMixin:IsVoiceActive()
	return self.voiceActive;
end

function CommunitiesMemberListEntryMixin:SetVoiceActive(voiceActive)
	self.voiceActive = voiceActive;
end

do
	function CommunitiesMemberListEntry_VoiceActivityNotificationCreatedCallback(self, notification)
		notification:SetParent(self);
		notification:ClearAllPoints();
		notification:SetPoint("RIGHT", self, "RIGHT", -5, 0);
		notification:Show();
	end

	function CommunitiesMemberListEntryMixin:UpdateVoiceActivityNotification()
		if self:IsVoiceActive() and self:IsChannelActive() then
			local guid = self.playerLocation and self.playerLocation:GetGUID();
			if guid ~= self.registeredGuid then
				if self.registeredGuid then
					VoiceActivityManager:UnregisterFrameForVoiceActivityNotifications(self);
				end

				if guid then
					VoiceActivityManager:RegisterFrameForVoiceActivityNotifications(self, guid, self:GetVoiceChannelID(), "VoiceActivityNotificationRosterTemplate", "Button", CommunitiesMemberListEntry_VoiceActivityNotificationCreatedCallback);
				end

				self.registeredGuid = guid;
			end
		else
			if self.registeredGuid then
				VoiceActivityManager:UnregisterFrameForVoiceActivityNotifications(self);
				self.registeredGuid = nil;
			end
		end
	end
end

function CommunitiesMemberListDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, CommunitiesMemberListDropdown_Initialize, "MENU");
end

function CommunitiesMemberListDropDown_OnHide(self)
	local CommunitiesMemberList = self:GetParent();
	CommunitiesMemberList:OnDropDownClosed();
end

local clubTypeToUnitPopup = {
	[Enum.ClubType.BattleNet] = "COMMUNITIES_MEMBER",
	[Enum.ClubType.Character] = "COMMUNITIES_WOW_MEMBER",
	[Enum.ClubType.Guild] = "COMMUNITIES_WOW_MEMBER",
};

function CommunitiesMemberListDropdown_Initialize(self, level)
	local CommunitiesMemberList = self:GetParent();
	local SelectedCommunitiesMemberListEntry = CommunitiesMemberList:GetSelectedEntry();
	if not SelectedCommunitiesMemberListEntry then
		return;
	end
		
	local clubId = CommunitiesMemberList:GetSelectedClubId();
	local memberInfo = SelectedCommunitiesMemberListEntry:GetMemberInfo();
	local clubPrivileges = CommunitiesMemberList:GetCommunitiesFrame():GetPrivilegesForClub(clubId);
	local clubInfo = C_Club.GetClubInfo(clubId);

	if memberInfo and clubInfo then
		self.clubMemberInfo = memberInfo;
		self.clubInfo = clubInfo;
		self.clubPrivileges = clubPrivileges;
		self.clubAssignableRoles = C_Club.GetAssignableRoles(clubId, memberInfo.memberId);
		UnitPopup_ShowMenu(self, clubTypeToUnitPopup[clubInfo.clubType], nil, memberInfo.name);
	end
end

GuildMemberListDropDownMenuMixin = {};

function GuildMemberListDropDownMenuMixin:OnLoad()
	UIDropDownMenu_SetWidth(self, self.width or 115);
end

function GuildMemberListDropDownMenuMixin:OnShow()
	UIDropDownMenu_Initialize(self, GuildMemberListDropDownMenu_Initialize);
	local communitiesFrame = self:GetCommunitiesFrame();
	UIDropDownMenu_SetSelectedValue(self, communitiesFrame.MemberList:GetGuildColumnIndex());

	local function CommunitiesClubSelectedCallback(event, clubId)
		if clubId and self:IsVisible() then
			local clubInfo = C_Club.GetClubInfo(clubId);
			if clubInfo and clubInfo.clubType ~= Enum.ClubType.Guild then
				self:Hide();
			end
		end
	end
	
	self.clubSelectedCallback = CommunitiesClubSelectedCallback;
	communitiesFrame:RegisterCallback(CommunitiesFrameMixin.Event.ClubSelected, self.clubSelectedCallback);
end

function GuildMemberListDropDownMenuMixin:OnHide()
	local communitiesFrame = self:GetCommunitiesFrame();
	communitiesFrame:UnregisterCallback(CommunitiesFrameMixin.Event.ClubSelected, self.clubSelectedCallback);
end

function GuildMemberListDropDownMenuMixin:GetCommunitiesFrame()
	return self:GetParent();
end

function GuildMemberListDropDownMenu_Initialize(self)
	local memberList = self:GetCommunitiesFrame().MemberList;
	local info = UIDropDownMenu_CreateInfo();
	for i, extraColumnInfo in ipairs(EXTRA_GUILD_COLUMNS) do
		info.text = extraColumnInfo.dropdownText;
		info.value = i;
		info.func = function(button)
			memberList:SetGuildColumnIndex(i);
			UIDropDownMenu_SetSelectedValue(self, i);
		end
		
		UIDropDownMenu_AddButton(info);
	end
	
	UIDropDownMenu_SetSelectedValue(self, memberList:GetGuildColumnIndex());
end