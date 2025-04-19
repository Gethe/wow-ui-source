local UIButtonShared =
{
	Tables =
	{
		{
			Name = "UIButtonInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "normal", Type = "textureAtlas", Nilable = false },
				{ Name = "pressed", Type = "textureAtlas", Nilable = false },
				{ Name = "highlight", Type = "textureAtlas", Nilable = false },
				{ Name = "icon", Type = "textureAtlas", Nilable = false },
				{ Name = "useNormalAsHiglight", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIButtonShared);