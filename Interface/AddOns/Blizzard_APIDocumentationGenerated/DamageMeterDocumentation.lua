local DamageMeter =
{
	Name = "DamageMeter",
	Type = "System",
	Namespace = "C_DamageMeter",

	Functions =
	{
		{
			Name = "GetCurrentCombatSession",
			Type = "Function",
			SecretWhenInCombat = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the data for the player's current combat session." },

			Arguments =
			{
				{ Name = "type", Type = "DamageMeterType", Nilable = false },
			},

			Returns =
			{
				{ Name = "session", Type = "DamageMeterCombatSession", Nilable = false },
			},
		},
		{
			Name = "GetCurrentCombatSessionSource",
			Type = "Function",
			MayReturnNothing = true,
			SecretWhenInCombat = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the data for a single source (unit) in the player's current combat session." },

			Arguments =
			{
				{ Name = "type", Type = "DamageMeterType", Nilable = false },
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "sessionSource", Type = "DamageMeterCombatSessionSource", Nilable = false },
			},
		},
		{
			Name = "IsDamageMeterAvailable",
			Type = "Function",
			Documentation = { "Returns whether the player can enable and use the Damage Meter." },

			Returns =
			{
				{ Name = "isAvailable", Type = "bool", Nilable = false },
				{ Name = "failureReason", Type = "string", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "DamageMeterType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "DamageDone", Type = "DamageMeterType", EnumValue = 0 },
				{ Name = "Dps", Type = "DamageMeterType", EnumValue = 1 },
				{ Name = "HealingDone", Type = "DamageMeterType", EnumValue = 2 },
				{ Name = "Hps", Type = "DamageMeterType", EnumValue = 3 },
			},
		},
		{
			Name = "DamageMeterCombatSession",
			Type = "Structure",
			Documentation = { "Aggregated data for all sources (units) in a damage meter combat session." },
			Fields =
			{
				{ Name = "combatSources", Type = "table", InnerType = "DamageMeterCombatSource", Nilable = false },
				{ Name = "maxAmount", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "DamageMeterCombatSessionSource",
			Type = "Structure",
			Documentation = { "Data for a single source (unit) in a combat session." },
			Fields =
			{
				{ Name = "combatSpells", Type = "table", InnerType = "DamageMeterCombatSpell", Nilable = false },
				{ Name = "maxAmount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "DamageMeterCombatSource",
			Type = "Structure",
			Documentation = { "Aggregated data for a single source (unit) in a damage meter combat session." },
			Fields =
			{
				{ Name = "unitToken", Type = "WOWGUID", Nilable = false },
				{ Name = "totalAmount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "DamageMeterCombatSpell",
			Type = "Structure",
			Documentation = { "Aggregated data for all spells of the same ID cast by a single source (unit) in a combat session." },
			Fields =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "totalAmount", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(DamageMeter);