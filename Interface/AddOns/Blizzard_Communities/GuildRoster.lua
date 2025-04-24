
COMMUNITIES_GUILD_DETAIL_NORM_HEIGHT = 175;
COMMUNITIES_GUILD_DETAIL_OFFICER_HEIGHT = 228;

CommunitiesGuildMemberDetailMixin = {};

function CommunitiesGuildMemberDetailMixin:OnLoad()
	self.RankDropdown:SetWidth(169 - self.RankLabel:GetWidth());
end

function CommunitiesGuildMemberDetailMixin:OnShow()
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	CommunitiesFrame:RegisterDialogShown(self);
end

function CommunitiesGuildMemberDetailMixin:SetupRankDropdown()
	local memberInfo = self:GetMemberInfo();
	if memberInfo == nil or memberInfo.guildRankOrder == nil or memberInfo.guid == nil then
		return;
	end
	
	local myMemberInfo = C_Club.GetMemberInfoForSelf(self:GetClubId());
	if myMemberInfo == nil or myMemberInfo.guildRankOrder == nil then
		return;
	end

	self.RankDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_GUILD_RANKS");

		local memberRankOrder = memberInfo.guildRankOrder;
		local highestRankOrder = CanGuildPromote() and (myMemberInfo.guildRankOrder + 1) or memberRankOrder;
		local lowestRankOrder = CanGuildDemote() and GuildControlGetNumRanks() or memberRankOrder;

		local function IsSelected(listRankOrder)
			return memberRankOrder == listRankOrder;
		end

		local function SetSelected(listRankOrder)
			if memberRankOrder ~= listRankOrder then
				C_GuildInfo.SetGuildRankOrder(memberInfo.guid, listRankOrder);
			end
		end

		for listRankOrder = highestRankOrder, lowestRankOrder do
			local text = GuildControlGetRankName(listRankOrder);
			local radio = rootDescription:CreateRadio(text, IsSelected, SetSelected, listRankOrder);

			if not C_GuildInfo.IsGuildRankAssignmentAllowed(memberInfo.guid, listRankOrder) then
				radio:SetEnabled(false);
				radio:SetTooltip(function(tooltip, elementDescription)
					GameTooltip_SetTitle(tooltip, GUILD_RANK_UNAVAILABLE);
					GameTooltip_AddNormalLine(tooltip, GUILD_RANK_UNAVAILABLE_AUTHENTICATOR);
				end);
			end
		end
	end);
end
	
function CommunitiesGuildMemberDetailMixin:OnHide()
	self:UnregisterEvent("GUILD_ROSTER_UPDATE");
end

function CommunitiesGuildMemberDetailMixin:OnEvent(event, ...)
	if event == "GUILD_ROSTER_UPDATE" then
		local canRequestRosterUpdate = ...;
		if ( canRequestRosterUpdate ) then
			C_GuildInfo.GuildRoster();
		end
		
		local clubId = self:GetClubId();
		local memberInfo = self:GetMemberInfo();
		if clubId ~= nil and memberInfo ~= nil then
			self:DisplayMember(clubId, memberInfo);
		end

		self:SetupRankDropdown();
	end
end

function CommunitiesGuildMemberDetailMixin:GetClubId()
	return self.clubId;
end

function CommunitiesGuildMemberDetailMixin:GetMemberInfo()
	if self.clubId ~= nil and self.memberId ~= nil then
		return C_Club.GetMemberInfo(self.clubId, self.memberId);
	end
	return nil;
end

function CommunitiesGuildMemberDetailMixin:DisplayMember(clubId, memberInfo)	
	if memberInfo == nil or memberInfo.name == nil or memberInfo.guildRankOrder == nil then
		self:Hide();
		return;
	end
	
	self.clubId = clubId;
	self.memberId = memberInfo.memberId;
	
	local myMemberInfo = C_Club.GetMemberInfoForSelf(clubId);
	if myMemberInfo == nil or myMemberInfo.guildRankOrder == nil then
		self:Hide();
		return;
	end
	
	self.Name:SetText(memberInfo.name);
	
	if memberInfo.classID then
		local classInfo = C_CreatureInfo.GetClassInfo(memberInfo.classID);
		if classInfo then
			self.Level:SetText(FRIENDS_LEVEL_TEMPLATE:format(memberInfo.level, classInfo.className));
		end
	end
	
	self.ZoneText:SetText(memberInfo.zone or "");
	self.RankText:SetText(memberInfo.guildRank or "");
	if not memberInfo.lastOnlineHour then
		self.OnlineText:SetText(GUILD_ONLINE_LABEL);
	else
		self.OnlineText:SetText(RecentTimeDate(memberInfo.lastOnlineYear, memberInfo.lastOnlineMonth, memberInfo.lastOnlineDay, memberInfo.lastOnlineHour));
	end

	local personalNoteText = self.NoteBackground.PersonalNoteText;
	local note = memberInfo.memberNote;
	local canEditNote = memberInfo.isSelf or CanEditPublicNote();
	if canEditNote then
		personalNoteText:SetTextColor(1.0, 1.0, 1.0);
		if not note or note == "" then
			note = GUILD_NOTE_EDITLABEL;
		end
	else
		personalNoteText:SetTextColor(0.65, 0.65, 0.65);
	end
	self.NoteBackground:EnableMouse(canEditNote);
	personalNoteText:SetText(note);

	local maxRankOrder = GuildControlGetNumRanks();	
	local myRankOrder = myMemberInfo.guildRankOrder;
	local rankOrder = memberInfo.guildRankOrder;
	local canPromote = CanGuildPromote() and rankOrder > myRankOrder + 1;
	local canDemote = CanGuildDemote() and rankOrder < maxRankOrder and rankOrder > myRankOrder;
	if canPromote or canDemote then
		self.RankLabel:SetHeight(20);
		self.RankDropdown:Show();
		self.RankText:Hide();
	else
		self.RankLabel:SetHeight(0);
		self.RankDropdown:Hide();
		self.RankText:Show();
	end
	
	-- Update officer note
	local officerNoteText = self.OfficerNoteBackground.OfficerNoteText;
	if C_GuildInfo.CanViewOfficerNote() then
		local officernote = memberInfo.officerNote;
		if C_GuildInfo.CanEditOfficerNote() then
			if not officernote or officernote == "" then
				officernote = GUILD_OFFICERNOTE_EDITLABEL;
			end
			officerNoteText:SetTextColor(1.0, 1.0, 1.0);
		else
			officerNoteText:SetTextColor(0.65, 0.65, 0.65);
		end
		self.OfficerNoteBackground:EnableMouse(C_GuildInfo.CanEditOfficerNote());
		officerNoteText:SetText(officernote);

		-- Resize detail frame
		self.OfficerNoteLabel:Show();
		self.OfficerNoteBackground:Show();
		self:SetHeight(COMMUNITIES_GUILD_DETAIL_OFFICER_HEIGHT + self.Name:GetHeight() + self.RankLabel:GetHeight());
	else
		self.OfficerNoteLabel:Hide();
		self.OfficerNoteBackground:Hide();
		self:SetHeight(COMMUNITIES_GUILD_DETAIL_NORM_HEIGHT + self.Name:GetHeight() + self.RankLabel:GetHeight());
	end
	
	self.RemoveButton:SetEnabled(CanGuildRemove() and rankOrder > myRankOrder);
	self.GroupInviteButton:SetEnabled(memberInfo.lastOnlineHour == nil and not memberInfo.isRemoteChat and memberInfo.presence ~= Enum.ClubMemberPresence.OnlineMobile);

	self:SetupRankDropdown();

	self:Show();
end