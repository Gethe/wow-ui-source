local CinematicList =
{
	Name = "CinematicList",
	Type = "System",
	Namespace = "C_CinematicList",

	Functions =
	{
		{
			Name = "GetUICinematicList",
			Type = "Function",

			Returns =
			{
				{ Name = "cinematics", Type = "table", InnerType = "UICinematic", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "UICinematic",
			Type = "Structure",
			Fields =
			{
				{ Name = "expansion", Type = "number", Nilable = false },
				{ Name = "movieIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "buttonUpAtlas", Type = "textureAtlas", Nilable = false },
				{ Name = "buttonDownAtlas", Type = "textureAtlas", Nilable = false },
				{ Name = "title", Type = "string", Nilable = true },
				{ Name = "disableAutoPlay", Type = "bool", Nilable = false },
				{ Name = "orderID", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CinematicList);