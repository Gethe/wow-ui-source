local CombatText =
{
	Name = "CombatText",
	Type = "System",
	Namespace = "C_CombatText",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetActiveUnit",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "unitTarget", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetCurrentEventInfo",
			Type = "Function",
			SecretReturns = true,

			Returns =
			{
			},
		},
		{
			Name = "SetActiveUnit",
			Type = "Function",
			RequiresDeclassifiedUnitIdentity = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "CombatTextUpdate",
			Type = "Event",
			LiteralName = "COMBAT_TEXT_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "combatTextType", Type = "cstring", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(CombatText);