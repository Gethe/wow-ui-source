local FrameScript =
{
	Name = "FrameScript",
	Type = "System",

	Functions =
	{
		{
			Name = "CreateWindow",
			Type = "Function",

			Arguments =
			{
				{ Name = "popupStyle", Type = "bool", Nilable = false, Default = true },
			},

			Returns =
			{
				{ Name = "window", Type = "SimpleWindow", Nilable = true },
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

APIDocumentation:AddDocumentationTable(FrameScript);