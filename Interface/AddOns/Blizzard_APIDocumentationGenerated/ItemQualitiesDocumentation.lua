local ItemQualities =
{
	Tables =
	{
		{
			Name = "ItemQuality",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 0,
			MaxValue = 8,
			Fields =
			{
				{ Name = "Poor", Type = "ItemQuality", EnumValue = 0 },
				{ Name = "Common", Type = "ItemQuality", EnumValue = 1 },
				{ Name = "Uncommon", Type = "ItemQuality", EnumValue = 2 },
				{ Name = "Rare", Type = "ItemQuality", EnumValue = 3 },
				{ Name = "Epic", Type = "ItemQuality", EnumValue = 4 },
				{ Name = "Legendary", Type = "ItemQuality", EnumValue = 5 },
				{ Name = "Artifact", Type = "ItemQuality", EnumValue = 6 },
				{ Name = "Heirloom", Type = "ItemQuality", EnumValue = 7 },
				{ Name = "WoWToken", Type = "ItemQuality", EnumValue = 8 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ItemQualities);