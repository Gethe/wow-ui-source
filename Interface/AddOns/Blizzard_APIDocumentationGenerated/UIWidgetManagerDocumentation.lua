local UIWidgetManager =
{
	Name = "UIWidgetManager",
	Type = "System",
	Namespace = "C_UIWidgetManager",

	Functions =
	{
		{
			Name = "GetAllWidgetsBySetID",
			Type = "Function",

			Arguments =
			{
				{ Name = "setID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgets", Type = "table", InnerType = "UIWidgetInfo", Nilable = false },
			},
		},
		{
			Name = "GetBelowMinimapWidgetSetID",
			Type = "Function",

			Returns =
			{
				{ Name = "setID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetBulletTextListWidgetVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "BulletTextListWidgetVisualizationInfo", Nilable = true },
			},
		},
		{
			Name = "GetCaptureBarWidgetVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "CaptureBarWidgetVisualizationInfo", Nilable = true },
			},
		},
		{
			Name = "GetDoubleIconAndTextWidgetVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "DoubleIconAndTextWidgetVisualizationInfo", Nilable = true },
			},
		},
		{
			Name = "GetDoubleStatusBarWidgetVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "DoubleStatusBarWidgetVisualizationInfo", Nilable = true },
			},
		},
		{
			Name = "GetHorizontalCurrenciesWidgetVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "HorizontalCurrenciesWidgetVisualizationInfo", Nilable = true },
			},
		},
		{
			Name = "GetIconAndTextWidgetVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "IconAndTextWidgetVisualizationInfo", Nilable = true },
			},
		},
		{
			Name = "GetIconTextAndBackgroundWidgetVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "IconTextAndBackgroundWidgetVisualizationInfo", Nilable = true },
			},
		},
		{
			Name = "GetIconTextAndCurrenciesWidgetVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "IconTextAndCurrenciesWidgetVisualizationInfo", Nilable = true },
			},
		},
		{
			Name = "GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "ScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo", Nilable = true },
			},
		},
		{
			Name = "GetStackedResourceTrackerWidgetVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "StackedResourceTrackerWidgetVisualizationInfo", Nilable = true },
			},
		},
		{
			Name = "GetStatusBarWidgetVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "StatusBarWidgetVisualizationInfo", Nilable = true },
			},
		},
		{
			Name = "GetTextWithStateWidgetVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "TextWithStateWidgetVisualizationInfo", Nilable = true },
			},
		},
		{
			Name = "GetTextureWithStateVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "TextureWithStateVisualizationInfo", Nilable = true },
			},
		},
		{
			Name = "GetTopCenterWidgetSetID",
			Type = "Function",

			Returns =
			{
				{ Name = "setID", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "UpdateAllUiWidgets",
			Type = "Event",
			LiteralName = "UPDATE_ALL_UI_WIDGETS",
		},
		{
			Name = "UpdateUiWidget",
			Type = "Event",
			LiteralName = "UPDATE_UI_WIDGET",
			Payload =
			{
				{ Name = "widgetInfo", Type = "UIWidgetInfo", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "IconAndTextWidgetState",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Hidden", Type = "IconAndTextWidgetState", EnumValue = 0 },
				{ Name = "Shown", Type = "IconAndTextWidgetState", EnumValue = 1 },
				{ Name = "ShownWithDynamicIconFlashing", Type = "IconAndTextWidgetState", EnumValue = 2 },
				{ Name = "ShownWithDynamicIconNotFlashing", Type = "IconAndTextWidgetState", EnumValue = 3 },
			},
		},
		{
			Name = "WidgetEnabledState",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Disabled", Type = "WidgetEnabledState", EnumValue = 0 },
				{ Name = "Enabled", Type = "WidgetEnabledState", EnumValue = 1 },
				{ Name = "Red", Type = "WidgetEnabledState", EnumValue = 2 },
				{ Name = "Highlight", Type = "WidgetEnabledState", EnumValue = 3 },
			},
		},
		{
			Name = "WidgetShownState",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Hidden", Type = "WidgetShownState", EnumValue = 0 },
				{ Name = "Shown", Type = "WidgetShownState", EnumValue = 1 },
			},
		},
		{
			Name = "BulletTextListWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "enabledState", Type = "WidgetEnabledState", Nilable = false },
				{ Name = "lines", Type = "table", InnerType = "string", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CaptureBarWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "barPercent", Type = "number", Nilable = false },
				{ Name = "neutralPercent", Type = "number", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
			},
		},
		{
			Name = "DoubleIconAndTextWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "label", Type = "string", Nilable = false },
				{ Name = "leftText", Type = "string", Nilable = false },
				{ Name = "leftTooltip", Type = "string", Nilable = false },
				{ Name = "rightText", Type = "string", Nilable = false },
				{ Name = "rightTooltip", Type = "string", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
			},
		},
		{
			Name = "DoubleStatusBarWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "leftBarMin", Type = "number", Nilable = false },
				{ Name = "leftBarMax", Type = "number", Nilable = false },
				{ Name = "leftBarValue", Type = "number", Nilable = false },
				{ Name = "rightBarMin", Type = "number", Nilable = false },
				{ Name = "rightBarMax", Type = "number", Nilable = false },
				{ Name = "rightBarValue", Type = "number", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
			},
		},
		{
			Name = "HorizontalCurrenciesWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "currencies", Type = "table", InnerType = "UIWidgetCurrencyInfo", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
			},
		},
		{
			Name = "IconAndTextWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "state", Type = "IconAndTextWidgetState", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
				{ Name = "dynamicTooltip", Type = "string", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
			},
		},
		{
			Name = "IconTextAndBackgroundWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "value", Type = "number", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
			},
		},
		{
			Name = "IconTextAndCurrenciesWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "enabledState", Type = "WidgetEnabledState", Nilable = false },
				{ Name = "descriptionShownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "descriptionEnabledState", Type = "WidgetEnabledState", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "currencies", Type = "table", InnerType = "UIWidgetCurrencyInfo", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "currencies", Type = "table", InnerType = "UIWidgetCurrencyInfo", Nilable = false },
				{ Name = "frameTextureKitID", Type = "number", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
			},
		},
		{
			Name = "StackedResourceTrackerWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "resources", Type = "table", InnerType = "UIWidgetCurrencyInfo", Nilable = false },
				{ Name = "frameTextureKitID", Type = "number", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
			},
		},
		{
			Name = "StatusBarWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "barMin", Type = "number", Nilable = false },
				{ Name = "barMax", Type = "number", Nilable = false },
				{ Name = "barValue", Type = "number", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "barWidth", Type = "number", Nilable = false },
				{ Name = "barValueInSeconds", Type = "number", Nilable = false },
				{ Name = "frameTextureKitID", Type = "number", Nilable = false },
				{ Name = "fillTextureKitID", Type = "number", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
			},
		},
		{
			Name = "TextWithStateWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "enabledState", Type = "WidgetEnabledState", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "widgetWidth", Type = "number", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
			},
		},
		{
			Name = "TextureWithStateVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "backgroundTextureKitID", Type = "number", Nilable = false },
				{ Name = "portraitTextureKitID", Type = "number", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
			},
		},
		{
			Name = "UIWidgetCurrencyInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "iconFileID", Type = "fileID", Nilable = false },
				{ Name = "leadingText", Type = "string", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
				{ Name = "isCurrencyMaxed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UIWidgetInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
				{ Name = "widgetSetID", Type = "number", Nilable = false },
				{ Name = "widgetType", Type = "UIWidgetVisualizationType", Nilable = false },
			},
		},
		{
			Name = "UIWidgetTextTooltipPair",
			Type = "Structure",
			Fields =
			{
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIWidgetManager);