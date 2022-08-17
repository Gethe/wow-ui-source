local IncomingSummon =
{
	Name = "IncomingSummon",
	Type = "System",
	Namespace = "C_IncomingSummon",

	Functions =
	{
		{
			Name = "HasIncomingSummon",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "summon", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IncomingSummonStatus",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "status", Type = "SummonStatus", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "SummonStatus",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "SummonStatus", EnumValue = 0 },
				{ Name = "Pending", Type = "SummonStatus", EnumValue = 1 },
				{ Name = "Accepted", Type = "SummonStatus", EnumValue = 2 },
				{ Name = "Declined", Type = "SummonStatus", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(IncomingSummon);