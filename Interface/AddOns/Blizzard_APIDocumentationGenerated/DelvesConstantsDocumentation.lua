local DelvesConstants =
{
	Tables =
	{
		{
			Name = "CompanionConfigSlotTypes",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Role", Type = "CompanionConfigSlotTypes", EnumValue = 0 },
				{ Name = "Utility", Type = "CompanionConfigSlotTypes", EnumValue = 1 },
				{ Name = "Combat", Type = "CompanionConfigSlotTypes", EnumValue = 2 },
			},
		},
		{
			Name = "CurioRarity",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 1,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Common", Type = "CurioRarity", EnumValue = 1 },
				{ Name = "Uncommon", Type = "CurioRarity", EnumValue = 2 },
				{ Name = "Rare", Type = "CurioRarity", EnumValue = 3 },
				{ Name = "Epic", Type = "CurioRarity", EnumValue = 4 },
			},
		},
		{
			Name = "DelveAssistActionData",
			Type = "Structure",
			Fields =
			{
				{ Name = "assistedPlayer", Type = "string", Nilable = false },
				{ Name = "mapName", Type = "cstring", Nilable = true },
				{ Name = "creatureName", Type = "cstring", Nilable = true },
				{ Name = "receivedSpellID", Type = "number", Nilable = true },
				{ Name = "assistAction", Type = "AssistActionType", Nilable = false },
			},
		},
		{
			Name = "DelvesConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "DELVES_MIN_PLAYER_LEVEL_CONTENT_TUNING_ID", Type = "number", Value = 2677 },
				{ Name = "DELVES_NORMAL_KEY_CURRENCY_ID", Type = "number", Value = 3028 },
				{ Name = "DELVES_COMPANION_INFO_SELECTION_CHARACTER_DATA_ELEMENT_ID", Type = "number", Value = 13 },
				{ Name = "DELVES_COMPANION_TOOLTIP_WIDGET_SET_ID", Type = "number", Value = 1331 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(DelvesConstants);