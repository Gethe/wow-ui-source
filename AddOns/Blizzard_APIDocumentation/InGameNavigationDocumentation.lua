local InGameNavigation =
{
	Name = "InGameNavigation",
	Type = "System",
	Namespace = "C_Navigation",

	Functions =
	{
		{
			Name = "GetDistance",
			Type = "Function",

			Returns =
			{
				{ Name = "distance", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFrame",
			Type = "Function",

			Returns =
			{
				{ Name = "frame", Type = "table", Nilable = true },
			},
		},
		{
			Name = "GetTargetState",
			Type = "Function",

			Returns =
			{
				{ Name = "state", Type = "NavigationState", Nilable = false },
			},
		},
		{
			Name = "HasValidScreenPosition",
			Type = "Function",

			Returns =
			{
				{ Name = "hasValidScreenPosition", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "WasClampedToScreen",
			Type = "Function",

			Returns =
			{
				{ Name = "wasClamped", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "NavigationFrameCreated",
			Type = "Event",
			LiteralName = "NAVIGATION_FRAME_CREATED",
			Payload =
			{
				{ Name = "region", Type = "table", Nilable = false },
			},
		},
		{
			Name = "NavigationFrameDestroyed",
			Type = "Event",
			LiteralName = "NAVIGATION_FRAME_DESTROYED",
		},
	},

	Tables =
	{
		{
			Name = "NavigationState",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Invalid", Type = "NavigationState", EnumValue = 0 },
				{ Name = "Occluded", Type = "NavigationState", EnumValue = 1 },
				{ Name = "InRange", Type = "NavigationState", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(InGameNavigation);