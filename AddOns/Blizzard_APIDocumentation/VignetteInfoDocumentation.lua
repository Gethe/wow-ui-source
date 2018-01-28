local VignetteInfo =
{
	Name = "VignetteInfo",
	Type = "System",
	Namespace = "C_VignetteInfo",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "VignetteAdded",
			Type = "Event",
			LiteralName = "VIGNETTE_ADDED",
			Payload =
			{
				{ Name = "instanceGUID", Type = "string", Nilable = false },
				{ Name = "showToast", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "VignetteRemoved",
			Type = "Event",
			LiteralName = "VIGNETTE_REMOVED",
			Payload =
			{
				{ Name = "instanceGUID", Type = "string", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(VignetteInfo);