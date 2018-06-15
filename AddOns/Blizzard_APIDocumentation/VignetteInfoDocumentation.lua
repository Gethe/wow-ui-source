local VignetteInfo =
{
	Name = "Vignette",
	Type = "System",
	Namespace = "C_VignetteInfo",

	Functions =
	{
		{
			Name = "FindBestUniqueVignette",
			Type = "Function",

			Arguments =
			{
				{ Name = "vignetteGUIDs", Type = "table", InnerType = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "bestUniqueVignetteIndex", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetVignetteInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "vignetteGUID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "vignetteInfo", Type = "VignetteInfo", Nilable = true },
			},
		},
		{
			Name = "GetVignettePosition",
			Type = "Function",

			Arguments =
			{
				{ Name = "vignetteGUID", Type = "string", Nilable = false },
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "vignettePosition", Type = "table", Mixin = "Vector2DMixin", Nilable = true },
			},
		},
		{
			Name = "GetVignettes",
			Type = "Function",

			Returns =
			{
				{ Name = "vignetteGUIDs", Type = "table", InnerType = "string", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "VignetteMinimapUpdated",
			Type = "Event",
			LiteralName = "VIGNETTE_MINIMAP_UPDATED",
			Payload =
			{
				{ Name = "vignetteGUID", Type = "string", Nilable = false },
				{ Name = "onMinimap", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "VignettesUpdated",
			Type = "Event",
			LiteralName = "VIGNETTES_UPDATED",
		},
	},

	Tables =
	{
		{
			Name = "VignetteType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Normal", Type = "VignetteType", EnumValue = 0 },
				{ Name = "PvpBounty", Type = "VignetteType", EnumValue = 1 },
			},
		},
		{
			Name = "VignetteInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "vignetteGUID", Type = "string", Nilable = false },
				{ Name = "objectGUID", Type = "string", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "isDead", Type = "bool", Nilable = false },
				{ Name = "onWorldMap", Type = "bool", Nilable = false },
				{ Name = "onMinimap", Type = "bool", Nilable = false },
				{ Name = "isUnique", Type = "bool", Nilable = false },
				{ Name = "inFogOfWar", Type = "bool", Nilable = false },
				{ Name = "atlasName", Type = "string", Nilable = false },
				{ Name = "hasTooltip", Type = "bool", Nilable = false },
				{ Name = "vignetteID", Type = "number", Nilable = false },
				{ Name = "type", Type = "VignetteType", Nilable = false },
				{ Name = "rewardQuestID", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(VignetteInfo);