local Spell =
{
	Name = "Spell",
	Type = "System",
	Namespace = "C_Spell",

	Functions =
	{
		{
			Name = "DoesSpellExist",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellExists", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSpellDataCached",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isCached", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestLoadSpellData",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "SpellDataLoadResult",
			Type = "Event",
			LiteralName = "SPELL_DATA_LOAD_RESULT",
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Spell);