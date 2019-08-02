local QuestSession =
{
	Name = "QuestSession",
	Type = "System",
	Namespace = "C_QuestSession",

	Functions =
	{
		{
			Name = "Exists",
			Type = "Function",

			Returns =
			{
				{ Name = "exists", Type = "bool", Nilable = false },
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
			Name = "GetSessionJoinRequestDetails",
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
			Name = "RequestSessionDrop",
			Type = "Function",
		},
		{
			Name = "RequestSessionJoin",
			Type = "Function",
		},
		{
			Name = "RequestSessionStart",
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
			Name = "SendSessionJoinRequestResponse",
			Type = "Function",

			Arguments =
			{
				{ Name = "requesterGUID", Type = "string", Nilable = false },
				{ Name = "accept", Type = "bool", Nilable = false },
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
			Name = "QuestSessionJoinRequest",
			Type = "Event",
			LiteralName = "QUEST_SESSION_JOIN_REQUEST",
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
			Name = "QuestSessionMemberJoinResponse",
			Type = "Event",
			LiteralName = "QUEST_SESSION_MEMBER_JOIN_RESPONSE",
			Payload =
			{
				{ Name = "guid", Type = "string", Nilable = false },
				{ Name = "response", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "QuestSessionMemberStartResponse",
			Type = "Event",
			LiteralName = "QUEST_SESSION_MEMBER_START_RESPONSE",
			Payload =
			{
				{ Name = "guid", Type = "string", Nilable = false },
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
				{ Name = "guid", Type = "string", Nilable = false },
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
				{ Name = "guid", Type = "string", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(QuestSession);