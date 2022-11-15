local TooltipComparison =
{
	Name = "TooltipComparison",
	Type = "System",
	Namespace = "C_TooltipComparison",

	Functions =
	{
		{
			Name = "GetItemComparisonDelta",
			Type = "Function",

			Arguments =
			{
				{ Name = "comparisonItem", Type = "table", Nilable = false },
				{ Name = "equippedItem", Type = "table", Nilable = false },
				{ Name = "pairedItem", Type = "table", Nilable = true },
				{ Name = "addPairedStats", Type = "bool", Nilable = true, Documentation = { "Whether the paired item's stats are added or subtracted" } },
			},

			Returns =
			{
				{ Name = "lines", Type = "table", InnerType = "string", Nilable = false },
			},
		},
		{
			Name = "GetItemComparisonInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "comparisonItem", Type = "table", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "TooltipItemComparisonInfo", Nilable = false },
			},
		},
	},

	Events =
	{
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
				{ Name = "item", Type = "table", Nilable = false },
				{ Name = "additionalItems", Type = "table", InnerType = "table", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(TooltipComparison);