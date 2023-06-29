local UIWidgetManagerShared =
{
	Tables =
	{
		{
			Name = "UIWidgetLayoutDirection",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Default", Type = "UIWidgetLayoutDirection", EnumValue = 0 },
				{ Name = "Vertical", Type = "UIWidgetLayoutDirection", EnumValue = 1 },
				{ Name = "Horizontal", Type = "UIWidgetLayoutDirection", EnumValue = 2 },
				{ Name = "Overlap", Type = "UIWidgetLayoutDirection", EnumValue = 3 },
				{ Name = "HorizontalForceNewRow", Type = "UIWidgetLayoutDirection", EnumValue = 4 },
			},
		},
		{
			Name = "UIWidgetScale",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "OneHundred", Type = "UIWidgetScale", EnumValue = 0 },
				{ Name = "Ninty", Type = "UIWidgetScale", EnumValue = 1 },
				{ Name = "Eighty", Type = "UIWidgetScale", EnumValue = 2 },
				{ Name = "Seventy", Type = "UIWidgetScale", EnumValue = 3 },
				{ Name = "Sixty", Type = "UIWidgetScale", EnumValue = 4 },
				{ Name = "Fifty", Type = "UIWidgetScale", EnumValue = 5 },
			},
		},
		{
			Name = "UIWidgetSetLayoutDirection",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Vertical", Type = "UIWidgetSetLayoutDirection", EnumValue = 0 },
				{ Name = "Horizontal", Type = "UIWidgetSetLayoutDirection", EnumValue = 1 },
			},
		},
		{
			Name = "UIWidgetVisualizationType",
			Type = "Enumeration",
			NumValues = 13,
			MinValue = 0,
			MaxValue = 12,
			Fields =
			{
				{ Name = "IconAndText", Type = "UIWidgetVisualizationType", EnumValue = 0 },
				{ Name = "CaptureBar", Type = "UIWidgetVisualizationType", EnumValue = 1 },
				{ Name = "StatusBar", Type = "UIWidgetVisualizationType", EnumValue = 2 },
				{ Name = "DoubleStatusBar", Type = "UIWidgetVisualizationType", EnumValue = 3 },
				{ Name = "IconTextAndBackground", Type = "UIWidgetVisualizationType", EnumValue = 4 },
				{ Name = "DoubleIconAndText", Type = "UIWidgetVisualizationType", EnumValue = 5 },
				{ Name = "StackedResourceTracker", Type = "UIWidgetVisualizationType", EnumValue = 6 },
				{ Name = "IconTextAndCurrencies", Type = "UIWidgetVisualizationType", EnumValue = 7 },
				{ Name = "TextWithState", Type = "UIWidgetVisualizationType", EnumValue = 8 },
				{ Name = "HorizontalCurrencies", Type = "UIWidgetVisualizationType", EnumValue = 9 },
				{ Name = "BulletTextList", Type = "UIWidgetVisualizationType", EnumValue = 10 },
				{ Name = "ScenarioHeaderCurrenciesAndBackground", Type = "UIWidgetVisualizationType", EnumValue = 11 },
				{ Name = "TextureWithState", Type = "UIWidgetVisualizationType", EnumValue = 12 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIWidgetManagerShared);