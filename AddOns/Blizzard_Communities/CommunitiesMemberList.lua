
local COMMUNITIES_MEMBER_LIST_EVENTS = {
	"CLUB_MEMBER_ADDED",
	"CLUB_MEMBER_REMOVED",
	"CLUB_MEMBER_UPDATED",
	"CLUB_MEMBER_PRESENCE_UPDATED",
	"VOICE_CHAT_CHANNEL_ACTIVATED",
	"VOICE_CHAT_CHANNEL_DEACTIVATED",
	"VOICE_CHAT_CHANNEL_JOINED",
	"VOICE_CHAT_CHANNEL_REMOVED",
	"VOICE_CHAT_CHANNEL_MEMBER_ADDED",
	"VOICE_CHAT_CHANNEL_MEMBER_GUID_UPDATED",
	"CLUB_INVITATIONS_RECEIVED_FOR_CLUB",
	"CLUB_MEMBER_ROLE_UPDATED",
};

local COMMUNITIES_MEMBER_LIST_ENTRY_EVENTS = {
	"CLUB_MEMBER_ROLE_UPDATED",
	"VOICE_CHAT_CHANNEL_MEMBER_ACTIVE_STATE_CHANGED",
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

CommunitiesMemberListMixin = {};

function CommunitiesMemberListMixin:OnClubSelected(clubId)
	self:ResetColumnSort();
end

function CommunitiesMemberListMixin:ResetColumnSort()
	self.activeColumnSortIndex = nil;
	self.reverseActiveColumnSort = nil;
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
	local memberList = self.sortedMemberList or {};
	local invitations = self.invitations;
	local displayInvitations = self.expandedDisplay and #invitations > 0;
	for i = 1, #buttons do
		local displayIndex = i + offset;
		local button = buttons[i];
		if displayIndex <= #memberList then
			local memberInfo = memberList[displayIndex];
			button:SetMember(memberInfo, false);
			button:Show();
			usedHeight = usedHeight + height;
		else
			if displayInvitations  then
				displayIndex = displayIndex - #memberList;
				
				-- Display an extra space and header first.
				if displayIndex == 1 then
					-- Leave an extra space between the member list and invitations.
					button:SetMember(nil);
					button:Hide();
					usedHeight = usedHeight + height;
				elseif displayInvitations and displayIndex == 2 then
					button:SetHeader(COMMUNITIES_MEMBER_LIST_PENDING_INVITE_HEADER:format(#invitations));
					button:Show();
					usedHeight = usedHeight + height;
				elseif displayInvitations and (displayIndex - 2) <= #invitations then
					button:SetMember(invitations[(displayIndex - 2)].invitee, true);
					button:Show();
					usedHeight = usedHeight + height;
				else
					button:SetMember(nil);
					button:Hide();
				end
			else
				button:SetMember(nil);
				button:Hide();
			end
		end
	end
	
	local totalNum = #memberList;
	if displayInvitations then
		totalNum = totalNum + #invitations + 2;
	end
	
	HybridScrollFrame_Update(scrollFrame, height * totalNum, usedHeight);
end

function CommunitiesMemberListMixin:UpdateMemberList()
	local clubId = self:GetSelectedClubId();
	local streamId;

	-- If we are showing the expandedDisplay, leave streamId as nil, so we show the roster of the whole club instead of just the current stream
	if not self.expandedDisplay then
		streamId = self:GetSelectedStreamId();
	end
	
	self.memberIds = CommunitiesUtil.GetMemberIdsSortedByName(clubId, streamId);
	self.allMemberList = CommunitiesUtil.GetMemberInfo(clubId, self.memberIds);
	self.allMemberInfoLookup = CommunitiesUtil.GetMemberInfoLookup(self.allMemberList);
	self.allMemberList = CommunitiesUtil.SortMemberInfo(clubId, self.allMemberList);
	if not self:ShouldShowOfflinePlayers() then 
		self.sortedMemberList = CommunitiesUtil.GetOnlineMembers(self.allMemberList);
		self.sortedMemberLookup = CommunitiesUtil.GetMemberInfoLookup(self.sortedMemberList);
	else
		self.sortedMemberList = self.allMemberList;
		self.sortedMemberLookup = self.allMemberInfoLookup
	end

	if self.activeColumnSortIndex then
		local keepSortDirection = true;
		self:SortByColumnIndex(self.activeColumnSortIndex, keepSortDirection);
	end
	
	self:UpdateMemberCount();
	self:Update();
end

COMMUNITIES_MEMBER_LIST_MEMBER_COUNT_FORMAT = "%s/%s "..GUILD_ONLINE_LABEL;
function CommunitiesMemberListMixin:UpdateMemberCount()
	local numOnlineMembers = 0;
	for i, memberInfo in ipairs(self.allMemberList) do
		if memberInfo.presence == Enum.ClubMemberPresence.Online or
			memberInfo.presence == Enum.ClubMemberPresence.Away or
			memberInfo.presence == Enum.ClubMemberPresence.Busy then
			numOnlineMembers = numOnlineMembers + 1;
		end
	end
	
	self.MemberCount:SetText(COMMUNITIES_MEMBER_LIST_MEMBER_COUNT_FORMAT:format(numOnlineMembers, #self.allMemberList));
end

function CommunitiesMemberListMixin:Update()
	self:UpdateVoiceChannel();
	self:RefreshLayout();
	self:RefreshListDisplay();
end

function CommunitiesMemberListMixin:MarkSortDirty()
	self.sortDirty = true;
end

function CommunitiesMemberListMixin:MarkMemberListDirty()
	self.memberListDirty = true;
end

function CommunitiesMemberListMixin:IsSortDirty()
	return self.sortDirty;
end

function CommunitiesMemberListMixin:IsMemberListDirty()
	return self.memberListDirty;
end

function CommunitiesMemberListMixin:ClearSortDirty()
	self.sortDirty = nil;
end

function CommunitiesMemberListMixin:ClearMemberListDirty()
	self.memberListDirty = nil;
end

function CommunitiesMemberListMixin:SortList()
	if self.activeColumnSortIndex then
		local keepSortDirection = true;
		self:SortByColumnIndex(self.activeColumnSortIndex, keepSortDirection);
	else
		CommunitiesUtil.SortMemberInfo(self:GetSelectedClubId(), self.sortedMemberList);
	end
	
	self:RefreshListDisplay();
end

function CommunitiesMemberListMixin:OnLoad()
	self.ListScrollFrame.update = function()
		self:Update(); 
	end;
	
	self.invitations = {};
	self.showOfflinePlayers = GetCVarBool("communitiesShowOffline");
	self.ShowOfflineButton:SetChecked(self.showOfflinePlayers);
	
	self.ListScrollFrame.scrollBar.doNotHide = true;
	self.ListScrollFrame.scrollBar:SetValue(0);
	
	self:SetExpandedDisplay(false);
end
	
function CommunitiesMemberListMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_MEMBER_LIST_EVENTS);
	
	self:UpdateMemberList();

	local function StreamSelectedCallback(event, streamId)
		self:UpdateMemberList();
	end

	self.streamSelectedCallback = StreamSelectedCallback;
	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.StreamSelected, self.streamSelectedCallback, self);
	
	local function ClubSelectedCallback(event, clubId)
		self:UpdateInvitations();
		self:UpdateMemberList();
	end

	self.clubSelectedCallback = ClubSelectedCallback;
	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.ClubSelected, self.clubSelectedCallback, self);

	local function CommunitiesDisplayModeChangedCallback(event, displayMode)
		local expandedDisplay = displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER;
		self:SetExpandedDisplay(expandedDisplay);
	end
	
	self.displayModeChangedCallback = CommunitiesDisplayModeChangedCallback;
	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.DisplayModeChanged, self.displayModeChangedCallback, self);
end

function CommunitiesMemberListMixin:OnUpdate()
	if self:IsMemberListDirty() then
		self:UpdateMemberList();
		self:ClearMemberListDirty();
	end

	if self:IsSortDirty() then
		if not self:ShouldShowOfflinePlayers() then 
			self.sortedMemberList = CommunitiesUtil.GetOnlineMembers(self.allMemberList);
			self.sortedMemberLookup = CommunitiesUtil.GetMemberInfoLookup(self.sortedMemberList);
		end
		self:SortList();
		self:ClearSortDirty();
		self:UpdateMemberCount();
	end
end

function CommunitiesMemberListMixin:UpdateInvitations()
	self.invitations = {};
	
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
	self.expandedDisplay = expandedDisplay;
	self.MemberCount:SetShown(not expandedDisplay);
	self:ResetColumnSort();
	self:UpdateMemberList();
	
	if expandedDisplay then
		self:UpdateInvitations();
	end
	
	self:RefreshLayout();
	self:RefreshListDisplay();
	self.ShowOfflineButton:SetShown(expandedDisplay);
end

function CommunitiesMemberListMixin:ShouldShowOfflinePlayers()
	return self.showOfflinePlayers or not self.expandedDisplay;
end

function CommunitiesMemberListMixin:SetShowOfflinePlayers(showOfflinePlayers)
	self.showOfflinePlayers = showOfflinePlayers;
	SetCVar("communitiesShowOffline", showOfflinePlayers and "1" or "0");
	self.ListScrollFrame.scrollBar:SetValue(0);
	self:UpdateMemberList();
end

function CommunitiesMemberListMixin:RefreshLayout()
	if self.expandedDisplay then
		self:SetPoint("TOPLEFT", self:GetCommunitiesFrame().CommunitiesList, "TOPRIGHT", 26, -60);
	else
		self:SetPoint("TOPLEFT", self:GetCommunitiesFrame(), "TOPRIGHT", -165, -63);
	end
	
	if not self.ListScrollFrame.buttons then
		HybridScrollFrame_CreateButtons(self.ListScrollFrame, "CommunitiesMemberListEntryTemplate", 0, 0);
	end
	
	self.ColumnDisplay:Hide();
	if self.expandedDisplay then
		local clubId = self:GetCommunitiesFrame():GetSelectedClubId();
		if clubId then
			local clubInfo = C_Club.GetClubInfo(clubId);
			if clubInfo then
				self.columnInfo = BNET_COLUMN_INFO;
				self.ColumnDisplay:LayoutColumns(BNET_COLUMN_INFO);
				self.ColumnDisplay:Show();
			end
		end
	end
	
	for i, button in ipairs(self.ListScrollFrame.buttons or {}) do
		button:SetExpanded(self.expandedDisplay);
	end
end

function CommunitiesMemberListMixin:OnEvent(event, ...)
	if event == "CLUB_MEMBER_ADDED" or event == "CLUB_MEMBER_REMOVED" or event == "CLUB_MEMBER_UPDATED" then
		local clubId, memberId = ...;
		if clubId == self:GetSelectedClubId() then
			self:MarkMemberListDirty();
		
			if event == "CLUB_MEMBER_ADDED" then
				self:RemoveInvitation(memberId);
			end
		end
	elseif event == "VOICE_CHAT_CHANNEL_JOINED" then
		local _, _, channelType, clubId, streamId = ...;
		if channelType == Enum.ChatChannelType.Communities and clubId == self:GetSelectedClubId() and streamId == self:GetSelectedStreamId() then
			self:MarkMemberListDirty();
		end
	elseif event == "VOICE_CHAT_CHANNEL_REMOVED" then
		local voiceChannelID = ...;
		if voiceChannelID == self:GetVoiceChannelID() then
			self:MarkMemberListDirty();
		end
	elseif event == "VOICE_CHAT_CHANNEL_ACTIVATED" or event == "VOICE_CHAT_CHANNEL_DEACTIVATED" then
		local voiceChannelID = ...;
		if voiceChannelID == self:GetVoiceChannelID() then
			self:Update();
		end
	elseif event == "VOICE_CHAT_CHANNEL_MEMBER_ADDED" or event == "VOICE_CHAT_CHANNEL_MEMBER_GUID_UPDATED" then
		local _, voiceChannelID = ...;
		if voiceChannelID == self:GetVoiceChannelID() then
			self:Update();
		end
	elseif event == "CLUB_INVITATIONS_RECEIVED_FOR_CLUB" then
		local clubId = ...;
		if self.expandedDisplay and clubId == self:GetCommunitiesFrame():GetSelectedClubId() then
			self:OnInvitationsUpdated();
		end
	elseif event == "CLUB_MEMBER_PRESENCE_UPDATED" then
		local clubId, memberId, presence = ...;
		if clubId == self:GetSelectedClubId() and self.allMemberInfoLookup[memberId] ~= nil then
			self.allMemberInfoLookup[memberId].presence = presence;
			self:MarkSortDirty();
		end
	elseif event == "CLUB_MEMBER_ROLE_UPDATED" then
		local clubId, memberId, roleId = ...;
		if clubId == self:GetSelectedClubId() and self.allMemberInfoLookup[memberId] ~= nil then
			self.allMemberInfoLookup[memberId].role = roleId;
			self:MarkSortDirty();
		end
	end
end

function CommunitiesMemberListMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, COMMUNITIES_MEMBER_LIST_EVENTS);
	self:GetCommunitiesFrame():UnregisterCallback(CommunitiesFrameMixin.Event.DisplayModeChanged, self);
	self:GetCommunitiesFrame():UnregisterCallback(CommunitiesFrameMixin.Event.StreamSelected, self);
	self:GetCommunitiesFrame():UnregisterCallback(CommunitiesFrameMixin.Event.ClubSelected, self);
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
		return;
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

local function CompareMembersByAttribute(lhsMemberInfo, rhsMemberInfo, attribute)
	local lhsAttribute = lhsMemberInfo[attribute];
	local rhsAttribute = rhsMemberInfo[attribute];
	local attributeType = type(lhsAttribute);
	if lhsAttribute == nil and rhsAttribute == nil then
		return nil;
	elseif lhsAttribute == nil then
		return false;
	elseif rhsAttribute == nil then
		return true;
	elseif attributeType == "string" then
		local compareResult = strcmputf8i(lhsAttribute, rhsAttribute);
		if compareResult == 0 then
			return nil;
		else
			return compareResult < 0;
		end
	elseif attributeType == "number" then
		return lhsAttribute > rhsAttribute;
	end
	
	return nil;
end

function CommunitiesMemberListMixin:SortByColumnIndex(columnIndex, keepSortDirection)
	local sortAttribute = columnIndex <= #self.columnInfo and self.columnInfo[columnIndex].attribute or nil;

	if sortAttribute == nil then
		return;
	end

	if not keepSortDirection or self.reverseActiveColumnSort == nil then	
		self.reverseActiveColumnSort = columnIndex ~= self.activeColumnSortIndex and false or not self.reverseActiveColumnSort;
	end
	self.activeColumnSortIndex = columnIndex;

	if sortAttribute == "name" then
		local clubId = self:GetSelectedClubId();
		local streamId = self:GetSelectedStreamId();
		self.sortedMemberList = CommunitiesUtil.SortMembersByList(self.sortedMemberLookup, self.memberIds);
		if self.reverseActiveColumnSort then
			-- Reverse the member list.
			local memberListSize = #self.sortedMemberList;
			for i = 1, memberListSize / 2 do
				local reverseIndex = (memberListSize - i) + 1;
				local reverseEntry = self.sortedMemberList[reverseIndex];
				self.sortedMemberList[reverseIndex] = self.sortedMemberList[i];
				self.sortedMemberList[i] = reverseEntry;
			end
		end
		
		return;
	elseif sortAttribute == "zone" then
		table.sort(self.sortedMemberList, function(lhsMemberInfo, rhsMemberInfo)
			if self.reverseActiveColumnSort then
				lhsMemberInfo, rhsMemberInfo = rhsMemberInfo, lhsMemberInfo;
			end
			if lhsMemberInfo.lastOnlineYear and rhsMemberInfo.lastOnlineYear then
				if lhsMemberInfo.lastOnlineYear ~= rhsMemberInfo.lastOnlineYear then
					return lhsMemberInfo.lastOnlineYear > rhsMemberInfo.lastOnlineYear;
				elseif lhsMemberInfo.lastOnlineMonth ~= rhsMemberInfo.lastOnlineMonth then
					return lhsMemberInfo.lastOnlineMonth > rhsMemberInfo.lastOnlineMonth;
				elseif lhsMemberInfo.lastOnlineDay ~= rhsMemberInfo.lastOnlineDay then
					return lhsMemberInfo.lastOnlineDay > rhsMemberInfo.lastOnlineDay;
				else
					return lhsMemberInfo.lastOnlineHour > rhsMemberInfo.lastOnlineHour;
				end
			elseif lhsMemberInfo.lastOnlineYear then
				return false;
			elseif rhsMemberInfo.lastOnlineYear then
				return true;
			else
				return CompareMembersByAttribute(lhsMemberInfo, rhsMemberInfo, sortAttribute);
			end
		end);
		return;
	end
	
	CommunitiesUtil.SortMemberInfoWithOverride(self:GetSelectedClubId(), self.sortedMemberList, function(lhsMemberInfo, rhsMemberInfo)
		if self.reverseActiveColumnSort then
			return CompareMembersByAttribute(lhsMemberInfo, rhsMemberInfo, sortAttribute);
		else
			return CompareMembersByAttribute(rhsMemberInfo, lhsMemberInfo, sortAttribute);
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
	elseif event == "VOICE_CHAT_CHANNEL_MEMBER_ACTIVE_STATE_CHANGED" then
		local voiceMemberId, voiceChannelId, isActive = ...;
		if voiceChannelId == self:GetVoiceChannelID() and voiceMemberId == self:GetVoiceMemberID() then
			self:SetVoiceActive(isActive);
			self:UpdateVoiceButtons();
			self:UpdateNameFrame();
		end
	end
end

function CommunitiesMemberListEntryMixin:GetMemberList()
	return self:GetParent():GetParent():GetParent();
end

function CommunitiesMemberListEntryMixin:UpdateRank()
	if self.isInvitation then
		self.NameFrame.RankIcon:Hide();
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

		self.NameFrame.PresenceIcon:SetPoint("LEFT", 0, 0);
		if memberInfo.presence == Enum.ClubMemberPresence.Away then
			self.NameFrame.PresenceIcon:SetTexture(FRIENDS_TEXTURE_AFK);
		elseif memberInfo.presence == Enum.ClubMemberPresence.Busy then
			self.NameFrame.PresenceIcon:SetTexture(FRIENDS_TEXTURE_DND);
		elseif memberInfo.presence == Enum.ClubMemberPresence.OnlineMobile then
			self.NameFrame.PresenceIcon:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ArmoryChat");
			self.NameFrame.PresenceIcon:SetPoint("LEFT", -2, 0);
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

function CommunitiesMemberListEntryMixin:SetHeader(headerText)
	self:SetMember(nil);
	self.NameFrame.Name:SetText(headerText);
end

function CommunitiesMemberListEntryMixin:SetCollapsed(collapsed)
	self.isCollapsed = collapsed;
end

function CommunitiesMemberListEntryMixin:SetMember(memberInfo, isInvitation)
	self.isInvitation = isInvitation;
	
	if memberInfo then
		self.memberInfo = memberInfo;
		self:SetMemberPlayerLocationFromGuid(memberInfo.guid);
		self.NameFrame.Name:SetText(memberInfo.name or "");
	else
		self.memberInfo = nil;
		self:SetMemberPlayerLocationFromGuid(nil);
		self.NameFrame.Name:SetText(nil);
	end
	
	self:UpdateRank();
	self:UpdatePresence();
	self:RefreshExpandedColumns();

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
		if not clubInfo then
			GameTooltip:AddLine("");
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
		
		if memberInfo.presence == Enum.ClubMemberPresence.OnlineMobile then
			GameTooltip:AddLine(COMMUNITIES_PRESENCE_MOBILE_CHAT, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
		elseif memberInfo.zone then
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
	if not self.isInvitation then
		self:GetMemberList():OnClubMemberButtonClicked(self, button);
	end
end

function CommunitiesMemberListEntryMixin:RefreshExpandedColumns()
	if not self.expanded then
		return;
	end

	local memberInfo = self:GetMemberInfo();
	local hasMemberInfo = memberInfo ~= nil;
	self.Level:SetShown(hasMemberInfo);
	self.Class:SetShown(hasMemberInfo);
	self.Zone:SetShown(hasMemberInfo);
	self.Rank:SetShown(hasMemberInfo);
	self.Note:SetShown(hasMemberInfo);
	if not hasMemberInfo then
		return;
	end

	local clubId = self:GetMemberList():GetSelectedClubId();
	local clubInfo = C_Club.GetClubInfo(clubId);
	if not clubInfo then
		return;
	end
	
	self.Level:Hide();
	self.Class:Hide();
	self.Zone:Hide();
	
	self.Rank:SetSize(75, 0);
	self.Rank:ClearAllPoints();
	self.Rank:SetPoint("LEFT", self.NameFrame, "RIGHT", 10, 0);
	
	local memberRoleId = memberInfo.role;
	if memberRoleId then
		self.Rank:SetText(COMMUNITY_MEMBER_ROLE_NAMES[memberRoleId]);
	else
		self.Rank:SetText("");
	end

	self.Note:SetText(memberInfo.memberNote or "");
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
		nameFrame:SetPoint("LEFT", self.Class, "RIGHT", 18, 0);
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

function CommunitiesMemberListEntryMixin:IsChannelPublic()
	return false;	-- community voice channels are never public
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
		self.isSelf = memberInfo.isSelf;
		self.guid = memberInfo.guid;
		UnitPopup_ShowMenu(self, "COMMUNITIES_MEMBER", nil, memberInfo.name);
	end
end
