local UIModifiedInstance =
{
	Name = "UIModifiedInstance",
	Type = "System",
	Namespace = "C_ModifiedInstance",

	Functions =
	{
		{
			Name = "GetModifiedInstanceInfoFromMapID",
			Type = "Function",

			Arguments =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "ModifiedInstanceInfo", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "ModifiedInstanceInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "lfrItemLevel", Type = "number", Nilable = true },
				{ Name = "normalItemLevel", Type = "number", Nilable = true },
				{ Name = "heroicItemLevel", Type = "number", Nilable = true },
				{ Name = "mythicItemLevel", Type = "number", Nilable = true },
				{ Name = "uiTextureKit", Type = "textureKit", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIModifiedInstance);