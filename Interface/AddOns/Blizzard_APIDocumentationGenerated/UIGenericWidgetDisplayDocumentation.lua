local UIGenericWidgetDisplay =
{
	Name = "GenericWidgetDisplay",
	Type = "System",
	Namespace = "C_GenericWidgetDisplay",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "GenericWidgetDisplayShow",
			Type = "Event",
			LiteralName = "GENERIC_WIDGET_DISPLAY_SHOW",
			Payload =
			{
				{ Name = "info", Type = "GenericWidgetDisplayFrameInfo", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "GenericWidgetDisplayFrameInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "uiWidgetSetID", Type = "number", Nilable = true },
				{ Name = "uiTextureKit", Type = "string", Nilable = true },
				{ Name = "title", Type = "string", Nilable = true },
				{ Name = "frameWidth", Type = "number", Nilable = false },
				{ Name = "frameHeight", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIGenericWidgetDisplay);