local EncounterJournal =
{
	Name = "EncounterJournal",
	Type = "System",
	Namespace = "C_EncounterJournal",

	Functions =
	{
		{
			Name = "GetDungeonEntrancesForMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "dungeonEntrances", Type = "table", InnerType = "DungeonEntranceMapInfo", Nilable = false },
			},
		},
		{
			Name = "GetEncountersOnMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "encounters", Type = "table", InnerType = "EncounterJournalMapEncounterInfo", Nilable = false },
			},
		},
		{
			Name = "GetLootInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "id", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemInfo", Type = "EncounterJournalItemInfo", Nilable = false },
			},
		},
		{
			Name = "GetLootInfoByIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
				{ Name = "encounterIndex", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "itemInfo", Type = "EncounterJournalItemInfo", Nilable = false },
			},
		},
		{
			Name = "GetSectionIconFlags",
			Type = "Function",
			Documentation = { "Represents the icon indices for this EJ section.  An icon index can be used to arrive at texture coordinates for specific encounter types, e.g.: EncounterJournal_SetFlagIcon" },

			Arguments =
			{
				{ Name = "sectionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "iconFlags", Type = "table", InnerType = "number", Nilable = true },
			},
		},
		{
			Name = "GetSectionInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "sectionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "EncounterJournalSectionInfo", Nilable = false },
			},
		},
		{
			Name = "GetSlotFilter",
			Type = "Function",

			Returns =
			{
				{ Name = "filter", Type = "ItemSlotFilterType", Nilable = false },
			},
		},
		{
			Name = "InstanceHasLoot",
			Type = "Function",

			Arguments =
			{
				{ Name = "instanceID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "hasLoot", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEncounterComplete",
			Type = "Function",

			Arguments =
			{
				{ Name = "journalEncounterID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isEncounterComplete", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ResetSlotFilter",
			Type = "Function",
		},
		{
			Name = "SetPreviewMythicPlusLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "level", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetPreviewPvpTier",
			Type = "Function",

			Arguments =
			{
				{ Name = "tier", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetSlotFilter",
			Type = "Function",

			Arguments =
			{
				{ Name = "filterSlot", Type = "ItemSlotFilterType", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "EjDifficultyUpdate",
			Type = "Event",
			LiteralName = "EJ_DIFFICULTY_UPDATE",
			Payload =
			{
				{ Name = "difficultyID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "EjLootDataRecieved",
			Type = "Event",
			LiteralName = "EJ_LOOT_DATA_RECIEVED",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = true },
			},
		},
	},

	Tables =
	{
		{
			Name = "ItemSlotFilterType",
			Type = "Enumeration",
			NumValues = 16,
			MinValue = 0,
			MaxValue = 15,
			Fields =
			{
				{ Name = "Head", Type = "ItemSlotFilterType", EnumValue = 0 },
				{ Name = "Neck", Type = "ItemSlotFilterType", EnumValue = 1 },
				{ Name = "Shoulder", Type = "ItemSlotFilterType", EnumValue = 2 },
				{ Name = "Cloak", Type = "ItemSlotFilterType", EnumValue = 3 },
				{ Name = "Chest", Type = "ItemSlotFilterType", EnumValue = 4 },
				{ Name = "Wrist", Type = "ItemSlotFilterType", EnumValue = 5 },
				{ Name = "Hand", Type = "ItemSlotFilterType", EnumValue = 6 },
				{ Name = "Waist", Type = "ItemSlotFilterType", EnumValue = 7 },
				{ Name = "Legs", Type = "ItemSlotFilterType", EnumValue = 8 },
				{ Name = "Feet", Type = "ItemSlotFilterType", EnumValue = 9 },
				{ Name = "MainHand", Type = "ItemSlotFilterType", EnumValue = 10 },
				{ Name = "OffHand", Type = "ItemSlotFilterType", EnumValue = 11 },
				{ Name = "Finger", Type = "ItemSlotFilterType", EnumValue = 12 },
				{ Name = "Trinket", Type = "ItemSlotFilterType", EnumValue = 13 },
				{ Name = "Other", Type = "ItemSlotFilterType", EnumValue = 14 },
				{ Name = "NoFilter", Type = "ItemSlotFilterType", EnumValue = 15 },
			},
		},
		{
			Name = "DungeonEntranceMapInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "areaPoiID", Type = "number", Nilable = false },
				{ Name = "position", Type = "table", Mixin = "Vector2DMixin", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "atlasName", Type = "string", Nilable = false },
				{ Name = "journalInstanceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "EncounterJournalItemInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "encounterID", Type = "number", Nilable = true },
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "itemQuality", Type = "string", Nilable = true },
				{ Name = "filterType", Type = "ItemSlotFilterType", Nilable = true },
				{ Name = "icon", Type = "number", Nilable = true },
				{ Name = "slot", Type = "string", Nilable = true },
				{ Name = "armorType", Type = "string", Nilable = true },
				{ Name = "link", Type = "string", Nilable = true },
				{ Name = "handError", Type = "bool", Nilable = true },
				{ Name = "weaponTypeError", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "EncounterJournalMapEncounterInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "encounterID", Type = "number", Nilable = false },
				{ Name = "mapX", Type = "number", Nilable = false },
				{ Name = "mapY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "EncounterJournalSectionInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "title", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = true },
				{ Name = "headerType", Type = "number", Nilable = false },
				{ Name = "abilityIcon", Type = "number", Nilable = false },
				{ Name = "creatureDisplayID", Type = "number", Nilable = false },
				{ Name = "uiModelSceneID", Type = "number", Nilable = false },
				{ Name = "siblingSectionID", Type = "number", Nilable = true },
				{ Name = "firstChildSectionID", Type = "number", Nilable = true },
				{ Name = "filteredByDifficulty", Type = "bool", Nilable = false },
				{ Name = "link", Type = "string", Nilable = false },
				{ Name = "startsOpen", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(EncounterJournal);