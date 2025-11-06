local RestrictedActions =
{
	Name = "RestrictedActions",
	Type = "System",

	Functions =
	{
		{
			Name = "GetRestrictedActionStatus",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Queries the status of an addon restriction." },

			Arguments =
			{
				{ Name = "actionType", Type = "RestrictedActionType", Nilable = false },
			},

			Returns =
			{
				{ Name = "isRestricted", Type = "bool", Nilable = false, Documentation = { "If true, the queried restriction will be actively enforced." } },
				{ Name = "reason", Type = "RestrictedActionReason", Nilable = true, Documentation = { "Additional context for the restriction if enforced. May be nil if enforcement reasons are unspecified." } },
			},
		},
		{
			Name = "InCombatLockdown",
			Type = "Function",

			Returns =
			{
				{ Name = "inCombatLockdown", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AddonActionBlocked",
			Type = "Event",
			LiteralName = "ADDON_ACTION_BLOCKED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "isTainted", Type = "cstring", Nilable = false },
				{ Name = "function", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "AddonActionForbidden",
			Type = "Event",
			LiteralName = "ADDON_ACTION_FORBIDDEN",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "isTainted", Type = "cstring", Nilable = false },
				{ Name = "function", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "MacroActionBlocked",
			Type = "Event",
			LiteralName = "MACRO_ACTION_BLOCKED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "function", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "MacroActionForbidden",
			Type = "Event",
			LiteralName = "MACRO_ACTION_FORBIDDEN",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "function", Type = "cstring", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "RestrictedActionReason",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "InCombat", Type = "RestrictedActionReason", EnumValue = 0 },
				{ Name = "ActiveEncounter", Type = "RestrictedActionReason", EnumValue = 1 },
				{ Name = "ActiveMythicKeystoneOrChallengeMode", Type = "RestrictedActionReason", EnumValue = 2 },
				{ Name = "ActivePvPMatch", Type = "RestrictedActionReason", EnumValue = 3 },
				{ Name = "RestrictedMap", Type = "RestrictedActionReason", EnumValue = 4 },
			},
		},
		{
			Name = "RestrictedActionType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "SecretAuras", Type = "RestrictedActionType", EnumValue = 0 },
				{ Name = "SecretCooldowns", Type = "RestrictedActionType", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(RestrictedActions);