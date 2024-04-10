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
				{ Name = "frame", Type = "ScriptRegion", Nilable = true },
			},
		},
		{
			Name = "GetNearestPartyMemberToken",
			Type = "Function",

			Returns =
			{
				{ Name = "unitToken", Type = "cstring", Nilable = false },
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
				{ Name = "region", Type = "ScriptRegion", Nilable = false },
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
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Invalid", Type = "NavigationState", EnumValue = 0 },
				{ Name = "Occluded", Type = "NavigationState", EnumValue = 1 },
				{ Name = "InRange", Type = "NavigationState", EnumValue = 2 },
				{ Name = "Disabled", Type = "NavigationState", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(InGameNavigation);