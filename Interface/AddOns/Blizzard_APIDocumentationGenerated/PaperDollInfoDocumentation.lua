local PaperDollInfo =
{
	Name = "PaperDollInfo",
	Type = "System",
	Namespace = "C_PaperDollInfo",
	Environment = "All",

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
			Name = "CancelTemporaryEnchantment",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Cancels active temporary enchantments on inventory slot items." },

			Arguments =
			{
				{ Name = "slot", Type = "LuaInventorySlot", Nilable = false },
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
			Name = "GetInventorySlotInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slotName", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "invSlot", Type = "number", Nilable = false },
				{ Name = "slotTexture", Type = "fileID", Nilable = false },
				{ Name = "checkRelic", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetInventorySlotInfoForInvSlot",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "invSlotValue", Type = "number", Nilable = false, Documentation = { "This is the Lua version of the INVSLOT enum, not a luaIndex" } },
			},

			Returns =
			{
				{ Name = "invSlot", Type = "number", Nilable = false },
				{ Name = "slotTexture", Type = "fileID", Nilable = false },
				{ Name = "checkRelic", Type = "bool", Nilable = false },
				{ Name = "slotName", Type = "cstring", Nilable = false },
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
			Name = "GetTemporaryEnchantmentInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Queries information about active temporary enchants on inventory slot items." },

			Arguments =
			{
				{ Name = "slot", Type = "LuaInventorySlot", Nilable = false, Documentation = { "An appropriate INVSLOT_ constant." } },
			},

			Returns =
			{
				{ Name = "enchantInfo", Type = "TemporaryItemEnchantInfo", Nilable = false, Documentation = { "Returns nothing if no temporary enchantment is active for this slot." } },
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
		{
			Name = "TemporaryItemEnchantInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "enchantID", Type = "number", Nilable = false },
				{ Name = "remainingTimeMs", Type = "number", Nilable = false },
				{ Name = "chargesRemaining", Type = "number", Nilable = false },
				{ Name = "hasExpirationTime", Type = "bool", Nilable = false },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(PaperDollInfo);