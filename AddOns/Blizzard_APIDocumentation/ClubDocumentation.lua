local Club =
{
	Name = "Club",
	Type = "System",
	Namespace = "C_Club",

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
			Name = "AddClubStreamToChatWindow",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
				{ Name = "chatWindowIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AdvanceStreamViewMarker",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "AssignMemberRole",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "memberId", Type = "number", Nilable = false },
				{ Name = "roleId", Type = "ClubRoleIdentifier", Nilable = false },
			},
		},
		{
			Name = "ClearAutoAdvanceStreamViewMarker",
			Type = "Function",
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
				{ Name = "allowedRedeemCount", Type = "number", Nilable = true, Documentation = { "Number of uses. nil means unlimited" } },
				{ Name = "duration", Type = "number", Nilable = true, Documentation = { "Duration in seconds. nil never expires" } },
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
			Name = "FocusStream",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "focused", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAssignableRoles",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "memberId", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "assignableRoles", Type = "table", InnerType = "ClubRoleIdentifier", Nilable = false },
			},
		},
		{
			Name = "GetAvatarIdList",
			Type = "Function",
			Documentation = { "listen for AVATAR_LIST_UPDATED event. This can happen if we haven't downloaded the battle.net avatar list yet" },

			Arguments =
			{
				{ Name = "clubType", Type = "ClubType", Nilable = false },
			},

			Returns =
			{
				{ Name = "avatarIds", Type = "table", InnerType = "number", Nilable = true },
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
				{ Name = "filter", Type = "string", Nilable = true },
				{ Name = "maxResults", Type = "number", Nilable = true },
				{ Name = "cursorPosition", Type = "number", Nilable = true },
				{ Name = "clubId", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "candidates", Type = "table", InnerType = "ClubInvitationCandidateInfo", Nilable = false },
			},
		},
		{
			Name = "GetInvitationInfo",
			Type = "Function",
			Documentation = { "Get info about a specific club the active player has been invited to." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "invitation", Type = "ClubSelfInvitationInfo", Nilable = true },
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
			Name = "GetMemberInfoForSelf",
			Type = "Function",
			Documentation = { "Info for the logged in user for this club" },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "ClubMemberInfo", Nilable = true },
			},
		},
		{
			Name = "GetMessageInfo",
			Type = "Function",
			Documentation = { "Get info about a particular message." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
				{ Name = "messageId", Type = "ClubMessageIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "message", Type = "ClubMessageInfo", Nilable = true },
			},
		},
		{
			Name = "GetMessageRanges",
			Type = "Function",
			Documentation = { "Get the ranges of the messages currently downloaded." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "ranges", Type = "table", InnerType = "ClubMessageRange", Nilable = false },
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
			Name = "GetStreamInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "streamInfo", Type = "ClubStreamInfo", Nilable = true },
			},
		},
		{
			Name = "GetStreamViewMarker",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "lastReadTime", Type = "number", Nilable = true, Documentation = { "nil is returned if stream view is at current" } },
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
			Name = "IsSubscribedToStream",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "subscribed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "KickMember",
			Type = "Function",
			Documentation = { "Check kickableRoleIds privilege." },

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
			Name = "RequestMoreMessagesAfter",
			Type = "Function",
			Documentation = { "Call this when the user scrolls near the bottom of the message view, and more need to be displayed." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
				{ Name = "messageId", Type = "ClubMessageIdentifier", Nilable = false },
			},
		},
		{
			Name = "RequestMoreMessagesBefore",
			Type = "Function",
			Documentation = { "Call this when the user scrolls near the top of the message view, and more need to be displayed. The history will be downloaded backwards (newest to oldest)." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
				{ Name = "messageId", Type = "ClubMessageIdentifier", Nilable = true },
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
			Name = "SetAutoAdvanceStreamViewMarker",
			Type = "Function",
			Documentation = { "Only one stream can be set for auto-advance at a time. Focused streams will have their view times advanced automatically." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetAvatarTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "texture", Type = "table", Nilable = false },
				{ Name = "avatarId", Type = "number", Nilable = false },
				{ Name = "clubType", Type = "ClubType", Nilable = false },
			},
		},
		{
			Name = "SetClubMemberNote",
			Type = "Function",
			Documentation = { "Check the canSetOtherMemberAttribute privilege." },

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "memberId", Type = "number", Nilable = false },
				{ Name = "note", Type = "string", Nilable = false },
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
		{
			Name = "SetCommunityID",
			Type = "Function",

			Arguments =
			{
				{ Name = "communityID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFavorite",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "isFavorite", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnfocusStream",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AvatarListUpdated",
			Type = "Event",
			LiteralName = "AVATAR_LIST_UPDATED",
			Payload =
			{
				{ Name = "clubType", Type = "ClubType", Nilable = false },
			},
		},
		{
			Name = "ClubAdded",
			Type = "Event",
			LiteralName = "CLUB_ADDED",
			Payload =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ClubInvitationAddedForSelf",
			Type = "Event",
			LiteralName = "CLUB_INVITATION_ADDED_FOR_SELF",
			Payload =
			{
				{ Name = "invitation", Type = "ClubSelfInvitationInfo", Nilable = false },
			},
		},
		{
			Name = "ClubInvitationRemovedForSelf",
			Type = "Event",
			LiteralName = "CLUB_INVITATION_REMOVED_FOR_SELF",
			Payload =
			{
				{ Name = "invitationId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ClubInvitationsReceivedForClub",
			Type = "Event",
			LiteralName = "CLUB_INVITATIONS_RECEIVED_FOR_CLUB",
			Payload =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ClubMemberAdded",
			Type = "Event",
			LiteralName = "CLUB_MEMBER_ADDED",
			Payload =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "memberId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ClubMemberPresenceUpdated",
			Type = "Event",
			LiteralName = "CLUB_MEMBER_PRESENCE_UPDATED",
			Payload =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "memberId", Type = "number", Nilable = false },
				{ Name = "presence", Type = "ClubMemberPresence", Nilable = false },
			},
		},
		{
			Name = "ClubMemberRemoved",
			Type = "Event",
			LiteralName = "CLUB_MEMBER_REMOVED",
			Payload =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "memberId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ClubMemberRoleUpdated",
			Type = "Event",
			LiteralName = "CLUB_MEMBER_ROLE_UPDATED",
			Payload =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "memberId", Type = "number", Nilable = false },
				{ Name = "roleId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ClubMemberUpdated",
			Type = "Event",
			LiteralName = "CLUB_MEMBER_UPDATED",
			Payload =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "memberId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ClubMessageAdded",
			Type = "Event",
			LiteralName = "CLUB_MESSAGE_ADDED",
			Payload =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
				{ Name = "messageId", Type = "ClubMessageIdentifier", Nilable = false },
			},
		},
		{
			Name = "ClubMessageHistoryReceived",
			Type = "Event",
			LiteralName = "CLUB_MESSAGE_HISTORY_RECEIVED",
			Payload =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
				{ Name = "downloadedRange", Type = "ClubMessageRange", Nilable = false, Documentation = { "Range of history messages received." } },
				{ Name = "contiguousRange", Type = "ClubMessageRange", Nilable = false, Documentation = { "Range of contiguous messages that the received messages are in." } },
			},
		},
		{
			Name = "ClubMessageUpdated",
			Type = "Event",
			LiteralName = "CLUB_MESSAGE_UPDATED",
			Payload =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
				{ Name = "messageId", Type = "ClubMessageIdentifier", Nilable = false },
			},
		},
		{
			Name = "ClubRemoved",
			Type = "Event",
			LiteralName = "CLUB_REMOVED",
			Payload =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ClubStreamAdded",
			Type = "Event",
			LiteralName = "CLUB_STREAM_ADDED",
			Payload =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ClubStreamRemoved",
			Type = "Event",
			LiteralName = "CLUB_STREAM_REMOVED",
			Payload =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ClubStreamSubscribed",
			Type = "Event",
			LiteralName = "CLUB_STREAM_SUBSCRIBED",
			Payload =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ClubStreamUnsubscribed",
			Type = "Event",
			LiteralName = "CLUB_STREAM_UNSUBSCRIBED",
			Payload =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ClubStreamUpdated",
			Type = "Event",
			LiteralName = "CLUB_STREAM_UPDATED",
			Payload =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ClubStreamsLoaded",
			Type = "Event",
			LiteralName = "CLUB_STREAMS_LOADED",
			Payload =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ClubTicketReceived",
			Type = "Event",
			LiteralName = "CLUB_TICKET_RECEIVED",
			Payload =
			{
				{ Name = "succeeded", Type = "bool", Nilable = false },
				{ Name = "ticket", Type = "string", Nilable = false },
				{ Name = "info", Type = "ClubInfo", Nilable = true },
			},
		},
		{
			Name = "ClubUpdated",
			Type = "Event",
			LiteralName = "CLUB_UPDATED",
			Payload =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},
		},
	},

	Tables =
	{
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
			Name = "ClubMemberPresence",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Unknown", Type = "ClubMemberPresence", EnumValue = 0 },
				{ Name = "Online", Type = "ClubMemberPresence", EnumValue = 1 },
				{ Name = "Offline", Type = "ClubMemberPresence", EnumValue = 2 },
				{ Name = "Away", Type = "ClubMemberPresence", EnumValue = 3 },
				{ Name = "Busy", Type = "ClubMemberPresence", EnumValue = 4 },
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
				{ Name = "favoriteTimeStamp", Type = "number", Nilable = true },
				{ Name = "joinTime", Type = "number", Nilable = true },
			},
		},
		{
			Name = "ClubMemberInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "memberId", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false, Documentation = { "name may be encoded as a Kstring" } },
				{ Name = "role", Type = "ClubRoleIdentifier", Nilable = true },
				{ Name = "presence", Type = "ClubMemberPresence", Nilable = false },
				{ Name = "memberNote", Type = "string", Nilable = true },
				{ Name = "classID", Type = "number", Nilable = true },
				{ Name = "race", Type = "number", Nilable = true },
				{ Name = "level", Type = "number", Nilable = true },
				{ Name = "zone", Type = "string", Nilable = true },
			},
		},
		{
			Name = "ClubSelfInvitationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "invitationId", Type = "string", Nilable = false },
				{ Name = "club", Type = "ClubInfo", Nilable = false },
				{ Name = "inviter", Type = "ClubMemberInfo", Nilable = false },
			},
		},
		{
			Name = "ClubInvitationCandidateInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "memberId", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "priority", Type = "number", Nilable = false },
				{ Name = "status", Type = "ClubInvitationCandidateStatus", Nilable = false },
			},
		},
		{
			Name = "ClubInvitationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "invitationId", Type = "string", Nilable = false },
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
			Name = "ClubMessageRange",
			Type = "Structure",
			Fields =
			{
				{ Name = "oldestMessageId", Type = "ClubMessageIdentifier", Nilable = false },
				{ Name = "newestMessageId", Type = "ClubMessageIdentifier", Nilable = false },
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
				{ Name = "kickableRoleIds", Type = "table", InnerType = "number", Nilable = false, Documentation = { "Roles that can be kicked and banned" } },
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
				{ Name = "creationTime", Type = "number", Nilable = false },
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
				{ Name = "creationTime", Type = "number", Nilable = false, Documentation = { "Creation time in microseconds since the UNIX epoch." } },
				{ Name = "expirationTime", Type = "number", Nilable = false, Documentation = { "Expiration time in microseconds since the UNIX epoch." } },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Club);