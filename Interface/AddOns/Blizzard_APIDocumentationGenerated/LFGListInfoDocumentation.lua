local LFGListInfo =
{
	Name = "LFGList",
	Type = "System",
	Namespace = "C_LFGList",

	Functions =
	{
		{
			Name = "ClearCreationTextFields",
			Type = "Function",
		},
		{
			Name = "CopyActiveEntryInfoToCreationFields",
			Type = "Function",
		},
		{
			Name = "CreateListing",
			Type = "Function",

			Arguments =
			{
				{ Name = "activityIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "newPlayerFriendly", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetActiveEntryInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "entryData", Type = "LfgEntryData", Nilable = false },
			},
		},
		{
			Name = "GetActivityInfoTable",
			Type = "Function",

			Arguments =
			{
				{ Name = "activityID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "activityInfo", Type = "GroupFinderActivityInfo", Nilable = false },
			},
		},
		{
			Name = "GetFilteredSearchResults",
			Type = "Function",

			Returns =
			{
				{ Name = "totalResultsFound", Type = "number", Nilable = false, Default = 0 },
				{ Name = "filteredResults", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetRedirectedMapDifficultyID",
			Type = "Function",

			Arguments =
			{
				{ Name = "difficultyID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "redirectedMapDifficultyID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRoles",
			Type = "Function",

			Returns =
			{
				{ Name = "roles", Type = "LFGRoles", Nilable = false },
			},
		},
		{
			Name = "GetSavedRoles",
			Type = "Function",

			Returns =
			{
				{ Name = "roles", Type = "LFGRoles", Nilable = false },
			},
		},
		{
			Name = "GetSearchResultInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "searchResultID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "searchResultData", Type = "LfgSearchResultData", Nilable = false },
			},
		},
		{
			Name = "GetSearchResults",
			Type = "Function",

			Returns =
			{
				{ Name = "totalResultsFound", Type = "number", Nilable = false, Default = 0 },
				{ Name = "results", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "HasActiveEntryInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "hasActiveEntryInfo", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasSearchResultInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "searchResultID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasSearchResultInfo", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsLookingForGroupEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPlayerAuthenticatedForLFG",
			Type = "Function",

			Arguments =
			{
				{ Name = "categoryID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "isAuthenticated", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestInvite",
			Type = "Function",

			Arguments =
			{
				{ Name = "searchResultID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "Search",
			Type = "Function",

			Arguments =
			{
				{ Name = "categoryID", Type = "number", Nilable = false },
				{ Name = "activityIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "filter", Type = "number", Nilable = false, Default = 0 },
				{ Name = "preferredFilters", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "SetRoles",
			Type = "Function",

			Arguments =
			{
				{ Name = "roles", Type = "LFGRoles", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UpdateListing",
			Type = "Function",

			Arguments =
			{
				{ Name = "activityIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "newPlayerFriendly", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "LfgGroupDelistedLeadershipChange",
			Type = "Event",
			LiteralName = "LFG_GROUP_DELISTED_LEADERSHIP_CHANGE",
			Payload =
			{
				{ Name = "listingName", Type = "string", Nilable = false },
				{ Name = "automaticDelistTimeRemaining", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LfgListActiveEntryUpdate",
			Type = "Event",
			LiteralName = "LFG_LIST_ACTIVE_ENTRY_UPDATE",
			Payload =
			{
				{ Name = "created", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "LfgListAvailabilityUpdate",
			Type = "Event",
			LiteralName = "LFG_LIST_AVAILABILITY_UPDATE",
		},
		{
			Name = "LfgListEntryCreationFailed",
			Type = "Event",
			LiteralName = "LFG_LIST_ENTRY_CREATION_FAILED",
		},
		{
			Name = "LfgListEntryExpiredTimeout",
			Type = "Event",
			LiteralName = "LFG_LIST_ENTRY_EXPIRED_TIMEOUT",
		},
		{
			Name = "LfgListEntryExpiredTooManyPlayers",
			Type = "Event",
			LiteralName = "LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS",
		},
		{
			Name = "LfgListRoleUpdate",
			Type = "Event",
			LiteralName = "LFG_LIST_ROLE_UPDATE",
		},
		{
			Name = "LfgListSearchFailed",
			Type = "Event",
			LiteralName = "LFG_LIST_SEARCH_FAILED",
			Payload =
			{
				{ Name = "reason", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "LfgListSearchResultUpdated",
			Type = "Event",
			LiteralName = "LFG_LIST_SEARCH_RESULT_UPDATED",
			Payload =
			{
				{ Name = "searchResultID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LfgListSearchResultsReceived",
			Type = "Event",
			LiteralName = "LFG_LIST_SEARCH_RESULTS_RECEIVED",
		},
	},

	Tables =
	{
		{
			Name = "LFGListDisplayType",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "RoleCount", Type = "LFGListDisplayType", EnumValue = 0 },
				{ Name = "RoleEnumerate", Type = "LFGListDisplayType", EnumValue = 1 },
				{ Name = "ClassEnumerate", Type = "LFGListDisplayType", EnumValue = 2 },
				{ Name = "HideAll", Type = "LFGListDisplayType", EnumValue = 3 },
				{ Name = "PlayerCount", Type = "LFGListDisplayType", EnumValue = 4 },
				{ Name = "Comment", Type = "LFGListDisplayType", EnumValue = 5 },
			},
		},
		{
			Name = "GroupFinderActivityInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "fullName", Type = "string", Nilable = false },
				{ Name = "shortName", Type = "string", Nilable = false },
				{ Name = "categoryID", Type = "number", Nilable = false },
				{ Name = "groupFinderActivityGroupID", Type = "number", Nilable = false },
				{ Name = "filters", Type = "number", Nilable = false },
				{ Name = "minLevel", Type = "number", Nilable = false },
				{ Name = "maxLevel", Type = "number", Nilable = false },
				{ Name = "maxLevelSuggestion", Type = "number", Nilable = false },
				{ Name = "maxNumPlayers", Type = "number", Nilable = false },
				{ Name = "displayType", Type = "LFGListDisplayType", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "iconFileDataID", Type = "number", Nilable = false },
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "difficultyID", Type = "number", Nilable = false },
				{ Name = "redirectedDifficultyID", Type = "number", Nilable = false },
				{ Name = "useDungeonRoleExpectations", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LfgEntryData",
			Type = "Structure",
			Fields =
			{
				{ Name = "activityIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "comment", Type = "kstringLfgListApplicant", Nilable = false },
				{ Name = "duration", Type = "time_t", Nilable = false },
				{ Name = "newPlayerFriendly", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LFGRoles",
			Type = "Structure",
			Fields =
			{
				{ Name = "tank", Type = "bool", Nilable = false },
				{ Name = "healer", Type = "bool", Nilable = false },
				{ Name = "dps", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LfgSearchResultData",
			Type = "Structure",
			Fields =
			{
				{ Name = "searchResultID", Type = "number", Nilable = false },
				{ Name = "activityIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "leaderName", Type = "string", Nilable = true },
				{ Name = "name", Type = "kstringLfgListSearch", Nilable = false },
				{ Name = "comment", Type = "kstringLfgListSearch", Nilable = false },
				{ Name = "voiceChat", Type = "kstringLfgListSearch", Nilable = false },
				{ Name = "requiredItemLevel", Type = "number", Nilable = false },
				{ Name = "requiredHonorLevel", Type = "number", Nilable = false },
				{ Name = "hasSelf", Type = "bool", Nilable = false },
				{ Name = "numMembers", Type = "number", Nilable = false },
				{ Name = "numBNetFriends", Type = "number", Nilable = false },
				{ Name = "numCharFriends", Type = "number", Nilable = false },
				{ Name = "numGuildMates", Type = "number", Nilable = false },
				{ Name = "isDelisted", Type = "bool", Nilable = false },
				{ Name = "autoAccept", Type = "bool", Nilable = false },
				{ Name = "isWarMode", Type = "bool", Nilable = false },
				{ Name = "age", Type = "time_t", Nilable = false },
				{ Name = "newPlayerFriendly", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "WowLocale",
			Type = "Structure",
			Fields =
			{
				{ Name = "enUS", Type = "bool", Nilable = false, Default = false },
				{ Name = "koKR", Type = "bool", Nilable = false, Default = false },
				{ Name = "frFR", Type = "bool", Nilable = false, Default = false },
				{ Name = "deDE", Type = "bool", Nilable = false, Default = false },
				{ Name = "zhCN", Type = "bool", Nilable = false, Default = false },
				{ Name = "zhTW", Type = "bool", Nilable = false, Default = false },
				{ Name = "esES", Type = "bool", Nilable = false, Default = false },
				{ Name = "esMX", Type = "bool", Nilable = false, Default = false },
				{ Name = "ruRU", Type = "bool", Nilable = false, Default = false },
				{ Name = "ptBR", Type = "bool", Nilable = false, Default = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LFGListInfo);