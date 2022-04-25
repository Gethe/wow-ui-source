local InputConstants =
{
	Tables =
	{
		{
			Name = "InputContext",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "InputContext", EnumValue = 0 },
				{ Name = "Keyboard", Type = "InputContext", EnumValue = 1 },
				{ Name = "Mouse", Type = "InputContext", EnumValue = 2 },
				{ Name = "GamePad", Type = "InputContext", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(InputConstants);