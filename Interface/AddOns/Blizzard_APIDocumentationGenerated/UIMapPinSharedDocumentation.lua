local UIMapPinShared =
{
	Tables =
	{
		{
			Name = "UIMapPinInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "button", Type = "UIButtonInfo", Nilable = false },
				{ Name = "buttonSelected", Type = "UIButtonInfo", Nilable = false },
				{ Name = "underlay", Type = "textureAtlas", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIMapPinShared);