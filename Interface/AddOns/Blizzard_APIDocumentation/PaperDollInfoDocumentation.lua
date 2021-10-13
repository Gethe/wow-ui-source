local PaperDollInfo =
{
	Name = "PaperDollInfo",
	Type = "System",
	Namespace = "C_PaperDollInfo",

	Functions =
	{
		{
			Name = "GetArmorEffectiveness",
			Type = "Function",

			Arguments =
			{
				{ Name = "armor", Type = "number", Nilable = false },
				{ Name = "attackerLevel", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "effectiveness", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetArmorEffectivenessAgainstTarget",
			Type = "Function",

			Arguments =
			{
				{ Name = "armor", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "effectiveness", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetInspectAzeriteItemEmpoweredChoices",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "string", Nilable = false },
				{ Name = "equipmentSlotIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "azeritePowerIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetInspectItemLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "equippedItemLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMinItemLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "minItemLevel", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetStaggerPercentage",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "stagger", Type = "number", Nilable = false },
				{ Name = "staggerAgainstTarget", Type = "number", Nilable = true },
			},
		},
		{
			Name = "OffhandHasShield",
			Type = "Function",

			Returns =
			{
				{ Name = "offhandHasShield", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "OffhandHasWeapon",
			Type = "Function",

			Returns =
			{
				{ Name = "offhandHasWeapon", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AvoidanceUpdate",
			Type = "Event",
			LiteralName = "AVOIDANCE_UPDATE",
		},
		{
			Name = "CharacterPointsChanged",
			Type = "Event",
			LiteralName = "CHARACTER_POINTS_CHANGED",
			Payload =
			{
				{ Name = "change", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CharacterUpgradeSpellTierSet",
			Type = "Event",
			LiteralName = "CHARACTER_UPGRADE_SPELL_TIER_SET",
			Payload =
			{
				{ Name = "tierIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CombatRatingUpdate",
			Type = "Event",
			LiteralName = "COMBAT_RATING_UPDATE",
		},
		{
			Name = "DisableXpGain",
			Type = "Event",
			LiteralName = "DISABLE_XP_GAIN",
		},
		{
			Name = "EnableXpGain",
			Type = "Event",
			LiteralName = "ENABLE_XP_GAIN",
		},
		{
			Name = "EquipBindConfirm",
			Type = "Event",
			LiteralName = "EQUIP_BIND_CONFIRM",
			Payload =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},
		},
		{
			Name = "InspectHonorUpdate",
			Type = "Event",
			LiteralName = "INSPECT_HONOR_UPDATE",
		},
		{
			Name = "InspectReady",
			Type = "Event",
			LiteralName = "INSPECT_READY",
			Payload =
			{
				{ Name = "inspecteeGUID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "LifestealUpdate",
			Type = "Event",
			LiteralName = "LIFESTEAL_UPDATE",
		},
		{
			Name = "MasteryUpdate",
			Type = "Event",
			LiteralName = "MASTERY_UPDATE",
		},
		{
			Name = "PetSpellPowerUpdate",
			Type = "Event",
			LiteralName = "PET_SPELL_POWER_UPDATE",
		},
		{
			Name = "PlayerAvgItemLevelUpdate",
			Type = "Event",
			LiteralName = "PLAYER_AVG_ITEM_LEVEL_UPDATE",
		},
		{
			Name = "PlayerEquipmentChanged",
			Type = "Event",
			LiteralName = "PLAYER_EQUIPMENT_CHANGED",
			Payload =
			{
				{ Name = "equipmentSlot", Type = "number", Nilable = false },
				{ Name = "hasCurrent", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PvpPowerUpdate",
			Type = "Event",
			LiteralName = "PVP_POWER_UPDATE",
		},
		{
			Name = "SpeedUpdate",
			Type = "Event",
			LiteralName = "SPEED_UPDATE",
		},
		{
			Name = "SpellPowerChanged",
			Type = "Event",
			LiteralName = "SPELL_POWER_CHANGED",
		},
		{
			Name = "SturdinessUpdate",
			Type = "Event",
			LiteralName = "STURDINESS_UPDATE",
		},
		{
			Name = "UpdateFaction",
			Type = "Event",
			LiteralName = "UPDATE_FACTION",
		},
		{
			Name = "UpdateInventoryAlerts",
			Type = "Event",
			LiteralName = "UPDATE_INVENTORY_ALERTS",
		},
		{
			Name = "UpdateInventoryDurability",
			Type = "Event",
			LiteralName = "UPDATE_INVENTORY_DURABILITY",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(PaperDollInfo);