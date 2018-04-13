
local COMMUNITIES_MEMBER_LIST_EVENTS = {
	"CLUB_MEMBER_ADDED",
	"CLUB_MEMBER_REMOVED",
	"CLUB_MEMBER_UPDATED",
};

local COMMUNITIES_MEMBER_LIST_ENTRY_EVENTS = {
	"CLUB_MEMBER_PRESENCE_UPDATED",
	"CLUB_MEMBER_ROLE_UPDATED",
};

COMMUNITY_MEMBER_ROLE_NAMES = {
	[Enum.ClubRoleIdentifier.Owner] = COMMUNITY_MEMBER_ROLE_NAME_OWNER,
	[Enum.ClubRoleIdentifier.Leader] = COMMUNITY_MEMBER_ROLE_NAME_LEADER,
	[Enum.ClubRoleIdentifier.Moderator] = COMMUNITY_MEMBER_ROLE_NAME_MODERATOR,
	[Enum.ClubRoleIdentifier.Member] = COMMUNITY_MEMBER_ROLE_NAME_MEMBER,
};

CommunitiesMemberListMixin = {};

function CommunitiesMemberListMixin:OnClubSelected(clubId)
	self:Update();
end

local PRESENCE_SORT_ORDER = {
	[Enum.ClubMemberPresence.Online] = 1,
	[Enum.ClubMemberPresence.Away] = 2,
	[Enum.ClubMemberPresence.Busy] = 3,
	[Enum.ClubMemberPresence.Offline] = 4,
	[Enum.ClubMemberPresence.Unknown] = 5,
};

local function CompareMembers(lhsMemberInfo, rhsMemberInfo)
	if lhsMemberInfo.presence == rhsMemberInfo.presence then
		return lhsMemberInfo.memberId < rhsMemberInfo.memberId;
	else
		return PRESENCE_SORT_ORDER[lhsMemberInfo.presence] < PRESENCE_SORT_ORDER[rhsMemberInfo.presence];
	end
end

function CommunitiesMemberListMixin:Update()
	local scrollFrame = self.ListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local clubId = self:GetSelectedClubId();

	local memberLookup = {};
	local members = clubId and C_Club.GetClubMembers(clubId) or {};
	table.sort(members, function(lhsMemberId, rhsMemberId)
		if not memberLookup[lhsMemberId] then
			memberLookup[lhsMemberId] = C_Club.GetMemberInfo(clubId, lhsMemberId);
		end
		
		if not memberLookup[rhsMemberId] then
			memberLookup[rhsMemberId] = C_Club.GetMemberInfo(clubId, rhsMemberId);
		end
		
		return CompareMembers(memberLookup[lhsMemberId], memberLookup[rhsMemberId]);
	end);
	
	local usedHeight = 0;
	local height = buttons[1]:GetHeight();
	for i=1, #buttons do
		local displayIndex = i + offset;
		local button = buttons[i];
		if displayIndex <= #members then
			local memberId = members[displayIndex];
			button:SetMember(clubId, memberId);
			button:Show();
			usedHeight = usedHeight + height;
		else
			button:SetMember(nil);
			button:Hide();
		end
	end
	HybridScrollFrame_Update(scrollFrame, height * #members, usedHeight);
end

function CommunitiesMemberListMixin:OnLoad()
	self.ListScrollFrame.update = function()
		self:Update(); 
	end;
	self.ListScrollFrame.scrollBar.doNotHide = true;
	self.ListScrollFrame.scrollBar:SetValue(0);	
end
	
function CommunitiesMemberListMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_MEMBER_LIST_EVENTS);
	
	HybridScrollFrame_CreateButtons(self.ListScrollFrame, "CommunitiesMemberListEntryTemplate", 0, 0);
	self:Update();
	
	local function CommunitiesDisplayModeChangedCallback(event, displayMode)
		local expandedDisplay = displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER;
		if expandedDisplay then
			self:SetPoint("TOPLEFT", self:GetCommunitiesFrame().CommunitiesList, "TOPRIGHT", 26, -60);
		else
			self:SetPoint("TOPLEFT", self:GetCommunitiesFrame(), "TOPRIGHT", -165, -63);
		end
		
		self.ColumnDisplay:SetShown(expandedDisplay);
		
		for i, button in ipairs(self.ListScrollFrame.buttons) do
			button:SetExpanded(expandedDisplay);
		end
	end
	
	self.displayModeChangedCallback = CommunitiesDisplayModeChangedCallback;
	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.DisplayModeChanged, self.displayModeChangedCallback);
end
	
function CommunitiesMemberListMixin:OnEvent(event)
	if event == "CLUB_MEMBER_ADDED" or event == "CLUB_MEMBER_REMOVED" or event == "CLUB_MEMBER_UPDATED" then
		self:Update();
	end
end

function CommunitiesMemberListMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, COMMUNITIES_MEMBER_LIST_EVENTS);
	self:GetCommunitiesFrame():UnregisterCallback(CommunitiesFrameMixin.Event.DisplayModeChanged, self.displayModeChangedCallback);
end

function CommunitiesMemberListMixin:GetCommunitiesFrame()
	return self:GetParent();
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

function CommunitiesMemberListMixin:RemoveSelectedEntryFromCommunity()
	local selectedEntry = self:GetSelectedEntry();
	if selectedEntry then
		local clubId = self:GetSelectedClubId();
		local memberId = selectedEntry:GetMemberId()
		if clubId and memberId then
			C_Club.KickMember(clubId, memberId);
		end
	end
end

function CommunitiesMemberListMixin:AssignRoleToSelectedEntry(roleId)
	local selectedEntry = self:GetSelectedEntry();
	if selectedEntry then
		local clubId = self:GetSelectedClubId();
		local memberId = selectedEntry:GetMemberId()
		if clubId and memberId then
			C_Club.AssignMemberRole(clubId, memberId, roleId);
		end
	end
end

function CommunitiesMemberListMixin:GetSelectedClubId()
	return self:GetCommunitiesFrame():GetSelectedClubId();
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
			self:UpdateRank(roleId);
			self:UpdateNameFrame();
		end
	elseif event == "CLUB_MEMBER_PRESENCE_UPDATED" then
		local clubId, memberId, presence = ...;
		local thisClubId = self:GetMemberList():GetSelectedClubId();
		local thisMemberId = self:GetMemberId();
		if clubId == thisClubId and memberId == thisMemberId then
			self:UpdatePresence(presence);
			self:UpdateNameFrame();
			self:GetMemberList():Update();
		end
	end
end

function CommunitiesMemberListEntryMixin:GetMemberList()
	return self:GetParent():GetParent():GetParent();
end

function CommunitiesMemberListEntryMixin:UpdateRank(roleId)
	self.NameFrame.RankIcon:Show();

	if roleId == Enum.ClubRoleIdentifier.Owner or roleId == Enum.ClubRoleIdentifier.Leader then
		self.NameFrame.RankIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
	elseif roleId == Enum.ClubRoleIdentifier.Moderator then
		self.NameFrame.RankIcon:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon");
	else
		self.NameFrame.RankIcon:Hide();
	end
end

function CommunitiesMemberListEntryMixin:UpdatePresence(presence)
	self.NameFrame.PresenceIcon:Show();
	
	if self.memberId then
		local clubId = self:GetMemberList():GetSelectedClubId();
		local memberInfo = C_Club.GetMemberInfo(clubId, self.memberId);
		if memberInfo.classID then
			local classInfo = C_CreatureInfo.GetClassInfo(memberInfo.classID);
			local color = (classInfo and RAID_CLASS_COLORS[classInfo.classFile]) or NORMAL_FONT_COLOR;
			self.NameFrame.Name:SetTextColor(color.r, color.g, color.b);
		else
			self.NameFrame.Name:SetTextColor(BATTLENET_FONT_COLOR:GetRGB());
		end
	end
	
	if presence == Enum.ClubMemberPresence.Away then
		self.NameFrame.PresenceIcon:SetTexture(FRIENDS_TEXTURE_AFK);
	elseif presence == Enum.ClubMemberPresence.Busy then
		self.NameFrame.PresenceIcon:SetTexture(FRIENDS_TEXTURE_DND);
	else
		self.NameFrame.PresenceIcon:Hide();
		if presence == Enum.ClubMemberPresence.Offline then
			self.NameFrame.Name:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		end
	end
end

function CommunitiesMemberListEntryMixin:SetMember(clubId, memberId)
	self.memberId = memberId;
	if memberId then
		local memberInfo = C_Club.GetMemberInfo(clubId, memberId);
		self.NameFrame.Name:SetText(memberInfo.name);
		self:UpdateRank(memberInfo.role);
		self:UpdatePresence(memberInfo.presence);
		self:RefreshExpandedColumns();
		self:UpdateNameFrame();
	else
		self.NameFrame.Name:SetText(nil);
		self:UpdatePresence(Enum.ClubMemberPresence.Offline);
		self:UpdateNameFrame();
	end
end

function CommunitiesMemberListEntryMixin:GetMemberId(memberId)
	return self.memberId;
end

function CommunitiesMemberListEntryMixin:OnEnter()
	if self.expanded then
		if not self.NameFrame.Name:IsTruncated() and not self.Rank:IsTruncated() and not self.Note:IsTruncated() and not self.Zone:IsTruncated() then
			return;
		end
	end
	
	local clubId = self:GetMemberList():GetSelectedClubId();
	local memberId = self:GetMemberId();
	if clubId and memberId then
		local member = C_Club.GetMemberInfo(clubId, memberId);
		GameTooltip:SetOwner(self);
		GameTooltip:AddLine(member.name);
		
		local memberRoleId = member.role;
		if memberRoleId then
			GameTooltip:AddLine(COMMUNITY_MEMBER_ROLE_NAMES[memberRoleId], HIGHLIGHT_FONT_COLOR:GetRGB());
		end
		
		if member.level and member.race and member.classID then
			local raceInfo = C_CreatureInfo.GetRaceInfo(member.race);
			local classInfo = C_CreatureInfo.GetClassInfo(member.classID);
			if raceInfo and classInfo then
				GameTooltip:AddLine(COMMUNITY_MEMBER_CHARACTER_INFO_FORMAT:format(member.level, raceInfo.raceName, classInfo.className), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
			end
		end
		
		if member.zone then
			GameTooltip:AddLine(member.zone, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
		end
		
		if member.memberNote then
			GameTooltip:AddLine(COMMUNITY_MEMBER_NOTE_FORMAT:format(member.memberNote), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		end
		
		GameTooltip:Show();
	end
end

function CommunitiesMemberListEntryMixin:OnLeave()
	GameTooltip:Hide();
end

function CommunitiesMemberListEntryMixin:OnClick(button)
	self:GetMemberList():OnClubMemberButtonClicked(self, button);
end

function CommunitiesMemberListEntryMixin:RefreshExpandedColumns()
	if not self.expanded then
		return;
	end

	local memberId = self:GetMemberId();
	if memberId then
		local clubId = self:GetMemberList():GetSelectedClubId();
		local clubInfo = C_Club.GetClubInfo(clubId);
		local memberInfo = C_Club.GetMemberInfo(clubId, memberId);
		if not clubInfo or not memberInfo then
			return;
		end
		
		if clubInfo.clubType == Enum.ClubType.BattleNet then
			self.Level:Hide();
			self.Class:Hide();
			self.Zone:Hide();
			
			self.Rank:SetSize(75, 0);
			self.Rank:ClearAllPoints();
			self.Rank:SetPoint("LEFT", self.NameFrame.Name, "RIGHT", 9, 0);
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
			self.Rank:SetPoint("LEFT", self.Zone, "RIGHT", 10, 0);
		end
		
		local memberRoleId = memberInfo.role;
		if memberRoleId then
			self.Rank:SetText(COMMUNITY_MEMBER_ROLE_NAMES[memberRoleId]);
		else
			self.Rank:SetText("");
		end
		self.Note:SetText(memberInfo.memberNote or "");
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

function CommunitiesMemberListEntryMixin:UpdateNameFrame()
	local nameFrame = self.NameFrame;
	nameFrame:SetSize(136, 20);
	nameFrame:ClearAllPoints();
	if self.Class:IsShown() then -- Character community roster view
		nameFrame:SetSize(90, 20);
		nameFrame:SetPoint("LEFT", self.Class, "RIGHT", 12, 0);
	else
		nameFrame:SetPoint("LEFT", 4, 0);
	end
	
	if nameFrame.PresenceIcon:IsShown() then
		nameFrame.Name:SetPoint("LEFT", nameFrame.PresenceIcon, "RIGHT");
	else
		nameFrame.Name:SetPoint("LEFT");
	end

	nameFrame.RankIcon:ClearAllPoints();
	nameFrame.RankIcon:SetPoint("LEFT", nameFrame.Name, "RIGHT", nameFrame.Name:GetStringWidth() - nameFrame.Name:GetWidth(), 0);
end

function CommunitiesMemberListDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, CommunitiesMemberListDropdown_Initialize, "MENU");
end

function CommunitiesMemberListDropDown_OnHide(self)
	local CommunitiesMemberList = self:GetParent();
	CommunitiesMemberList:OnDropDownClosed();
end

local function CanKickMember(clubPrivileges, memberInfo)
	return tContains(clubPrivileges.kickableRoleIds, memberInfo.role);
end

function CommunitiesMemberListDropdown_Initialize(self, level)
	local CommunitiesMemberList = self:GetParent();
	local SelectedCommunitiesMemberListEntry = CommunitiesMemberList:GetSelectedEntry();
	if not SelectedCommunitiesMemberListEntry then
		return;
	end
		
	local clubId = CommunitiesMemberList:GetSelectedClubId();
	local memberId = SelectedCommunitiesMemberListEntry:GetMemberId();
	local memberInfo = C_Club.GetMemberInfo(clubId, memberId);
	local clubPrivileges = C_Club.GetClubPrivileges(clubId);
	local myMemberInfo = C_Club.GetMemberInfoForSelf(clubId);
	if memberInfo then
		if level == 1 then
			if myMemberInfo and myMemberInfo.memberId == memberInfo.memberId then
				info = CommunitiesDropDown_GetLeaveCommunityButtonInfo(clubId);
				if info then
					UIDropDownMenu_AddButton(info, level);
				end
			else
				if CanKickMember(clubPrivileges, memberInfo) then
					local info = UIDropDownMenu_CreateInfo();
					info.text = COMMUNITY_MEMBER_LIST_DROP_DOWN_REMOVE;
					info.func = function()
						CommunitiesMemberList:RemoveSelectedEntryFromCommunity();
					end 
					
					info.isNotRadio = true;
					info.notCheckable = true;
					UIDropDownMenu_AddButton(info, level);
				end
			end
			
			if clubPrivileges.canSetOtherMemberAttribute then
				local info = UIDropDownMenu_CreateInfo();
				info.text = COMMUNITY_MEMBER_LIST_DROP_DOWN_SET_NOTE;
				info.func = function()
					StaticPopup_Show("SET_COMMUNITY_MEMBER_NOTE", memberInfo.name, nil, { clubId = clubId, memberId = memberId });
				end 
				
				info.isNotRadio = true;
				info.notCheckable = true;
				UIDropDownMenu_AddButton(info, level);
			end
			
			local assignableRoles = C_Club.GetAssignableRoles(clubId, memberId);
			if assignableRoles and #assignableRoles > 0 then
				local info = UIDropDownMenu_CreateInfo();
				info.hasArrow = true;
				info.notCheckable = true;
				info.text = COMMUNITY_MEMBER_LIST_DROP_DOWN_ROLES;
				UIDropDownMenu_AddButton(info, level);
			end
		elseif level == 2 then
			local assignableRoles = C_Club.GetAssignableRoles(clubId, memberId);
			if assignableRoles and #assignableRoles > 0 then
				local function AssignRole(button, roleId)
					CommunitiesMemberList:AssignRoleToSelectedEntry(roleId);
					CloseDropDownMenus();
				end
				
				local info = UIDropDownMenu_CreateInfo();
				info.func = AssignRole;
				info.isNotRadio = true;
				info.notCheckable = true;
				for i, roleId in ipairs(assignableRoles) do
					info.text = COMMUNITY_MEMBER_ROLE_NAMES[roleId];
					info.arg1 = roleId;
					UIDropDownMenu_AddButton(info, level);
				end
			end
		end
	end
end

local BNET_COLUMN_INFO = {
	[1] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_NAME,
		width = 145,
	},
	
	[2] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_RANK,
		width = 85,
	},
	
	[3] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_NOTE,
		width = 0,
	},
};

local CHARACTER_COLUMN_INFO = {
	[1] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_LEVEL,
		width = 40,
	},
	
	[2] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_CLASS,
		width = 30,
	},
	
	[3] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_NAME,
		width = 100,
	},
	
	[4] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_ZONE,
		width = 100,
	},
	
	[5] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_RANK,
		width = 85,
	},
	
	[6] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_NOTE,
		width = 0,
	},
};

CommunitiesMemberListColumnDisplayMixin = {};

function CommunitiesMemberListColumnDisplayMixin:OnLoad()
	self.columnHeaders = CreateFramePool("BUTTON", self, "CommunitiesMemberListColumnButtonTemplate");
end

function CommunitiesMemberListColumnDisplayMixin:OnShow()
	local communitiesFrame = self:GetParent():GetCommunitiesFrame();
	local clubId = communitiesFrame:GetSelectedClubId();
	if clubId then
		local clubInfo = C_Club.GetClubInfo(clubId);
		if clubInfo then
			if clubInfo.clubType == Enum.ClubType.BattleNet then
				self:LayoutColumns(BNET_COLUMN_INFO);
			else
				self:LayoutColumns(CHARACTER_COLUMN_INFO);
			end
		end
	end
end

function CommunitiesMemberListColumnDisplayMixin:LayoutColumns(columnInfo)
	self.columnHeaders:ReleaseAll();
	local previousHeader = nil;
	for i, info in ipairs(columnInfo) do
		local header = self.columnHeaders:Acquire();
		header:SetText(info.title);
		header:SetWidth(info.width);
		if i == 1 then
			header:SetPoint("BOTTOMLEFT", 2, 1);
			if #columnInfo == 1 then
				header:SetPoint("BOTTOMRIGHT");
			end
		elseif i == #columnInfo then
			header:SetPoint("BOTTOMLEFT", previousHeader, "BOTTOMRIGHT");
			
			if info.width == 0 then
				header:SetPoint("BOTTOMRIGHT", -28, 1);
			end
		else
			header:SetPoint("BOTTOMLEFT", previousHeader, "BOTTOMRIGHT");
		end
		
		header:Show();
		previousHeader = header;
	end
end

function CommunitiesMemberListColumnButton_OnClick()
	-- TODO:: Implementing sorting by column.
end
