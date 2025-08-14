local RemixArtifactUI =
{
	Name = "RemixArtifactUI",
	Type = "System",
	Namespace = "C_RemixArtifactUI",

	Functions =
	{
		{
			Name = "ClearRemixArtifactItem",
			Type = "Function",
		},
		{
			Name = "GetAppearanceInfoByID",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "artifactAppearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "uiCameraID", Type = "number", Nilable = false },
				{ Name = "altHandUICameraID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetArtifactArtInfo",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "artifactArtInfo", Type = "RemixArtifactArtInfo", Nilable = false },
			},
		},
		{
			Name = "GetArtifactItemInfo",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
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
		{
			Name = "GetCurrArtifactItemID",
			Type = "Function",

			Returns =
			{
				{ Name = "reqitemID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetCurrItemSpecIndex",
			Type = "Function",

			Returns =
			{
				{ Name = "specIndex", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "GetCurrTraitTreeID",
			Type = "Function",

			Returns =
			{
				{ Name = "traitTreeID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "ItemInSlotIsRemixArtifact",
			Type = "Function",

			Arguments =
			{
				{ Name = "invSlot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isRemixArtifact", Type = "bool", Nilable = false },
			},
		},
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