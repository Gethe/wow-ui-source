local BNetOutage =
{
	Name = "BNetOutage",
	Type = "System",
	Environment = "All",

	Functions =
	{
		{
			Name = "ClearOutage",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "OutageDetected",
			Type = "Function",
			HasRestrictions = true,
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(BNetOutage);