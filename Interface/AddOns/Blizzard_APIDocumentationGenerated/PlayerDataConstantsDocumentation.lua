local PlayerDataConstants =
{
	Tables =
	{
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