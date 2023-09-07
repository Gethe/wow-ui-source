local InterfaceFileManifest =
{
	Name = "InterfaceFileManifest",
	Type = "System",
	Namespace = "C_InterfaceFileManifest",

	Functions =
	{
		{
			Name = "GetInterfaceArtFiles",
			Type = "Function",

			Returns =
			{
				{ Name = "images", Type = "table", InnerType = "string", Nilable = false },
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

APIDocumentation:AddDocumentationTable(InterfaceFileManifest);