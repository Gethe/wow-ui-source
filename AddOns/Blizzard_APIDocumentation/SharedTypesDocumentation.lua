local SharedTypes =
{
	Tables =
	{
		{
			Name = "ChatChannelType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "ChatChannelType", EnumValue = 0 },
				{ Name = "Custom", Type = "ChatChannelType", EnumValue = 1 },
				{ Name = "PrivateParty", Type = "ChatChannelType", EnumValue = 2 },
				{ Name = "PublicParty", Type = "ChatChannelType", EnumValue = 3 },
				{ Name = "Count", Type = "ChatChannelType", EnumValue = 4 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SharedTypes);