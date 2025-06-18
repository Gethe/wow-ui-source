local LFGConstants =
{
	Tables =
	{
		{
			Name = "LFGEntryPlaystyle",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "LFGEntryPlaystyle", EnumValue = 0 },
				{ Name = "Standard", Type = "LFGEntryPlaystyle", EnumValue = 1 },
				{ Name = "Casual", Type = "LFGEntryPlaystyle", EnumValue = 2 },
				{ Name = "Hardcore", Type = "LFGEntryPlaystyle", EnumValue = 3 },
			},
		},
		{
			Name = "LFGListFilter",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 1,
			MaxValue = 128,
			Fields =
			{
				{ Name = "Recommended", Type = "LFGListFilter", EnumValue = 1 },
				{ Name = "NotRecommended", Type = "LFGListFilter", EnumValue = 2 },
				{ Name = "PvE", Type = "LFGListFilter", EnumValue = 4 },
				{ Name = "PvP", Type = "LFGListFilter", EnumValue = 8 },
				{ Name = "Timerunning", Type = "LFGListFilter", EnumValue = 16 },
				{ Name = "CurrentExpansion", Type = "LFGListFilter", EnumValue = 32 },
				{ Name = "CurrentSeason", Type = "LFGListFilter", EnumValue = 64 },
				{ Name = "NotCurrentSeason", Type = "LFGListFilter", EnumValue = 128 },
			},
		},
		{
			Name = "LFGRole",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Tank", Type = "LFGRole", EnumValue = 0 },
				{ Name = "Healer", Type = "LFGRole", EnumValue = 1 },
				{ Name = "Damage", Type = "LFGRole", EnumValue = 2 },
			},
		},
		{
			Name = "LFGSlotInvalidReason",
			Type = "Enumeration",
			NumValues = 20,
			MinValue = 0,
			MaxValue = 19,
			Fields =
			{
				{ Name = "None", Type = "LFGSlotInvalidReason", EnumValue = 0 },
				{ Name = "ExpansionTooLow", Type = "LFGSlotInvalidReason", EnumValue = 1 },
				{ Name = "LevelTooLow", Type = "LFGSlotInvalidReason", EnumValue = 2 },
				{ Name = "LevelTooHigh", Type = "LFGSlotInvalidReason", EnumValue = 3 },
				{ Name = "GearTooLow", Type = "LFGSlotInvalidReason", EnumValue = 4 },
				{ Name = "GearTooHigh", Type = "LFGSlotInvalidReason", EnumValue = 5 },
				{ Name = "RaidLocked", Type = "LFGSlotInvalidReason", EnumValue = 6 },
				{ Name = "LevelTargetTooLow", Type = "LFGSlotInvalidReason", EnumValue = 7 },
				{ Name = "LevelTargetTooHigh", Type = "LFGSlotInvalidReason", EnumValue = 8 },
				{ Name = "AreaNotExplored", Type = "LFGSlotInvalidReason", EnumValue = 9 },
				{ Name = "WrongFaction", Type = "LFGSlotInvalidReason", EnumValue = 10 },
				{ Name = "NoValidRoles", Type = "LFGSlotInvalidReason", EnumValue = 11 },
				{ Name = "EngagedInPvP", Type = "LFGSlotInvalidReason", EnumValue = 12 },
				{ Name = "NoSpec", Type = "LFGSlotInvalidReason", EnumValue = 13 },
				{ Name = "CannotRunAnyChildDungeon", Type = "LFGSlotInvalidReason", EnumValue = 14 },
				{ Name = "Restricted", Type = "LFGSlotInvalidReason", EnumValue = 15 },
				{ Name = "ChromieTime", Type = "LFGSlotInvalidReason", EnumValue = 16 },
				{ Name = "Npe", Type = "LFGSlotInvalidReason", EnumValue = 17 },
				{ Name = "Timerunning", Type = "LFGSlotInvalidReason", EnumValue = 18 },
				{ Name = "PlayerConditionFailed", Type = "LFGSlotInvalidReason", EnumValue = 19 },
			},
		},
		{
			Name = "PremadeGroupFinderStyle",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Disabled", Type = "PremadeGroupFinderStyle", EnumValue = 0 },
				{ Name = "Mainline", Type = "PremadeGroupFinderStyle", EnumValue = 1 },
				{ Name = "Vanilla", Type = "PremadeGroupFinderStyle", EnumValue = 2 },
			},
		},
		{
			Name = "LFGConstsExposed",
			Type = "Constants",
			Values =
			{
				{ Name = "GROUP_FINDER_MAX_ACTIVITY_CAPACITY", Type = "number", Value = 16 },
			},
		},
		{
			Name = "LFG_ROLEConstants",
			Type = "Constants",
			Values =
			{
				{ Name = "LFG_ROLE_NO_ROLE", Type = "LFGRole", Value = -1 },
				{ Name = "LFG_ROLE_ANY", Type = "LFGRole", Value = Enum.LFGRoleMeta.NumValues },
			},
		},
		{
			Name = "LFGRoles",
			Type = "Structure",
			Fields =
			{
				{ Name = "tank", Type = "bool", Nilable = false },
				{ Name = "healer", Type = "bool", Nilable = false },
				{ Name = "dps", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LFGConstants);