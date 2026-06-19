local BattleNet =
{
	Name = "BattleNet",
	Type = "System",
	Namespace = "C_BattleNet",
	Environment = "All",

	Functions =
	{
		{
			Name = "AreFriendTagsEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "areFriendTagsEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "AreTitleFriendsEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "areTitleFriendsEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "BNCheckBattleTagInviteToRecentAlly",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "recentAllyGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "BNCheckTitleFriendInviteToUnit",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},
		},
		{
			Name = "GetAccountInfoByGUID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "accountInfo", Type = "BNetAccountInfo", Nilable = true },
			},
		},
		{
			Name = "GetAccountInfoByID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "wowAccountGUID", Type = "WOWGUID", Nilable = true },
			},

			Returns =
			{
				{ Name = "accountInfo", Type = "BNetAccountInfo", Nilable = true },
			},
		},
		{
			Name = "GetFriendAccountInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "friendIndex", Type = "luaIndex", Nilable = false },
				{ Name = "wowAccountGUID", Type = "WOWGUID", Nilable = true },
			},

			Returns =
			{
				{ Name = "accountInfo", Type = "BNetAccountInfo", Nilable = true },
			},
		},
		{
			Name = "GetFriendGameAccountInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "friendIndex", Type = "luaIndex", Nilable = false },
				{ Name = "accountIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "gameAccountInfo", Type = "BNetGameAccountInfo", Nilable = true },
			},
		},
		{
			Name = "GetFriendInviteInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "inviteIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "inviteInfo", Type = "BNetFriendInviteInfo", Nilable = true },
			},
		},
		{
			Name = "GetFriendNumGameAccounts",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "friendIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "numGameAccounts", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetGameAccountInfoByGUID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "gameAccountInfo", Type = "BNetGameAccountInfo", Nilable = true },
			},
		},
		{
			Name = "GetGameAccountInfoByID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "id", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "gameAccountInfo", Type = "BNetGameAccountInfo", Nilable = true },
			},
		},
		{
			Name = "InstallHighResTextures",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "InviteFriend",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "gameAccountID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsBattleNetFriendsListEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isBattleNetFriendsListEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsBattleNetFriendsListSupported",
			Type = "Function",

			Returns =
			{
				{ Name = "isBattleNetFriendsListSupported", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SendGameData",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "gameAccountID", Type = "number", Nilable = false },
				{ Name = "prefix", Type = "stringView", Nilable = false },
				{ Name = "data", Type = "stringView", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "SendAddonMessageResult", Nilable = false },
			},
		},
		{
			Name = "SendVerifiedBattleNetFriendInvite",
			Type = "Function",
		},
		{
			Name = "SendWhisper",
			Type = "Function",
			HasRestrictions = true,
			RestrictedForMacroChatMessages = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "bnetAccountID", Type = "number", Nilable = false },
				{ Name = "text", Type = "stringView", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetAFK",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "isAFK", Type = "bool", Nilable = false, Default = true },
			},
		},
		{
			Name = "SetCustomMessage",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetDND",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "isDND", Type = "bool", Nilable = false, Default = true },
			},
		},
		{
			Name = "SetFriendTags",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "friendTags", Type = "table", InnerType = "BattleNetFriendTag", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "BNetAccountInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "bnetAccountID", Type = "number", Nilable = false },
				{ Name = "accountName", Type = "string", Nilable = false },
				{ Name = "battleTag", Type = "string", Nilable = false },
				{ Name = "isFriend", Type = "bool", Nilable = false },
				{ Name = "isBattleTagFriend", Type = "bool", Nilable = false },
				{ Name = "friendLevel", Type = "BattleNetFriendLevel", Nilable = true },
				{ Name = "lastOnlineTime", Type = "number", Nilable = false },
				{ Name = "isAFK", Type = "bool", Nilable = false },
				{ Name = "isDND", Type = "bool", Nilable = false },
				{ Name = "isFavorite", Type = "bool", Nilable = false },
				{ Name = "friendTags", Type = "table", InnerType = "BattleNetFriendTag", Nilable = false },
				{ Name = "appearOffline", Type = "bool", Nilable = false },
				{ Name = "customMessage", Type = "string", Nilable = false },
				{ Name = "customMessageTime", Type = "number", Nilable = false },
				{ Name = "note", Type = "string", Nilable = false },
				{ Name = "rafLinkType", Type = "RafLinkType", Nilable = false },
				{ Name = "gameAccountInfo", Type = "BNetGameAccountInfo", Nilable = false },
			},
		},
		{
			Name = "BNetFriendInviteInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "inviteID", Type = "number", Nilable = false },
				{ Name = "accountName", Type = "kstringAuroraName", Nilable = false },
				{ Name = "creationTimestamp", Type = "number", Nilable = false },
				{ Name = "friendLevel", Type = "BattleNetFriendLevel", Nilable = true },
			},
		},
		{
			Name = "BNetGameAccountInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "gameAccountID", Type = "number", Nilable = false },
				{ Name = "clientProgram", Type = "string", Nilable = false },
				{ Name = "isOnline", Type = "bool", Nilable = false },
				{ Name = "isGameBusy", Type = "bool", Nilable = false },
				{ Name = "isGameAFK", Type = "bool", Nilable = false },
				{ Name = "wowProjectID", Type = "number", Nilable = true },
				{ Name = "characterName", Type = "string", Nilable = true },
				{ Name = "realmName", Type = "string", Nilable = true },
				{ Name = "realmDisplayName", Type = "string", Nilable = true },
				{ Name = "realmID", Type = "number", Nilable = true },
				{ Name = "factionName", Type = "string", Nilable = true },
				{ Name = "raceName", Type = "string", Nilable = true },
				{ Name = "classID", Type = "number", Nilable = true },
				{ Name = "className", Type = "string", Nilable = true },
				{ Name = "classFilename", Type = "cstring", Nilable = true },
				{ Name = "areaName", Type = "string", Nilable = true },
				{ Name = "characterLevel", Type = "number", Nilable = true },
				{ Name = "richPresence", Type = "string", Nilable = true },
				{ Name = "playerGuid", Type = "WOWGUID", Nilable = true },
				{ Name = "canSummon", Type = "bool", Nilable = false },
				{ Name = "hasFocus", Type = "bool", Nilable = false },
				{ Name = "regionID", Type = "number", Nilable = false },
				{ Name = "isInCurrentRegion", Type = "bool", Nilable = false },
				{ Name = "timerunningSeasonID", Type = "number", Nilable = true },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(BattleNet);