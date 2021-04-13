local UIFrameManager =
{
	Name = "UIFrameManager",
	Type = "System",
	Namespace = "C_FrameManager",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "FrameManagerHideFrame",
			Type = "Event",
			LiteralName = "FRAME_MANAGER_HIDE_FRAME",
			Payload =
			{
				{ Name = "type", Type = "UIFrameType", Nilable = false },
			},
		},
		{
			Name = "FrameManagerShowFrame",
			Type = "Event",
			LiteralName = "FRAME_MANAGER_SHOW_FRAME",
			Payload =
			{
				{ Name = "type", Type = "UIFrameType", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "UIFrameDataSource",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "WorldState", Type = "UIFrameDataSource", EnumValue = 0 },
			},
		},
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