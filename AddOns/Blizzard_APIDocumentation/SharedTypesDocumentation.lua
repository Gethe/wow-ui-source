local SharedTypes =
{
	Tables =
	{
		{
			Name = "ChatChannelType",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "None", Type = "ChatChannelType", EnumValue = 0 },
				{ Name = "Custom", Type = "ChatChannelType", EnumValue = 1 },
				{ Name = "PrivateParty", Type = "ChatChannelType", EnumValue = 2 },
				{ Name = "PublicParty", Type = "ChatChannelType", EnumValue = 3 },
				{ Name = "Communities", Type = "ChatChannelType", EnumValue = 4 },
				{ Name = "Count", Type = "ChatChannelType", EnumValue = 5 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SharedTypes);