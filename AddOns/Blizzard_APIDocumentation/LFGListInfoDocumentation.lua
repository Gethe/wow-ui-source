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
	},

	Events =
	{
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