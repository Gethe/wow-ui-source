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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
			},
		},
		{
			Name = "AddClubStreamChatChannel",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
			},
		},
		{
			Name = "AdvanceStreamViewMarker",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
			},
		},
		{
			Name = "AssignMemberRole",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "memberId", Type = "number", Nilable = false },
				{ Name = "roleId", Type = "ClubRoleIdentifier", Nilable = false },
			},
		},
		{
			Name = "CanResolvePlayerLocationFromClubMessageData",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
				{ Name = "epoch", Type = "BigUInteger", Nilable = false },
				{ Name = "position", Type = "BigUInteger", Nilable = false },
			},

			Returns =
			{
				{ Name = "canResolve", Type = "bool", Nilable = false },
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
			Name = "CompareBattleNetDisplayName",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "lhsMemberId", Type = "number", Nilable = false },
				{ Name = "rhsMemberId", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "comparison", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CreateClub",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "shortName", Type = "string", Nilable = true },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "clubType", Type = "ClubType", Nilable = false, Documentation = { "Valid types are BattleNet or Character" } },
				{ Name = "avatarId", Type = "number", Nilable = false },
				{ Name = "isCrossFaction", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "CreateStream",
			Type = "Function",
			Documentation = { "Check the canCreateStream privilege." },

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "allowedRedeemCount", Type = "number", Nilable = true, Documentation = { "Number of uses. nil means unlimited" } },
				{ Name = "duration", Type = "number", Nilable = true, Documentation = { "Duration in seconds. nil never expires" } },
				{ Name = "defaultStreamId", Type = "ClubStreamId", Nilable = true },
			},
		},
		{
			Name = "DeclineInvitation",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
			},
		},
		{
			Name = "DestroyClub",
			Type = "Function",
			Documentation = { "Check the canDestroy privilege." },

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
			},
		},
		{
			Name = "DestroyMessage",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
				{ Name = "messageId", Type = "ClubMessageIdentifier", Nilable = false },
			},
		},
		{
			Name = "DestroyStream",
			Type = "Function",
			Documentation = { "Check canDestroyStream privilege." },

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
			},
		},
		{
			Name = "DestroyTicket",
			Type = "Function",
			Documentation = { "Check canDestroyTicket privilege." },

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "ticketId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "DoesAnyCommunityHaveUnreadMessages",
			Type = "Function",

			Returns =
			{
				{ Name = "hasUnreadMessages", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "EditClub",
			Type = "Function",
			Documentation = { "nil arguments will not change existing club data" },

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "shortName", Type = "string", Nilable = true },
				{ Name = "description", Type = "string", Nilable = true },
				{ Name = "avatarId", Type = "number", Nilable = true },
				{ Name = "broadcast", Type = "string", Nilable = true },
				{ Name = "crossFaction", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "EditMessage",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "subject", Type = "string", Nilable = true },
				{ Name = "leadersAndModeratorsOnly", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "Flush",
			Type = "Function",
		},
		{
			Name = "FocusCommunityStreams",
			Type = "Function",
		},
		{
			Name = "FocusStream",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = true },
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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
			},

			Returns =
			{
				{ Name = "privilegeInfo", Type = "ClubPrivilegeInfo", Nilable = false },
			},
		},
		{
			Name = "GetClubStreamNotificationSettings",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
			},

			Returns =
			{
				{ Name = "settings", Type = "table", InnerType = "ClubStreamNotificationSetting", Nilable = false },
			},
		},
		{
			Name = "GetCommunityNameResultText",
			Type = "Function",

			Arguments =
			{
				{ Name = "result", Type = "ValidateNameResult", Nilable = false },
			},

			Returns =
			{
				{ Name = "errorCode", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "GetInfoFromLastCommunityChatLine",
			Type = "Function",

			Returns =
			{
				{ Name = "messageInfo", Type = "ClubMessageInfo", Nilable = false },
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
				{ Name = "clubType", Type = "ClubType", Nilable = false },
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
				{ Name = "allowFullMatch", Type = "bool", Nilable = true },
				{ Name = "clubId", Type = "ClubId", Nilable = false },
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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
			},

			Returns =
			{
				{ Name = "ranges", Type = "table", InnerType = "ClubMessageRange", Nilable = false },
			},
		},
		{
			Name = "GetMessagesBefore",
			Type = "Function",
			Documentation = { "Get downloaded messages before (and including) the specified messageId limited by count. These are filtered by ignored players" },

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
				{ Name = "newest", Type = "ClubMessageIdentifier", Nilable = false },
				{ Name = "count", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "messages", Type = "table", InnerType = "ClubMessageInfo", Nilable = false },
			},
		},
		{
			Name = "GetMessagesInRange",
			Type = "Function",
			Documentation = { "Get downloaded messages in the given range. These are filtered by ignored players" },

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
			},

			Returns =
			{
				{ Name = "lastReadTime", Type = "BigUInteger", Nilable = true, Documentation = { "nil if stream view is at current" } },
			},
		},
		{
			Name = "GetStreams",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
			},

			Returns =
			{
				{ Name = "tickets", Type = "table", InnerType = "ClubTicketInfo", Nilable = false },
			},
		},
		{
			Name = "IsAccountMuted",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
			},

			Returns =
			{
				{ Name = "accountMuted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsBeginningOfStream",
			Type = "Function",
			Documentation = { "Returns whether the given message is the first message in the stream, taking into account ignored messages" },

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
				{ Name = "messageId", Type = "ClubMessageIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "isBeginningOfStream", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "clubsEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRestricted",
			Type = "Function",

			Returns =
			{
				{ Name = "restrictionReason", Type = "ClubRestrictionReason", Nilable = false },
			},
		},
		{
			Name = "IsSubscribedToStream",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "memberId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LeaveClub",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
			},
		},
		{
			Name = "RequestMoreMessagesBefore",
			Type = "Function",
			Documentation = { "Call this when the user scrolls near the top of the message view, and more need to be displayed. The history will be downloaded backwards (newest to oldest)." },

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
				{ Name = "messageId", Type = "ClubMessageIdentifier", Nilable = true },
				{ Name = "count", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "alreadyHasMessages", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestTicket",
			Type = "Function",

			Arguments =
			{
				{ Name = "ticketId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "RequestTickets",
			Type = "Function",
			Documentation = { "Request tickets from server. Check canGetTicket privilege." },

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
			},
		},
		{
			Name = "RevokeInvitation",
			Type = "Function",
			Documentation = { "Check canRevokeOwnInvitation or canRevokeOtherInvitation" },

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "memberId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SendBattleTagFriendRequest",
			Type = "Function",

			Arguments =
			{
				{ Name = "guildClubId", Type = "ClubId", Nilable = false },
				{ Name = "memberId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SendInvitation",
			Type = "Function",
			Documentation = { "Check the canSendInvitation privilege." },

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "memberId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SendMessage",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
				{ Name = "message", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetAutoAdvanceStreamViewMarker",
			Type = "Function",
			Documentation = { "Only one stream can be set for auto-advance at a time. Focused streams will have their view times advanced automatically." },

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
			},
		},
		{
			Name = "SetAvatarTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "texture", Type = "SimpleTexture", Nilable = false },
				{ Name = "avatarId", Type = "number", Nilable = false },
				{ Name = "clubType", Type = "ClubType", Nilable = false },
			},
		},
		{
			Name = "SetClubMemberNote",
			Type = "Function",
			Documentation = { "Check the canSetOwnMemberNote and canSetOtherMemberNote privileges." },

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
			},
		},
		{
			Name = "SetClubStreamNotificationSettings",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "settings", Type = "table", InnerType = "ClubStreamNotificationSetting", Nilable = false },
			},
		},
		{
			Name = "SetCommunityID",
			Type = "Function",

			Arguments =
			{
				{ Name = "communityID", Type = "BigUInteger", Nilable = false },
			},
		},
		{
			Name = "SetFavorite",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "isFavorite", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetSocialQueueingEnabled",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldAllowClubType",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubType", Type = "ClubType", Nilable = false },
			},

			Returns =
			{
				{ Name = "clubTypeIsAllowed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnfocusAllStreams",
			Type = "Function",

			Arguments =
			{
				{ Name = "unsubscribe", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnfocusStream",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
			},
		},
		{
			Name = "ValidateText",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubType", Type = "ClubType", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "clubFieldType", Type = "ClubFieldType", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "ValidateNameResult", Nilable = false },
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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
			},
		},
		{
			Name = "ClubError",
			Type = "Event",
			LiteralName = "CLUB_ERROR",
			Payload =
			{
				{ Name = "action", Type = "ClubActionType", Nilable = false },
				{ Name = "error", Type = "ClubErrorType", Nilable = false },
				{ Name = "clubType", Type = "ClubType", Nilable = false },
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
				{ Name = "invitationId", Type = "ClubInvitationId", Nilable = false },
			},
		},
		{
			Name = "ClubInvitationsReceivedForClub",
			Type = "Event",
			LiteralName = "CLUB_INVITATIONS_RECEIVED_FOR_CLUB",
			Payload =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
			},
		},
		{
			Name = "ClubMemberAdded",
			Type = "Event",
			LiteralName = "CLUB_MEMBER_ADDED",
			Payload =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "memberId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ClubMemberPresenceUpdated",
			Type = "Event",
			LiteralName = "CLUB_MEMBER_PRESENCE_UPDATED",
			Payload =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "memberId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ClubMemberRoleUpdated",
			Type = "Event",
			LiteralName = "CLUB_MEMBER_ROLE_UPDATED",
			Payload =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "memberId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ClubMessageAdded",
			Type = "Event",
			LiteralName = "CLUB_MESSAGE_ADDED",
			Payload =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
				{ Name = "messageId", Type = "ClubMessageIdentifier", Nilable = false },
			},
		},
		{
			Name = "ClubMessageHistoryReceived",
			Type = "Event",
			LiteralName = "CLUB_MESSAGE_HISTORY_RECEIVED",
			Payload =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
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
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
				{ Name = "messageId", Type = "ClubMessageIdentifier", Nilable = false },
			},
		},
		{
			Name = "ClubRemoved",
			Type = "Event",
			LiteralName = "CLUB_REMOVED",
			Payload =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
			},
		},
		{
			Name = "ClubRemovedMessage",
			Type = "Event",
			LiteralName = "CLUB_REMOVED_MESSAGE",
			Payload =
			{
				{ Name = "clubName", Type = "string", Nilable = false },
				{ Name = "clubRemovedReason", Type = "ClubRemovedReason", Nilable = false },
			},
		},
		{
			Name = "ClubSelfMemberRoleUpdated",
			Type = "Event",
			LiteralName = "CLUB_SELF_MEMBER_ROLE_UPDATED",
			Payload =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "roleId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ClubStreamAdded",
			Type = "Event",
			LiteralName = "CLUB_STREAM_ADDED",
			Payload =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
			},
		},
		{
			Name = "ClubStreamRemoved",
			Type = "Event",
			LiteralName = "CLUB_STREAM_REMOVED",
			Payload =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
			},
		},
		{
			Name = "ClubStreamSubscribed",
			Type = "Event",
			LiteralName = "CLUB_STREAM_SUBSCRIBED",
			Payload =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
			},
		},
		{
			Name = "ClubStreamUnsubscribed",
			Type = "Event",
			LiteralName = "CLUB_STREAM_UNSUBSCRIBED",
			Payload =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
			},
		},
		{
			Name = "ClubStreamUpdated",
			Type = "Event",
			LiteralName = "CLUB_STREAM_UPDATED",
			Payload =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
			},
		},
		{
			Name = "ClubStreamsLoaded",
			Type = "Event",
			LiteralName = "CLUB_STREAMS_LOADED",
			Payload =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
			},
		},
		{
			Name = "ClubTicketCreated",
			Type = "Event",
			LiteralName = "CLUB_TICKET_CREATED",
			Payload =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "ticketInfo", Type = "ClubTicketInfo", Nilable = false },
			},
		},
		{
			Name = "ClubTicketReceived",
			Type = "Event",
			LiteralName = "CLUB_TICKET_RECEIVED",
			Payload =
			{
				{ Name = "error", Type = "ClubErrorType", Nilable = false },
				{ Name = "ticket", Type = "string", Nilable = false },
				{ Name = "info", Type = "ClubInfo", Nilable = true },
			},
		},
		{
			Name = "ClubTicketsReceived",
			Type = "Event",
			LiteralName = "CLUB_TICKETS_RECEIVED",
			Payload =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
			},
		},
		{
			Name = "ClubUpdated",
			Type = "Event",
			LiteralName = "CLUB_UPDATED",
			Payload =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
			},
		},
		{
			Name = "InitialClubsLoaded",
			Type = "Event",
			LiteralName = "INITIAL_CLUBS_LOADED",
		},
		{
			Name = "StreamViewMarkerUpdated",
			Type = "Event",
			LiteralName = "STREAM_VIEW_MARKER_UPDATED",
			Payload =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
				{ Name = "lastReadTime", Type = "BigUInteger", Nilable = true, Documentation = { "nil if stream view is at current" } },
			},
		},
	},

	Tables =
	{
		{
			Name = "ClubActionType",
			Type = "Enumeration",
			NumValues = 27,
			MinValue = 0,
			MaxValue = 26,
			Fields =
			{
				{ Name = "ErrorClubActionSubscribe", Type = "ClubActionType", EnumValue = 0 },
				{ Name = "ErrorClubActionCreate", Type = "ClubActionType", EnumValue = 1 },
				{ Name = "ErrorClubActionEdit", Type = "ClubActionType", EnumValue = 2 },
				{ Name = "ErrorClubActionDestroy", Type = "ClubActionType", EnumValue = 3 },
				{ Name = "ErrorClubActionLeave", Type = "ClubActionType", EnumValue = 4 },
				{ Name = "ErrorClubActionCreateTicket", Type = "ClubActionType", EnumValue = 5 },
				{ Name = "ErrorClubActionDestroyTicket", Type = "ClubActionType", EnumValue = 6 },
				{ Name = "ErrorClubActionRedeemTicket", Type = "ClubActionType", EnumValue = 7 },
				{ Name = "ErrorClubActionGetTicket", Type = "ClubActionType", EnumValue = 8 },
				{ Name = "ErrorClubActionGetTickets", Type = "ClubActionType", EnumValue = 9 },
				{ Name = "ErrorClubActionGetBans", Type = "ClubActionType", EnumValue = 10 },
				{ Name = "ErrorClubActionGetInvitations", Type = "ClubActionType", EnumValue = 11 },
				{ Name = "ErrorClubActionRevokeInvitation", Type = "ClubActionType", EnumValue = 12 },
				{ Name = "ErrorClubActionAcceptInvitation", Type = "ClubActionType", EnumValue = 13 },
				{ Name = "ErrorClubActionDeclineInvitation", Type = "ClubActionType", EnumValue = 14 },
				{ Name = "ErrorClubActionCreateStream", Type = "ClubActionType", EnumValue = 15 },
				{ Name = "ErrorClubActionEditStream", Type = "ClubActionType", EnumValue = 16 },
				{ Name = "ErrorClubActionDestroyStream", Type = "ClubActionType", EnumValue = 17 },
				{ Name = "ErrorClubActionInviteMember", Type = "ClubActionType", EnumValue = 18 },
				{ Name = "ErrorClubActionEditMember", Type = "ClubActionType", EnumValue = 19 },
				{ Name = "ErrorClubActionEditMemberNote", Type = "ClubActionType", EnumValue = 20 },
				{ Name = "ErrorClubActionKickMember", Type = "ClubActionType", EnumValue = 21 },
				{ Name = "ErrorClubActionAddBan", Type = "ClubActionType", EnumValue = 22 },
				{ Name = "ErrorClubActionRemoveBan", Type = "ClubActionType", EnumValue = 23 },
				{ Name = "ErrorClubActionCreateMessage", Type = "ClubActionType", EnumValue = 24 },
				{ Name = "ErrorClubActionEditMessage", Type = "ClubActionType", EnumValue = 25 },
				{ Name = "ErrorClubActionDestroyMessage", Type = "ClubActionType", EnumValue = 26 },
			},
		},
		{
			Name = "ClubErrorType",
			Type = "Enumeration",
			NumValues = 42,
			MinValue = 0,
			MaxValue = 41,
			Fields =
			{
				{ Name = "ErrorCommunitiesNone", Type = "ClubErrorType", EnumValue = 0 },
				{ Name = "ErrorCommunitiesUnknown", Type = "ClubErrorType", EnumValue = 1 },
				{ Name = "ErrorCommunitiesNeutralFaction", Type = "ClubErrorType", EnumValue = 2 },
				{ Name = "ErrorCommunitiesUnknownRealm", Type = "ClubErrorType", EnumValue = 3 },
				{ Name = "ErrorCommunitiesBadTarget", Type = "ClubErrorType", EnumValue = 4 },
				{ Name = "ErrorCommunitiesWrongFaction", Type = "ClubErrorType", EnumValue = 5 },
				{ Name = "ErrorCommunitiesRestricted", Type = "ClubErrorType", EnumValue = 6 },
				{ Name = "ErrorCommunitiesIgnored", Type = "ClubErrorType", EnumValue = 7 },
				{ Name = "ErrorCommunitiesGuild", Type = "ClubErrorType", EnumValue = 8 },
				{ Name = "ErrorCommunitiesWrongRegion", Type = "ClubErrorType", EnumValue = 9 },
				{ Name = "ErrorCommunitiesUnknownTicket", Type = "ClubErrorType", EnumValue = 10 },
				{ Name = "ErrorCommunitiesMissingShortName", Type = "ClubErrorType", EnumValue = 11 },
				{ Name = "ErrorCommunitiesProfanity", Type = "ClubErrorType", EnumValue = 12 },
				{ Name = "ErrorCommunitiesTrial", Type = "ClubErrorType", EnumValue = 13 },
				{ Name = "ErrorCommunitiesVeteranTrial", Type = "ClubErrorType", EnumValue = 14 },
				{ Name = "ErrorCommunitiesChatMute", Type = "ClubErrorType", EnumValue = 15 },
				{ Name = "ErrorClubFull", Type = "ClubErrorType", EnumValue = 16 },
				{ Name = "ErrorClubNoClub", Type = "ClubErrorType", EnumValue = 17 },
				{ Name = "ErrorClubNotMember", Type = "ClubErrorType", EnumValue = 18 },
				{ Name = "ErrorClubAlreadyMember", Type = "ClubErrorType", EnumValue = 19 },
				{ Name = "ErrorClubNoSuchMember", Type = "ClubErrorType", EnumValue = 20 },
				{ Name = "ErrorClubNoSuchInvitation", Type = "ClubErrorType", EnumValue = 21 },
				{ Name = "ErrorClubInvitationAlreadyExists", Type = "ClubErrorType", EnumValue = 22 },
				{ Name = "ErrorClubInvalidRoleID", Type = "ClubErrorType", EnumValue = 23 },
				{ Name = "ErrorClubInsufficientPrivileges", Type = "ClubErrorType", EnumValue = 24 },
				{ Name = "ErrorClubTooManyClubsJoined", Type = "ClubErrorType", EnumValue = 25 },
				{ Name = "ErrorClubVoiceFull", Type = "ClubErrorType", EnumValue = 26 },
				{ Name = "ErrorClubStreamNoStream", Type = "ClubErrorType", EnumValue = 27 },
				{ Name = "ErrorClubStreamInvalidName", Type = "ClubErrorType", EnumValue = 28 },
				{ Name = "ErrorClubStreamCountAtMin", Type = "ClubErrorType", EnumValue = 29 },
				{ Name = "ErrorClubStreamCountAtMax", Type = "ClubErrorType", EnumValue = 30 },
				{ Name = "ErrorClubMemberHasRequiredRole", Type = "ClubErrorType", EnumValue = 31 },
				{ Name = "ErrorClubSentInvitationCountAtMax", Type = "ClubErrorType", EnumValue = 32 },
				{ Name = "ErrorClubReceivedInvitationCountAtMax", Type = "ClubErrorType", EnumValue = 33 },
				{ Name = "ErrorClubTargetIsBanned", Type = "ClubErrorType", EnumValue = 34 },
				{ Name = "ErrorClubBanAlreadyExists", Type = "ClubErrorType", EnumValue = 35 },
				{ Name = "ErrorClubBanCountAtMax", Type = "ClubErrorType", EnumValue = 36 },
				{ Name = "ErrorClubTicketCountAtMax", Type = "ClubErrorType", EnumValue = 37 },
				{ Name = "ErrorClubTicketNoSuchTicket", Type = "ClubErrorType", EnumValue = 38 },
				{ Name = "ErrorClubTicketHasConsumedAllowedRedeemCount", Type = "ClubErrorType", EnumValue = 39 },
				{ Name = "ErrorClubDoesntAllowCrossFaction", Type = "ClubErrorType", EnumValue = 40 },
				{ Name = "ErrorClubEditHasCrossFactionMembers", Type = "ClubErrorType", EnumValue = 41 },
			},
		},
		{
			Name = "ClubFieldType",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "ClubName", Type = "ClubFieldType", EnumValue = 0 },
				{ Name = "ClubShortName", Type = "ClubFieldType", EnumValue = 1 },
				{ Name = "ClubDescription", Type = "ClubFieldType", EnumValue = 2 },
				{ Name = "ClubBroadcast", Type = "ClubFieldType", EnumValue = 3 },
				{ Name = "ClubStreamName", Type = "ClubFieldType", EnumValue = 4 },
				{ Name = "ClubStreamSubject", Type = "ClubFieldType", EnumValue = 5 },
				{ Name = "NumTypes", Type = "ClubFieldType", EnumValue = 6 },
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
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Unknown", Type = "ClubMemberPresence", EnumValue = 0 },
				{ Name = "Online", Type = "ClubMemberPresence", EnumValue = 1 },
				{ Name = "OnlineMobile", Type = "ClubMemberPresence", EnumValue = 2 },
				{ Name = "Offline", Type = "ClubMemberPresence", EnumValue = 3 },
				{ Name = "Away", Type = "ClubMemberPresence", EnumValue = 4 },
				{ Name = "Busy", Type = "ClubMemberPresence", EnumValue = 5 },
			},
		},
		{
			Name = "ClubRemovedReason",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "ClubRemovedReason", EnumValue = 0 },
				{ Name = "Banned", Type = "ClubRemovedReason", EnumValue = 1 },
				{ Name = "Removed", Type = "ClubRemovedReason", EnumValue = 2 },
				{ Name = "ClubDestroyed", Type = "ClubRemovedReason", EnumValue = 3 },
			},
		},
		{
			Name = "ClubRestrictionReason",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "None", Type = "ClubRestrictionReason", EnumValue = 0 },
				{ Name = "Unavailable", Type = "ClubRestrictionReason", EnumValue = 1 },
			},
		},
		{
			Name = "ClubStreamNotificationFilter",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "ClubStreamNotificationFilter", EnumValue = 0 },
				{ Name = "Mention", Type = "ClubStreamNotificationFilter", EnumValue = 1 },
				{ Name = "All", Type = "ClubStreamNotificationFilter", EnumValue = 2 },
			},
		},
		{
			Name = "ClubStreamType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "General", Type = "ClubStreamType", EnumValue = 0 },
				{ Name = "Guild", Type = "ClubStreamType", EnumValue = 1 },
				{ Name = "Officer", Type = "ClubStreamType", EnumValue = 2 },
				{ Name = "Other", Type = "ClubStreamType", EnumValue = 3 },
			},
		},
		{
			Name = "ClubType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "BattleNet", Type = "ClubType", EnumValue = 0 },
				{ Name = "Character", Type = "ClubType", EnumValue = 1 },
				{ Name = "Guild", Type = "ClubType", EnumValue = 2 },
				{ Name = "Other", Type = "ClubType", EnumValue = 3 },
			},
		},
		{
			Name = "ClubInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "shortName", Type = "string", Nilable = true },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "broadcast", Type = "string", Nilable = false },
				{ Name = "clubType", Type = "ClubType", Nilable = false },
				{ Name = "avatarId", Type = "number", Nilable = false },
				{ Name = "memberCount", Type = "number", Nilable = true },
				{ Name = "favoriteTimeStamp", Type = "BigUInteger", Nilable = true },
				{ Name = "joinTime", Type = "BigUInteger", Nilable = true },
				{ Name = "socialQueueingEnabled", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "ClubInvitationCandidateInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "memberId", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "priority", Type = "luaIndex", Nilable = false },
				{ Name = "status", Type = "ClubInvitationCandidateStatus", Nilable = false },
			},
		},
		{
			Name = "ClubInvitationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "invitationId", Type = "ClubInvitationId", Nilable = false },
				{ Name = "isMyInvitation", Type = "bool", Nilable = false },
				{ Name = "invitee", Type = "ClubMemberInfo", Nilable = false },
			},
		},
		{
			Name = "ClubLimits",
			Type = "Structure",
			Fields =
			{
				{ Name = "maximumNumberOfStreams", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ClubMemberInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "isSelf", Type = "bool", Nilable = false },
				{ Name = "memberId", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = true, Documentation = { "name may be encoded as a Kstring" } },
				{ Name = "role", Type = "ClubRoleIdentifier", Nilable = true },
				{ Name = "presence", Type = "ClubMemberPresence", Nilable = false },
				{ Name = "clubType", Type = "ClubType", Nilable = true },
				{ Name = "guid", Type = "WOWGUID", Nilable = true },
				{ Name = "bnetAccountId", Type = "number", Nilable = true },
				{ Name = "memberNote", Type = "string", Nilable = true },
				{ Name = "officerNote", Type = "string", Nilable = true },
				{ Name = "classID", Type = "number", Nilable = true },
				{ Name = "race", Type = "number", Nilable = true },
				{ Name = "level", Type = "number", Nilable = true },
				{ Name = "zone", Type = "string", Nilable = true },
				{ Name = "achievementPoints", Type = "number", Nilable = true },
				{ Name = "profession1ID", Type = "number", Nilable = true },
				{ Name = "profession1Rank", Type = "number", Nilable = true },
				{ Name = "profession1Name", Type = "string", Nilable = true },
				{ Name = "profession2ID", Type = "number", Nilable = true },
				{ Name = "profession2Rank", Type = "number", Nilable = true },
				{ Name = "profession2Name", Type = "string", Nilable = true },
				{ Name = "lastOnlineYear", Type = "number", Nilable = true },
				{ Name = "lastOnlineMonth", Type = "number", Nilable = true },
				{ Name = "lastOnlineDay", Type = "number", Nilable = true },
				{ Name = "lastOnlineHour", Type = "number", Nilable = true },
				{ Name = "guildRank", Type = "string", Nilable = true },
				{ Name = "guildRankOrder", Type = "luaIndex", Nilable = true },
				{ Name = "isRemoteChat", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "ClubMessageIdentifier",
			Type = "Structure",
			Fields =
			{
				{ Name = "epoch", Type = "BigUInteger", Nilable = false, Documentation = { "number of microseconds since the UNIX epoch." } },
				{ Name = "position", Type = "BigUInteger", Nilable = false, Documentation = { "sort order for messages at the same time" } },
			},
		},
		{
			Name = "ClubMessageInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "messageId", Type = "ClubMessageIdentifier", Nilable = false },
				{ Name = "content", Type = "kstringClubMessage", Nilable = false },
				{ Name = "author", Type = "ClubMemberInfo", Nilable = false },
				{ Name = "destroyer", Type = "ClubMemberInfo", Nilable = true, Documentation = { "May be nil even if the message has been destroyed" } },
				{ Name = "destroyed", Type = "bool", Nilable = false },
				{ Name = "edited", Type = "bool", Nilable = false },
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
				{ Name = "canSetOwnMemberNote", Type = "bool", Nilable = false },
				{ Name = "canSetOtherMemberNote", Type = "bool", Nilable = false },
				{ Name = "canSetOwnVoiceState", Type = "bool", Nilable = false },
				{ Name = "canSetOwnPresenceLevel", Type = "bool", Nilable = false },
				{ Name = "canUseVoice", Type = "bool", Nilable = false },
				{ Name = "canVoiceMuteMemberForAll", Type = "bool", Nilable = false },
				{ Name = "canGetInvitation", Type = "bool", Nilable = false },
				{ Name = "canSendInvitation", Type = "bool", Nilable = false },
				{ Name = "canSendGuestInvitation", Type = "bool", Nilable = false },
				{ Name = "canRevokeOwnInvitation", Type = "bool", Nilable = false },
				{ Name = "canRevokeOtherInvitation", Type = "bool", Nilable = false },
				{ Name = "canGetBan", Type = "bool", Nilable = false },
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
			Name = "ClubSelfInvitationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "invitationId", Type = "ClubInvitationId", Nilable = false },
				{ Name = "club", Type = "ClubInfo", Nilable = false },
				{ Name = "inviter", Type = "ClubMemberInfo", Nilable = false },
				{ Name = "leaders", Type = "table", InnerType = "ClubMemberInfo", Nilable = false },
			},
		},
		{
			Name = "ClubStreamInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "subject", Type = "string", Nilable = false },
				{ Name = "leadersAndModeratorsOnly", Type = "bool", Nilable = false },
				{ Name = "streamType", Type = "ClubStreamType", Nilable = false },
				{ Name = "creationTime", Type = "BigUInteger", Nilable = false },
			},
		},
		{
			Name = "ClubStreamNotificationSetting",
			Type = "Structure",
			Fields =
			{
				{ Name = "streamId", Type = "ClubStreamId", Nilable = false },
				{ Name = "filter", Type = "ClubStreamNotificationFilter", Nilable = false },
			},
		},
		{
			Name = "ClubTicketInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "ticketId", Type = "string", Nilable = false },
				{ Name = "allowedRedeemCount", Type = "number", Nilable = false },
				{ Name = "currentRedeemCount", Type = "number", Nilable = false },
				{ Name = "creationTime", Type = "BigUInteger", Nilable = false, Documentation = { "Creation time in microseconds since the UNIX epoch." } },
				{ Name = "expirationTime", Type = "BigUInteger", Nilable = false, Documentation = { "Expiration time in microseconds since the UNIX epoch." } },
				{ Name = "defaultStreamId", Type = "ClubStreamId", Nilable = true },
				{ Name = "creator", Type = "ClubMemberInfo", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Club);