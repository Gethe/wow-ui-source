local UIFrameManager =
{
	Name = "UIFrameManager",
	Type = "System",
	Namespace = "C_FrameManager",

	Functions =
	{
		{
			Name = "GetFrameVisibilityState",
			Type = "Function",

			Arguments =
			{
				{ Name = "frameType", Type = "UIFrameType", Nilable = false },
			},

			Returns =
			{
				{ Name = "shouldShow", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "FrameManagerUpdateAll",
			Type = "Event",
			LiteralName = "FRAME_MANAGER_UPDATE_ALL",
		},
		{
			Name = "FrameManagerUpdateFrame",
			Type = "Event",
			LiteralName = "FRAME_MANAGER_UPDATE_FRAME",
			Payload =
			{
				{ Name = "type", Type = "UIFrameType", Nilable = false },
				{ Name = "show", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "UIFrameType",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "JailersTowerBuffs", Type = "UIFrameType", EnumValue = 0 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIFrameManager);