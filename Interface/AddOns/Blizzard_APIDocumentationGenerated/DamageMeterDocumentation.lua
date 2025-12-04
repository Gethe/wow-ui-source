local DamageMeter =
{
	Name = "DamageMeter",
	Type = "System",
	Namespace = "C_DamageMeter",

	Functions =
	{
		{
			Name = "GetAvailableCombatSessions",
			Type = "Function",
			Documentation = { "Returns a list of combat sessions currently being tracked." },

			Returns =
			{
				{ Name = "availableSessions", Type = "table", InnerType = "DamageMeterAvailableCombatSession", Nilable = false },
			},
		},
		{
			Name = "GetCombatSessionFromID",
			Type = "Function",
			SecretWhenInCombat = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the data for the player's combat session with the specified ID." },

			Arguments =
			{
				{ Name = "sessionID", Type = "number", Nilable = false },
				{ Name = "type", Type = "DamageMeterType", Nilable = false },
			},

			Returns =
			{
				{ Name = "session", Type = "DamageMeterCombatSession", Nilable = false },
			},
		},
		{
			Name = "GetCombatSessionFromType",
			Type = "Function",
			SecretWhenInCombat = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the data for the player's current combat session." },

			Arguments =
			{
				{ Name = "sessionType", Type = "DamageMeterSessionType", Nilable = false },
				{ Name = "type", Type = "DamageMeterType", Nilable = false },
			},

			Returns =
			{
				{ Name = "session", Type = "DamageMeterCombatSession", Nilable = false },
			},
		},
		{
			Name = "GetCombatSessionSourceFromID",
			Type = "Function",
			SecretWhenInCombat = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the data for a single source (unit) in the player's current combat session with the specified ID." },

			Arguments =
			{
				{ Name = "sessionID", Type = "number", Nilable = false },
				{ Name = "type", Type = "DamageMeterType", Nilable = false },
				{ Name = "sourceGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "sessionSource", Type = "DamageMeterCombatSessionSource", Nilable = false },
			},
		},
		{
			Name = "GetCombatSessionSourceFromType",
			Type = "Function",
			SecretWhenInCombat = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the data for a single source (unit) in the player's current combat session." },

			Arguments =
			{
				{ Name = "sessionType", Type = "DamageMeterSessionType", Nilable = false },
				{ Name = "type", Type = "DamageMeterType", Nilable = false },
				{ Name = "sourceGUID", Type = "WOWGUID", Nilable = false },
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
		{
			Name = "ResetAllCombatSessions",
			Type = "Function",
			Documentation = { "Clears the data for all the player's combat sessions." },
		},
	},

	Events =
	{
		{
			Name = "DamageMeterCombatSessionUpdated",
			Type = "Event",
			LiteralName = "DAMAGE_METER_COMBAT_SESSION_UPDATED",
			UniqueEvent = true,
			Payload =
			{
				{ Name = "type", Type = "DamageMeterType", Nilable = false },
				{ Name = "sessionID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "DamageMeterCurrentSessionUpdated",
			Type = "Event",
			LiteralName = "DAMAGE_METER_CURRENT_SESSION_UPDATED",
			UniqueEvent = true,
		},
		{
			Name = "DamageMeterReset",
			Type = "Event",
			LiteralName = "DAMAGE_METER_RESET",
			UniqueEvent = true,
		},
	},

	Tables =
	{
		{
			Name = "DamageMeterAvailableCombatSession",
			Type = "Structure",
			Documentation = { "Data for a combat session currently being tracked." },
			Fields =
			{
				{ Name = "sessionID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
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
				{ Name = "sourceGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "classFilename", Type = "cstring", Nilable = false },
				{ Name = "totalAmount", Type = "number", Nilable = false },
				{ Name = "amountPerSecond", Type = "number", Nilable = false },
				{ Name = "isLocalPlayer", Type = "bool", Nilable = false },
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
				{ Name = "amountPerSecond", Type = "number", Nilable = false },
				{ Name = "creatureName", Type = "cstring", Nilable = false },
				{ Name = "combatSpellDetails", Type = "DamageMeterCombatSpellUnitDetails", Nilable = false },
			},
		},
		{
			Name = "DamageMeterCombatSpellUnitDetails",
			Type = "Structure",
			Documentation = { "Amount for a single target for all casts of the same spellID by a single source (unit) in a combat session." },
			Fields =
			{
				{ Name = "unitName", Type = "cstring", Nilable = false },
				{ Name = "unitClassFilename", Type = "cstring", Nilable = false },
				{ Name = "classification", Type = "cstring", Nilable = false },
				{ Name = "amount", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(DamageMeter);