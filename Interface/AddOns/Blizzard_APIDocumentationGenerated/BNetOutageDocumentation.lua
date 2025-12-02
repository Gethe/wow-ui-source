local BNetOutage =
{
	Name = "BNetOutage",
	Type = "System",

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