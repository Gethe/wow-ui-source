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
				{ Name = "unitToken", Type = "cstring", Nilable = false },
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
				{ Name = "unitToken", Type = "cstring", Nilable = false },
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "filter", Type = "cstring", Nilable = true },
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
				{ Name = "unitToken", Type = "cstring", Nilable = false },
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
				{ Name = "unitToken", Type = "cstring", Nilable = false },
				{ Name = "spellName", Type = "cstring", Nilable = false },
				{ Name = "filter", Type = "cstring", Nilable = true },
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
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
				{ Name = "filter", Type = "cstring", Nilable = true },
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
				{ Name = "unitToken", Type = "cstring", Nilable = false },
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "filter", Type = "cstring", Nilable = true },
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
				{ Name = "unitToken", Type = "cstring", Nilable = false },
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "filter", Type = "cstring", Nilable = true },
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
			Name = "IsAuraFilteredOutByInstanceID",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitToken", Type = "cstring", Nilable = false },
				{ Name = "auraInstanceID", Type = "number", Nilable = false },
				{ Name = "filterFlags", Type = "cstring", Nilable = false },
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
				{ Name = "unitToken", Type = "cstring", Nilable = false },
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