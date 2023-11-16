local PlayerScript =
{
	Name = "PlayerScript",
	Type = "System",

	Functions =
	{
		{
			Name = "GetAttackPowerForStat",
			Type = "Function",

			Arguments =
			{
				{ Name = "stat", Type = "luaIndex", Nilable = false },
				{ Name = "value", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetBlockChance",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCombatRating",
			Type = "Function",

			Arguments =
			{
				{ Name = "ratingIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetCombatRatingBonus",
			Type = "Function",

			Arguments =
			{
				{ Name = "ratingIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetCombatRatingBonusForCombatRatingValue",
			Type = "Function",

			Arguments =
			{
				{ Name = "ratingIndex", Type = "luaIndex", Nilable = false },
				{ Name = "value", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetCorruption",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCorruptionResistance",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCritChance",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDodgeChance",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDodgeChanceFromAttribute",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetHaste",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMaxCombatRatingBonus",
			Type = "Function",

			Arguments =
			{
				{ Name = "ratingIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetMeleeHaste",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetModResilienceDamageReduction",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetOverrideAPBySpellPower",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetOverrideSpellPowerByAP",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetParryChance",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetParryChanceFromAttribute",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPetMeleeHaste",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPetSpellBonusDamage",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPvpPowerDamage",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPvpPowerHealing",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRangedCritChance",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRangedHaste",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetShieldBlock",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpellBonusDamage",
			Type = "Function",

			Arguments =
			{
				{ Name = "school", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetSpellBonusHealing",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpellCritChance",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpellPenetration",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HasDualWieldPenalty",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAdvancedFlyableArea",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsDualWielding",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsFlyableArea",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsGuildLeader",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsInGuild",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsInJailersTower",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsIndoors",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsInsane",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsJailersTowerLayerTimeLocked",
			Type = "Function",

			Arguments =
			{
				{ Name = "layerLevel", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "IsLoggedIn",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMounted",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsOnGroundFloorInJailersTower",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsOutOfBounds",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsOutdoors",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRangedWeapon",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsResting",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsStealthed",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PlayerCanTeleport",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(PlayerScript);