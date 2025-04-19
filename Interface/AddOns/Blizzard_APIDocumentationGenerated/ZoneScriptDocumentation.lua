local ZoneScript =
{
	Name = "ZoneScript",
	Type = "System",

	Functions =
	{
		{
			Name = "GetAreaText",
			Type = "Function",

			Returns =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetMinimapZoneText",
			Type = "Function",

			Returns =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetRealZoneText",
			Type = "Function",

			Arguments =
			{
				{ Name = "mapID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetSubZoneText",
			Type = "Function",

			Returns =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetZoneText",
			Type = "Function",

			Returns =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
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

APIDocumentation:AddDocumentationTable(ZoneScript);