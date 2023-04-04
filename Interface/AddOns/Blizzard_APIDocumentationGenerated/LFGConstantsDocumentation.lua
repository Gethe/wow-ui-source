local LFGConstants =
{
	Tables =
	{
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
			Name = "GroupFinderConstants",
			Type = "Constants",
			Values =
			{
				{ Name = "MAX_GROUP_FINDER_ACTIVITIES", Type = "number", Value = 41 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LFGConstants);