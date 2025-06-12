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
			Name = "GetInspectGuildInfo",
			Type = "Function",

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
			Name = "GetInspectRatedBGData",
			Type = "Function",

			Returns =
			{
				{ Name = "ratedBGData", Type = "InspectRatedBGData", Nilable = false },
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
			Name = "IsInventorySlotEnabled",
			Type = "Function",

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
			Name = "CharacterPointsChanged",
			Type = "Event",
			LiteralName = "CHARACTER_POINTS_CHANGED",
			Payload =
			{
				{ Name = "change", Type = "number", Nilable = false },
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
				{ Name = "inspecteeGUID", Type = "WOWGUID", Nilable = false },
			},
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
			Name = "PetTalentUpdate",
			Type = "Event",
			LiteralName = "PET_TALENT_UPDATE",
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
			Name = "PreviewPetTalentPointsChanged",
			Type = "Event",
			LiteralName = "PREVIEW_PET_TALENT_POINTS_CHANGED",
			Payload =
			{
				{ Name = "talentIndex", Type = "number", Nilable = false },
				{ Name = "tabIndex", Type = "number", Nilable = false },
				{ Name = "groupIndex", Type = "number", Nilable = false },
				{ Name = "points", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PreviewTalentPointsChanged",
			Type = "Event",
			LiteralName = "PREVIEW_TALENT_POINTS_CHANGED",
			Payload =
			{
				{ Name = "talentIndex", Type = "number", Nilable = false },
				{ Name = "tabIndex", Type = "number", Nilable = false },
				{ Name = "groupIndex", Type = "number", Nilable = false },
				{ Name = "points", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PreviewTalentPrimaryTreeChanged",
			Type = "Event",
			LiteralName = "PREVIEW_TALENT_PRIMARY_TREE_CHANGED",
			Payload =
			{
				{ Name = "newTabID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SpellPowerChanged",
			Type = "Event",
			LiteralName = "SPELL_POWER_CHANGED",
		},
		{
			Name = "TalentGroupRoleChanged",
			Type = "Event",
			LiteralName = "TALENT_GROUP_ROLE_CHANGED",
			Payload =
			{
				{ Name = "groupIndex", Type = "number", Nilable = false },
				{ Name = "newRole", Type = "cstring", Nilable = false },
			},
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