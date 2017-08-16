local MapCanvasLua =
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
			Name = "GetPreferredHelpTextPosition",
			Type = "Function",

			Arguments =
			{
				{ Name = "mapAreaID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "position", Type = "MapCanvasPosition", Nilable = false },
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
		{
			Name = "MapCanvasPosition",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "BottomLeft", Type = "MapCanvasPosition", EnumValue = 0 },
				{ Name = "BottomRight", Type = "MapCanvasPosition", EnumValue = 1 },
				{ Name = "TopLeft", Type = "MapCanvasPosition", EnumValue = 2 },
				{ Name = "TopRight", Type = "MapCanvasPosition", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(MapCanvasLua);