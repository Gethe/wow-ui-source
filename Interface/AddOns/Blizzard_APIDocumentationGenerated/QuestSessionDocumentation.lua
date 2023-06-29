local QuestSession =
{
	Name = "QuestSession",
	Type = "System",
	Namespace = "C_QuestSession",

	Functions =
	{
		{
			Name = "CanStart",
			Type = "Function",

			Returns =
			{
				{ Name = "allowed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanStop",
			Type = "Function",

			Returns =
			{
				{ Name = "allowed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Exists",
			Type = "Function",

			Returns =
			{
				{ Name = "exists", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAvailableSessionCommand",
			Type = "Function",

			Returns =
			{
				{ Name = "command", Type = "QuestSessionCommand", Nilable = false },
			},
		},
		{
			Name = "GetPendingCommand",
			Type = "Function",

			Returns =
			{
				{ Name = "command", Type = "QuestSessionCommand", Nilable = false },
			},
		},
		{
			Name = "GetProposedMaxLevelForSession",
			Type = "Function",

			Returns =
			{
				{ Name = "proposedMaxLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSessionBeginDetails",
			Type = "Function",

			Returns =
			{
				{ Name = "details", Type = "QuestSessionPlayerDetails", Nilable = true },
			},
		},
		{
			Name = "GetSuperTrackedQuest",
			Type = "Function",

			Returns =
			{
				{ Name = "questID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "HasJoined",
			Type = "Function",

			Returns =
			{
				{ Name = "hasJoined", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasPendingCommand",
			Type = "Function",

			Returns =
			{
				{ Name = "hasPendingCommand", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestSessionStart",
			Type = "Function",
		},
		{
			Name = "RequestSessionStop",
			Type = "Function",
		},
		{
			Name = "SendSessionBeginResponse",
			Type = "Function",

			Arguments =
			{
				{ Name = "beginSession", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetQuestIsSuperTracked",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "superTrack", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "QuestSessionCreated",
			Type = "Event",
			LiteralName = "QUEST_SESSION_CREATED",
		},
		{
			Name = "QuestSessionDestroyed",
			Type = "Event",
			LiteralName = "QUEST_SESSION_DESTROYED",
		},
		{
			Name = "QuestSessionEnabledStateChanged",
			Type = "Event",
			LiteralName = "QUEST_SESSION_ENABLED_STATE_CHANGED",
			Payload =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "QuestSessionJoined",
			Type = "Event",
			LiteralName = "QUEST_SESSION_JOINED",
		},
		{
			Name = "QuestSessionLeft",
			Type = "Event",
			LiteralName = "QUEST_SESSION_LEFT",
		},
		{
			Name = "QuestSessionMemberConfirm",
			Type = "Event",
			LiteralName = "QUEST_SESSION_MEMBER_CONFIRM",
		},
		{
			Name = "QuestSessionMemberStartResponse",
			Type = "Event",
			LiteralName = "QUEST_SESSION_MEMBER_START_RESPONSE",
			Payload =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "response", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "QuestSessionNotification",
			Type = "Event",
			LiteralName = "QUEST_SESSION_NOTIFICATION",
			Payload =
			{
				{ Name = "result", Type = "QuestSessionResult", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "QuestSessionPlayerDetails",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(QuestSession);