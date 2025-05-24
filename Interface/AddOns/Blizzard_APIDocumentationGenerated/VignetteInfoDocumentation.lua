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
				{ Name = "vignetteGUIDs", Type = "table", InnerType = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "bestUniqueVignetteIndex", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "GetHealthPercent",
			Type = "Function",

			Arguments =
			{
				{ Name = "vignetteGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "healthPct", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetRecommendedGroupSize",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "vignetteGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "minGroupSize", Type = "number", Nilable = false },
				{ Name = "maxGroupSize", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetVignetteInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "vignetteGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "vignetteInfo", Type = "VignetteInfo", Nilable = true },
			},
		},
		{
			Name = "GetVignettePosition",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "vignetteGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "vignettePosition", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
				{ Name = "vignetteFacing", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetVignettes",
			Type = "Function",

			Returns =
			{
				{ Name = "vignetteGUIDs", Type = "table", InnerType = "WOWGUID", Nilable = false },
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
				{ Name = "vignetteGUID", Type = "WOWGUID", Nilable = false },
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
			Name = "VignetteInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "vignetteGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "objectGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "isDead", Type = "bool", Nilable = false },
				{ Name = "onWorldMap", Type = "bool", Nilable = false },
				{ Name = "zoneInfiniteAOI", Type = "bool", Nilable = false },
				{ Name = "onMinimap", Type = "bool", Nilable = false },
				{ Name = "isUnique", Type = "bool", Nilable = false },
				{ Name = "inFogOfWar", Type = "bool", Nilable = false },
				{ Name = "atlasName", Type = "textureAtlas", Nilable = false },
				{ Name = "hasTooltip", Type = "bool", Nilable = false },
				{ Name = "vignetteID", Type = "number", Nilable = false },
				{ Name = "type", Type = "VignetteType", Nilable = false },
				{ Name = "rewardQuestID", Type = "number", Nilable = false },
				{ Name = "tooltipWidgetSet", Type = "number", Nilable = true },
				{ Name = "iconWidgetSet", Type = "number", Nilable = true },
				{ Name = "addPaddingAboveTooltipWidgets", Type = "bool", Nilable = true },
				{ Name = "mapPin", Type = "UIMapPinInfo", Nilable = true },
				{ Name = "objectiveType", Type = "VignetteObjectiveType", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(VignetteInfo);