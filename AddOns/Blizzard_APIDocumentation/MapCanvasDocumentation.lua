local MapCanvas =
{
	Name = "MapCanvas",
	Type = "System",
	Namespace = "C_MapCanvas",

	Functions =
	{
		{
			Name = "GetBackgroundInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "mapAreaID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "backgroundAtlas", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetScaleExtentsForMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "mapAreaID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "maxScale", Type = "number", Nilable = false },
				{ Name = "minScale", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(MapCanvas);