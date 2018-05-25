
local COMMUNITIES_INVITATION_FRAME_EVENTS = {
	"CLUB_MEMBER_UPDATED",
};

CommunitiesInvitationFrameMixin = {};

function CommunitiesInvitationFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_INVITATION_FRAME_EVENTS);
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
	end
end

function CommunitiesInvitationFrameMixin:GetCommunitiesFrame()
	return self:GetParent();
end

function CommunitiesInvitationFrameMixin:DisplayInvitation(invitationInfo)
	self.invitationId = invitationInfo.invitationId;
	
	local clubInfo = invitationInfo.club;
	local inviterInfo = invitationInfo.inviter;
	self.clubId = clubInfo.clubId;
	self.InvitationText:SetText(COMMUNITY_INVITATION_FRAME_INVITATION_TEXT:format(inviterInfo.name));

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
	
	local leadersText = "";
	for i, leader in ipairs(invitationInfo.leaders) do
		leadersText = leadersText..leader.name;
		if i ~= #invitationInfo.leaders then
			leadersText = leadersText..PLAYER_LIST_DELIMITER;
		end
	end

	self.Leader:SetText(COMMUNITIES_INVIVATION_FRAME_LEADER_FORMAT:format(leadersText));
	
	-- TODO:: Discuss if we want this and add proper accessors if we do.
	self.MemberCount:SetText(COMMUNITIES_INVITATION_FRAME_MEMBER_COUNT:format(clubInfo.memberCount or 1));
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

function CommunitiesInviteButton_OnClick(self)
	local communitiesFrame = self:GetParent();
	local clubId = communitiesFrame:GetSelectedClubId();
	local privileges = communitiesFrame:GetPrivilegesForClub(clubId);
	local clubInfo = C_Club.GetClubInfo(clubId);
	if not clubInfo then
		return;
	end
	
	if clubInfo.clubType == Enum.ClubType.Guild then
		StaticPopup_Show("ADD_GUILDMEMBER");
	elseif privileges.canCreateTicket then
		StaticPopup_Show("INVITE_COMMUNITY_MEMBER_WITH_INVITE_LINK", nil, nil, { clubId = clubId, streamId = communitiesFrame:GetSelectedStreamId(), });
	else
		StaticPopup_Show("INVITE_COMMUNITY_MEMBER", nil, nil, { clubId = clubId, streamId = communitiesFrame:GetSelectedStreamId(), });
	end
end

function CommunitiesInvitebutton_OnHide(self)
	if StaticPopup_Visible("INVITE_COMMUNITY_MEMBER") then
		StaticPopup_Hide("INVITE_COMMUNITY_MEMBER");
	end
	
	if StaticPopup_Visible("INVITE_COMMUNITY_MEMBER_WITH_INVITE_LINK") then
		StaticPopup_Hide("INVITE_COMMUNITY_MEMBER_WITH_INVITE_LINK");
	end
end
