local DelvesUI =
{
	Name = "DelvesUI",
	Type = "System",
	Namespace = "C_DelvesUI",

	Functions =
	{
		{
			Name = "GetCreatureDisplayInfoForCompanion",
			Type = "Function",

			Arguments =
			{
				{ Name = "companionID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "creatureDisplayInfoID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCurioNodeForCompanion",
			Type = "Function",

			Arguments =
			{
				{ Name = "companionID", Type = "number", Nilable = true },
				{ Name = "curioType", Type = "CurioType", Nilable = false },
			},

			Returns =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCurioRarityByTraitCondAccountElementID",
			Type = "Function",

			Arguments =
			{
				{ Name = "traitCondAccountElementID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "rarity", Type = "CurioRarity", Nilable = false },
			},
		},
		{
			Name = "GetCurrentDelvesSeasonNumber",
			Type = "Function",

			Returns =
			{
				{ Name = "seasonNumber", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDelvesAffixSpellsForSeason",
			Type = "Function",

			Returns =
			{
				{ Name = "affixSpellIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetDelvesFactionForSeason",
			Type = "Function",

			Returns =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDelvesMinRequiredLevel",
			Type = "Function",
			Documentation = { "Players must be at or above the min level + offset to enter Delves. This function returns that min level." },

			Returns =
			{
				{ Name = "minRequiredLevel", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetFactionForCompanion",
			Type = "Function",

			Arguments =
			{
				{ Name = "companionID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetModelSceneForCompanion",
			Type = "Function",

			Arguments =
			{
				{ Name = "companionID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "modelSceneID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRoleNodeForCompanion",
			Type = "Function",

			Arguments =
			{
				{ Name = "companionID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRoleSubtreeForCompanion",
			Type = "Function",

			Arguments =
			{
				{ Name = "companionID", Type = "number", Nilable = true },
				{ Name = "roleType", Type = "CompanionRoleType", Nilable = false },
			},

			Returns =
			{
				{ Name = "subTreeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTraitTreeForCompanion",
			Type = "Function",

			Arguments =
			{
				{ Name = "companionID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "treeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetUnseenCuriosBySlotType",
			Type = "Function",

			Arguments =
			{
				{ Name = "slotType", Type = "CompanionConfigSlotTypes", Nilable = false },
				{ Name = "ownedCurioNodeIDs", Type = "table", InnerType = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "unseenCurioNodeIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "HasActiveDelve",
			Type = "Function",

			Arguments =
			{
				{ Name = "mapID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEligibleForActiveDelveRewards",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SaveSeenCuriosBySlotType",
			Type = "Function",

			Arguments =
			{
				{ Name = "slotType", Type = "CompanionConfigSlotTypes", Nilable = false },
				{ Name = "ownedCurioNodeIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "ActiveDelveDataUpdate",
			Type = "Event",
			LiteralName = "ACTIVE_DELVE_DATA_UPDATE",
			Documentation = { "Signaled when SpellScript calls change the data for players/parties owning a delve or when the delve is shut down." },
		},
		{
			Name = "ShowDelvesDisplayUI",
			Type = "Event",
			LiteralName = "SHOW_DELVES_DISPLAY_UI",
		},
		{
			Name = "WalkInDataUpdate",
			Type = "Event",
			LiteralName = "WALK_IN_DATA_UPDATE",
			Documentation = { "Signaled when the player or a private party member join a new walk-in instance or when the instance is shut down." },
		},
	},

	Tables =
	{
		{
			Name = "CompanionRoleType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Dps", Type = "CompanionRoleType", EnumValue = 0 },
				{ Name = "Heal", Type = "CompanionRoleType", EnumValue = 1 },
			},
		},
		{
			Name = "CurioType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Combat", Type = "CurioType", EnumValue = 0 },
				{ Name = "Utility", Type = "CurioType", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(DelvesUI);