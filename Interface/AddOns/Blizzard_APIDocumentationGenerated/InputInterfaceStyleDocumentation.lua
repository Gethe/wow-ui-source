local InputInterfaceStyle =
{
	Name = "InputInterfaceStyle",
	Type = "System",
	Namespace = "C_InputInterfaceStyle",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetCurrentStyle",
			Type = "Function",

			Returns =
			{
				{ Name = "style", Type = "InputDeviceInterfaceType", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(InputInterfaceStyle);