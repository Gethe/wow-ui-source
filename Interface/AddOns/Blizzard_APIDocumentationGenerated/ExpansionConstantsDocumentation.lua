local ExpansionConstants =
{
	Tables =
	{
		{
			Name = "ReleaseType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 1,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Original", Type = "ReleaseType", EnumValue = 1 },
				{ Name = "Classic", Type = "ReleaseType", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ExpansionConstants);