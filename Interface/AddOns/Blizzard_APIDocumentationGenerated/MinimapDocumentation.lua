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
			Name = "ClearMinimapInsetInfo",
			Type = "Function",
		},
		{
			Name = "GetDefaultTrackingValue",
			Type = "Function",

			Arguments =
			{
				{ Name = "filterType", Type = "MinimapTrackingFilter", Nilable = false },
			},

			Returns =
			{
				{ Name = "defaultValue", Type = "bool", Nilable = false },
			},
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
				{ Name = "spellIndex", Type = "luaIndex", Nilable = false },
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
				{ Name = "spellIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "trackingInfo", Type = "MinimapScriptTrackingInfo", Nilable = true },
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
			Name = "IsInsideQuestBlob",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isInside", Type = "bool", Nilable = false },
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
			Name = "IsTrackingAccountCompletedQuests",
			Type = "Function",

			Returns =
			{
				{ Name = "IsTrackingAccountCompletedQuests", Type = "bool", Nilable = false },
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
			Name = "SetMinimapInsetInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "minAngle", Type = "number", Nilable = false },
				{ Name = "maxAngle", Type = "number", Nilable = false },
				{ Name = "scalar", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetTracking",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
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
				{ Name = "unitTarget", Type = "UnitToken", Nilable = false },
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
		{
			Name = "PlayerInsideQuestBlobStateChanged",
			Type = "Event",
			LiteralName = "PLAYER_INSIDE_QUEST_BLOB_STATE_CHANGED",
			Payload =
			{
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "isInside", Type = "bool", Nilable = false },
			},
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
		{
			Name = "MinimapScriptTrackingInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "texture", Type = "fileID", Nilable = false },
				{ Name = "active", Type = "bool", Nilable = false },
				{ Name = "type", Type = "cstring", Nilable = false },
				{ Name = "subType", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Minimap);