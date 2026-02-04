local SpellDiminishUI =
{
	Name = "SpellDiminishUI",
	Type = "System",
	Namespace = "C_SpellDiminish",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetAllSpellDiminishCategories",
			Type = "Function",
			RequiresSpellDiminishUI = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "ruleset", Type = "SpellDiminishRuleset", Nilable = true },
			},

			Returns =
			{
				{ Name = "categories", Type = "table", InnerType = "SpellDiminishCategoryInfo", Nilable = false },
			},
		},
		{
			Name = "GetSpellDiminishCategoryInfo",
			Type = "Function",
			RequiresSpellDiminishUI = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "category", Type = "SpellDiminishCategory", Nilable = false },
			},

			Returns =
			{
				{ Name = "categoryInfo", Type = "SpellDiminishCategoryInfo", Nilable = true },
			},
		},
		{
			Name = "IsSystemSupported",
			Type = "Function",

			Returns =
			{
				{ Name = "isSystemSupported", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldTrackSpellDiminishCategory",
			Type = "Function",
			RequiresSpellDiminishUI = true,
			SecretReturns = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "category", Type = "SpellDiminishCategory", Nilable = false },
				{ Name = "ruleset", Type = "SpellDiminishRuleset", Nilable = false },
			},

			Returns =
			{
				{ Name = "isTracked", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "UnitSpellDiminishCategoryStateUpdated",
			Type = "Event",
			LiteralName = "UNIT_SPELL_DIMINISH_CATEGORY_STATE_UPDATED",
			SecretPayloads = true,
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "trackerInfo", Type = "SpellDiminishTrackerInfo", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "SpellDiminishCategoryInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "category", Type = "SpellDiminishCategory", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = true },
			},
		},
		{
			Name = "SpellDiminishTrackerInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "category", Type = "SpellDiminishCategory", Nilable = false },
				{ Name = "startTime", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
				{ Name = "showCountdown", Type = "bool", Nilable = false },
				{ Name = "isImmune", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SpellDiminishUI);