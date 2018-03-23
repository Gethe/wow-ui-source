local ClubsLua =
{
	Name = "Clubs",
	Type = "System",
	Namespace = "C_Clubs",

	Functions =
	{
		{
			Name = "AcceptInvitation",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ClearClubPresenceSubscription",
			Type = "Function",
		},
		{
			Name = "CreateClub",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "clubType", Type = "ClubType", Nilable = false, Documentation = { "Valid types are BattleNet or Character" } },
				{ Name = "avatarId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CreateStream",
			Type = "Function",
			Documentation = { "Check the canCreateStream privilege." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "subject", Type = "string", Nilable = false },
				{ Name = "leadersAndModeratorsOnly", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CreateTicket",
			Type = "Function",
			Documentation = { "Check canCreateTicket privilege." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "allowedRedeemCount", Type = "number", Nilable = false, Documentation = { "Number of uses. 0 means unlimited" } },
				{ Name = "duration", Type = "number", Nilable = false, Documentation = { "Duration in seconds. 0 never expires" } },
			},
		},
		{
			Name = "DeclineInvitation",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "DestroyClub",
			Type = "Function",
			Documentation = { "Check the canDestroy privilege." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "DestroyMessage",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
				{ Name = "messageId", Type = "ClubMessageIdentifier", Nilable = false },
			},
		},
		{
			Name = "DestroyStream",
			Type = "Function",
			Documentation = { "Check canDestroyStream privilege." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "DestroyTicket",
			Type = "Function",
			Documentation = { "Check canDestroyTicket privilege." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "ticketId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "EditClub",
			Type = "Function",
			Documentation = { "nil arguments will not change existing club data" },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "description", Type = "string", Nilable = true },
				{ Name = "avatarId", Type = "number", Nilable = true },
			},
		},
		{
			Name = "EditMessage",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
				{ Name = "messageId", Type = "ClubMessageIdentifier", Nilable = false },
				{ Name = "message", Type = "string", Nilable = false },
			},
		},
		{
			Name = "EditStream",
			Type = "Function",
			Documentation = { "Check the canSetStreamName, canSetStreamSubject, canSetStreamAccess privileges. nil arguments will not change existing stream data." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "subject", Type = "string", Nilable = true },
				{ Name = "leadersAndModeratorsOnly", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "GetClubInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "ClubInfo", Nilable = true },
			},
		},
		{
			Name = "GetClubMembers",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "members", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetClubPrivileges",
			Type = "Function",
			Documentation = { "The privileges for the logged in user for this club" },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "privilegeInfo", Type = "ClubPrivilegeInfo", Nilable = false },
			},
		},
		{
			Name = "GetInvitationCandidates",
			Type = "Function",
			Documentation = { "Returns a list of players that you can send a request to a Battle.net club. Returns an empty list for Character based clubs" },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "candidates", Type = "table", InnerType = "ClubInvitationCandidateInfo", Nilable = false },
			},
		},
		{
			Name = "GetInvitationsForClub",
			Type = "Function",
			Documentation = { "Get the pending invitations for this club. Call RequestInvitationsForClub() to retrieve invitations from server." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "invitations", Type = "table", InnerType = "ClubInvitationInfo", Nilable = false },
			},
		},
		{
			Name = "GetInvitationsForSelf",
			Type = "Function",
			Documentation = { "These are the clubs the active player has been invited to." },

			Returns =
			{
				{ Name = "invitations", Type = "table", InnerType = "ClubSelfInvitationInfo", Nilable = false },
			},
		},
		{
			Name = "GetMemberInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "memberId", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "ClubMemberInfo", Nilable = true },
			},
		},
		{
			Name = "GetMessageRange",
			Type = "Function",
			Documentation = { "Get the range of the messages currently downloaded." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "oldest", Type = "ClubMessageIdentifier", Nilable = false },
				{ Name = "newest", Type = "ClubMessageIdentifier", Nilable = false },
			},
		},
		{
			Name = "GetMessagesInRange",
			Type = "Function",
			Documentation = { "Get all downloaded messages in the given range." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
				{ Name = "oldest", Type = "ClubMessageIdentifier", Nilable = false },
				{ Name = "newest", Type = "ClubMessageIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "messages", Type = "table", InnerType = "ClubMessageInfo", Nilable = false },
			},
		},
		{
			Name = "GetStreams",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "streams", Type = "table", InnerType = "ClubStreamInfo", Nilable = false },
			},
		},
		{
			Name = "GetSubscribedClubs",
			Type = "Function",

			Returns =
			{
				{ Name = "clubs", Type = "table", InnerType = "ClubInfo", Nilable = false },
			},
		},
		{
			Name = "GetTickets",
			Type = "Function",
			Documentation = { "Get the existing tickets for this club. Call RequestTickets() to retrieve tickets from server." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "tickets", Type = "table", InnerType = "ClubTicketInfo", Nilable = false },
			},
		},
		{
			Name = "KickMember",
			Type = "Function",
			Documentation = { "Check canKickMember privilege." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "memberId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LeaveClub",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "RedeemTicket",
			Type = "Function",

			Arguments =
			{
				{ Name = "ticketId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "RequestInvitationsForClub",
			Type = "Function",
			Documentation = { "Request invitations for this club from server. Check canGetInvitation privilege." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "RequestMoreMessages",
			Type = "Function",
			Documentation = { "Call this when the user scrolls near the top of the message view, and more need to be displayed. The history will be downloaded backwards (newest to oldest)." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "RequestTickets",
			Type = "Function",
			Documentation = { "Request tickets from server. Check canGetTicket privilege." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "RevokeInvitation",
			Type = "Function",
			Documentation = { "Check canRevokeOwnInvitation or canRevokeOtherInvitation" },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "memberId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SendCharacterInvitation",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "character", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SendInvitation",
			Type = "Function",
			Documentation = { "Check the canSendInvitation privilege." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "memberId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SendMessage",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
				{ Name = "message", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetClubMemberRole",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "memberId", Type = "number", Nilable = false },
				{ Name = "role", Type = "ClubRoleIdentifier", Nilable = false },
			},
		},
		{
			Name = "SetClubPresenceSubscription",
			Type = "Function",
			Documentation = { "You can only be subscribed to 0 or 1 clubs for presence.  Subscribing to a new club automatically unsuscribes you to existing subscription." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "ClubType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "BattleNet", Type = "ClubType", EnumValue = 0 },
				{ Name = "Character", Type = "ClubType", EnumValue = 1 },
				{ Name = "Guild", Type = "ClubType", EnumValue = 2 },
			},
		},
		{
			Name = "ClubInvitationCandidateStatus",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Available", Type = "ClubInvitationCandidateStatus", EnumValue = 0 },
				{ Name = "InvitePending", Type = "ClubInvitationCandidateStatus", EnumValue = 1 },
				{ Name = "AlreadyMember", Type = "ClubInvitationCandidateStatus", EnumValue = 2 },
			},
		},
		{
			Name = "ClubMemberPresence",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Online", Type = "ClubMemberPresence", EnumValue = 0 },
				{ Name = "Offline", Type = "ClubMemberPresence", EnumValue = 1 },
				{ Name = "Away", Type = "ClubMemberPresence", EnumValue = 2 },
				{ Name = "Busy", Type = "ClubMemberPresence", EnumValue = 3 },
			},
		},
		{
			Name = "ClubRoleIdentifier",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Owner", Type = "ClubRoleIdentifier", EnumValue = 1 },
				{ Name = "Leader", Type = "ClubRoleIdentifier", EnumValue = 2 },
				{ Name = "Moderator", Type = "ClubRoleIdentifier", EnumValue = 3 },
				{ Name = "Member", Type = "ClubRoleIdentifier", EnumValue = 4 },
			},
		},
		{
			Name = "ClubRoleInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "roleId", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "required", Type = "bool", Nilable = false, Documentation = { "At least one user must be in this role" } },
				{ Name = "unique", Type = "bool", Nilable = false, Documentation = { "At most one user can be in this role" } },
			},
		},
		{
			Name = "ClubInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "broadcast", Type = "string", Nilable = false },
				{ Name = "clubType", Type = "ClubType", Nilable = false },
				{ Name = "avatarId", Type = "number", Nilable = false },
				{ Name = "clubRoles", Type = "table", InnerType = "ClubRoleInfo", Nilable = false },
			},
		},
		{
			Name = "ClubInvitationCandidateInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "memberId", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "status", Type = "ClubInvitationCandidateStatus", Nilable = false },
			},
		},
		{
			Name = "ClubMemberInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "memberId", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false, Documentation = { "name is encoded as a Kstring" } },
				{ Name = "role", Type = "number", Nilable = true },
				{ Name = "presence", Type = "ClubMemberPresence", Nilable = false },
			},
		},
		{
			Name = "ClubInvitationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "isMyInvitation", Type = "bool", Nilable = false },
				{ Name = "invitee", Type = "ClubMemberInfo", Nilable = false },
			},
		},
		{
			Name = "ClubMessageIdentifier",
			Type = "Structure",
			Fields =
			{
				{ Name = "epoch", Type = "number", Nilable = false, Documentation = { "number of microseconds since the UNIX epoch." } },
				{ Name = "position", Type = "number", Nilable = false, Documentation = { "sort order for messages at the same time" } },
			},
		},
		{
			Name = "ClubMessageInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "messageId", Type = "ClubMessageIdentifier", Nilable = false },
				{ Name = "content", Type = "string", Nilable = false },
				{ Name = "author", Type = "ClubMemberInfo", Nilable = false },
				{ Name = "destroyer", Type = "ClubMemberInfo", Nilable = true, Documentation = { "If destroyer is not nil, then the message has been destroyed" } },
			},
		},
		{
			Name = "ClubPrivilegeInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "canDestroy", Type = "bool", Nilable = false },
				{ Name = "canSetAttribute", Type = "bool", Nilable = false },
				{ Name = "canSetName", Type = "bool", Nilable = false },
				{ Name = "canSetDescription", Type = "bool", Nilable = false },
				{ Name = "canSetAvatar", Type = "bool", Nilable = false },
				{ Name = "canSetBroadcast", Type = "bool", Nilable = false },
				{ Name = "canSetPrivacyLevel", Type = "bool", Nilable = false },
				{ Name = "canKickMember", Type = "bool", Nilable = false },
				{ Name = "canSetOwnMemberAttribute", Type = "bool", Nilable = false },
				{ Name = "canSetOtherMemberAttribute", Type = "bool", Nilable = false },
				{ Name = "canSetOwnVoiceState", Type = "bool", Nilable = false },
				{ Name = "canSetOwnPresenceLevel", Type = "bool", Nilable = false },
				{ Name = "canUseVoice", Type = "bool", Nilable = false },
				{ Name = "canVoiceMuteMemberForAll", Type = "bool", Nilable = false },
				{ Name = "canGetInvitation", Type = "bool", Nilable = false },
				{ Name = "canSendInvitation", Type = "bool", Nilable = false },
				{ Name = "canSendGuestInvitation", Type = "bool", Nilable = false },
				{ Name = "canRevokeOwnInvitation", Type = "bool", Nilable = false },
				{ Name = "canRevokeOtherInvitation", Type = "bool", Nilable = false },
				{ Name = "canGetSuggestion", Type = "bool", Nilable = false },
				{ Name = "canSuggestMember", Type = "bool", Nilable = false },
				{ Name = "canGetTicket", Type = "bool", Nilable = false },
				{ Name = "canCreateTicket", Type = "bool", Nilable = false },
				{ Name = "canDestroyTicket", Type = "bool", Nilable = false },
				{ Name = "canAddBan", Type = "bool", Nilable = false },
				{ Name = "canRemoveBan", Type = "bool", Nilable = false },
				{ Name = "canCreateStream", Type = "bool", Nilable = false },
				{ Name = "canDestroyStream", Type = "bool", Nilable = false },
				{ Name = "canSetStreamPosition", Type = "bool", Nilable = false },
				{ Name = "canSetStreamAttribute", Type = "bool", Nilable = false },
				{ Name = "canSetStreamName", Type = "bool", Nilable = false },
				{ Name = "canSetStreamSubject", Type = "bool", Nilable = false },
				{ Name = "canSetStreamAccess", Type = "bool", Nilable = false },
				{ Name = "canSetStreamVoiceLevel", Type = "bool", Nilable = false },
				{ Name = "canCreateMessage", Type = "bool", Nilable = false },
				{ Name = "canDestroyOwnMessage", Type = "bool", Nilable = false },
				{ Name = "canDestroyOtherMessage", Type = "bool", Nilable = false },
				{ Name = "canEditOwnMessage", Type = "bool", Nilable = false },
				{ Name = "canPinMessage", Type = "bool", Nilable = false },
				{ Name = "bannableRoleIds", Type = "table", InnerType = "number", Nilable = false, Documentation = { "Roles that can be banned" } },
			},
		},
		{
			Name = "ClubSelfInvitationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "club", Type = "ClubInfo", Nilable = false },
				{ Name = "inviter", Type = "ClubMemberInfo", Nilable = false },
			},
		},
		{
			Name = "ClubStreamInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "streamId", Type = "string", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "subject", Type = "string", Nilable = false },
				{ Name = "leadersAndModeratorsOnly", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ClubTicketInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "ticketId", Type = "string", Nilable = false },
				{ Name = "isMyTicket", Type = "bool", Nilable = false },
				{ Name = "allowedRedeemCount", Type = "number", Nilable = false },
				{ Name = "currentRedeemCount", Type = "number", Nilable = false },
				{ Name = "creationTime", Type = "number", Nilable = false, Documentation = { "Creation time in seconds since the UNIX epoch." } },
				{ Name = "expirationTime", Type = "number", Nilable = false, Documentation = { "Expiration time in seconds since the UNIX epoch." } },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ClubsLua);