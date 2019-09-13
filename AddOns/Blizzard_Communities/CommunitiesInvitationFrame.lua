
local COMMUNITIES_INVITATION_FRAME_EVENTS = {
	"CLUB_MEMBER_UPDATED",
	"PLAYER_REPORT_SUBMITTED",
};

CommunitiesInvitationFrameMixin = {};

function CommunitiesInvitationFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_INVITATION_FRAME_EVENTS);
	self:GetCommunitiesFrame().ClubFinderInvitationFrame:Hide(); 
end

function CommunitiesInvitationFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, COMMUNITIES_INVITATION_FRAME_EVENTS);
end

function CommunitiesInvitationFrameMixin:OnEvent(event, ...)
	if event == "CLUB_MEMBER_UPDATED" then
		local clubId, memberId = ...;
		if clubId == self.clubId then
			local invitationInfo = C_Club.GetInvitationInfo(self.clubId);
			self:DisplayInvitation(invitationInfo);
		end
	elseif event == "PLAYER_REPORT_SUBMITTED" then
		local guid = ...;
		if self.inviterInfo and self.inviterInfo.guid == guid then
			self:DeclineInvitation();
		end
	end
end

function CommunitiesInvitationFrameMixin:GetCommunitiesFrame()
	return self:GetParent();
end

function CommunitiesInvitationFrameMixin:DisplayInvitation(invitationInfo)
	self.invitationId = invitationInfo.invitationId;
	
	local clubInfo = invitationInfo.club;
	local inviterInfo = invitationInfo.inviter;
	self.inviterInfo = inviterInfo;
	self.clubId = clubInfo.clubId;
	
	local isCharacterClub = clubInfo.clubType == Enum.ClubType.Character;
	local inviterName = inviterInfo.name or "";
	local classInfo = inviterInfo.classID and C_CreatureInfo.GetClassInfo(inviterInfo.classID);
	local inviterText;
	if isCharacterClub and classInfo then
		local classColorInfo = RAID_CLASS_COLORS[classInfo.classFile];
		inviterText = GetPlayerLink(inviterName, ("[%s]"):format(WrapTextInColorCode(inviterName, classColorInfo.colorStr)));
	elseif isCharacterClub then
		inviterText = GetPlayerLink(inviterName, ("[%s]"):format(inviterName));
	else
		inviterText = inviterName;
	end

	self.InvitationText:SetText(COMMUNITY_INVITATION_FRAME_INVITATION_TEXT:format(inviterText));
	
	local clubTypeText = isCharacterClub and COMMUNITIES_INVITATION_FRAME_TYPE_CHARACTER or COMMUNITIES_INVITATION_FRAME_TYPE;
	self.Type:SetText(clubTypeText);
	C_Club.SetAvatarTexture(self.Icon, clubInfo.avatarId, clubInfo.clubType);
	self.IconRing:SetAtlas(clubInfo.clubType == Enum.ClubType.BattleNet and "communities-ring-blue" or "communities-ring-gold");
	self.Name:SetText(clubInfo.name);
	
	if clubInfo.description ~= "" then
		self.Description:SetText(COMMUNITIES_INVIVATION_FRAME_DESCRIPTION_FORMAT:format(clubInfo.description));
	else
		self.Description:SetText("");
	end
	
	local leadersText = "";
	for i, leader in ipairs(invitationInfo.leaders) do
		if leader.name then
			leadersText = leadersText..leader.name;
			if i ~= #invitationInfo.leaders then
				leadersText = leadersText..PLAYER_LIST_DELIMITER;
			end
		end
	end

	self.Leader:SetText(COMMUNITIES_INVIVATION_FRAME_LEADER_FORMAT:format(leadersText));
	self.MemberCount:SetText(COMMUNITIES_INVITATION_FRAME_MEMBER_COUNT:format(clubInfo.memberCount or 1));
	
	GuildMicroButton:MarkCommunitiesInvitiationDisplayed(self.clubId);
end

function CommunitiesInvitationFrameMixin:AcceptInvitation()
	C_Club.AcceptInvitation(self.clubId);
	local communitiesFrame = self:GetCommunitiesFrame();
	communitiesFrame:SelectClub(nil);
	communitiesFrame:TriggerEvent(CommunitiesFrameMixin.Event.InviteAccepted, self.invitationId, self.clubId);
	self:Hide();
end

function CommunitiesInvitationFrameMixin:DeclineInvitation()
	C_Club.DeclineInvitation(self.clubId);
	self:GetCommunitiesFrame():TriggerEvent(CommunitiesFrameMixin.Event.InviteDeclined, self.invitationId, self.clubId);
	self:Hide();
end

function CommunitiesInvitationFrameMixin:OnHyperlinkClick(link, text, button, ...)
	if button == "RightButton" then
		FriendsFrame_ShowDropdown(self.inviterInfo.name or "", 1, nil, nil, nil, nil, nil, self.clubId, nil, nil, nil, self.inviterInfo.guid)
	else
		SetItemRef(link, text, button, nil);
	end
end

function CommunitiesInviteButton_OnClick(self)
	local communitiesFrame = self:GetParent();
	local clubId = communitiesFrame:GetSelectedClubId();
	local streamId = communitiesFrame:GetSelectedStreamId();
	CommunitiesUtil.OpenInviteDialog(clubId, streamId);

	HelpTip:Acknowledge(communitiesFrame, CLUB_FINDER_TUTORIAL_GUILD_LINK);
end

function CommunitiesInvitebutton_OnHide(self)
	if StaticPopup_Visible("INVITE_COMMUNITY_MEMBER") then
		StaticPopup_Hide("INVITE_COMMUNITY_MEMBER");
	end
	
	if StaticPopup_Visible("INVITE_COMMUNITY_MEMBER_WITH_INVITE_LINK") then
		StaticPopup_Hide("INVITE_COMMUNITY_MEMBER_WITH_INVITE_LINK");
	end
end

CommunitiesTicketFrameMixin = {};

-- overrides CommunitiesInvitationFrameMixin:OnShow 
function CommunitiesTicketFrameMixin:OnShow()
end

-- overrides CommunitiesInvitationFrameMixin:OnHide 
function CommunitiesTicketFrameMixin:OnHide()
end

function CommunitiesTicketFrameMixin:OnEvent(event, ...)
end

function CommunitiesTicketFrameMixin:DisplayTicket(ticketInfo)
	self.ticketId = ticketInfo.ticketId;
	
	local clubInfo = ticketInfo.clubInfo;
	self.clubId = clubInfo.clubId;

	local isCharacterClub = clubInfo.clubType == Enum.ClubType.Character;
	local clubTypeText = isCharacterClub and COMMUNITIES_INVITATION_FRAME_TYPE_CHARACTER or COMMUNITIES_INVITATION_FRAME_TYPE;
	self.Type:SetText(clubTypeText);
	C_Club.SetAvatarTexture(self.Icon, clubInfo.avatarId, clubInfo.clubType);
	self.Name:SetText(clubInfo.name);
	
	if clubInfo.description ~= "" then
		self.Description:SetText(COMMUNITIES_INVIVATION_FRAME_DESCRIPTION_FORMAT:format(clubInfo.description));
	else
		self.Description:SetText("");
	end
	
	self.Leader:SetText(nil);

	self.MemberCount:SetText(COMMUNITIES_INVITATION_FRAME_MEMBER_COUNT:format(clubInfo.memberCount or 1));
end

function CommunitiesTicketFrameMixin:AcceptTicket()
	C_Club.RedeemTicket(self.ticketId);
	local communitiesFrame = self:GetCommunitiesFrame();
	communitiesFrame.CommunitiesList:RemoveTicket(self.ticketId);
	communitiesFrame:SelectClub(nil);
	communitiesFrame:TriggerEvent(CommunitiesFrameMixin.Event.TicketAccepted, self.ticketId, self.clubId);
	self:Hide();
end

function CommunitiesTicketFrameMixin:DeclineTicket()
	local communitiesFrame = self:GetCommunitiesFrame();
	communitiesFrame.CommunitiesList:RemoveTicket(self.ticketId);
	communitiesFrame:SelectClub(nil);
	self:Hide();
end