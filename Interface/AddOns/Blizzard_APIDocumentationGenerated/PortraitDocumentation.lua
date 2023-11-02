local Portrait =
{
	Name = "Portrait",
	Type = "System",

	Functions =
	{
		{
			Name = "SetPortraitToTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "texture", Type = "SimpleTexture", Nilable = false },
				{ Name = "asset", Type = "TextureAssetDisk", Nilable = false },
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

APIDocumentation:AddDocumentationTable(Portrait);