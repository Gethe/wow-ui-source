local UnitAura =
{
	Name = "UnitAuras",
	Type = "System",
	Namespace = "C_UnitAuras",

	Functions =
	{
		{
			Name = "GetAuraDataByAuraInstanceID",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
				{ Name = "auraInstanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "aura", Type = "table", Nilable = true },
			},
		},
		{
			Name = "GetAuraDataBySlot",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "aura", Type = "table", Nilable = true },
			},
		},
		{
			Name = "GetCooldownAuraBySpellID",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "cooldownSpellID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetPlayerAuraBySpellID",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "aura", Type = "table", Nilable = true },
			},
		},
		{
			Name = "IsAuraFilteredOutByInstanceID",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
				{ Name = "auraInstanceID", Type = "number", Nilable = false },
				{ Name = "filterFlags", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "isFiltered", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "WantsAlteredForm",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "wantsAlteredForm", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "UnitAura",
			Type = "Event",
			LiteralName = "UNIT_AURA",
			Payload =
			{
				{ Name = "unitTarget", Type = "string", Nilable = false },
				{ Name = "updateInfo", Type = "UnitAuraUpdateInfo", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(UnitAura);