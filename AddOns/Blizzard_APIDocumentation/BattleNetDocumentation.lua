local BattleNet =
{
	Name = "BattleNet",
	Type = "System",
	Namespace = "C_BattleNet",

	Functions =
	{
		{
			Name = "GetAccountInfoByFriendIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "friendIndex", Type = "number", Nilable = false },
				{ Name = "wowAccountGUID", Type = "string", Nilable = true },
			},

			Returns =
			{
				{ Name = "accountInfo", Type = "BNetAccountInfo", Nilable = true },
			},
		},
		{
			Name = "GetAccountInfoByGUID",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "accountInfo", Type = "BNetAccountInfo", Nilable = true },
			},
		},
		{
			Name = "GetAccountInfoByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "wowAccountGUID", Type = "string", Nilable = true },
			},

			Returns =
			{
				{ Name = "accountInfo", Type = "BNetAccountInfo", Nilable = true },
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
				{ Name = "gameAccountID", Type = "number", Nilable = true },
				{ Name = "accountName", Type = "string", Nilable = false },
				{ Name = "battleTag", Type = "string", Nilable = false },
				{ Name = "isFriend", Type = "bool", Nilable = false },
				{ Name = "isBattleTagFriend", Type = "bool", Nilable = false },
				{ Name = "lastOnlineTime", Type = "number", Nilable = false },
				{ Name = "isAFK", Type = "bool", Nilable = false },
				{ Name = "isDND", Type = "bool", Nilable = false },
				{ Name = "isFavorite", Type = "bool", Nilable = false },
				{ Name = "appearOffline", Type = "bool", Nilable = false },
				{ Name = "customMessage", Type = "string", Nilable = false },
				{ Name = "customMessageTime", Type = "number", Nilable = false },
				{ Name = "note", Type = "string", Nilable = false },
				{ Name = "clientProgram", Type = "string", Nilable = false },
				{ Name = "isOnline", Type = "bool", Nilable = false },
				{ Name = "isGameBusy", Type = "bool", Nilable = false },
				{ Name = "isGameAFK", Type = "bool", Nilable = false },
				{ Name = "wowProjectID", Type = "number", Nilable = true },
				{ Name = "characterName", Type = "string", Nilable = true },
				{ Name = "realmName", Type = "string", Nilable = true },
				{ Name = "realmID", Type = "number", Nilable = true },
				{ Name = "factionName", Type = "string", Nilable = true },
				{ Name = "raceName", Type = "string", Nilable = true },
				{ Name = "className", Type = "string", Nilable = true },
				{ Name = "areaName", Type = "string", Nilable = true },
				{ Name = "characterLevel", Type = "number", Nilable = true },
				{ Name = "richPresence", Type = "string", Nilable = true },
				{ Name = "playerGuid", Type = "string", Nilable = true },
				{ Name = "isWowMobile", Type = "bool", Nilable = false },
				{ Name = "rafLinkType", Type = "RafLinkType", Nilable = false },
				{ Name = "canSummon", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(BattleNet);