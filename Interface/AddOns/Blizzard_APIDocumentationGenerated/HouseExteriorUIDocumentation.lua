local HouseExteriorUI =
{
	Name = "HouseExteriorUI",
	Type = "System",
	Namespace = "C_HouseExterior",

	Functions =
	{
		{
			Name = "CancelActiveExteriorEditing",
			Type = "Function",
		},
		{
			Name = "GetCoreFixtureOptionsInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "coreFixtureType", Type = "HousingFixtureType", Nilable = false },
			},

			Returns =
			{
				{ Name = "coreFixtureOptionsInfo", Type = "HousingCoreFixtureInfo", Nilable = true },
			},
		},
		{
			Name = "GetCurrentHouseExteriorSize",
			Type = "Function",

			Returns =
			{
				{ Name = "houseExteriorSize", Type = "HousingFixtureSize", Nilable = true },
			},
		},
		{
			Name = "GetCurrentHouseExteriorTypeName",
			Type = "Function",

			Returns =
			{
				{ Name = "houseExteriorTypeName", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "GetSelectedFixturePointInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "fixturePointInfo", Type = "HousingFixturePointInfo", Nilable = true },
			},
		},
		{
			Name = "HasHoveredFixture",
			Type = "Function",

			Returns =
			{
				{ Name = "anyHoveredFixture", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasSelectedFixturePoint",
			Type = "Function",

			Returns =
			{
				{ Name = "anySelectedFixturePoint", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RemoveFixtureFromSelectedPoint",
			Type = "Function",
		},
		{
			Name = "SelectCoreFixtureOption",
			Type = "Function",

			Arguments =
			{
				{ Name = "fixtureID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SelectFixtureOption",
			Type = "Function",

			Arguments =
			{
				{ Name = "fixtureID", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "HousingCoreFixtureChanged",
			Type = "Event",
			LiteralName = "HOUSING_CORE_FIXTURE_CHANGED",
			Payload =
			{
				{ Name = "coreFixtureType", Type = "HousingFixtureType", Nilable = false },
			},
		},
		{
			Name = "HousingFixtureHoverChanged",
			Type = "Event",
			LiteralName = "HOUSING_FIXTURE_HOVER_CHANGED",
			Payload =
			{
				{ Name = "anyHovered", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HousingFixturePointFrameAdded",
			Type = "Event",
			LiteralName = "HOUSING_FIXTURE_POINT_FRAME_ADDED",
			Payload =
			{
				{ Name = "pointFrame", Type = "HousingFixturePointFrame", Nilable = false },
			},
		},
		{
			Name = "HousingFixturePointFrameReleased",
			Type = "Event",
			LiteralName = "HOUSING_FIXTURE_POINT_FRAME_RELEASED",
			Payload =
			{
				{ Name = "pointFrame", Type = "HousingFixturePointFrame", Nilable = false },
			},
		},
		{
			Name = "HousingFixturePointFramesReleased",
			Type = "Event",
			LiteralName = "HOUSING_FIXTURE_POINT_FRAMES_RELEASED",
		},
		{
			Name = "HousingFixturePointSelectionChanged",
			Type = "Event",
			LiteralName = "HOUSING_FIXTURE_POINT_SELECTION_CHANGED",
			Payload =
			{
				{ Name = "hasSelection", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(HouseExteriorUI);