local SecretPredicateAPI =
{
	Name = "SecretUtil",
	Type = "System",
	Namespace = "C_Secrets",
	Environment = "All",
	Documentation = { "'How is it a secret if we can C it?'" },

	Functions =
	{
		{
			Name = "HasSecretRestrictions",
			Type = "Function",
			Documentation = { "Returns true if this client build has secret value restrictions enabled. If false, all APIs that are tagged as potentially returning secrets will never do so." },

			Returns =
			{
				{ Name = "hasSecretRestrictions", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldActionCooldownBeSecret",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if a given action bar slot ID will produce secret values for cooldowns if queried." },

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isCooldownSecret", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldAurasBeSecret",
			Type = "Function",
			Documentation = { "Returns true if queries for aura data will generally produce secret values." },

			Returns =
			{
				{ Name = "hasSecretAuras", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldCooldownsBeSecret",
			Type = "Function",
			Documentation = { "Returns true if queries for cooldown data will generally produce secret values." },

			Returns =
			{
				{ Name = "hasSecretCooldowns", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldSpellAuraBeSecret",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if a given spell identifier would, if applied as an aura, produce secret values when queried." },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAuraSecret", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldSpellBookItemCooldownBeSecret",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if a given spellbook item will produce secret values for cooldowns if queried." },

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "isCooldownSecret", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldSpellCooldownBeSecret",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if a given spell identifier will produce secret values for cooldowns if queried." },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "isCooldownSecret", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldUnitAuraIndexBeSecret",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if a given aura index will produce secret values if queried." },

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "filter", Type = "AuraFilters", Nilable = true },
			},

			Returns =
			{
				{ Name = "isAuraSecret", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldUnitAuraInstanceBeSecret",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if a given aura instance ID will produce secret values if queried." },

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "auraInstanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAuraSecret", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldUnitAuraSlotBeSecret",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if a given aura slot ID will produce secret values if queried." },

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAuraSecret", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldUnitComparisonBeSecret",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if queries that compare units will produce secret values." },

			Arguments =
			{
				{ Name = "unit1", Type = "UnitToken", Nilable = false },
				{ Name = "unit2", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "isUnitComparisonSecret", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldUnitIdentityBeSecret",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if queries for unit identity (such as name or GUID) will produce secret values." },

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "isUnitIdentitySecret", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldUnitPowerBeSecret",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if queries for unit power will produce secret values." },

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "powerType", Type = "PowerType", Nilable = true },
			},

			Returns =
			{
				{ Name = "isUnitPowerSecret", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldUnitPowerMaxBeSecret",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if queries for maximum unit power will produce secret values." },

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "powerType", Type = "PowerType", Nilable = true },
			},

			Returns =
			{
				{ Name = "isUnitPowerMaxSecret", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldUnitSpellCastBeSecret",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if queries for spell casting information for a unit would produce secret values when queried." },

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "isSpellCastSecret", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldUnitSpellCastingBeSecret",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if queries for spell casting information for a specific unit will generally produce secret values." },

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "isSpellCastingSecret", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(SecretPredicateAPI);