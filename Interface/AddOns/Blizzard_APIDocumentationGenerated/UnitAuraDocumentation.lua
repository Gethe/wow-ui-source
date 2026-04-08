local UnitAura =
{
	Name = "UnitAuras",
	Type = "System",
	Namespace = "C_UnitAuras",

	Functions =
	{
		{
			Name = "AddPrivateAuraAnchor",
			Type = "Function",

			Arguments =
			{
				{ Name = "args", Type = "AddPrivateAuraAnchorArgs", Nilable = false },
			},

			Returns =
			{
				{ Name = "anchorID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "AddPrivateAuraAppliedSound",
			Type = "Function",

			Arguments =
			{
				{ Name = "sound", Type = "UnitPrivateAuraAppliedSoundInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "privateAuraSoundID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "AuraIsPrivate",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isPrivate", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAuraDataByAuraInstanceID",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "auraInstanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "aura", Type = "AuraData", Nilable = true },
			},
		},
		{
			Name = "GetAuraDataByIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "filter", Type = "AuraFilters", Nilable = true },
			},

			Returns =
			{
				{ Name = "aura", Type = "AuraData", Nilable = true },
			},
		},
		{
			Name = "GetAuraDataBySlot",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "aura", Type = "AuraData", Nilable = true },
			},
		},
		{
			Name = "GetAuraDataBySpellName",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "spellName", Type = "cstring", Nilable = false },
				{ Name = "filter", Type = "AuraFilters", Nilable = true },
			},

			Returns =
			{
				{ Name = "aura", Type = "AuraData", Nilable = true },
			},
		},
		{
			Name = "GetAuraSlots",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "filter", Type = "AuraFilters", Nilable = true },
				{ Name = "maxSlots", Type = "number", Nilable = true },
				{ Name = "continuationToken", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "outContinuationToken", Type = "number", Nilable = true },
				{ Name = "slots", Type = "number", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "GetBuffDataByIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "filter", Type = "AuraFilters", Nilable = true },
			},

			Returns =
			{
				{ Name = "aura", Type = "AuraData", Nilable = true },
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
			Name = "GetDebuffDataByIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "filter", Type = "AuraFilters", Nilable = true },
			},

			Returns =
			{
				{ Name = "aura", Type = "AuraData", Nilable = true },
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
				{ Name = "aura", Type = "AuraData", Nilable = true },
			},
		},
		{
			Name = "GetUnitAuraBySpellID",
			Type = "Function",
			Documentation = { "Returns the first instance of an aura on a unit matching a given spell ID. Returns nil if no such aura is found. Additionally can return nil if querying a unit that is not visible (eg. party members on other maps)." },

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "aura", Type = "AuraData", Nilable = true },
			},
		},
		{
			Name = "GetUnitAuras",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "filter", Type = "AuraFilters", Nilable = false },
				{ Name = "maxCount", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "auras", Type = "table", InnerType = "AuraData", Nilable = false },
			},
		},
		{
			Name = "IsAuraFilteredOutByInstanceID",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "auraInstanceID", Type = "number", Nilable = false },
				{ Name = "filter", Type = "AuraFilters", Nilable = false },
			},

			Returns =
			{
				{ Name = "isFiltered", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RemovePrivateAuraAnchor",
			Type = "Function",

			Arguments =
			{
				{ Name = "anchorID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RemovePrivateAuraAppliedSound",
			Type = "Function",

			Arguments =
			{
				{ Name = "privateAuraSoundID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetPrivateWarningTextAnchor",
			Type = "Function",

			Arguments =
			{
				{ Name = "parent", Type = "SimpleFrame", Nilable = false },
				{ Name = "anchor", Type = "AnchorBinding", Nilable = true },
			},
		},
		{
			Name = "WantsAlteredForm",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
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
				{ Name = "unitTarget", Type = "UnitToken", Nilable = false },
				{ Name = "updateInfo", Type = "UnitAuraUpdateInfo", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(UnitAura);