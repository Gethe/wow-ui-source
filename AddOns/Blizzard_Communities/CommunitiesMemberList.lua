
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
		dropdownText = GUILLD_ROSTER_DROPDOWN_ACHIEVEMENT_POINTS,
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_ACHIEVEMENT,
		attribute = "achievementPoints",
		width = 130,
	};

	[EXTRA_GUILD_COLUMN_PROFESSION] = {
		dropdownText = GUILLD_ROSTER_DROPDOWN_PROFESSION,
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_PROFESSION,
		attribute = "profession", -- This is a special case since there are 2 separate sets of profession attributes.
		width = 130,
	};
};

CommunitiesMemberListMixin = {};

function CommunitiesMemberListMixin:OnClubSelected(clubId)
	self.activeColumnSortIndex = nil;
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

function CommunitiesMemberListMixin:UpdateProfessionDisplay()
	if not self.sortedMemberList then
		return;
	end
	
	-- Clear out the profession lists without removing the additional data.
	local professionLookup = self.professionDisplay;
	for professionId, professionList in pairs(professionLookup) do
		wipe(professionList.memberList);
	end
	
	for i, member in ipairs(self.sortedMemberList) do
		local firstProfessionID = member.profession1ID
		if firstProfessionID then
			if not professionLookup[firstProfessionID] then
				professionLookup[firstProfessionID] = {};
				
				local professionList = professionLookup[firstProfessionID];
				professionList.memberList = { member };
				professionList.collapsed = true;
				professionList.professionName = member.profession1Name;
			else
				table.insert(professionLookup[firstProfessionID].memberList, member);
			end
		end
		
		local secondProfessionID = member.profession2ID
		if secondProfessionID then
			if not professionLookup[secondProfessionID] then
				professionLookup[secondProfessionID] = {};
				
				local professionList = professionLookup[secondProfessionID];
				professionList.memberList = { member };
				professionList.collapsed = true;
				professionList.professionName = member.profession2Name;
			else
				table.insert(professionLookup[secondProfessionID].memberList, member);
			end
		end
	end
	
	self:UpdateSortedProfessionList();
end

function CommunitiesMemberListMixin:UpdateSortedProfessionList()
	self.sortedProfessionList = {};
	sortedProfessionList = self.sortedProfessionList;
	for professionId, professionList in pairs(self.professionDisplay) do
		local professionEntry = {
			professionHeaderId = professionId,
			professionHeaderName = professionList.professionName,
			professionHeaderCollapsed = professionList.collapsed,
		};
		
		table.insert(sortedProfessionList, professionEntry);
		
		if not professionList.collapsed then
			for i, member in ipairs(professionList.memberList) do
				table.insert(sortedProfessionList, member);
			end
		end
	end
end

function CommunitiesMemberListMixin:SetProfessionCollapsed(professionId, collapsed)
	self.professionDisplay[professionId].collapsed = collapsed;
	if self:IsDisplayingProfessions() then
		self:UpdateSortedProfessionList();
		self:RefreshListDisplay();
	end
end

function CommunitiesMemberListMixin:IsDisplayingProfessions()
	return self.expandedDisplay and self.extraGuildColumnIndex == EXTRA_GUILD_COLUMN_PROFESSION;
end

function CommunitiesMemberListMixin:RefreshListDisplay()
	local scrollFrame = self.ListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	
	local displayingProfessions = self:IsDisplayingProfessions();
	local professionId = nil;
	local usedHeight = 0;
	local height = buttons[1]:GetHeight();
	local memberList = displayingProfessions and (self.sortedProfessionList) or (self.sortedMemberList or {});
	local invitations = self.invitations;
	local displayInvitations = self.expandedDisplay and not displayingProfessions and #invitations > 0;
	for i = 1, #buttons do
		local displayIndex = i + offset;
		local button = buttons[i];
		if displayIndex <= #memberList then
			local memberInfo = memberList[displayIndex];
			if memberInfo.professionHeaderId then
				professionId = memberInfo.professionHeaderId;
				button:SetProfessionHeader(memberInfo.professionHeaderId, memberInfo.professionHeaderName, memberInfo.professionHeaderCollapsed);
				button:Show();
				usedHeight = usedHeight + height;
			else
				button:SetMember(memberInfo, false, professionId);
				button:Show();
				usedHeight = usedHeight + height;
			end
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
	
	self.sortedMemberList = CommunitiesUtil.GetAndSortMemberInfo(clubId, streamId);
	if self.activeColumnSortIndex then
		self:SortByColumnIndex(self.activeColumnSortIndex);
	end
	
	if self:IsDisplayingProfessions() then
		self:UpdateProfessionDisplay();
	end
	
	self:Update();
end

function CommunitiesMemberListMixin:Update()
	self:UpdateVoiceChannel();
	self:RefreshLayout();
	self:RefreshListDisplay();
end

function CommunitiesMemberListMixin:SortList()
	CommunitiesUtil.SortMemberInfo(self.sortedMemberList);
	if self:IsDisplayingProfessions() then
		self:UpdateProfessionDisplay();
	end
	
	self:RefreshListDisplay();
end

function CommunitiesMemberListMixin:OnLoad()
	self.ListScrollFrame.update = function()
		self:Update(); 
	end;
	
	self.invitations = {};
	self.professionDisplay = {};
	
	self.ListScrollFrame.scrollBar.doNotHide = true;
	self.ListScrollFrame.scrollBar:SetValue(0);
	
	self:SetExpandedDisplay(false);
	self:SetGuildColumnIndex(EXTRA_GUILD_COLUMN_ACHIEVEMENT);
end
	
function CommunitiesMemberListMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_MEMBER_LIST_EVENTS);
	
	self:UpdateMemberList();

	local function StreamSelectedCallback(event, streamId)
		self:UpdateMemberList();
	end

	self.streamSelectedCallback = StreamSelectedCallback;
	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.StreamSelected, self.streamSelectedCallback);
	
	local function ClubSelectedCallback(event, clubId)
		self:UpdateInvitations();
		self:UpdateMemberList();
	end

	self.clubSelectedCallback = ClubSelectedCallback;
	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.ClubSelected, self.clubSelectedCallback);

	local function CommunitiesDisplayModeChangedCallback(event, displayMode)
		local expandedDisplay = displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER;
		self:SetExpandedDisplay(expandedDisplay);
	end
	
	self.displayModeChangedCallback = CommunitiesDisplayModeChangedCallback;
	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.DisplayModeChanged, self.displayModeChangedCallback);
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
	if expandedDisplay then
		if self:IsDisplayingProfessions() then
			self:UpdateProfessionDisplay();
		else
			self:UpdateInvitations();
		end
	end
	
	self:RefreshLayout();
	self:RefreshListDisplay();
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
		self:UpdateMemberList();
		
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
		local _, voiceChannelID = ...;
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
	self:GetCommunitiesFrame():UnregisterCallback(CommunitiesFrameMixin.Event.StreamSelected, self.streamSelectedCallback);
	self:GetCommunitiesFrame():UnregisterCallback(CommunitiesFrameMixin.Event.ClubSelected, self.clubSelectedCallback);
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
	elseif entry:GetProfessionId() ~= nil then
		local memberInfo = entry:GetMemberInfo();
		if memberInfo then
			C_GuildInfo.QueryGuildMemberRecipes(memberInfo.guid, entry:GetProfessionId());
		end
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
		if self:IsDisplayingProfessions() then
			self:UpdateProfessionDisplay();
		end
		
		self:RefreshLayout();
		self:RefreshListDisplay();
	end
end

function CommunitiesMemberListMixin:GetGuildColumnIndex()
	return self.extraGuildColumnIndex;
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

function CommunitiesMemberListMixin:SortByColumnIndex(columnIndex)
	local sortAttribute = columnIndex <= #self.columnInfo and self.columnInfo[columnIndex].attribute or nil;
	if columnIndex > #self.columnInfo and self.extraGuildColumnIndex then
		sortAttribute = EXTRA_GUILD_COLUMNS[self.extraGuildColumnIndex].attribute;
	end
	
	if sortAttribute == nil then
		return;
	end
	
	self.reverseActiveColumnSort = columnIndex ~= self.activeColumnSortIndex and false or not self.reverseActiveColumnSort;
	self.activeColumnSortIndex = columnIndex;

	if sortAttribute == "name" then
		local clubId = self:GetSelectedClubId();
		local streamId = self:GetSelectedStreamId();
		self.sortedMemberList = CommunitiesUtil.GetMemberInfo(clubId, streamId);
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
		
		if self:IsDisplayingProfessions() then
			self:UpdateProfessionDisplay();
		end

		return;
	elseif sortAttribute == "profession" then
		for professionId, professionList in pairs(self.professionDisplay) do
			table.sort(professionList.memberList, function(lhsMemberInfo, rhsMemberInfo)
				local lhsSkill = lhsMemberInfo.profession1ID == professionId and lhsMemberInfo.profession1Rank or lhsMemberInfo.profession2Rank;
				local rhsSkill = rhsMemberInfo.profession1ID == professionId and rhsMemberInfo.profession1Rank or rhsMemberInfo.profession2Rank;
				if self.reverseActiveColumnSort then
					return rhsSkill < lhsSkill;
				else
					return lhsSkill < rhsSkill;
				end
			end);
		end
		
		self:UpdateSortedProfessionList();
		
		return;
	end
		
	CommunitiesUtil.SortMemberInfoWithOverride(self.sortedMemberList, function(lhsMemberInfo, rhsMemberInfo)
		if self.reverseActiveColumnSort then
			return CompareMembersByAttribute(lhsMemberInfo, rhsMemberInfo, sortAttribute);
		else
			return CompareMembersByAttribute(rhsMemberInfo, lhsMemberInfo, sortAttribute);
		end
	end);
	
	if self:IsDisplayingProfessions() then
		self:UpdateProfessionDisplay();
	end
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

function CommunitiesMemberListEntryMixin:SetHeader(headerText)
	self:SetMember(nil);
	self.NameFrame.Name:SetText(headerText);
end

function CommunitiesMemberListEntryMixin:SetProfessionId(professionId)
	self.professionId = professionId;
end

function CommunitiesMemberListEntryMixin:GetProfessionId()
	return self.professionId;
end

function CommunitiesMemberListEntryMixin:SetProfessionHeader(professionId, professionName, isCollapsed)
	self:SetMember(nil, nil, professionId);
	
	local professionHeader = self.ProfessionHeader;
	professionHeader.AllRecipes:SetShown(CanViewGuildRecipes(professionId));
	professionHeader.Icon:SetTexture(C_TradeSkillUI.GetTradeSkillTexture(professionId));
	professionHeader.Name:SetText(C_TradeSkillUI.GetTradeSkillDisplayName(professionId));
	self:SetCollapsed(isCollapsed);
	professionHeader:Show();
end

function CommunitiesMemberListEntryMixin:OnProfessionHeaderClicked()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:SetCollapsed(not self.isCollapsed);
	self:GetMemberList():SetProfessionCollapsed(self:GetProfessionId(), self.isCollapsed);
end

function CommunitiesMemberListEntryMixin:SetCollapsed(collapsed)
	self.isCollapsed = collapsed;
	self.ProfessionHeader.CollapsedIcon:SetShown(collapsed);
	self.ProfessionHeader.ExpandedIcon:SetShown(not collapsed);
end

function CommunitiesMemberListEntryMixin:SetMember(memberInfo, isInvitation, professionId)
	self.isInvitation = isInvitation;
	
	self:SetProfessionId(professionId);
	self.ProfessionHeader:Hide();
	
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
	self.GuildInfo:SetShown(hasMemberInfo and self.guildColumnIndex ~= nil);
	if not hasMemberInfo then
		return;
	end

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
	if clubInfo.clubType == Enum.ClubType.Guild then
		self.Rank:SetText(memberInfo.guildRank or "");
	elseif memberRoleId then
		self.Rank:SetText(COMMUNITY_MEMBER_ROLE_NAMES[memberRoleId]);
	else
		self.Rank:SetText("");
	end
		self.Note:SetText(memberInfo.memberNote or "");
		
	-- TODO:: Replace these hardcoded strings with proper accessors.
	if self.guildColumnIndex == EXTRA_GUILD_COLUMN_ACHIEVEMENT then
		self.GuildInfo:SetText(memberInfo.achievementPoints or "");
	elseif self.guildColumnIndex == EXTRA_GUILD_COLUMN_PROFESSION then
		local professionId = self:GetProfessionId();
		if professionId == memberInfo.profession1ID then
			self.GuildInfo:SetText(COMMUNITIES_MEMBER_LIST_PROFESSION_DISPLAY:format(memberInfo.profession1Rank));
		elseif professionId == memberInfo.profession2ID then
			self.GuildInfo:SetText(COMMUNITIES_MEMBER_LIST_PROFESSION_DISPLAY:format(memberInfo.profession2Rank));
		else
			self.GuildInfo:SetText("");
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
		self.isSelf = memberInfo.isSelf;
		self.guid = memberInfo.guid;
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