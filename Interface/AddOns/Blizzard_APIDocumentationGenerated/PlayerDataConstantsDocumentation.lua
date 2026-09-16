local PlayerDataConstants =
{
	Tables =
	{
		{
			Name = "PlayerDataElementAccountFlags",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Log", Type = "PlayerDataElementAccountFlags", EnumValue = 1 },
			},
		},
		{
			Name = "PlayerDataElementCharacterFlags",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Log", Type = "PlayerDataElementCharacterFlags", EnumValue = 1 },
			},
		},
		{
			Name = "PlayerDataElementType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Int", Type = "PlayerDataElementType", EnumValue = 0 },
				{ Name = "Float", Type = "PlayerDataElementType", EnumValue = 1 },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(PlayerDataConstants);