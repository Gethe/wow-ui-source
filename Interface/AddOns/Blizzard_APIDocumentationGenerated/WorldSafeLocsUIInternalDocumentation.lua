local WorldSafeLocsUIInternal =
{
	Name = "WorldSafeLocsUIInternal",
	Type = "System",
	Namespace = "C_WorldSafeLocsUIInternal",

	Functions =
	{
		{
			Name = "GetWorldSafeLocs",
			Type = "Function",

			Returns =
			{
				{ Name = "worldSafeLocs", Type = "table", InnerType = "WorldSafeLocInfo", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "WorldSafeLocInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "continent", Type = "number", Nilable = false },
				{ Name = "loc", Type = "vector3", Mixin = "Vector3DMixin", Nilable = false },
				{ Name = "facing", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(WorldSafeLocsUIInternal);