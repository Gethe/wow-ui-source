local SharedTypes =
{
	Tables =
	{
		{
			Name = "ChatChannelType",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "None", Type = "ChatChannelType", EnumValue = 0 },
				{ Name = "Custom", Type = "ChatChannelType", EnumValue = 1 },
				{ Name = "Party", Type = "ChatChannelType", EnumValue = 2 },
				{ Name = "Raid", Type = "ChatChannelType", EnumValue = 3 },
				{ Name = "Instance", Type = "ChatChannelType", EnumValue = 4 },
				{ Name = "Battleground", Type = "ChatChannelType", EnumValue = 5 },
				{ Name = "Count", Type = "ChatChannelType", EnumValue = 6 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SharedTypes);