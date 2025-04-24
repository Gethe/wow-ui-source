local WorldStateInfo =
{
	Name = "WorldStateInfo",
	Type = "System",
	Namespace = "C_WorldStateInfo",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "CancelPlayerCountdown",
			Type = "Event",
			LiteralName = "CANCEL_PLAYER_COUNTDOWN",
			Payload =
			{
				{ Name = "initiatedBy", Type = "WOWGUID", Nilable = false },
				{ Name = "informChat", Type = "bool", Nilable = false },
				{ Name = "initiatedByName", Type = "string", Nilable = true },
			},
		},
		{
			Name = "StartPlayerCountdown",
			Type = "Event",
			LiteralName = "START_PLAYER_COUNTDOWN",
			Payload =
			{
				{ Name = "initiatedBy", Type = "WOWGUID", Nilable = false },
				{ Name = "timeRemaining", Type = "time_t", Nilable = false },
				{ Name = "totalTime", Type = "time_t", Nilable = false },
				{ Name = "informChat", Type = "bool", Nilable = false },
				{ Name = "initiatedByName", Type = "string", Nilable = true },
			},
		},
		{
			Name = "StartTimer",
			Type = "Event",
			LiteralName = "START_TIMER",
			Payload =
			{
				{ Name = "timerType", Type = "StartTimerType", Nilable = false },
				{ Name = "timeRemaining", Type = "time_t", Nilable = false },
				{ Name = "totalTime", Type = "time_t", Nilable = false },
			},
		},
		{
			Name = "StopTimerOfType",
			Type = "Event",
			LiteralName = "STOP_TIMER_OF_TYPE",
			Payload =
			{
				{ Name = "timerType", Type = "StartTimerType", Nilable = false },
			},
		},
		{
			Name = "WorldStateTimerStart",
			Type = "Event",
			LiteralName = "WORLD_STATE_TIMER_START",
			Payload =
			{
				{ Name = "timerID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "WorldStateTimerStop",
			Type = "Event",
			LiteralName = "WORLD_STATE_TIMER_STOP",
			Payload =
			{
				{ Name = "timerID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(WorldStateInfo);