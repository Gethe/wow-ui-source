local PingConstants =
{
	Tables =
	{
		{
			Name = "PingSubjectType",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Attack", Type = "PingSubjectType", EnumValue = 0 },
				{ Name = "Warning", Type = "PingSubjectType", EnumValue = 1 },
				{ Name = "Assist", Type = "PingSubjectType", EnumValue = 2 },
				{ Name = "OnMyWay", Type = "PingSubjectType", EnumValue = 3 },
				{ Name = "AlertThreat", Type = "PingSubjectType", EnumValue = 4 },
				{ Name = "AlertNotThreat", Type = "PingSubjectType", EnumValue = 5 },
			},
		},
		{
			Name = "PingTypeFlags",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "DefaultPing", Type = "PingTypeFlags", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PingConstants);