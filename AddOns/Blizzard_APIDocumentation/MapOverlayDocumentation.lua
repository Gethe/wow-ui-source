local MapOverlay =
{
	Name = "MapOverlayInfo",
	Type = "System",
	Namespace = "C_MapOverlayInfo",

	Functions =
	{
		{
			Name = "GetMapOverlays",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "overlayInfo", Type = "table", InnerType = "UiMapOverlayInfo", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "UiMapOverlayHitRect",
			Type = "Structure",
			Fields =
			{
				{ Name = "top", Type = "number", Nilable = false },
				{ Name = "bottom", Type = "number", Nilable = false },
				{ Name = "left", Type = "number", Nilable = false },
				{ Name = "right", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UiMapOverlayInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "textureWidth", Type = "number", Nilable = false },
				{ Name = "textureHeight", Type = "number", Nilable = false },
				{ Name = "offsetX", Type = "number", Nilable = false },
				{ Name = "offsetY", Type = "number", Nilable = false },
				{ Name = "isShownByMouseOver", Type = "bool", Nilable = false },
				{ Name = "fileDataIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "hitRect", Type = "UiMapOverlayHitRect", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(MapOverlay);