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
			MayReturnNothing = true,

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