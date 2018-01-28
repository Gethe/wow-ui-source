local Friends =
{
	Name = "Friends",
	Type = "System",
	Namespace = "C_Friends",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "BattletagInviteShow",
			Type = "Event",
			LiteralName = "BATTLETAG_INVITE_SHOW",
			Payload =
			{
				{ Name = "name", Type = "string", Nilable = false },
			},
		},
		{
			Name = "BnBlockFailedTooMany",
			Type = "Event",
			LiteralName = "BN_BLOCK_FAILED_TOO_MANY",
			Payload =
			{
				{ Name = "blockType", Type = "string", Nilable = false },
			},
		},
		{
			Name = "BnBlockListUpdated",
			Type = "Event",
			LiteralName = "BN_BLOCK_LIST_UPDATED",
		},
		{
			Name = "BnChatWhisperUndeliverable",
			Type = "Event",
			LiteralName = "BN_CHAT_WHISPER_UNDELIVERABLE",
			Payload =
			{
				{ Name = "senderID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "BnConnected",
			Type = "Event",
			LiteralName = "BN_CONNECTED",
		},
		{
			Name = "BnCustomMessageChanged",
			Type = "Event",
			LiteralName = "BN_CUSTOM_MESSAGE_CHANGED",
			Payload =
			{
				{ Name = "id", Type = "number", Nilable = true },
			},
		},
		{
			Name = "BnCustomMessageLoaded",
			Type = "Event",
			LiteralName = "BN_CUSTOM_MESSAGE_LOADED",
		},
		{
			Name = "BnDisconnected",
			Type = "Event",
			LiteralName = "BN_DISCONNECTED",
			Payload =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "BnFriendAccountOffline",
			Type = "Event",
			LiteralName = "BN_FRIEND_ACCOUNT_OFFLINE",
			Payload =
			{
				{ Name = "friendId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "BnFriendAccountOnline",
			Type = "Event",
			LiteralName = "BN_FRIEND_ACCOUNT_ONLINE",
			Payload =
			{
				{ Name = "friendId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "BnFriendInfoChanged",
			Type = "Event",
			LiteralName = "BN_FRIEND_INFO_CHANGED",
			Payload =
			{
				{ Name = "friendIndex", Type = "number", Nilable = true },
			},
		},
		{
			Name = "BnFriendInviteAdded",
			Type = "Event",
			LiteralName = "BN_FRIEND_INVITE_ADDED",
			Payload =
			{
				{ Name = "accountID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "BnFriendInviteListInitialized",
			Type = "Event",
			LiteralName = "BN_FRIEND_INVITE_LIST_INITIALIZED",
			Payload =
			{
				{ Name = "listSize", Type = "number", Nilable = false },
			},
		},
		{
			Name = "BnFriendInviteRemoved",
			Type = "Event",
			LiteralName = "BN_FRIEND_INVITE_REMOVED",
		},
		{
			Name = "BnFriendListSizeChanged",
			Type = "Event",
			LiteralName = "BN_FRIEND_LIST_SIZE_CHANGED",
			Payload =
			{
				{ Name = "accountID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "BnInfoChanged",
			Type = "Event",
			LiteralName = "BN_INFO_CHANGED",
		},
		{
			Name = "BnRequestFofSucceeded",
			Type = "Event",
			LiteralName = "BN_REQUEST_FOF_SUCCEEDED",
		},
		{
			Name = "FriendlistUpdate",
			Type = "Event",
			LiteralName = "FRIENDLIST_UPDATE",
		},
		{
			Name = "IgnorelistUpdate",
			Type = "Event",
			LiteralName = "IGNORELIST_UPDATE",
		},
		{
			Name = "MutelistUpdate",
			Type = "Event",
			LiteralName = "MUTELIST_UPDATE",
		},
		{
			Name = "WhoListUpdate",
			Type = "Event",
			LiteralName = "WHO_LIST_UPDATE",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Friends);