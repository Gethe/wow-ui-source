local TooltipInfo =
{
	Name = "TooltipInfo",
	Type = "System",
	Namespace = "C_TooltipInfo",
	Environment = "All",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "HideHyperlinkTooltip",
			Type = "Event",
			LiteralName = "HIDE_HYPERLINK_TOOLTIP",
			SynchronousEvent = true,
		},
		{
			Name = "ShowHyperlinkTooltip",
			Type = "Event",
			LiteralName = "SHOW_HYPERLINK_TOOLTIP",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "hyperlink", Type = "string", Nilable = false },
			},
		},
		{
			Name = "TooltipDataUpdate",
			Type = "Event",
			LiteralName = "TOOLTIP_DATA_UPDATE",
			UniqueEvent = true,
			Documentation = { "Sends an update to the UI that a sparse or cache lookup has resolved" },
			Payload =
			{
				{ Name = "dataInstanceID", Type = "number", Nilable = true },
			},
		},
	},

	Tables =
	{
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(TooltipInfo);