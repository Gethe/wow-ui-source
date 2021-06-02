local ItemConstants_Mainline =
{
	Tables =
	{
		{
			Name = "ItemGemSubclass",
			Type = "Enumeration",
			NumValues = 12,
			MinValue = 0,
			MaxValue = 11,
			Fields =
			{
				{ Name = "Intellect", Type = "ItemGemSubclass", EnumValue = 0 },
				{ Name = "Agility", Type = "ItemGemSubclass", EnumValue = 1 },
				{ Name = "Strength", Type = "ItemGemSubclass", EnumValue = 2 },
				{ Name = "Stamina", Type = "ItemGemSubclass", EnumValue = 3 },
				{ Name = "Spirit", Type = "ItemGemSubclass", EnumValue = 4 },
				{ Name = "Criticalstrike", Type = "ItemGemSubclass", EnumValue = 5 },
				{ Name = "Mastery", Type = "ItemGemSubclass", EnumValue = 6 },
				{ Name = "Haste", Type = "ItemGemSubclass", EnumValue = 7 },
				{ Name = "Versatility", Type = "ItemGemSubclass", EnumValue = 8 },
				{ Name = "Other", Type = "ItemGemSubclass", EnumValue = 9 },
				{ Name = "Multiplestats", Type = "ItemGemSubclass", EnumValue = 10 },
				{ Name = "Artifactrelic", Type = "ItemGemSubclass", EnumValue = 11 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ItemConstants_Mainline);