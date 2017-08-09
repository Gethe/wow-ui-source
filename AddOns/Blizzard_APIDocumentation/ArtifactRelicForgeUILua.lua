local ArtifactRelicForgeUILua =
{
	Name = "ArtifactUI",
	Type = "System",
	Namespace = "C_ArtifactRelicForgeUI",

	Functions =
	{
		{
			Name = "AddRelicTalent",
			Type = "Function",

			Arguments =
			{
				{ Name = "slotIndex", Type = "number", Nilable = false },
				{ Name = "talentIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "AttunePreviewRelic",
			Type = "Function",
		},
		{
			Name = "AttuneSocketedRelic",
			Type = "Function",

			Arguments =
			{
				{ Name = "relicSlotIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CanSetPreviewRelicFromCursor",
			Type = "Function",

			Returns =
			{
				{ Name = "canSet", Type = "bool", Nilable = false, Default = false },
				{ Name = "bindWarning", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "Clear",
			Type = "Function",
		},
		{
			Name = "ClearPreviewRelic",
			Type = "Function",
		},
		{
			Name = "GetPreviewRelicAttuneInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "isAttuned", Type = "bool", Nilable = false },
				{ Name = "canAttune", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetPreviewRelicItemID",
			Type = "Function",

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetPreviewRelicItemLink",
			Type = "Function",

			Returns =
			{
				{ Name = "link", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetPreviewRelicTalents",
			Type = "Function",

			Returns =
			{
				{ Name = "talents", Type = "table", InnerType = "ArtifactRelicTalentInfo", Nilable = false },
			},
		},
		{
			Name = "GetSocketedRelicTalents",
			Type = "Function",

			Arguments =
			{
				{ Name = "relicSlotIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "talents", Type = "table", InnerType = "ArtifactRelicTalentInfo", Nilable = false },
			},
		},
		{
			Name = "IsAtForge",
			Type = "Function",

			Returns =
			{
				{ Name = "isAtForge", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PickUpPreviewRelic",
			Type = "Function",
		},
		{
			Name = "SetPreviewRelicFromCursor",
			Type = "Function",

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "ArtifactRelicTalentInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "powerID", Type = "number", Nilable = false, Default = 0 },
				{ Name = "icon", Type = "number", Nilable = false, Default = 0 },
				{ Name = "canChoose", Type = "bool", Nilable = false, Default = false },
				{ Name = "isChosen", Type = "bool", Nilable = false, Default = false },
				{ Name = "tier", Type = "number", Nilable = false, Default = 0 },
				{ Name = "requiredArtifactLevel", Type = "number", Nilable = false, Default = 0 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ArtifactRelicForgeUILua);