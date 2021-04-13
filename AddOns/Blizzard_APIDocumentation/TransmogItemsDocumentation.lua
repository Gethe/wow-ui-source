local TransmogItems =
{
	Name = "TransmogrifyCollection",
	Type = "System",
	Namespace = "C_TransmogCollection",

	Functions =
	{
		{
			Name = "CanAppearanceHaveIllusion",
			Type = "Function",

			Arguments =
			{
				{ Name = "appearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canHaveIllusion", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "DeleteOutfit",
			Type = "Function",

			Arguments =
			{
				{ Name = "outfitID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetAppearanceSources",
			Type = "Function",

			Arguments =
			{
				{ Name = "appearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "sources", Type = "table", InnerType = "AppearanceSourceInfo", Nilable = false },
			},
		},
		{
			Name = "GetArtifactAppearanceStrings",
			Type = "Function",

			Arguments =
			{
				{ Name = "appearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "hyperlink", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetFallbackWeaponAppearance",
			Type = "Function",

			Returns =
			{
				{ Name = "appearanceID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetIllusionInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "illusionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "TransmogIllusionInfo", Nilable = false },
			},
		},
		{
			Name = "GetInspectItemTransmogInfoList",
			Type = "Function",

			Returns =
			{
				{ Name = "list", Type = "table", InnerType = "table", Nilable = false },
			},
		},
		{
			Name = "GetNumMaxOutfits",
			Type = "Function",

			Returns =
			{
				{ Name = "maxOutfits", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetOutfitInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "outfitID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetOutfitItemTransmogInfoList",
			Type = "Function",

			Arguments =
			{
				{ Name = "outfitID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "list", Type = "table", InnerType = "table", Nilable = false },
			},
		},
		{
			Name = "GetOutfits",
			Type = "Function",

			Returns =
			{
				{ Name = "outfitID", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetSourceIcon",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "icon", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSourceInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "sourceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "sourceInfo", Type = "AppearanceSourceInfo", Nilable = false },
			},
		},
		{
			Name = "IsAppearanceHiddenVisual",
			Type = "Function",

			Arguments =
			{
				{ Name = "appearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isHiddenVisual", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ModifyOutfit",
			Type = "Function",

			Arguments =
			{
				{ Name = "outfitID", Type = "number", Nilable = false },
				{ Name = "itemTransmogInfoList", Type = "table", InnerType = "table", Nilable = false },
			},
		},
		{
			Name = "NewOutfit",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "itemTransmogInfoList", Type = "table", InnerType = "table", Nilable = false },
			},

			Returns =
			{
				{ Name = "outfitID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "RenameOutfit",
			Type = "Function",

			Arguments =
			{
				{ Name = "outfitID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "TransmogIllusionInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "visualID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "hyperlink", Type = "string", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "isCollected", Type = "bool", Nilable = false },
				{ Name = "isUsable", Type = "bool", Nilable = false },
				{ Name = "isHiddenVisual", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(TransmogItems);