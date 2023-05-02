local UIGenericWidgetDisplay =
{
	Name = "GenericWidgetDisplay",
	Type = "System",
	Namespace = "C_GenericWidgetDisplay",

	Functions =
	{
		{
			Name = "Acknowledge",
			Type = "Function",
		},
		{
			Name = "Close",
			Type = "Function",
		},
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
				{ Name = "uiTextureKit", Type = "textureKit", Nilable = true },
				{ Name = "title", Type = "string", Nilable = true },
				{ Name = "frameWidth", Type = "number", Nilable = false },
				{ Name = "frameHeight", Type = "number", Nilable = false },
				{ Name = "extraButtonText", Type = "string", Nilable = true },
				{ Name = "closeButtonText", Type = "string", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIGenericWidgetDisplay);