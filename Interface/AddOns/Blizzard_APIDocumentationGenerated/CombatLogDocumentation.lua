local CombatLog =
{
	Name = "CombatLog",
	Type = "System",
	Namespace = "C_CombatLog",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "CombatLogEvent",
			Type = "Event",
			LiteralName = "COMBAT_LOG_EVENT",
		},
		{
			Name = "CombatLogEventUnfiltered",
			Type = "Event",
			LiteralName = "COMBAT_LOG_EVENT_UNFILTERED",
		},
		{
			Name = "CombatTextUpdate",
			Type = "Event",
			LiteralName = "COMBAT_TEXT_UPDATE",
			Payload =
			{
				{ Name = "combatTextType", Type = "cstring", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(CombatLog);