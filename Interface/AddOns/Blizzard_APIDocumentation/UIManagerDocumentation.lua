local UIManager =
{
	Name = "UI",
	Type = "System",
	Namespace = "C_UI",

	Functions =
	{
		{
			Name = "Reload",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "UiScaleChanged",
			Type = "Event",
			LiteralName = "UI_SCALE_CHANGED",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(UIManager);