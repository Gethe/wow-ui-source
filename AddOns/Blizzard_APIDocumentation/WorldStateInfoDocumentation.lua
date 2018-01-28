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
				{ Name = "timerType", Type = "number", Nilable = false },
				{ Name = "timeRemaining", Type = "number", Nilable = false },
				{ Name = "totalTime", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UpdateWorldStates",
			Type = "Event",
			LiteralName = "UPDATE_WORLD_STATES",
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
		{
			Name = "WorldStateUiTimerUpdate",
			Type = "Event",
			LiteralName = "WORLD_STATE_UI_TIMER_UPDATE",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(WorldStateInfo);