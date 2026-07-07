local HousingInspectModeUI =
{
	Name = "HousingInspectModeUI",
	Type = "System",
	Namespace = "C_HousingInspectMode",
	Environment = "All",

	Functions =
	{
		{
			Name = "EnterInspectMode",
			Type = "Function",
			Documentation = { "Enters inspect mode, enabling decor inspection" },
		},
		{
			Name = "ExitInspectMode",
			Type = "Function",
			Documentation = { "Exits inspect mode, disabling decor inspection" },
		},
		{
			Name = "GetHoveredDecorGUID",
			Type = "Function",
			Documentation = { "Returns the GUID of the decor instance currently being hovered, if there is one" },

			Returns =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "IsHoveringDecor",
			Type = "Function",
			Documentation = { "Returns true if a decor instance is currently being hovered in inspect mode" },

			Returns =
			{
				{ Name = "isHoveringDecor", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsInInspectMode",
			Type = "Function",
			Documentation = { "Returns true if the player is currently in inspect mode" },

			Returns =
			{
				{ Name = "isInInspectMode", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "HousingInspectModeDecorHoveredChanged",
			Type = "Event",
			LiteralName = "HOUSING_INSPECT_MODE_DECOR_HOVERED_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "HousingInspectModeStateUpdated",
			Type = "Event",
			LiteralName = "HOUSING_INSPECT_MODE_STATE_UPDATED",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(HousingInspectModeUI);