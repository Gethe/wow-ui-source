local LFGListInfo =
{
	Name = "LFGList",
	Type = "System",
	Namespace = "C_LFGList",

	Functions =
	{
		{
			Name = "CanActiveEntryUseAutoAccept",
			Type = "Function",

			Returns =
			{
				{ Name = "canUseAutoAccept", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanCreateQuestGroup",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canCreate", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ClearApplicationTextFields",
			Type = "Function",
		},
		{
			Name = "ClearCreationTextFields",
			Type = "Function",
		},
		{
			Name = "ClearSearchTextFields",
			Type = "Function",
		},
		{
			Name = "CopyActiveEntryInfoToCreationFields",
			Type = "Function",
		},
		{
			Name = "DoesEntryTitleMatchPrebuiltTitle",
			Type = "Function",

			Arguments =
			{
				{ Name = "activityID", Type = "number", Nilable = false },
				{ Name = "groupID", Type = "number", Nilable = false },
				{ Name = "playstyle", Type = "LFGEntryPlaystyle", Nilable = true },
			},

			Returns =
			{
				{ Name = "matches", Type = "bool", Nilable = false },
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
			Name = "GetActivityFullName",
			Type = "Function",

			Arguments =
			{
				{ Name = "activityID", Type = "number", Nilable = false },
				{ Name = "questID", Type = "number", Nilable = true },
				{ Name = "showWarmode", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "fullName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetActivityGroupInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "groupID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetActivityInfoTable",
			Type = "Function",

			Arguments =
			{
				{ Name = "activityID", Type = "number", Nilable = false },
				{ Name = "questID", Type = "number", Nilable = true },
				{ Name = "showWarmode", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "activityInfo", Type = "GroupFinderActivityInfo", Nilable = false },
			},
		},
		{
			Name = "GetApplicantDungeonScoreForListing",
			Type = "Function",

			Arguments =
			{
				{ Name = "localID", Type = "number", Nilable = false },
				{ Name = "applicantIndex", Type = "luaIndex", Nilable = false },
				{ Name = "activityID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "bestDungeonScoreForListing", Type = "BestDungeonScoreMapInfo", Nilable = false },
			},
		},
		{
			Name = "GetApplicantInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "applicantID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "applicantData", Type = "LfgApplicantData", Nilable = false },
			},
		},
		{
			Name = "GetApplicantPvpRatingInfoForListing",
			Type = "Function",

			Arguments =
			{
				{ Name = "localID", Type = "number", Nilable = false },
				{ Name = "applicantIndex", Type = "luaIndex", Nilable = false },
				{ Name = "activityID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "pvpRatingInfo", Type = "PvpRatingInfo", Nilable = false },
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
			Name = "GetKeystoneForActivity",
			Type = "Function",

			Arguments =
			{
				{ Name = "activityID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "level", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetLfgCategoryInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "categoryID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "categoryData", Type = "LfgCategoryData", Nilable = false },
			},
		},
		{
			Name = "GetOwnedKeystoneActivityAndGroupAndLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "getTimewalking", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "activityID", Type = "number", Nilable = false },
				{ Name = "groupID", Type = "number", Nilable = false },
				{ Name = "keystoneLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPlaystyleString",
			Type = "Function",

			Arguments =
			{
				{ Name = "playstyle", Type = "LFGEntryPlaystyle", Nilable = false },
				{ Name = "activityInfo", Type = "GroupFinderActivityInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "playstyleString", Type = "string", Nilable = false },
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
			Name = "IsPlayerAuthenticatedForLFG",
			Type = "Function",

			Arguments =
			{
				{ Name = "activityID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "isAuthenticated", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Search",
			Type = "Function",

			Arguments =
			{
				{ Name = "categoryID", Type = "number", Nilable = false },
				{ Name = "filter", Type = "number", Nilable = false, Default = 0 },
				{ Name = "preferredFilters", Type = "number", Nilable = false, Default = 0 },
				{ Name = "languageFilter", Type = "WowLocale", Nilable = true },
				{ Name = "searchCrossFactionListings", Type = "bool", Nilable = true, Default = false },
			},
		},
		{
			Name = "SetEntryTitle",
			Type = "Function",

			Arguments =
			{
				{ Name = "activityID", Type = "number", Nilable = false },
				{ Name = "groupID", Type = "number", Nilable = false },
				{ Name = "playstyle", Type = "LFGEntryPlaystyle", Nilable = true },
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
			Name = "SetSearchToActivity",
			Type = "Function",

			Arguments =
			{
				{ Name = "activityID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetSearchToQuestID",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ValidateRequiredDungeonScore",
			Type = "Function",

			Arguments =
			{
				{ Name = "dungeonScore", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "passes", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ValidateRequiredPvpRatingForActivity",
			Type = "Function",

			Arguments =
			{
				{ Name = "activityID", Type = "number", Nilable = false },
				{ Name = "rating", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "passes", Type = "bool", Nilable = false },
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
			Name = "LfgListApplicantListUpdated",
			Type = "Event",
			LiteralName = "LFG_LIST_APPLICANT_LIST_UPDATED",
			Payload =
			{
				{ Name = "newPendingEntry", Type = "bool", Nilable = true },
				{ Name = "newPendingEntryWithData", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "LfgListApplicantUpdated",
			Type = "Event",
			LiteralName = "LFG_LIST_APPLICANT_UPDATED",
			Payload =
			{
				{ Name = "applicantID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LfgListApplicationStatusUpdated",
			Type = "Event",
			LiteralName = "LFG_LIST_APPLICATION_STATUS_UPDATED",
			Payload =
			{
				{ Name = "searchResultID", Type = "number", Nilable = false },
				{ Name = "newStatus", Type = "cstring", Nilable = false },
				{ Name = "oldStatus", Type = "cstring", Nilable = false },
				{ Name = "groupName", Type = "kstringLfgListChat", Nilable = false },
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
			Name = "LfgListJoinedGroup",
			Type = "Event",
			LiteralName = "LFG_LIST_JOINED_GROUP",
			Payload =
			{
				{ Name = "searchResultID", Type = "number", Nilable = false },
				{ Name = "groupName", Type = "kstringLfgListChat", Nilable = false },
			},
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
			Name = "BestDungeonScoreMapInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "mapScore", Type = "number", Nilable = false },
				{ Name = "mapName", Type = "string", Nilable = false },
				{ Name = "bestRunLevel", Type = "number", Nilable = false },
				{ Name = "finishedSuccess", Type = "bool", Nilable = false },
				{ Name = "bestRunDurationMs", Type = "number", Nilable = false },
				{ Name = "bestLevelIncrement", Type = "number", Nilable = false },
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
				{ Name = "ilvlSuggestion", Type = "number", Nilable = false },
				{ Name = "filters", Type = "number", Nilable = false },
				{ Name = "minLevel", Type = "number", Nilable = false },
				{ Name = "maxLevel", Type = "number", Nilable = false },
				{ Name = "maxLevelSuggestion", Type = "number", Nilable = false },
				{ Name = "maxNumPlayers", Type = "number", Nilable = false },
				{ Name = "displayType", Type = "LFGListDisplayType", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "useHonorLevel", Type = "bool", Nilable = false },
				{ Name = "showQuickJoinToast", Type = "bool", Nilable = false },
				{ Name = "isMythicPlusActivity", Type = "bool", Nilable = false },
				{ Name = "isRatedPvpActivity", Type = "bool", Nilable = false },
				{ Name = "isCurrentRaidActivity", Type = "bool", Nilable = false },
				{ Name = "isPvpActivity", Type = "bool", Nilable = false },
				{ Name = "isMythicActivity", Type = "bool", Nilable = false },
				{ Name = "allowCrossFaction", Type = "bool", Nilable = false },
				{ Name = "iconFileDataID", Type = "number", Nilable = false },
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "difficultyID", Type = "number", Nilable = false },
				{ Name = "redirectedDifficultyID", Type = "number", Nilable = false },
				{ Name = "useDungeonRoleExpectations", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LfgApplicantData",
			Type = "Structure",
			Fields =
			{
				{ Name = "applicantID", Type = "number", Nilable = false },
				{ Name = "applicationStatus", Type = "cstring", Nilable = false },
				{ Name = "pendingApplicationStatus", Type = "cstring", Nilable = true },
				{ Name = "numMembers", Type = "number", Nilable = false },
				{ Name = "isNew", Type = "bool", Nilable = false },
				{ Name = "comment", Type = "kstringLfgListApplicant", Nilable = false },
				{ Name = "displayOrderID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LfgCategoryData",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "searchPromptOverride", Type = "cstring", Nilable = true },
				{ Name = "separateRecommended", Type = "bool", Nilable = false },
				{ Name = "autoChooseActivity", Type = "bool", Nilable = false },
				{ Name = "preferCurrentArea", Type = "bool", Nilable = false },
				{ Name = "showPlaystyleDropdown", Type = "bool", Nilable = false },
				{ Name = "allowCrossFaction", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LfgEntryData",
			Type = "Structure",
			Fields =
			{
				{ Name = "activityID", Type = "number", Nilable = false },
				{ Name = "activityIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "requiredItemLevel", Type = "number", Nilable = false },
				{ Name = "requiredHonorLevel", Type = "number", Nilable = false },
				{ Name = "name", Type = "kstringLfgListApplicant", Nilable = false },
				{ Name = "comment", Type = "kstringLfgListApplicant", Nilable = false },
				{ Name = "voiceChat", Type = "kstringLfgListApplicant", Nilable = false },
				{ Name = "duration", Type = "time_t", Nilable = false },
				{ Name = "autoAccept", Type = "bool", Nilable = false },
				{ Name = "privateGroup", Type = "bool", Nilable = false },
				{ Name = "questID", Type = "number", Nilable = true },
				{ Name = "requiredDungeonScore", Type = "number", Nilable = true },
				{ Name = "requiredPvpRating", Type = "number", Nilable = true },
				{ Name = "playstyle", Type = "LFGEntryPlaystyle", Nilable = true },
				{ Name = "isCrossFactionListing", Type = "bool", Nilable = false },
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
				{ Name = "activityID", Type = "number", Nilable = false },
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
				{ Name = "leaderOverallDungeonScore", Type = "number", Nilable = true },
				{ Name = "leaderDungeonScoreInfo", Type = "BestDungeonScoreMapInfo", Nilable = true },
				{ Name = "leaderBestDungeonScoreInfo", Type = "BestDungeonScoreMapInfo", Nilable = true },
				{ Name = "leaderPvpRatingInfo", Type = "PvpRatingInfo", Nilable = true },
				{ Name = "leaderFactionGroup", Type = "number", Nilable = false },
				{ Name = "newPlayerFriendly", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "PvpRatingInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "bracket", Type = "number", Nilable = false },
				{ Name = "rating", Type = "number", Nilable = false },
				{ Name = "activityName", Type = "string", Nilable = false },
				{ Name = "tier", Type = "number", Nilable = false },
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
				{ Name = "itIT", Type = "bool", Nilable = false, Default = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LFGListInfo);