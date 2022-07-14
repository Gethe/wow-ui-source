local errorFrame = CreateFrame("FRAME");
errorFrame:RegisterEvent("CLUB_ERROR");
errorFrame:RegisterEvent("CLUB_REMOVED_MESSAGE");

local actionStrings = 
{
	[Enum.ClubActionType.ErrorClubActionCreate] = "ERROR_CLUB_ACTION_CREATE",
	[Enum.ClubActionType.ErrorClubActionEdit] = "ERROR_CLUB_ACTION_EDIT",
	[Enum.ClubActionType.ErrorClubActionDestroy] = "ERROR_CLUB_ACTION_DESTROY",
	[Enum.ClubActionType.ErrorClubActionLeave] = "ERROR_CLUB_ACTION_LEAVE",
	[Enum.ClubActionType.ErrorClubActionCreateTicket] = "ERROR_CLUB_ACTION_CREATE_TICKET",
	[Enum.ClubActionType.ErrorClubActionDestroyTicket] = "ERROR_CLUB_ACTION_DESTROY_TICKET",
	[Enum.ClubActionType.ErrorClubActionRedeemTicket] = "ERROR_CLUB_ACTION_REDEEM_TICKET",
	[Enum.ClubActionType.ErrorClubActionGetTicket] = "ERROR_CLUB_ACTION_GET_TICKET",
	[Enum.ClubActionType.ErrorClubActionGetTickets] = "ERROR_CLUB_ACTION_GET_TICKETS",
	[Enum.ClubActionType.ErrorClubActionGetBans] = "ERROR_CLUB_ACTION_GET_BANS",
	[Enum.ClubActionType.ErrorClubActionGetInvitations] = "ERROR_CLUB_ACTION_GET_INVITATIONS",
	[Enum.ClubActionType.ErrorClubActionRevokeInvitation] = "ERROR_CLUB_ACTION_REVOKE_INVITATION",
	[Enum.ClubActionType.ErrorClubActionAcceptInvitation] = "ERROR_CLUB_ACTION_ACCEPT_INVITATION",
	[Enum.ClubActionType.ErrorClubActionDeclineInvitation] = "ERROR_CLUB_ACTION_DECLINE_INVITATION",
	[Enum.ClubActionType.ErrorClubActionCreateStream] = "ERROR_CLUB_ACTION_CREATE_STREAM",
	[Enum.ClubActionType.ErrorClubActionEditStream] = "ERROR_CLUB_ACTION_EDIT_STREAM",
	[Enum.ClubActionType.ErrorClubActionDestroyStream] = "ERROR_CLUB_ACTION_DESTROY_STREAM",
	[Enum.ClubActionType.ErrorClubActionInviteMember] = "ERROR_CLUB_ACTION_INVITE_MEMBER",
	[Enum.ClubActionType.ErrorClubActionEditMember] = "ERROR_CLUB_ACTION_EDIT_MEMBER",
	[Enum.ClubActionType.ErrorClubActionEditMemberNote] = "ERROR_CLUB_ACTION_EDIT_MEMBER_NOTE",
	[Enum.ClubActionType.ErrorClubActionKickMember] = "ERROR_CLUB_ACTION_KICK_MEMBER",
	[Enum.ClubActionType.ErrorClubActionAddBan] = "ERROR_CLUB_ACTION_ADD_BAN",
	[Enum.ClubActionType.ErrorClubActionRemoveBan] = "ERROR_CLUB_ACTION_REMOVE_BAN",
	[Enum.ClubActionType.ErrorClubActionCreateMessage] = "ERROR_CLUB_ACTION_CREATE_MESSAGE",
	[Enum.ClubActionType.ErrorClubActionEditMessage] = "ERROR_CLUB_ACTION_EDIT_MESSAGE",
	[Enum.ClubActionType.ErrorClubActionDestroyMessage] = "ERROR_CLUB_ACTION_DESTROY_MESSAGE",
};

local function GetActionString(action, community)
	local key = actionStrings[action];
	if key then
		key = community and (key.."_COMMUNITY") or key;
		return _G[key];
	end
	return nil;
end

local errorStrings = 
{
	[Enum.ClubErrorType.ErrorCommunitiesUnknown] = "ERROR_COMMUNITIES_UNKNOWN",
	[Enum.ClubErrorType.ErrorCommunitiesNeutralFaction] = "ERROR_COMMUNITIES_NEUTRAL_FACTION",
	[Enum.ClubErrorType.ErrorCommunitiesUnknownRealm] = "ERROR_COMMUNITIES_UNKNOWN_REALM",
	[Enum.ClubErrorType.ErrorCommunitiesBadTarget] = "ERROR_COMMUNITIES_BAD_TARGET",
	[Enum.ClubErrorType.ErrorCommunitiesWrongFaction] = "ERROR_COMMUNITIES_WRONG_FACTION",
	[Enum.ClubErrorType.ErrorCommunitiesRestricted] = "ERROR_COMMUNITIES_RESTRICTED",
	[Enum.ClubErrorType.ErrorCommunitiesIgnored] = "ERROR_COMMUNITIES_IGNORED",
	[Enum.ClubErrorType.ErrorCommunitiesGuild] = "ERROR_COMMUNITIES_GUILD",
	[Enum.ClubErrorType.ErrorCommunitiesWrongRegion] = "ERROR_COMMUNITIES_WRONG_REGION",
	[Enum.ClubErrorType.ErrorCommunitiesUnknownTicket] = "ERROR_COMMUNITIES_UNKNOWN_TICKET",
	[Enum.ClubErrorType.ErrorCommunitiesMissingShortName] = "ERROR_COMMUNITIES_MISSING_SHORT_NAME",
	[Enum.ClubErrorType.ErrorCommunitiesProfanity] = "ERROR_COMMUNITIES_PROFANITY",
	[Enum.ClubErrorType.ErrorCommunitiesTrial] = "ERROR_COMMUNITIES_TRIAL",
	[Enum.ClubErrorType.ErrorCommunitiesVeteranTrial] = "ERROR_COMMUNITIES_VETERAN_TRIAL",
	[Enum.ClubErrorType.ErrorCommunitiesChatMute] = "ERR_PARENTAL_CONTROLS_CHAT_MUTED",
	[Enum.ClubErrorType.ErrorClubFull] = "ERROR_CLUB_FULL",
	[Enum.ClubErrorType.ErrorClubNoClub] = "ERROR_CLUB_NO_CLUB",
	[Enum.ClubErrorType.ErrorClubNotMember] = "ERROR_CLUB_NOT_MEMBER",
	[Enum.ClubErrorType.ErrorClubAlreadyMember] = "ERROR_CLUB_ALREADY_MEMBER",
	[Enum.ClubErrorType.ErrorClubNoSuchMember] = "ERROR_CLUB_NO_SUCH_MEMBER",
	[Enum.ClubErrorType.ErrorClubNoSuchInvitation] = "ERROR_CLUB_NO_SUCH_INVITATION",
	[Enum.ClubErrorType.ErrorClubInvitationAlreadyExists] = "ERROR_CLUB_INVITATION_ALREADY_EXISTS",
	[Enum.ClubErrorType.ErrorClubInvalidRoleID] = "ERROR_CLUB_INVALID_ROLE_ID",
	[Enum.ClubErrorType.ErrorClubInsufficientPrivileges] = "ERROR_CLUB_INSUFFICIENT_PRIVILEGES",
	[Enum.ClubErrorType.ErrorClubTooManyClubsJoined] = "ERROR_CLUB_TOO_MANY_CLUBS_JOINED",
	[Enum.ClubErrorType.ErrorClubVoiceFull] = "ERROR_CLUB_VOICE_FULL",
	[Enum.ClubErrorType.ErrorClubStreamNoStream] = "ERROR_CLUB_STREAM_NO_STREAM",
	[Enum.ClubErrorType.ErrorClubStreamInvalidName] = "ERROR_CLUB_STREAM_INVALID_NAME",
	[Enum.ClubErrorType.ErrorClubStreamCountAtMin] = "ERROR_CLUB_STREAM_COUNT_AT_MIN",
	[Enum.ClubErrorType.ErrorClubStreamCountAtMax] = "ERROR_CLUB_STREAM_COUNT_AT_MAX",
	[Enum.ClubErrorType.ErrorClubMemberHasRequiredRole] = "ERROR_CLUB_MEMBER_HAS_REQUIRED_ROLE",
	[Enum.ClubErrorType.ErrorClubSentInvitationCountAtMax] = "ERROR_CLUB_SENT_INVITATION_COUNT_AT_MAX",
	[Enum.ClubErrorType.ErrorClubReceivedInvitationCountAtMax] = "ERROR_CLUB_RECEIVED_INVITATION_COUNT_AT_MAX",
	[Enum.ClubErrorType.ErrorClubTargetIsBanned] = "ERROR_CLUB_TARGET_IS_BANNED",
	[Enum.ClubErrorType.ErrorClubBanAlreadyExists] = "ERROR_CLUB_BAN_ALREADY_EXISTS",
	[Enum.ClubErrorType.ErrorClubBanCountAtMax] = "ERROR_CLUB_BAN_COUNT_AT_MAX",
	[Enum.ClubErrorType.ErrorClubTicketCountAtMax] = "ERROR_CLUB_TICKET_COUNT_AT_MAX",
	[Enum.ClubErrorType.ErrorClubTicketNoSuchTicket] = "ERROR_CLUB_TICKET_NO_SUCH_TICKET",
	[Enum.ClubErrorType.ErrorClubTicketHasConsumedAllowedRedeemCount] = "ERROR_CLUB_TICKET_HAS_CONSUMED_ALLOWED_REDEEM_COUNT",
	[Enum.ClubErrorType.ErrorClubDoesntAllowCrossFaction] = "ERROR_CLUB_DOESNT_ALLOW_CROSS_FACTION",
	[Enum.ClubErrorType.ErrorClubEditHasCrossFactionMembers] = "COMMUNITIES_SETTING_CROSS_FACTION_TOOLTIP_ERROR",
};

local clubRemovedStrings = 
{
	[Enum.ClubRemovedReason.Removed] = CLUB_REMOVED_REASON_REMOVED,
	[Enum.ClubRemovedReason.Banned] = CLUB_REMOVED_REASON_BANNED,
	[Enum.ClubRemovedReason.ClubDestroyed] = CLUB_REMOVED_REASON_CLUB_DESTROYED,
};

local function GetErrorString(error, community)
	local key = errorStrings[error];
	if key then
		key = community and (key.."_COMMUNITY") or key;
		return _G[key]
	end
	return nil;
end

function GetCommunitiesErrorString(action, error, clubType)
	local actionCodeString, errorCodeString;
	if clubType ~= Enum.ClubType.BattleNet then
		actionCodeString = GetActionString(action, true);
		errorCodeString = GetErrorString(error, true);
	end
	if not actionCodeString then
		actionCodeString = GetActionString(action, false);
	end
	if not errorCodeString then
		errorCodeString = GetErrorString(error, false);
	end
	if actionCodeString then
		return actionCodeString:format(errorCodeString or "");
	end
end

errorFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "CLUB_ERROR" then
		local errorString = GetCommunitiesErrorString(...);
		if errorString then
			UIErrorsFrame:AddExternalErrorMessage(errorString);
		end
	elseif event == "CLUB_REMOVED_MESSAGE" then
		local clubName, clubRemovedReason = ...;
		if (clubName ~= nil and clubRemovedStrings[clubRemovedReason] ~= nil) then
			local errorString = clubRemovedStrings[clubRemovedReason]:format(clubName);
			UIErrorsFrame:AddExternalErrorMessage(errorString);
		end
	end
end);
