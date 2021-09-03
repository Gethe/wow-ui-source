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
			Name = "GetActiveEntryInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "entryData", Type = "LfgEntryData", Nilable = false },
			},
		},
		{
			Name = "GetApplicantDungeonScoreForListing",
			Type = "Function",

			Arguments =
			{
				{ Name = "localID", Type = "number", Nilable = false },
				{ Name = "applicantIndex", Type = "number", Nilable = false },
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
				{ Name = "applicantIndex", Type = "number", Nilable = false },
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
			Name = "Search",
			Type = "Function",

			Arguments =
			{
				{ Name = "categoryID", Type = "number", Nilable = false },
				{ Name = "filter", Type = "number", Nilable = false, Default = 0 },
				{ Name = "preferredFilters", Type = "number", Nilable = false, Default = 0 },
				{ Name = "languageFilter", Type = "WowLocale", Nilable = true },
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
				{ Name = "newStatus", Type = "string", Nilable = false },
				{ Name = "oldStatus", Type = "string", Nilable = false },
				{ Name = "groupName", Type = "string", Nilable = false },
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
				{ Name = "groupName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "LfgListSearchFailed",
			Type = "Event",
			LiteralName = "LFG_LIST_SEARCH_FAILED",
			Payload =
			{
				{ Name = "reason", Type = "string", Nilable = true },
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
			Name = "LfgEntryPlaystyle",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "LfgEntryPlaystyle", EnumValue = 0 },
				{ Name = "Standard", Type = "LfgEntryPlaystyle", EnumValue = 1 },
				{ Name = "Casual", Type = "LfgEntryPlaystyle", EnumValue = 2 },
				{ Name = "Hardcore", Type = "LfgEntryPlaystyle", EnumValue = 3 },
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
			},
		},
		{
			Name = "LfgApplicantData",
			Type = "Structure",
			Fields =
			{
				{ Name = "applicantID", Type = "number", Nilable = false },
				{ Name = "applicationStatus", Type = "string", Nilable = false },
				{ Name = "pendingApplicationStatus", Type = "string", Nilable = true },
				{ Name = "numMembers", Type = "number", Nilable = false },
				{ Name = "isNew", Type = "bool", Nilable = false },
				{ Name = "comment", Type = "string", Nilable = false },
				{ Name = "displayOrderID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LfgCategoryData",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "searchPromptOverride", Type = "string", Nilable = true },
				{ Name = "separateRecommended", Type = "bool", Nilable = false },
				{ Name = "autoChooseActivity", Type = "bool", Nilable = false },
				{ Name = "preferCurrentArea", Type = "bool", Nilable = false },
				{ Name = "showPlaystyleDropdown", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LfgEntryData",
			Type = "Structure",
			Fields =
			{
				{ Name = "activityID", Type = "number", Nilable = false },
				{ Name = "requiredItemLevel", Type = "number", Nilable = false },
				{ Name = "requiredHonorLevel", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "comment", Type = "string", Nilable = false },
				{ Name = "voiceChat", Type = "string", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
				{ Name = "autoAccept", Type = "bool", Nilable = false },
				{ Name = "privateGroup", Type = "bool", Nilable = false },
				{ Name = "questID", Type = "number", Nilable = true },
				{ Name = "requiredDungeonScore", Type = "number", Nilable = true },
				{ Name = "requiredPvpRating", Type = "number", Nilable = true },
				{ Name = "playstyle", Type = "LfgEntryPlaystyle", Nilable = true },
			},
		},
		{
			Name = "LfgSearchResultData",
			Type = "Structure",
			Fields =
			{
				{ Name = "searchResultID", Type = "number", Nilable = false },
				{ Name = "activityID", Type = "number", Nilable = false },
				{ Name = "leaderName", Type = "string", Nilable = true },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "comment", Type = "string", Nilable = false },
				{ Name = "voiceChat", Type = "string", Nilable = false },
				{ Name = "requiredItemLevel", Type = "number", Nilable = false },
				{ Name = "requiredHonorLevel", Type = "number", Nilable = false },
				{ Name = "numMembers", Type = "number", Nilable = false },
				{ Name = "numBNetFriends", Type = "number", Nilable = false },
				{ Name = "numCharFriends", Type = "number", Nilable = false },
				{ Name = "numGuildMates", Type = "number", Nilable = false },
				{ Name = "isDelisted", Type = "bool", Nilable = false },
				{ Name = "autoAccept", Type = "bool", Nilable = false },
				{ Name = "isWarMode", Type = "bool", Nilable = false },
				{ Name = "age", Type = "number", Nilable = false },
				{ Name = "questID", Type = "number", Nilable = true },
				{ Name = "leaderOverallDungeonScore", Type = "number", Nilable = true },
				{ Name = "leaderDungeonScoreInfo", Type = "BestDungeonScoreMapInfo", Nilable = true },
				{ Name = "leaderPvpRatingInfo", Type = "PvpRatingInfo", Nilable = true },
				{ Name = "requiredDungeonScore", Type = "number", Nilable = true },
				{ Name = "requiredPvpRating", Type = "number", Nilable = true },
				{ Name = "playstyle", Type = "LfgEntryPlaystyle", Nilable = true },
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