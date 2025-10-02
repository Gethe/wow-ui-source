local LogConstants =
{
	Tables =
	{
		{
			Name = "LogPriority",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 1,
			MaxValue = 40,
			Fields =
			{
				{ Name = "Fatal", Type = "LogPriority", EnumValue = 1 },
				{ Name = "Error", Type = "LogPriority", EnumValue = 2 },
				{ Name = "Warning", Type = "LogPriority", EnumValue = 3 },
				{ Name = "Normal", Type = "LogPriority", EnumValue = 10 },
				{ Name = "Debug", Type = "LogPriority", EnumValue = 30 },
				{ Name = "Spam", Type = "LogPriority", EnumValue = 40 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LogConstants);