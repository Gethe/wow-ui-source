local LobbyMatchmakerInfo =
{
	Name = "LobbyMatchmakerInfo",
	Type = "System",
	Namespace = "C_LobbyMatchmakerInfo",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "LobbyMatchmakerQueueAbandoned",
			Type = "Event",
			LiteralName = "LOBBY_MATCHMAKER_QUEUE_ABANDONED",
		},
		{
			Name = "LobbyMatchmakerQueueError",
			Type = "Event",
			LiteralName = "LOBBY_MATCHMAKER_QUEUE_ERROR",
		},
		{
			Name = "LobbyMatchmakerQueueExpired",
			Type = "Event",
			LiteralName = "LOBBY_MATCHMAKER_QUEUE_EXPIRED",
		},
		{
			Name = "LobbyMatchmakerQueuePopped",
			Type = "Event",
			LiteralName = "LOBBY_MATCHMAKER_QUEUE_POPPED",
		},
		{
			Name = "LobbyMatchmakerQueueStatusUpdate",
			Type = "Event",
			LiteralName = "LOBBY_MATCHMAKER_QUEUE_STATUS_UPDATE",
		},
	},

	Tables =
	{
		{
			Name = "PlunderstormQueueState",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "PlunderstormQueueState", EnumValue = 0 },
				{ Name = "Queued", Type = "PlunderstormQueueState", EnumValue = 1 },
				{ Name = "Proposed", Type = "PlunderstormQueueState", EnumValue = 2 },
				{ Name = "Suspended", Type = "PlunderstormQueueState", EnumValue = 3 },
			},
		},
		{
			Name = "LobbyMatchmakerQueueInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "isQueueActive", Type = "bool", Nilable = false, Default = false },
				{ Name = "playlistEntryID", Type = "PartyPlaylistEntry", Nilable = false },
				{ Name = "queueState", Type = "PlunderstormQueueState", Nilable = false },
				{ Name = "queueStartTime", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LobbyMatchmakerInfo);