local CovenantCallings =
{
	Name = "CovenantCallings",
	Type = "System",
	Namespace = "C_CovenantCallings",
	Environment = "All",

	Functions =
	{
		{
			Name = "AreCallingsUnlocked",
			Type = "Function",

			Returns =
			{
				{ Name = "unlocked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestCallings",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "CovenantCallingsUpdated",
			Type = "Event",
			LiteralName = "COVENANT_CALLINGS_UPDATED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "callings", Type = "table", InnerType = "BountyInfo", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(CovenantCallings);