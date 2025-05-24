local Screen =
{
	Name = "Screen",
	Type = "System",

	Functions =
	{
		{
			Name = "GetDefaultScale",
			Type = "Function",

			Returns =
			{
				{ Name = "scale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPhysicalScreenSize",
			Type = "Function",

			Returns =
			{
				{ Name = "sizeX", Type = "number", Nilable = false },
				{ Name = "sizeY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetScreenDPIScale",
			Type = "Function",

			Returns =
			{
				{ Name = "scale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetScreenHeight",
			Type = "Function",

			Returns =
			{
				{ Name = "height", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetScreenWidth",
			Type = "Function",

			Returns =
			{
				{ Name = "width", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(Screen);