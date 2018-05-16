
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
	self:Update();
end

function CommunitiesMemberListMixin:RefreshListDisplay()
	local scrollFrame = self.ListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;

	local usedHeight = 0;
	local height = buttons[1]:GetHeight();
	for i = 1, #buttons do
		local displayIndex = i + offset;
		local button = buttons[i];
		if displayIndex <= #self.sortedMemberList then
			local memberInfo = self.sortedMemberList[displayIndex];
			button:SetMember(memberInfo);
			button:Show();
			usedHeight = usedHeight + height;
		else
			button:SetMember(nil);
			button:Hide();
		end
	end
	HybridScrollFrame_Update(scrollFrame, height * #self.sortedMemberList, usedHeight);

end

function CommunitiesMemberListMixin:Update()
	local clubId = self:GetSelectedClubId();

	-- TODO: update on stream selected and pass that in to GetAndSortMemberInfo
	self.sortedMemberList = CommunitiesUtil.GetAndSortMemberInfo(clubId);
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
	
	self.ListScrollFrame.scrollBar.doNotHide = true;
	self.ListScrollFrame.scrollBar:SetValue(0);
	
	self:SetExpandedDisplay(false);
	self:SetGuildColumnIndex(EXTRA_GUILD_COLUMN_ACHIEVEMENT);
end
	
function CommunitiesMemberListMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_MEMBER_LIST_EVENTS);
	
	self:Update();
	
	local function CommunitiesDisplayModeChangedCallback(event, displayMode)
		local expandedDisplay = displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER;
		self:SetExpandedDisplay(expandedDisplay);
	end
	
	self.displayModeChangedCallback = CommunitiesDisplayModeChangedCallback;
	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.DisplayModeChanged, self.displayModeChangedCallback);
end

function CommunitiesMemberListMixin:SetExpandedDisplay(expandedDisplay)
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
					self.ColumnDisplay:LayoutColumns(CHARACTER_COLUMN_INFO, EXTRA_GUILD_COLUMNS[guildColumnIndex]);
				elseif clubInfo.clubType == Enum.ClubType.Character then
					self.ColumnDisplay:LayoutColumns(CHARACTER_COLUMN_INFO);
				else
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
	end
end

function CommunitiesMemberListEntryMixin:GetMemberList()
	return self:GetParent():GetParent():GetParent();
end

function CommunitiesMemberListEntryMixin:UpdateRank()
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

function CommunitiesMemberListEntryMixin:SetMember(memberInfo)
	if memberInfo then
		self.memberInfo = memberInfo;
		self.NameFrame.Name:SetText(memberInfo.name or "");
		self:UpdateRank();
		self:UpdatePresence();
		self:RefreshExpandedColumns();
		self:UpdateNameFrame();
	else
		self.memberInfo = nil;
		self.NameFrame.Name:SetText(nil);
		self:UpdateRank();
		self:UpdatePresence();
		self:UpdateNameFrame();
	end
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
		
		local memberRoleId = memberInfo.role;
		if memberRoleId then
			GameTooltip:AddLine(COMMUNITY_MEMBER_ROLE_NAMES[memberRoleId], HIGHLIGHT_FONT_COLOR:GetRGB());
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
			self.Rank:SetPoint("LEFT", self.NameFrame.Name, "RIGHT", 10, 0);
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
		if memberRoleId then
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
	nameFrame:SetSize(136, 20);
	nameFrame:ClearAllPoints();
	if self.Class:IsShown() then -- Character community roster view
		nameFrame:SetSize(90, 20);
		nameFrame:SetPoint("LEFT", self.Class, "RIGHT", 11, 0);
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
	local clubPrivileges = C_Club.GetClubPrivileges(clubId);
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