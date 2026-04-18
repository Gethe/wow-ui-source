local HouseExteriorUI =
{
	Name = "HouseExteriorUI",
	Type = "System",
	Namespace = "C_HouseExterior",
	Environment = "All",

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
			Name = "GetCurrentHouseExteriorType",
			Type = "Function",

			Returns =
			{
				{ Name = "houseExteriorTypeID", Type = "number", Nilable = true },
				{ Name = "houseExteriorTypeName", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "GetHouseExteriorSizeOptions",
			Type = "Function",

			Returns =
			{
				{ Name = "options", Type = "HouseExteriorSizeOptionsInfo", Nilable = true },
			},
		},
		{
			Name = "GetHouseExteriorTypeOptions",
			Type = "Function",

			Returns =
			{
				{ Name = "options", Type = "HouseExteriorTypeOptionsInfo", Nilable = true },
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
			Name = "IsAnyDecorAttachedToCoreFixture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if any decor is attached to the specified core fixture type, OR any child fixtures attached to it; Will also return false if the type provided is not a core fixture type, or if not in Exterior Customization mode on an owned plot" },

			Arguments =
			{
				{ Name = "coreFixtureType", Type = "HousingFixtureType", Nilable = false },
			},

			Returns =
			{
				{ Name = "anyAttachedDecor", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAnyDecorAttachedToDoor",
			Type = "Function",
			Documentation = { "Returns true if any decor is attached to the current House Exterior's door; Will also return false if not in Exterior Customization mode on an owned plot" },

			Returns =
			{
				{ Name = "anyAttachedDecor", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAnyDecorAttachedToHouseExterior",
			Type = "Function",
			Documentation = { "Returns true if any decor is attached to any component of the current House Exterior; Will also return false if not in House Exterior Customization mode on an owned Plot" },

			Returns =
			{
				{ Name = "anyAttachedDecor", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAnyDecorAttachedToSelectedFixturePoint",
			Type = "Function",
			Documentation = { "Returns true if any decor is attached to the Fixture occupying the currently selected fixture point; Will also return false if no point is currently selected, or if there is currently no Fixture there" },

			Returns =
			{
				{ Name = "anyAttachedDecor", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsExteriorDecorHidden",
			Type = "Function",

			Returns =
			{
				{ Name = "decorHidden", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RemoveFixtureFromSelectedPoint",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "attachedDecorAction", Type = "HousingFixtureDecorAction", Nilable = false, Default = "Store", Documentation = { "What to do with any decor currently attached to the fixture" } },
			},
		},
		{
			Name = "SelectCoreFixtureOption",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "fixtureID", Type = "number", Nilable = false },
				{ Name = "attachedDecorAction", Type = "HousingFixtureDecorAction", Nilable = false, Default = "Store", Documentation = { "What to do with any decor attached to the old core fixture; If the fixture being swapped is a variant (ie recolor) of the existing one, attached decor will always be reparented directly to the new one" } },
			},
		},
		{
			Name = "SelectFixtureOption",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "fixtureID", Type = "number", Nilable = false },
				{ Name = "attachedDecorAction", Type = "HousingFixtureDecorAction", Nilable = false, Default = "Store", Documentation = { "If this fixture choice is replacing an existing one that has decor attached, what to do with any decor attached to the old one" } },
			},
		},
		{
			Name = "SetExteriorDecorHidden",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "decorHidden", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetHouseExteriorSize",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "size", Type = "HousingFixtureSize", Nilable = false },
				{ Name = "attachedDecorAction", Type = "HousingFixtureDecorAction", Nilable = false, Default = "Store", Documentation = { "What to do with decor attached to any of the house's existing exterior components" } },
			},
		},
		{
			Name = "SetHouseExteriorType",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "houseExteriorTypeID", Type = "number", Nilable = false },
				{ Name = "attachedDecorAction", Type = "HousingFixtureDecorAction", Nilable = false, Default = "Store", Documentation = { "What to do with decor attached to any of the house's existing exterior components" } },
			},
		},
	},

	Events =
	{
		{
			Name = "HouseExteriorDecorHiddenChanged",
			Type = "Event",
			LiteralName = "HOUSE_EXTERIOR_DECOR_HIDDEN_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "isDecorHidden", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HouseExteriorTypeUnlocked",
			Type = "Event",
			LiteralName = "HOUSE_EXTERIOR_TYPE_UNLOCKED",
			UniqueEvent = true,
			Payload =
			{
				{ Name = "fixtureID", Type = "number", Nilable = false },
			},
		},
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
		{
			Name = "HousingFixtureUnlocked",
			Type = "Event",
			LiteralName = "HOUSING_FIXTURE_UNLOCKED",
			UniqueEvent = true,
			Payload =
			{
				{ Name = "fixtureID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HousingSetExteriorHouseSizeResponse",
			Type = "Event",
			LiteralName = "HOUSING_SET_EXTERIOR_HOUSE_SIZE_RESPONSE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "result", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HousingSetExteriorHouseTypeResponse",
			Type = "Event",
			LiteralName = "HOUSING_SET_EXTERIOR_HOUSE_TYPE_RESPONSE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "result", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HousingSetFixtureResponse",
			Type = "Event",
			LiteralName = "HOUSING_SET_FIXTURE_RESPONSE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "result", Type = "HousingResult", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(HouseExteriorUI);