local Minimap =
{
	Name = "Minimap",
	Type = "System",
	Namespace = "C_Minimap",

	Functions =
	{
		{
			Name = "CanTrackBattlePets",
			Type = "Function",

			Returns =
			{
				{ Name = "CanTrackBattlePets", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ClearAllTracking",
			Type = "Function",
		},
		{
			Name = "GetDrawGroundTextures",
			Type = "Function",

			Returns =
			{
				{ Name = "draw", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetNumQuestPOIWorldEffects",
			Type = "Function",

			Returns =
			{
				{ Name = "worldEffectCount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumTrackingTypes",
			Type = "Function",

			Returns =
			{
				{ Name = "numTrackingTypes", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetObjectIconTextureCoords",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "textureCoordsX", Type = "number", Nilable = false },
				{ Name = "textureCoordsY", Type = "number", Nilable = false },
				{ Name = "textureCoordsZ", Type = "number", Nilable = false },
				{ Name = "textureCoordsW", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPOITextureCoords",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "textureCoordsX", Type = "number", Nilable = false },
				{ Name = "textureCoordsY", Type = "number", Nilable = false },
				{ Name = "textureCoordsZ", Type = "number", Nilable = false },
				{ Name = "textureCoordsW", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTrackingFilter",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "trackingType", Type = "MinimapScriptTrackingFilter", Nilable = false },
			},
		},
		{
			Name = "GetTrackingInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "textureFileID", Type = "number", Nilable = false },
				{ Name = "active", Type = "bool", Nilable = false },
				{ Name = "type", Type = "string", Nilable = false },
				{ Name = "subType", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetUiMapID",
			Type = "Function",

			Returns =
			{
				{ Name = "uiMapID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetViewRadius",
			Type = "Function",

			Returns =
			{
				{ Name = "yards", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsFilteredOut",
			Type = "Function",

			Arguments =
			{
				{ Name = "filterType", Type = "MinimapTrackingFilter", Nilable = false },
			},

			Returns =
			{
				{ Name = "isFiltered", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRotateMinimapIgnored",
			Type = "Function",

			Returns =
			{
				{ Name = "isIgnored", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsTrackingBattlePets",
			Type = "Function",

			Returns =
			{
				{ Name = "isTrackingBattlePets", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsTrackingHiddenQuests",
			Type = "Function",

			Returns =
			{
				{ Name = "isTrackingHiddenQuests", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetDrawGroundTextures",
			Type = "Function",

			Arguments =
			{
				{ Name = "draw", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetIgnoreRotateMinimap",
			Type = "Function",

			Arguments =
			{
				{ Name = "ignore", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetTracking",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
				{ Name = "on", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldUseHybridMinimap",
			Type = "Function",

			Returns =
			{
				{ Name = "shouldUse", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "MinimapPing",
			Type = "Event",
			LiteralName = "MINIMAP_PING",
			Payload =
			{
				{ Name = "unitTarget", Type = "string", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
				{ Name = "x", Type = "number", Nilable = false },
			},
		},
		{
			Name = "MinimapUpdateTracking",
			Type = "Event",
			LiteralName = "MINIMAP_UPDATE_TRACKING",
		},
		{
			Name = "MinimapUpdateZoom",
			Type = "Event",
			LiteralName = "MINIMAP_UPDATE_ZOOM",
		},
	},

	Tables =
	{
		{
			Name = "MinimapScriptTrackingFilter",
			Type = "Structure",
			Fields =
			{
				{ Name = "spellID", Type = "number", Nilable = true },
				{ Name = "filterID", Type = "MinimapTrackingFilter", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Minimap);