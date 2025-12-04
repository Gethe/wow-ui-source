local CombatLogInternal =
{
	Name = "CombatLogInternal",
	Type = "System",
	Namespace = "C_CombatLogInternal",

	Functions =
	{
		{
			Name = "GetCurrentEventInfo",
			Type = "Function",

			Returns =
			{
			},
		},
	},

	Events =
	{
		{
			Name = "CombatLogEventInternalUnfiltered",
			Type = "Event",
			LiteralName = "COMBAT_LOG_EVENT_INTERNAL_UNFILTERED",
			SynchronousEvent = true,
			CallbackEvent = true,
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(CombatLogInternal);