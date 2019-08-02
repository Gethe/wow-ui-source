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
			Name = "GetCaptureZoneVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "CaptureZoneVisualizationInfo", Nilable = true },
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
			Name = "GetDoubleStateIconRowVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "DoubleStateIconRowVisualizationInfo", Nilable = true },
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
			Name = "GetObjectiveTrackerWidgetSetID",
			Type = "Function",

			Returns =
			{
				{ Name = "setID", Type = "number", Nilable = false },
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
			Name = "GetSpellDisplayVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "SpellDisplayVisualizationInfo", Nilable = true },
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
			Name = "GetTextureAndTextRowVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "TextureAndTextRowVisualizationInfo", Nilable = true },
			},
		},
		{
			Name = "GetTextureAndTextVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "TextureAndTextVisualizationInfo", Nilable = true },
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
		{
			Name = "GetZoneControlVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "ZoneControlVisualizationInfo", Nilable = true },
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
			Name = "WidgetAnimationType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "None", Type = "WidgetAnimationType", EnumValue = 0 },
				{ Name = "Fade", Type = "WidgetAnimationType", EnumValue = 1 },
			},
		},
		{
			Name = "CaptureBarWidgetGlowAnimType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "None", Type = "CaptureBarWidgetGlowAnimType", EnumValue = 0 },
				{ Name = "Pulse", Type = "CaptureBarWidgetGlowAnimType", EnumValue = 1 },
			},
		},
		{
			Name = "ZoneControlMode",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "BothStatesAreGood", Type = "ZoneControlMode", EnumValue = 0 },
				{ Name = "State1IsGood", Type = "ZoneControlMode", EnumValue = 1 },
				{ Name = "State2IsGood", Type = "ZoneControlMode", EnumValue = 2 },
				{ Name = "NeitherStateIsGood", Type = "ZoneControlMode", EnumValue = 3 },
			},
		},
		{
			Name = "ZoneControlLeadingEdgeType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "NoLeadingEdge", Type = "ZoneControlLeadingEdgeType", EnumValue = 0 },
				{ Name = "UseLeadingEdge", Type = "ZoneControlLeadingEdgeType", EnumValue = 1 },
			},
		},
		{
			Name = "ZoneControlDangerFlashType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "ShowOnGoodStates", Type = "ZoneControlDangerFlashType", EnumValue = 0 },
				{ Name = "ShowOnBadStates", Type = "ZoneControlDangerFlashType", EnumValue = 1 },
				{ Name = "ShowOnBoth", Type = "ZoneControlDangerFlashType", EnumValue = 2 },
				{ Name = "ShowOnNeither", Type = "ZoneControlDangerFlashType", EnumValue = 3 },
			},
		},
		{
			Name = "ZoneControlState",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "State1", Type = "ZoneControlState", EnumValue = 0 },
				{ Name = "State2", Type = "ZoneControlState", EnumValue = 1 },
			},
		},
		{
			Name = "ZoneControlActiveState",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Inactive", Type = "ZoneControlActiveState", EnumValue = 0 },
				{ Name = "Active", Type = "ZoneControlActiveState", EnumValue = 1 },
			},
		},
		{
			Name = "ZoneControlFillType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "SingleFillClockwise", Type = "ZoneControlFillType", EnumValue = 0 },
				{ Name = "SingleFillCounterClockwise", Type = "ZoneControlFillType", EnumValue = 1 },
				{ Name = "DoubleFillClockwise", Type = "ZoneControlFillType", EnumValue = 2 },
				{ Name = "DoubleFillCounterClockwise", Type = "ZoneControlFillType", EnumValue = 3 },
			},
		},
		{
			Name = "IconState",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Hidden", Type = "IconState", EnumValue = 0 },
				{ Name = "ShowState1", Type = "IconState", EnumValue = 1 },
				{ Name = "ShowState2", Type = "IconState", EnumValue = 2 },
			},
		},
		{
			Name = "StatusBarValueTextType",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "Hidden", Type = "StatusBarValueTextType", EnumValue = 0 },
				{ Name = "Percentage", Type = "StatusBarValueTextType", EnumValue = 1 },
				{ Name = "Value", Type = "StatusBarValueTextType", EnumValue = 2 },
				{ Name = "Time", Type = "StatusBarValueTextType", EnumValue = 3 },
				{ Name = "TimeShowOneLevelOnly", Type = "StatusBarValueTextType", EnumValue = 4 },
				{ Name = "ValueOverMax", Type = "StatusBarValueTextType", EnumValue = 5 },
				{ Name = "ValueOverMaxNormalized", Type = "StatusBarValueTextType", EnumValue = 6 },
			},
		},
		{
			Name = "UIWidgetVisualizationType",
			Type = "Enumeration",
			NumValues = 18,
			MinValue = 0,
			MaxValue = 17,
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
				{ Name = "TextureAndText", Type = "UIWidgetVisualizationType", EnumValue = 12 },
				{ Name = "SpellDisplay", Type = "UIWidgetVisualizationType", EnumValue = 13 },
				{ Name = "DoubleStateIconRow", Type = "UIWidgetVisualizationType", EnumValue = 14 },
				{ Name = "TextureAndTextRow", Type = "UIWidgetVisualizationType", EnumValue = 15 },
				{ Name = "ZoneControl", Type = "UIWidgetVisualizationType", EnumValue = 16 },
				{ Name = "CaptureZone", Type = "UIWidgetVisualizationType", EnumValue = 17 },
			},
		},
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
			Name = "SpellDisplayIconSizeType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Small", Type = "SpellDisplayIconSizeType", EnumValue = 0 },
				{ Name = "Medium", Type = "SpellDisplayIconSizeType", EnumValue = 1 },
				{ Name = "Large", Type = "SpellDisplayIconSizeType", EnumValue = 2 },
			},
		},
		{
			Name = "SpellDisplayIconDisplayType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Buff", Type = "SpellDisplayIconDisplayType", EnumValue = 0 },
				{ Name = "Debuff", Type = "SpellDisplayIconDisplayType", EnumValue = 1 },
			},
		},
		{
			Name = "StatusBarOverrideBarTextShownType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Never", Type = "StatusBarOverrideBarTextShownType", EnumValue = 0 },
				{ Name = "Always", Type = "StatusBarOverrideBarTextShownType", EnumValue = 1 },
				{ Name = "OnlyOnMouseover", Type = "StatusBarOverrideBarTextShownType", EnumValue = 2 },
				{ Name = "OnlyNotOnMouseover", Type = "StatusBarOverrideBarTextShownType", EnumValue = 3 },
			},
		},
		{
			Name = "UIWidgetTextSizeType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Small", Type = "UIWidgetTextSizeType", EnumValue = 0 },
				{ Name = "Medium", Type = "UIWidgetTextSizeType", EnumValue = 1 },
				{ Name = "Large", Type = "UIWidgetTextSizeType", EnumValue = 2 },
				{ Name = "Huge", Type = "UIWidgetTextSizeType", EnumValue = 3 },
			},
		},
		{
			Name = "WidgetCurrencyClass",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Currency", Type = "WidgetCurrencyClass", EnumValue = 0 },
				{ Name = "Item", Type = "WidgetCurrencyClass", EnumValue = 1 },
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
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "frameTextureKitID", Type = "number", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
			},
		},
		{
			Name = "CaptureBarWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "barValue", Type = "number", Nilable = false },
				{ Name = "barMinValue", Type = "number", Nilable = false },
				{ Name = "barMaxValue", Type = "number", Nilable = false },
				{ Name = "neutralZoneSize", Type = "number", Nilable = false },
				{ Name = "neutralZoneCenter", Type = "number", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
				{ Name = "glowAnimType", Type = "CaptureBarWidgetGlowAnimType", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "frameTextureKitID", Type = "number", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
			},
		},
		{
			Name = "ZoneEntry",
			Type = "Structure",
			Fields =
			{
				{ Name = "state", Type = "ZoneControlState", Nilable = false },
				{ Name = "activeState", Type = "ZoneControlActiveState", Nilable = false },
				{ Name = "fillType", Type = "ZoneControlFillType", Nilable = false },
				{ Name = "min", Type = "number", Nilable = false },
				{ Name = "max", Type = "number", Nilable = false },
				{ Name = "current", Type = "number", Nilable = false },
				{ Name = "capturePoint", Type = "number", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CaptureZoneVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "mode", Type = "ZoneControlMode", Nilable = false },
				{ Name = "leadingEdgeType", Type = "ZoneControlLeadingEdgeType", Nilable = false },
				{ Name = "dangerFlashType", Type = "ZoneControlDangerFlashType", Nilable = false },
				{ Name = "zoneInfo", Type = "ZoneEntry", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "frameTextureKitID", Type = "number", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
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
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "frameTextureKitID", Type = "number", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
			},
		},
		{
			Name = "UIWidgetStateIconInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "iconState", Type = "IconState", Nilable = false },
				{ Name = "state1Tooltip", Type = "string", Nilable = false },
				{ Name = "state2Tooltip", Type = "string", Nilable = false },
			},
		},
		{
			Name = "DoubleStateIconRowVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "leftIcons", Type = "table", InnerType = "UIWidgetStateIconInfo", Nilable = false },
				{ Name = "rightIcons", Type = "table", InnerType = "UIWidgetStateIconInfo", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "frameTextureKitID", Type = "number", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
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
				{ Name = "leftBarTooltip", Type = "string", Nilable = false },
				{ Name = "rightBarMin", Type = "number", Nilable = false },
				{ Name = "rightBarMax", Type = "number", Nilable = false },
				{ Name = "rightBarValue", Type = "number", Nilable = false },
				{ Name = "rightBarTooltip", Type = "string", Nilable = false },
				{ Name = "barValueTextType", Type = "StatusBarValueTextType", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "frameTextureKitID", Type = "number", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
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
			Name = "UIWidgetCurrencyInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "iconFileID", Type = "number", Nilable = false },
				{ Name = "leadingText", Type = "string", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
				{ Name = "isCurrencyMaxed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HorizontalCurrenciesWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "currencies", Type = "table", InnerType = "UIWidgetCurrencyInfo", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "frameTextureKitID", Type = "number", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
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
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "frameTextureKitID", Type = "number", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
			},
		},
		{
			Name = "IconTextAndBackgroundWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "frameTextureKitID", Type = "number", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
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
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "frameTextureKitID", Type = "number", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
			},
		},
		{
			Name = "ScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "currencies", Type = "table", InnerType = "UIWidgetCurrencyInfo", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "frameTextureKitID", Type = "number", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
			},
		},
		{
			Name = "UIWidgetSpellInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "stackDisplay", Type = "number", Nilable = false },
				{ Name = "iconSizeType", Type = "SpellDisplayIconSizeType", Nilable = false },
				{ Name = "iconDisplayType", Type = "SpellDisplayIconDisplayType", Nilable = false },
			},
		},
		{
			Name = "SpellDisplayVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "enabledState", Type = "WidgetEnabledState", Nilable = false },
				{ Name = "spellInfo", Type = "UIWidgetSpellInfo", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "frameTextureKitID", Type = "number", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
			},
		},
		{
			Name = "StackedResourceTrackerWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "resources", Type = "table", InnerType = "UIWidgetCurrencyInfo", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "frameTextureKitID", Type = "number", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
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
				{ Name = "tooltip", Type = "string", Nilable = false },
				{ Name = "barValueTextType", Type = "StatusBarValueTextType", Nilable = false },
				{ Name = "overrideBarText", Type = "string", Nilable = false },
				{ Name = "overrideBarTextShownType", Type = "StatusBarOverrideBarTextShownType", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "frameTextureKitID", Type = "number", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
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
				{ Name = "tooltip", Type = "string", Nilable = false },
				{ Name = "textSizeType", Type = "UIWidgetTextSizeType", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "frameTextureKitID", Type = "number", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
			},
		},
		{
			Name = "TextureAndTextEntryInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
			},
		},
		{
			Name = "TextureAndTextRowVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "entries", Type = "table", InnerType = "TextureAndTextEntryInfo", Nilable = false },
				{ Name = "textSizeType", Type = "UIWidgetTextSizeType", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "frameTextureKitID", Type = "number", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
			},
		},
		{
			Name = "TextureAndTextVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "frameTextureKitID", Type = "number", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
			},
		},
		{
			Name = "ZoneControlVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "mode", Type = "ZoneControlMode", Nilable = false },
				{ Name = "leadingEdgeType", Type = "ZoneControlLeadingEdgeType", Nilable = false },
				{ Name = "dangerFlashType", Type = "ZoneControlDangerFlashType", Nilable = false },
				{ Name = "zoneEntries", Type = "table", InnerType = "ZoneEntry", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKitID", Type = "number", Nilable = false },
				{ Name = "frameTextureKitID", Type = "number", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIWidgetManager);