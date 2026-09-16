local AddOnConstants =
{
	Tables =
	{
		{
			Name = "AddOnEnableState",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "AddOnEnableState", EnumValue = 0 },
				{ Name = "Some", Type = "AddOnEnableState", EnumValue = 1 },
				{ Name = "All", Type = "AddOnEnableState", EnumValue = 2 },
			},
		},
		{
			Name = "AddOnSecurityStatus",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Secure", Type = "AddOnSecurityStatus", EnumValue = 0 },
				{ Name = "Insecure", Type = "AddOnSecurityStatus", EnumValue = 1 },
				{ Name = "Banned", Type = "AddOnSecurityStatus", EnumValue = 2 },
				{ Name = "NotAvailable", Type = "AddOnSecurityStatus", EnumValue = 3 },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(AddOnConstants);