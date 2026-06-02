local TooltipComparison =
{
	Name = "TooltipComparison",
	Type = "System",
	Namespace = "C_TooltipComparison",
	Environment = "All",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "TooltipShowItemComparison",
			Type = "Event",
			LiteralName = "TOOLTIP_SHOW_ITEM_COMPARISON",
			CallbackEvent = true,
			Payload =
			{
				{ Name = "comparisonItem", Type = "TooltipComparisonItem", Nilable = false },
				{ Name = "tooltip", Type = "Tooltip", Nilable = false },
				{ Name = "anchorFrame", Type = "SimpleFrame", Nilable = true },
			},
		},
	},

	Tables =
	{
		{
			Name = "TooltipComparisonMethod",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Single", Type = "TooltipComparisonMethod", EnumValue = 0 },
				{ Name = "WithBothHands", Type = "TooltipComparisonMethod", EnumValue = 1 },
				{ Name = "WithBagMainHandItem", Type = "TooltipComparisonMethod", EnumValue = 2 },
				{ Name = "WithBagOffHandItem", Type = "TooltipComparisonMethod", EnumValue = 3 },
			},
		},
		{
			Name = "TooltipItemComparisonInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "method", Type = "TooltipComparisonMethod", Nilable = false, Default = "Single" },
				{ Name = "item", Type = "TooltipComparisonItem", Nilable = false },
				{ Name = "additionalItems", Type = "table", InnerType = "TooltipComparisonItem", Nilable = false },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(TooltipComparison);