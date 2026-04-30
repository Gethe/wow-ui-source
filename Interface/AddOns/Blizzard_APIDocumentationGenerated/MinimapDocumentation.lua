local Minimap =
{
	Name = "Minimap",
	Type = "System",
	Namespace = "C_Minimap",
	Environment = "All",

	Functions =
	{
		{
			Name = "ClearAllTracking",
			Type = "Function",
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
			Name = "SetTracking",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "on", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "MinimapPing",
			Type = "Event",
			LiteralName = "MINIMAP_PING",
			HasRestrictions = true,
			CallbackEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
				{ Name = "x", Type = "number", Nilable = false },
			},
		},
		{
			Name = "MinimapUpdateTracking",
			Type = "Event",
			LiteralName = "MINIMAP_UPDATE_TRACKING",
			UniqueEvent = true,
		},
		{
			Name = "MinimapUpdateZoom",
			Type = "Event",
			LiteralName = "MINIMAP_UPDATE_ZOOM",
			UniqueEvent = true,
		},
		{
			Name = "PlayerInsideQuestBlobStateChanged",
			Type = "Event",
			LiteralName = "PLAYER_INSIDE_QUEST_BLOB_STATE_CHANGED",
			SynchronousEvent = true,
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
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(Minimap);