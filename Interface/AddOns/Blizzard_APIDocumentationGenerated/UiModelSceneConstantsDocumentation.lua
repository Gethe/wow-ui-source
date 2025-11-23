local UiModelSceneConstants =
{
	Tables =
	{
		{
			Name = "UIModelSceneContext",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = -1,
			MaxValue = 0,
			Fields =
			{
				{ Name = "None", Type = "UIModelSceneContext", EnumValue = -1 },
				{ Name = "PerksProgram", Type = "UIModelSceneContext", EnumValue = 0 },
			},
		},
		{
			Name = "UIModelSceneFlags",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 1,
			MaxValue = 8,
			Fields =
			{
				{ Name = "SheatheWeapon", Type = "UIModelSceneFlags", EnumValue = 1 },
				{ Name = "HideWeapon", Type = "UIModelSceneFlags", EnumValue = 2 },
				{ Name = "Autodress", Type = "UIModelSceneFlags", EnumValue = 4 },
				{ Name = "NoCameraSpin", Type = "UIModelSceneFlags", EnumValue = 8 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UiModelSceneConstants);