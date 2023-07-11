local PingConstants =
{
	Tables =
	{
		{
			Name = "PingSubjectType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Attack", Type = "PingSubjectType", EnumValue = 0 },
				{ Name = "Warning", Type = "PingSubjectType", EnumValue = 1 },
				{ Name = "Assist", Type = "PingSubjectType", EnumValue = 2 },
				{ Name = "GroupHere", Type = "PingSubjectType", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PingConstants);