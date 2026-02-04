local PerksActivities =
{
	Name = "PerksActivities",
	Type = "System",
	Namespace = "C_PerksActivities",
	Environment = "All",

	Functions =
	{
		{
			Name = "AddTrackedPerksActivity",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "perksActivityID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ClearPerksActivitiesPendingCompletion",
			Type = "Function",
		},
		{
			Name = "GetAllPerksActivityTags",
			Type = "Function",

			Returns =
			{
				{ Name = "tags", Type = "PerksActivityTags", Nilable = false },
			},
		},
		{
			Name = "GetPerksActivitiesInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "PerksActivitiesInfo", Nilable = false },
			},
		},
		{
			Name = "GetPerksActivitiesPendingCompletion",
			Type = "Function",

			Returns =
			{
				{ Name = "pending", Type = "PerksActivitiesPending", Nilable = false },
			},
		},
		{
			Name = "GetPerksActivityChatLink",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "perksActivityID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "link", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetPerksActivityInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "perksActivityID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "PerksActivityInfo", Nilable = true },
			},
		},
		{
			Name = "GetPerksUIThemePrefix",
			Type = "Function",

			Returns =
			{
				{ Name = "kitPrefix", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetTrackedPerksActivities",
			Type = "Function",

			Returns =
			{
				{ Name = "trackedPerksActivities", Type = "PerksActivitiesTracked", Nilable = false },
			},
		},
		{
			Name = "RemoveTrackedPerksActivity",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "perksActivityID", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "PerksActivitiesTrackedListChanged",
			Type = "Event",
			LiteralName = "PERKS_ACTIVITIES_TRACKED_LIST_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "perksActivityID", Type = "number", Nilable = false },
				{ Name = "added", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PerksActivitiesTrackedUpdated",
			Type = "Event",
			LiteralName = "PERKS_ACTIVITIES_TRACKED_UPDATED",
			UniqueEvent = true,
		},
		{
			Name = "PerksActivitiesUpdated",
			Type = "Event",
			LiteralName = "PERKS_ACTIVITIES_UPDATED",
			UniqueEvent = true,
		},
		{
			Name = "PerksActivityCompleted",
			Type = "Event",
			LiteralName = "PERKS_ACTIVITY_COMPLETED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "perksActivityID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "PerksActivitiesInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "activePerksMonth", Type = "number", Nilable = false },
				{ Name = "displayMonthName", Type = "cstring", Nilable = false },
				{ Name = "secondsRemaining", Type = "time_t", Nilable = false },
				{ Name = "activities", Type = "table", InnerType = "PerksActivityInfo", Nilable = false },
				{ Name = "thresholds", Type = "table", InnerType = "PerksActivityThresholdInfo", Nilable = false },
			},
		},
		{
			Name = "PerksActivitiesPending",
			Type = "Structure",
			Fields =
			{
				{ Name = "pendingIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "PerksActivitiesTracked",
			Type = "Structure",
			Fields =
			{
				{ Name = "trackedIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "PerksActivityCondition",
			Type = "Structure",
			Fields =
			{
				{ Name = "isMet", Type = "bool", Nilable = false },
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "uiPriority", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PerksActivityInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "activityName", Type = "cstring", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "thresholdContributionAmount", Type = "number", Nilable = false },
				{ Name = "completed", Type = "bool", Nilable = false },
				{ Name = "inProgress", Type = "bool", Nilable = false },
				{ Name = "tracked", Type = "bool", Nilable = false },
				{ Name = "supersedes", Type = "number", Nilable = false },
				{ Name = "uiPriority", Type = "number", Nilable = false },
				{ Name = "areAllConditionsMet", Type = "bool", Nilable = false },
				{ Name = "conditions", Type = "table", InnerType = "PerksActivityCondition", Nilable = false },
				{ Name = "eventName", Type = "cstring", Nilable = true },
				{ Name = "eventStartTime", Type = "time_t", Nilable = true },
				{ Name = "eventEndTime", Type = "time_t", Nilable = true },
				{ Name = "requirementsList", Type = "table", InnerType = "CriteriaRequirement", Nilable = false },
				{ Name = "criteriaList", Type = "table", InnerType = "CriteriaRequiredValue", Nilable = false },
				{ Name = "tagNames", Type = "table", InnerType = "string", Nilable = false },
			},
		},
		{
			Name = "PerksActivityTags",
			Type = "Structure",
			Fields =
			{
				{ Name = "tagName", Type = "table", InnerType = "string", Nilable = false },
			},
		},
		{
			Name = "PerksActivityThresholdInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "thresholdOrderIndex", Type = "number", Nilable = false },
				{ Name = "currencyAwardAmount", Type = "number", Nilable = false },
				{ Name = "requiredContributionAmount", Type = "number", Nilable = false },
				{ Name = "pendingReward", Type = "bool", Nilable = false },
				{ Name = "itemReward", Type = "number", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PerksActivities);