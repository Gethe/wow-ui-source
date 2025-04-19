local UISystemVisibilityManager =
{
	Name = "UISystemVisibilityManager",
	Type = "System",
	Namespace = "C_SystemVisibilityManager",

	Functions =
	{
		{
			Name = "IsSystemVisible",
			Type = "Function",

			Arguments =
			{
				{ Name = "system", Type = "UISystemType", Nilable = false },
			},

			Returns =
			{
				{ Name = "visible", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "SystemVisibilityChanged",
			Type = "Event",
			LiteralName = "SYSTEM_VISIBILITY_CHANGED",
		},
	},

	Tables =
	{
		{
			Name = "UISystemType",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "InGameNavigation", Type = "UISystemType", EnumValue = 0 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UISystemVisibilityManager);