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
			Name = "StartTimer",
			Type = "Event",
			LiteralName = "START_TIMER",
			Payload =
			{
				{ Name = "timerType", Type = "luaIndex", Nilable = false },
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
				{ Name = "timerType", Type = "luaIndex", Nilable = false },
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