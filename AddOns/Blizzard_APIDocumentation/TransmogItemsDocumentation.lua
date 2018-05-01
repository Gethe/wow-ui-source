local TransmogItems =
{
	Name = "Transmogrify",
	Type = "System",
	Namespace = "C_TransmogCollection",

	Functions =
	{
		{
			Name = "GetAppearanceSources",
			Type = "Function",

			Arguments =
			{
				{ Name = "appearanceID", Type = "number", Nilable = false },
				{ Name = "slot", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "sources", Type = "table", InnerType = "AppearanceSourceInfo", Nilable = false },
			},
		},
		{
			Name = "GetSourceIcon",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "icon", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSourceInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "sourceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "sourceInfo", Type = "AppearanceSourceInfo", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(TransmogItems);