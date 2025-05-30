local AssistedCombat =
{
	Name = "AssistedCombat",
	Type = "System",
	Namespace = "C_AssistedCombat",

	Functions =
	{
		{
			Name = "GetActionSpell",
			Type = "Function",

			Returns =
			{
				{ Name = "spellID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetNextCastSpell",
			Type = "Function",

			Arguments =
			{
				{ Name = "checkForVisibleButton", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "spellID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetRotationSpells",
			Type = "Function",

			Returns =
			{
				{ Name = "spellIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "IsAvailable",
			Type = "Function",

			Returns =
			{
				{ Name = "isAvailable", Type = "bool", Nilable = false },
				{ Name = "failureReason", Type = "string", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AssistedCombatActionSpellCast",
			Type = "Event",
			LiteralName = "ASSISTED_COMBAT_ACTION_SPELL_CAST",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(AssistedCombat);