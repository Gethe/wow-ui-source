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
			NumValues = 4,
			MinValue = 1,
			MaxValue = 8,
			Fields =
			{
				{ Name = "Recommended", Type = "LFGListFilter", EnumValue = 1 },
				{ Name = "NotRecommended", Type = "LFGListFilter", EnumValue = 2 },
				{ Name = "PvE", Type = "LFGListFilter", EnumValue = 4 },
				{ Name = "PvP", Type = "LFGListFilter", EnumValue = 8 },
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
			Name = "GroupFinderConstants",
			Type = "Constants",
			Values =
			{
				{ Name = "MAX_GROUP_FINDER_ACTIVITIES", Type = "number", Value = 41 },
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
	},
};

APIDocumentation:AddDocumentationTable(LFGConstants);