local PaperDollInfo =
{
	Name = "PaperDollInfo",
	Type = "System",
	Namespace = "C_PaperDollInfo",

	Functions =
	{
		{
			Name = "CanAutoEquipCursorItem",
			Type = "Function",

			Returns =
			{
				{ Name = "canAutoEquip", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanCursorCanGoInSlot",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "canOccupySlot", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetArmorEffectiveness",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "equipmentSlotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "azeritePowerIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetInspectGuildInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unitString", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "achievementPoints", Type = "number", Nilable = false },
				{ Name = "numMembers", Type = "number", Nilable = false },
				{ Name = "guildName", Type = "string", Nilable = false },
				{ Name = "realmName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetInspectItemLevel",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "equippedItemLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetInspectRatedBGBlitzData",
			Type = "Function",

			Returns =
			{
				{ Name = "ratedBGBlitzData", Type = "InspectPVPData", Nilable = false },
			},
		},
		{
			Name = "GetInspectRatedBGData",
			Type = "Function",

			Returns =
			{
				{ Name = "ratedBGData", Type = "InspectRatedBGData", Nilable = false },
			},
		},
		{
			Name = "GetInspectRatedSoloShuffleData",
			Type = "Function",

			Returns =
			{
				{ Name = "ratedSoloShuffleData", Type = "InspectPVPData", Nilable = false },
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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "stagger", Type = "number", Nilable = false },
				{ Name = "staggerAgainstTarget", Type = "number", Nilable = true },
			},
		},
		{
			Name = "IsInventorySlotEnabled",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slotName", Type = "stringView", Nilable = false },
			},

			Returns =
			{
				{ Name = "isEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRangedSlotShown",
			Type = "Function",

			Returns =
			{
				{ Name = "isShown", Type = "bool", Nilable = false },
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
			SynchronousEvent = true,
		},
		{
			Name = "CharacterPointsChanged",
			Type = "Event",
			LiteralName = "CHARACTER_POINTS_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "change", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CharacterUpgradeSpellTierSet",
			Type = "Event",
			LiteralName = "CHARACTER_UPGRADE_SPELL_TIER_SET",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "tierIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CombatRatingUpdate",
			Type = "Event",
			LiteralName = "COMBAT_RATING_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "DisableXpGain",
			Type = "Event",
			LiteralName = "DISABLE_XP_GAIN",
			SynchronousEvent = true,
		},
		{
			Name = "EnableXpGain",
			Type = "Event",
			LiteralName = "ENABLE_XP_GAIN",
			SynchronousEvent = true,
		},
		{
			Name = "EquipBindConfirm",
			Type = "Event",
			LiteralName = "EQUIP_BIND_CONFIRM",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "slot", Type = "number", Nilable = false },
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},
		},
		{
			Name = "InspectHonorUpdate",
			Type = "Event",
			LiteralName = "INSPECT_HONOR_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "InspectReady",
			Type = "Event",
			LiteralName = "INSPECT_READY",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "inspecteeGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "LifestealUpdate",
			Type = "Event",
			LiteralName = "LIFESTEAL_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "MasteryUpdate",
			Type = "Event",
			LiteralName = "MASTERY_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "PetSpellPowerUpdate",
			Type = "Event",
			LiteralName = "PET_SPELL_POWER_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerAvgItemLevelUpdate",
			Type = "Event",
			LiteralName = "PLAYER_AVG_ITEM_LEVEL_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerEquipmentChanged",
			Type = "Event",
			LiteralName = "PLAYER_EQUIPMENT_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "equipmentSlot", Type = "number", Nilable = false },
				{ Name = "hasCurrent", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ProfessionEquipmentChanged",
			Type = "Event",
			LiteralName = "PROFESSION_EQUIPMENT_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
				{ Name = "isTool", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PvpPowerUpdate",
			Type = "Event",
			LiteralName = "PVP_POWER_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "SpeedUpdate",
			Type = "Event",
			LiteralName = "SPEED_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "SpellPowerChanged",
			Type = "Event",
			LiteralName = "SPELL_POWER_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "SturdinessUpdate",
			Type = "Event",
			LiteralName = "STURDINESS_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "UpdateFaction",
			Type = "Event",
			LiteralName = "UPDATE_FACTION",
			SynchronousEvent = true,
		},
		{
			Name = "UpdateInventoryAlerts",
			Type = "Event",
			LiteralName = "UPDATE_INVENTORY_ALERTS",
			SynchronousEvent = true,
		},
		{
			Name = "UpdateInventoryDurability",
			Type = "Event",
			LiteralName = "UPDATE_INVENTORY_DURABILITY",
			SynchronousEvent = true,
		},
		{
			Name = "WeaponSlotChanged",
			Type = "Event",
			LiteralName = "WEAPON_SLOT_CHANGED",
			UniqueEvent = true,
		},
	},

	Tables =
	{
		{
			Name = "InspectGuildInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "achievementPoints", Type = "number", Nilable = false },
				{ Name = "numMembers", Type = "number", Nilable = false },
				{ Name = "guildName", Type = "string", Nilable = false },
				{ Name = "realmName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "InspectPVPData",
			Type = "Structure",
			Fields =
			{
				{ Name = "rating", Type = "number", Nilable = false },
				{ Name = "gamesWon", Type = "number", Nilable = false },
				{ Name = "gamesPlayed", Type = "number", Nilable = false },
				{ Name = "roundsWon", Type = "number", Nilable = false },
				{ Name = "roundsPlayed", Type = "number", Nilable = false },
			},
		},
		{
			Name = "InspectRatedBGData",
			Type = "Structure",
			Fields =
			{
				{ Name = "rating", Type = "number", Nilable = false },
				{ Name = "played", Type = "number", Nilable = false },
				{ Name = "won", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PaperDollInfo);