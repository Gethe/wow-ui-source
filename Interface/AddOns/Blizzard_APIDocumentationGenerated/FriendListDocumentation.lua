local FriendList =
{
	Name = "FriendList",
	Type = "System",
	Namespace = "C_FriendList",

	Functions =
	{
		{
			Name = "AddFriend",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "notes", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "AddIgnore",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "added", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "AddOrDelIgnore",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "AddOrRemoveFriend",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "notes", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "DelIgnore",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "removed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "DelIgnoreByIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetFriendInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "FriendInfo", Nilable = false },
			},
		},
		{
			Name = "GetFriendInfoByIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "FriendInfo", Nilable = false },
			},
		},
		{
			Name = "GetIgnoreName",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetNumFriends",
			Type = "Function",

			Returns =
			{
				{ Name = "numFriends", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumIgnores",
			Type = "Function",

			Returns =
			{
				{ Name = "numIgnores", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumOnlineFriends",
			Type = "Function",

			Returns =
			{
				{ Name = "numOnline", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumWhoResults",
			Type = "Function",

			Returns =
			{
				{ Name = "numWhos", Type = "number", Nilable = false },
				{ Name = "totalNumWhos", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSelectedFriend",
			Type = "Function",

			Returns =
			{
				{ Name = "index", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "GetSelectedIgnore",
			Type = "Function",

			Returns =
			{
				{ Name = "index", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "GetWhoInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "WhoInfo", Nilable = false },
			},
		},
		{
			Name = "IsFriend",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "isFriend", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsIgnored",
			Type = "Function",

			Arguments =
			{
				{ Name = "token", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "isIgnored", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsIgnoredByGuid",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "isIgnored", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsOnIgnoredList",
			Type = "Function",

			Arguments =
			{
				{ Name = "token", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "isIgnored", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RemoveFriend",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "removed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RemoveFriendByIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "SendWho",
			Type = "Function",

			Arguments =
			{
				{ Name = "filter", Type = "cstring", Nilable = false },
				{ Name = "origin", Type = "number", Nilable = true },
			},
		},
		{
			Name = "SetFriendNotes",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "notes", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "found", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetFriendNotesByIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "notes", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SetSelectedFriend",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "SetSelectedIgnore",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "SetWhoToUi",
			Type = "Function",

			Arguments =
			{
				{ Name = "whoToUi", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShowFriends",
			Type = "Function",
		},
		{
			Name = "SortWho",
			Type = "Function",

			Arguments =
			{
				{ Name = "sorting", Type = "cstring", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "BattletagInviteShow",
			Type = "Event",
			LiteralName = "BATTLETAG_INVITE_SHOW",
			Payload =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "BnBlockFailedTooMany",
			Type = "Event",
			LiteralName = "BN_BLOCK_FAILED_TOO_MANY",
			Payload =
			{
				{ Name = "blockType", Type = "cstring", Nilable = false },
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
				{ Name = "friendIndex", Type = "luaIndex", Nilable = true },
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
		{
			Name = "FriendInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "connected", Type = "bool", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "className", Type = "string", Nilable = true },
				{ Name = "area", Type = "string", Nilable = true },
				{ Name = "notes", Type = "string", Nilable = true },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "dnd", Type = "bool", Nilable = false },
				{ Name = "afk", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "WhoInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "fullName", Type = "string", Nilable = false },
				{ Name = "fullGuildName", Type = "string", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "raceStr", Type = "string", Nilable = false },
				{ Name = "classStr", Type = "string", Nilable = false },
				{ Name = "area", Type = "string", Nilable = false },
				{ Name = "filename", Type = "string", Nilable = true },
				{ Name = "gender", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(FriendList);