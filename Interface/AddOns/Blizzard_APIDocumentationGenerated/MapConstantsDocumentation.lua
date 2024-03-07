local MapConstants =
{
	Tables =
	{
		{
			Name = "MapCanvasPosition",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "MapCanvasPosition", EnumValue = 0 },
				{ Name = "BottomLeft", Type = "MapCanvasPosition", EnumValue = 1 },
				{ Name = "BottomRight", Type = "MapCanvasPosition", EnumValue = 2 },
				{ Name = "TopLeft", Type = "MapCanvasPosition", EnumValue = 3 },
				{ Name = "TopRight", Type = "MapCanvasPosition", EnumValue = 4 },
			},
		},
		{
			Name = "UIMapFlag",
			Type = "Enumeration",
			NumValues = 20,
			MinValue = 1,
			MaxValue = 524288,
			Fields =
			{
				{ Name = "NoHighlight", Type = "UIMapFlag", EnumValue = 1 },
				{ Name = "ShowOverlays", Type = "UIMapFlag", EnumValue = 2 },
				{ Name = "ShowTaxiNodes", Type = "UIMapFlag", EnumValue = 4 },
				{ Name = "GarrisonMap", Type = "UIMapFlag", EnumValue = 8 },
				{ Name = "FallbackToParentMap", Type = "UIMapFlag", EnumValue = 16 },
				{ Name = "NoHighlightTexture", Type = "UIMapFlag", EnumValue = 32 },
				{ Name = "ShowTaskObjectives", Type = "UIMapFlag", EnumValue = 64 },
				{ Name = "NoWorldPositions", Type = "UIMapFlag", EnumValue = 128 },
				{ Name = "HideArchaeologyDigs", Type = "UIMapFlag", EnumValue = 256 },
				{ Name = "DoNotTranslateBranches", Type = "UIMapFlag", EnumValue = 512 },
				{ Name = "HideIcons", Type = "UIMapFlag", EnumValue = 1024 },
				{ Name = "HideVignettes", Type = "UIMapFlag", EnumValue = 2048 },
				{ Name = "ForceAllOverlayExplored", Type = "UIMapFlag", EnumValue = 4096 },
				{ Name = "FlightMapShowZoomOut", Type = "UIMapFlag", EnumValue = 8192 },
				{ Name = "FlightMapAutoZoom", Type = "UIMapFlag", EnumValue = 16384 },
				{ Name = "ForceOnNavbar", Type = "UIMapFlag", EnumValue = 32768 },
				{ Name = "AlwaysAllowUserWaypoints", Type = "UIMapFlag", EnumValue = 65536 },
				{ Name = "AlwaysAllowTaxiPathing", Type = "UIMapFlag", EnumValue = 131072 },
				{ Name = "ForceAllowMapLinks", Type = "UIMapFlag", EnumValue = 262144 },
				{ Name = "DoNotShowOnNavbar", Type = "UIMapFlag", EnumValue = 524288 },
			},
		},
		{
			Name = "UIMapSystem",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "World", Type = "UIMapSystem", EnumValue = 0 },
				{ Name = "Taxi", Type = "UIMapSystem", EnumValue = 1 },
				{ Name = "Adventure", Type = "UIMapSystem", EnumValue = 2 },
				{ Name = "Minimap", Type = "UIMapSystem", EnumValue = 3 },
			},
		},
		{
			Name = "UIMapType",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "Cosmic", Type = "UIMapType", EnumValue = 0 },
				{ Name = "World", Type = "UIMapType", EnumValue = 1 },
				{ Name = "Continent", Type = "UIMapType", EnumValue = 2 },
				{ Name = "Zone", Type = "UIMapType", EnumValue = 3 },
				{ Name = "Dungeon", Type = "UIMapType", EnumValue = 4 },
				{ Name = "Micro", Type = "UIMapType", EnumValue = 5 },
				{ Name = "Orphan", Type = "UIMapType", EnumValue = 6 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(MapConstants);