local NeighborhoodInitiative =
{
	Name = "NeighborhoodInitiative",
	Type = "System",
	Namespace = "C_NeighborhoodInitiative",

	Functions =
	{
		{
			Name = "AddTrackedInitiativeTask",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "initiativeTaskID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetInitiativeActivityLogInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "InitiativeActivityLogInfo", Nilable = true },
			},
		},
		{
			Name = "GetInitiativeTaskChatLink",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "initiativeTaskID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "link", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetInitiativeTaskInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "initiativeTaskID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "InitiativeTaskInfo", Nilable = true },
			},
		},
		{
			Name = "GetNeighborhoodInitiativeInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "NeighborhoodInitiativeInfo", Nilable = true },
			},
		},
		{
			Name = "GetTrackedInitiativeTasks",
			Type = "Function",

			Returns =
			{
				{ Name = "trackedInitiativeTasks", Type = "InitiativeTasksTracked", Nilable = false },
			},
		},
		{
			Name = "IsInitiativeEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsViewingActiveNeighborhood",
			Type = "Function",

			Returns =
			{
				{ Name = "isViewingActiveNeighborhood", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RemoveTrackedInitiativeTask",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "initiativeTaskID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RequestNeighborhoodInitiativeInfo",
			Type = "Function",
		},
		{
			Name = "SetActiveNeighborhood",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "neighborhoodGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "SetViewingNeighborhood",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "neighborhoodGUID", Type = "WOWGUID", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "InitiativeActivityLogUpdated",
			Type = "Event",
			LiteralName = "INITIATIVE_ACTIVITY_LOG_UPDATED",
		},
		{
			Name = "InitiativeTaskCompleted",
			Type = "Event",
			LiteralName = "INITIATIVE_TASK_COMPLETED",
			Payload =
			{
				{ Name = "initiativeTaskID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "InitiativeTasksTrackedListChanged",
			Type = "Event",
			LiteralName = "INITIATIVE_TASKS_TRACKED_LIST_CHANGED",
			Payload =
			{
				{ Name = "initiativeTaskID", Type = "number", Nilable = false },
				{ Name = "added", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "InitiativeTasksTrackedUpdated",
			Type = "Event",
			LiteralName = "INITIATIVE_TASKS_TRACKED_UPDATED",
		},
		{
			Name = "NeighborhoodInitiativeUpdated",
			Type = "Event",
			LiteralName = "NEIGHBORHOOD_INITIATIVE_UPDATED",
		},
	},

	Tables =
	{
		{
			Name = "InitiativeActivityLogEntry",
			Type = "Structure",
			Fields =
			{
				{ Name = "taskID", Type = "number", Nilable = false },
				{ Name = "playerName", Type = "string", Nilable = false },
				{ Name = "taskName", Type = "cstring", Nilable = false },
				{ Name = "completionTime", Type = "time_t", Nilable = false },
				{ Name = "amount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "InitiativeActivityLogInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "isLoaded", Type = "bool", Nilable = false },
				{ Name = "neighborhoodGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "taskActivity", Type = "table", InnerType = "InitiativeActivityLogEntry", Nilable = false },
			},
		},
		{
			Name = "InitiativeMilestoneInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "milestoneOrderIndex", Type = "number", Nilable = false },
				{ Name = "requiredContributionAmount", Type = "number", Nilable = false },
				{ Name = "rewards", Type = "table", InnerType = "InitiativeMilestoneRewardInfo", Nilable = false },
			},
		},
		{
			Name = "InitiativeMilestoneRewardInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "title", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "decorID", Type = "number", Nilable = false },
				{ Name = "decorQuantity", Type = "number", Nilable = false },
				{ Name = "favor", Type = "number", Nilable = false },
				{ Name = "money", Type = "WOWMONEY", Nilable = false },
			},
		},
		{
			Name = "InitiativeTaskInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "taskName", Type = "cstring", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "progressContributionAmount", Type = "number", Nilable = false },
				{ Name = "tracked", Type = "bool", Nilable = false },
				{ Name = "supersedes", Type = "number", Nilable = false },
				{ Name = "timesCompleted", Type = "number", Nilable = false },
				{ Name = "completed", Type = "bool", Nilable = false },
				{ Name = "inProgress", Type = "bool", Nilable = false },
				{ Name = "taskType", Type = "NeighborhoodInitiativeTaskType", Nilable = false },
				{ Name = "sortOrder", Type = "number", Nilable = false },
				{ Name = "requirementsList", Type = "table", InnerType = "CriteriaRequirement", Nilable = false },
				{ Name = "criteriaList", Type = "table", InnerType = "CriteriaRequiredValue", Nilable = false },
			},
		},
		{
			Name = "InitiativeTasksTracked",
			Type = "Structure",
			Fields =
			{
				{ Name = "trackedIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "NeighborhoodInitiativeInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "isLoaded", Type = "bool", Nilable = false },
				{ Name = "neighborhoodGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "initiativeID", Type = "number", Nilable = false },
				{ Name = "currentCycleID", Type = "number", Nilable = false },
				{ Name = "progressRequired", Type = "number", Nilable = false },
				{ Name = "currentProgress", Type = "number", Nilable = false },
				{ Name = "playerTotalContribution", Type = "number", Nilable = false },
				{ Name = "duration", Type = "time_t", Nilable = false },
				{ Name = "tasks", Type = "table", InnerType = "InitiativeTaskInfo", Nilable = false },
				{ Name = "milestones", Type = "table", InnerType = "InitiativeMilestoneInfo", Nilable = false },
				{ Name = "title", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(NeighborhoodInitiative);