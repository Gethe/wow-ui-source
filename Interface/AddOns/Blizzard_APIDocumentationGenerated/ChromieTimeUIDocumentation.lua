local ChromieTimeUI =
{
	Name = "ChromieTimeInfo",
	Type = "System",
	Namespace = "C_ChromieTime",

	Functions =
	{
		{
			Name = "CloseUI",
			Type = "Function",
		},
		{
			Name = "GetChromieTimeExpansionOption",
			Type = "Function",

			Arguments =
			{
				{ Name = "expansionRecID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "ChromieTimeExpansionInfo", Nilable = true },
			},
		},
		{
			Name = "GetChromieTimeExpansionOptions",
			Type = "Function",

			Returns =
			{
				{ Name = "expansionOptions", Type = "table", InnerType = "ChromieTimeExpansionInfo", Nilable = false },
			},
		},
		{
			Name = "SelectChromieTimeOption",
			Type = "Function",

			Arguments =
			{
				{ Name = "chromieTimeExpansionInfoId", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "ChromieTimeExpansionInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "description", Type = "cstring", Nilable = false },
				{ Name = "mapAtlas", Type = "textureAtlas", Nilable = false },
				{ Name = "previewAtlas", Type = "textureAtlas", Nilable = false },
				{ Name = "completed", Type = "bool", Nilable = false },
				{ Name = "alreadyOn", Type = "bool", Nilable = false },
				{ Name = "recommended", Type = "bool", Nilable = false },
				{ Name = "sortPriority", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ChromieTimeUI);