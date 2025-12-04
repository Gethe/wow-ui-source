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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "AuraIsBigDefensive",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isBigDefensive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "AuraIsPrivate",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",

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
			Name = "GetAuraBaseDuration",
			Type = "Function",
			SecretWhenAuraInstanceRestricted = true,
			SecretArguments = "AllowedWhenTainted",
			Documentation = { "Returns the base duration of the given spell (or aura). Takes an optional spellID to use as the new duration if that cannot be derived from the aura, if that value isn't supplied the aura's spellID will be used" },

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "auraInstanceID", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "newDuration", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetAuraDataByAuraInstanceID",
			Type = "Function",
			SecretWhenAuraDataRestricted = true,
			SecretArguments = "AllowedWhenTainted",

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
			SecretWhenAuraDataRestricted = true,
			SecretArguments = "AllowedWhenTainted",

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
			SecretWhenAuraDataRestricted = true,
			SecretArguments = "AllowedWhenTainted",

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
			SecretWhenAuraDataRestricted = true,
			RequiresNonSecretAuraSpellName = true,
			SecretArguments = "AllowedWhenTainted",

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
			Name = "GetAuraDurationRemainingByAuraInstanceID",
			Type = "Function",
			SecretWhenAuraInstanceRestricted = true,
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "auraInstanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "durationRemaining", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetAuraSlots",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretWhenAuraDataRestricted = true,
			SecretArguments = "AllowedWhenTainted",

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
			SecretArguments = "AllowedWhenTainted",

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
			SecretWhenAuraDataRestricted = true,
			SecretArguments = "AllowedWhenTainted",

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
			SecretWhenAuraDataRestricted = true,
			RequiresNonSecretAuraSpellID = true,
			SecretArguments = "AllowedWhenTainted",

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
			Name = "GetRefreshExtendedDuration",
			Type = "Function",
			SecretWhenAuraInstanceRestricted = true,
			SecretArguments = "AllowedWhenTainted",
			Documentation = { "Returns the client-predicted new duration of this aura if it were cast again right now. Takes an optional spellID to use as the new duration if that cannot be derived from the aura, if that value isn't supplied the aura's spellID will be used" },

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "auraInstanceID", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "newDuration", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetUnitAuraBySpellID",
			Type = "Function",
			SecretWhenAuraDataRestricted = true,
			RequiresNonSecretAuraSpellID = true,
			SecretArguments = "AllowedWhenTainted",
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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "filter", Type = "AuraFilters", Nilable = false },
				{ Name = "maxCount", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "auras", Type = "table", InnerType = "AuraData", Nilable = false, ConditionalSecretContents = true },
			},
		},
		{
			Name = "IsAuraFilteredOutByInstanceID",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "anchorID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RemovePrivateAuraAppliedSound",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "privateAuraSoundID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetPrivateWarningTextAnchor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "parent", Type = "SimpleFrame", Nilable = false },
				{ Name = "anchor", Type = "AnchorBinding", Nilable = true },
			},
		},
		{
			Name = "WantsAlteredForm",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",

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
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "updateInfo", Type = "UnitAuraUpdateInfo", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(UnitAura);