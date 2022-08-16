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
		{
			Name = "ChromieTimeClose",
			Type = "Event",
			LiteralName = "CHROMIE_TIME_CLOSE",
		},
		{
			Name = "ChromieTimeOpen",
			Type = "Event",
			LiteralName = "CHROMIE_TIME_OPEN",
		},
	},

	Tables =
	{
		{
			Name = "ChromieTimeExpansionInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "mapAtlas", Type = "string", Nilable = false },
				{ Name = "previewAtlas", Type = "string", Nilable = false },
				{ Name = "completed", Type = "bool", Nilable = false },
				{ Name = "alreadyOn", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ChromieTimeUI);