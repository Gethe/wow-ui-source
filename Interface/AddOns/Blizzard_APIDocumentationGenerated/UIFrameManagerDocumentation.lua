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
			SecretArguments = "AllowedWhenUntainted",

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
			SynchronousEvent = true,
		},
		{
			Name = "FrameManagerUpdateFrame",
			Type = "Event",
			LiteralName = "FRAME_MANAGER_UPDATE_FRAME",
			SynchronousEvent = true,
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
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "JailersTowerBuffs", Type = "UIFrameType", EnumValue = 0 },
				{ Name = "InterruptTutorial", Type = "UIFrameType", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIFrameManager);