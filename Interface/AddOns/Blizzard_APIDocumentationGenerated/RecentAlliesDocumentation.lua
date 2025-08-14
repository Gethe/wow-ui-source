local RecentAllies =
{
	Name = "RecentAllies",
	Type = "System",
	Namespace = "C_RecentAllies",

	Functions =
	{
		{
			Name = "CanSetRecentAllyNote",
			Type = "Function",
			RequiresRecentAllies = true,

			Arguments =
			{
				{ Name = "characterGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "canSetNote", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetRecentAllies",
			Type = "Function",
			RequiresRecentAllies = true,

			Returns =
			{
				{ Name = "recentAlliesData", Type = "table", InnerType = "RecentAllyData", Nilable = false },
			},
		},
		{
			Name = "GetRecentAllyByFullName",
			Type = "Function",
			RequiresRecentAllies = true,

			Arguments =
			{
				{ Name = "fullCharacterName", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "recentAllyData", Type = "RecentAllyData", Nilable = true },
			},
		},
		{
			Name = "GetRecentAllyByGUID",
			Type = "Function",
			RequiresRecentAllies = true,

			Arguments =
			{
				{ Name = "characterGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "recentAllyData", Type = "RecentAllyData", Nilable = true },
			},
		},
		{
			Name = "IsRecentAllyByFullName",
			Type = "Function",
			RequiresRecentAllies = true,

			Arguments =
			{
				{ Name = "fullCharacterName", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "isRecentAlly", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRecentAllyByGUID",
			Type = "Function",
			RequiresRecentAllies = true,

			Arguments =
			{
				{ Name = "characterGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "isRecentAlly", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRecentAllyPinned",
			Type = "Function",
			RequiresRecentAllies = true,

			Arguments =
			{
				{ Name = "characterGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "isPinned", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSystemEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isRecentAllySystemEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSystemSupported",
			Type = "Function",

			Returns =
			{
				{ Name = "isRecentAllySystemSupported", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestRecentAlliesDataFromServer",
			Type = "Function",
			HasRestrictions = true,
			RequiresRecentAllies = true,
		},
		{
			Name = "SetRecentAllyNote",
			Type = "Function",
			RequiresRecentAllies = true,

			Arguments =
			{
				{ Name = "characterGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "note", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SetRecentAllyPinned",
			Type = "Function",
			RequiresRecentAllies = true,

			Arguments =
			{
				{ Name = "characterGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "isPinned", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "RecentAlliesCacheUpdate",
			Type = "Event",
			LiteralName = "RECENT_ALLIES_CACHE_UPDATE",
		},
		{
			Name = "RecentAlliesSystemStatusUpdated",
			Type = "Event",
			LiteralName = "RECENT_ALLIES_SYSTEM_STATUS_UPDATED",
		},
		{
			Name = "RecentAllyDataUpdated",
			Type = "Event",
			LiteralName = "RECENT_ALLY_DATA_UPDATED",
			Payload =
			{
				{ Name = "characterGUID", Type = "WOWGUID", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "RecentAllyCharacterData",
			Type = "Structure",
			Fields =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "fullName", Type = "string", Nilable = false },
				{ Name = "realmName", Type = "string", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "classID", Type = "number", Nilable = false },
				{ Name = "raceID", Type = "number", Nilable = false },
				{ Name = "sex", Type = "UnitSex", Nilable = false },
			},
		},
		{
			Name = "RecentAllyData",
			Type = "Structure",
			Fields =
			{
				{ Name = "stateData", Type = "RecentAllyStateData", Nilable = false },
				{ Name = "characterData", Type = "RecentAllyCharacterData", Nilable = false },
				{ Name = "interactionData", Type = "RecentAllyInteractionData", Nilable = false },
			},
		},
		{
			Name = "RecentAllyInteraction",
			Type = "Structure",
			Fields =
			{
				{ Name = "type", Type = "RolodexType", Nilable = false },
				{ Name = "timestamp", Type = "time_t", Nilable = false },
				{ Name = "contextData", Type = "RecentAllyInteractionContextData", Nilable = false },
			},
		},
		{
			Name = "RecentAllyInteractionContextData",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemID", Type = "number", Nilable = true },
				{ Name = "locationName", Type = "cstring", Nilable = true },
				{ Name = "activityDifficultyID", Type = "number", Nilable = true },
				{ Name = "activityDifficultyLevel", Type = "number", Nilable = true },
			},
		},
		{
			Name = "RecentAllyInteractionData",
			Type = "Structure",
			Fields =
			{
				{ Name = "interactions", Type = "table", InnerType = "RecentAllyInteraction", Nilable = false },
				{ Name = "note", Type = "string", Nilable = true },
			},
		},
		{
			Name = "RecentAllyStateData",
			Type = "Structure",
			Fields =
			{
				{ Name = "isOnline", Type = "bool", Nilable = false },
				{ Name = "isDND", Type = "bool", Nilable = false },
				{ Name = "isAFK", Type = "bool", Nilable = false },
				{ Name = "pinExpirationDate", Type = "time_t", Nilable = true },
				{ Name = "hasFriendRequestPending", Type = "bool", Nilable = false },
				{ Name = "currentLocation", Type = "cstring", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(RecentAllies);