local RemixArtifactUI =
{
	Name = "RemixArtifactUI",
	Type = "System",
	Namespace = "C_RemixArtifactUI",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "RemixArtifactItemSpecsLoaded",
			Type = "Event",
			LiteralName = "REMIX_ARTIFACT_ITEM_SPECS_LOADED",
			Payload =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RemixArtifactUpdate",
			Type = "Event",
			LiteralName = "REMIX_ARTIFACT_UPDATE",
		},
	},

	Tables =
	{
		{
			Name = "RemixArtifactAppearanceInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "uiCameraID", Type = "number", Nilable = false },
				{ Name = "altHandUICameraID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "RemixArtifactArtInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "titleName", Type = "string", Nilable = false },
				{ Name = "uiModelSceneID", Type = "number", Nilable = false },
				{ Name = "spellVisualKitID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RemixArtifactInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "altItemID", Type = "number", Nilable = true },
				{ Name = "artifactAppearanceID", Type = "number", Nilable = false },
				{ Name = "appearanceModID", Type = "number", Nilable = false },
				{ Name = "itemAppearanceID", Type = "number", Nilable = true },
				{ Name = "altItemAppearanceID", Type = "number", Nilable = true },
				{ Name = "altOnTop", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(RemixArtifactUI);