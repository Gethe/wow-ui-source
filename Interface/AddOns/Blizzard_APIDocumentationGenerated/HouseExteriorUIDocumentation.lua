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
			Documentation = { "Cancels all in-progress editing of house exterior fixtures, which will deselect any active targets" },
		},
		{
			Name = "GetCoreFixtureOptionsInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "fixtureID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SelectFixtureOption",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			UniqueEvent = true,
			Payload =
			{
				{ Name = "coreFixtureType", Type = "HousingFixtureType", Nilable = false },
			},
		},
		{
			Name = "HousingFixtureHoverChanged",
			Type = "Event",
			LiteralName = "HOUSING_FIXTURE_HOVER_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "anyHovered", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HousingFixturePointFrameAdded",
			Type = "Event",
			LiteralName = "HOUSING_FIXTURE_POINT_FRAME_ADDED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "pointFrame", Type = "HousingFixturePointFrame", Nilable = false },
			},
		},
		{
			Name = "HousingFixturePointFrameReleased",
			Type = "Event",
			LiteralName = "HOUSING_FIXTURE_POINT_FRAME_RELEASED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "pointFrame", Type = "HousingFixturePointFrame", Nilable = false },
			},
		},
		{
			Name = "HousingFixturePointFramesReleased",
			Type = "Event",
			LiteralName = "HOUSING_FIXTURE_POINT_FRAMES_RELEASED",
			SynchronousEvent = true,
		},
		{
			Name = "HousingFixturePointSelectionChanged",
			Type = "Event",
			LiteralName = "HOUSING_FIXTURE_POINT_SELECTION_CHANGED",
			SynchronousEvent = true,
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