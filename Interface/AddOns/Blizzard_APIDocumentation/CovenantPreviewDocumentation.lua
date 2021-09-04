local CovenantPreview =
{
	Name = "CovenantPreview",
	Type = "System",
	Namespace = "C_CovenantPreview",

	Functions =
	{
		{
			Name = "CloseFromUI",
			Type = "Function",
		},
		{
			Name = "GetCovenantInfoForPlayerChoiceResponseID",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerChoiceResponseID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "previewInfo", Type = "CovenantPreviewInfo", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "CovenantPreviewClose",
			Type = "Event",
			LiteralName = "COVENANT_PREVIEW_CLOSE",
		},
		{
			Name = "CovenantPreviewOpen",
			Type = "Event",
			LiteralName = "COVENANT_PREVIEW_OPEN",
			Payload =
			{
				{ Name = "previewInfo", Type = "CovenantPreviewInfo", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "CovenantAbilityType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Class", Type = "CovenantAbilityType", EnumValue = 0 },
				{ Name = "Signature", Type = "CovenantAbilityType", EnumValue = 1 },
				{ Name = "Soulbind", Type = "CovenantAbilityType", EnumValue = 2 },
			},
		},
		{
			Name = "CovenantAbilityInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "type", Type = "CovenantAbilityType", Nilable = false },
			},
		},
		{
			Name = "CovenantFeatureInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "texture", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CovenantPreviewInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "transmogSetID", Type = "number", Nilable = false },
				{ Name = "mountID", Type = "number", Nilable = false },
				{ Name = "covenantName", Type = "string", Nilable = false },
				{ Name = "covenantZone", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "covenantCrest", Type = "string", Nilable = false },
				{ Name = "covenantAbilities", Type = "table", InnerType = "CovenantAbilityInfo", Nilable = false },
				{ Name = "fromPlayerChoice", Type = "bool", Nilable = false },
				{ Name = "covenantSoulbinds", Type = "table", InnerType = "CovenantSoulbindInfo", Nilable = false },
				{ Name = "featureInfo", Type = "CovenantFeatureInfo", Nilable = false },
			},
		},
		{
			Name = "CovenantSoulbindInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "uiTextureKit", Type = "string", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "sortOrder", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CovenantPreview);