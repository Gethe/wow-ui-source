local CovenantCallings =
{
	Name = "CovenantCallings",
	Type = "System",
	Namespace = "C_CovenantCallings",

	Functions =
	{
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