local TaxiMap =
{
	Name = "TaxiMap",
	Type = "System",
	Namespace = "C_TaxiMap",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "TaximapClosed",
			Type = "Event",
			LiteralName = "TAXIMAP_CLOSED",
		},
		{
			Name = "TaximapOpened",
			Type = "Event",
			LiteralName = "TAXIMAP_OPENED",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(TaxiMap);