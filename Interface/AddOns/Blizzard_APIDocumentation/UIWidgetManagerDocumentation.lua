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
			Name = "GetDiscreteProgressStepsVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "DiscreteProgressStepsVisualizationInfo", Nilable = true },
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
			Name = "GetPowerBarWidgetSetID",
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
			Name = "GetScenarioHeaderTimerWidgetVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "ScenarioHeaderTimerWidgetVisualizationInfo", Nilable = true },
			},
		},
		{
			Name = "GetSpacerVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "SpacerVisualizationInfo", Nilable = true },
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
			Name = "GetTextColumnRowVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "TextColumnRowVisualizationInfo", Nilable = true },
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
			Name = "GetTextureWithAnimationVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "TextureWithAnimationVisualizationInfo", Nilable = true },
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
			Name = "GetWidgetSetInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetSetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetSetInfo", Type = "UIWidgetSetInfo", Nilable = false },
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
		{
			Name = "RegisterUnitForWidgetUpdates",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
				{ Name = "isGuid", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetProcessingUnit",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "string", Nilable = true },
			},
		},
		{
			Name = "SetProcessingUnitGuid",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "string", Nilable = true },
			},
		},
		{
			Name = "UnregisterUnitForWidgetUpdates",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
				{ Name = "isGuid", Type = "bool", Nilable = false, Default = false },
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
			Name = "CaptureBarWidgetFillDirectionType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "RightToLeft", Type = "CaptureBarWidgetFillDirectionType", EnumValue = 0 },
				{ Name = "LeftToRight", Type = "CaptureBarWidgetFillDirectionType", EnumValue = 1 },
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
			Name = "SpellDisplayIconDisplayType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Buff", Type = "SpellDisplayIconDisplayType", EnumValue = 0 },
				{ Name = "Debuff", Type = "SpellDisplayIconDisplayType", EnumValue = 1 },
				{ Name = "Circular", Type = "SpellDisplayIconDisplayType", EnumValue = 2 },
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
			Name = "SpellDisplayTextShownStateType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Shown", Type = "SpellDisplayTextShownStateType", EnumValue = 0 },
				{ Name = "Hidden", Type = "SpellDisplayTextShownStateType", EnumValue = 1 },
			},
		},
		{
			Name = "StatusBarColorTintValue",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 0,
			MaxValue = 8,
			Fields =
			{
				{ Name = "None", Type = "StatusBarColorTintValue", EnumValue = 0 },
				{ Name = "Black", Type = "StatusBarColorTintValue", EnumValue = 1 },
				{ Name = "White", Type = "StatusBarColorTintValue", EnumValue = 2 },
				{ Name = "Red", Type = "StatusBarColorTintValue", EnumValue = 3 },
				{ Name = "Yellow", Type = "StatusBarColorTintValue", EnumValue = 4 },
				{ Name = "Orange", Type = "StatusBarColorTintValue", EnumValue = 5 },
				{ Name = "Purple", Type = "StatusBarColorTintValue", EnumValue = 6 },
				{ Name = "Green", Type = "StatusBarColorTintValue", EnumValue = 7 },
				{ Name = "Blue", Type = "StatusBarColorTintValue", EnumValue = 8 },
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
			Name = "UIWidgetFlag",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "UniversalWidget", Type = "UIWidgetFlag", EnumValue = 1 },
			},
		},
		{
			Name = "UIWidgetFontType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Normal", Type = "UIWidgetFontType", EnumValue = 0 },
				{ Name = "Shadow", Type = "UIWidgetFontType", EnumValue = 1 },
				{ Name = "Outline", Type = "UIWidgetFontType", EnumValue = 2 },
			},
		},
		{
			Name = "UIWidgetModelSceneLayer",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "UIWidgetModelSceneLayer", EnumValue = 0 },
				{ Name = "Front", Type = "UIWidgetModelSceneLayer", EnumValue = 1 },
				{ Name = "Back", Type = "UIWidgetModelSceneLayer", EnumValue = 2 },
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
			Name = "UIWidgetTooltipLocation",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 0,
			MaxValue = 8,
			Fields =
			{
				{ Name = "Default", Type = "UIWidgetTooltipLocation", EnumValue = 0 },
				{ Name = "BottomLeft", Type = "UIWidgetTooltipLocation", EnumValue = 1 },
				{ Name = "Left", Type = "UIWidgetTooltipLocation", EnumValue = 2 },
				{ Name = "TopLeft", Type = "UIWidgetTooltipLocation", EnumValue = 3 },
				{ Name = "Top", Type = "UIWidgetTooltipLocation", EnumValue = 4 },
				{ Name = "TopRight", Type = "UIWidgetTooltipLocation", EnumValue = 5 },
				{ Name = "Right", Type = "UIWidgetTooltipLocation", EnumValue = 6 },
				{ Name = "BottomRight", Type = "UIWidgetTooltipLocation", EnumValue = 7 },
				{ Name = "Bottom", Type = "UIWidgetTooltipLocation", EnumValue = 8 },
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
			Name = "WidgetEnabledState",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Disabled", Type = "WidgetEnabledState", EnumValue = 0 },
				{ Name = "Enabled", Type = "WidgetEnabledState", EnumValue = 1 },
				{ Name = "Red", Type = "WidgetEnabledState", EnumValue = 2 },
				{ Name = "White", Type = "WidgetEnabledState", EnumValue = 3 },
				{ Name = "Green", Type = "WidgetEnabledState", EnumValue = 4 },
				{ Name = "Gold", Type = "WidgetEnabledState", EnumValue = 5 },
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
			Name = "WidgetTextHorizontalAlignmentType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Left", Type = "WidgetTextHorizontalAlignmentType", EnumValue = 0 },
				{ Name = "Center", Type = "WidgetTextHorizontalAlignmentType", EnumValue = 1 },
				{ Name = "Right", Type = "WidgetTextHorizontalAlignmentType", EnumValue = 2 },
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
			Name = "BulletTextListWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "enabledState", Type = "WidgetEnabledState", Nilable = false },
				{ Name = "lines", Type = "table", InnerType = "string", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
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
				{ Name = "fillDirectionType", Type = "CaptureBarWidgetFillDirectionType", Nilable = false },
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
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
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "DiscreteProgressStepsVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
				{ Name = "progressMin", Type = "number", Nilable = false },
				{ Name = "progressMax", Type = "number", Nilable = false },
				{ Name = "progressVal", Type = "number", Nilable = false },
				{ Name = "numSteps", Type = "number", Nilable = false },
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
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
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
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
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
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
				{ Name = "leftBarTooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "rightBarTooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HorizontalCurrenciesWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "currencies", Type = "table", InnerType = "UIWidgetCurrencyInfo", Nilable = false },
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
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
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
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
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
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
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "currencies", Type = "table", InnerType = "UIWidgetCurrencyInfo", Nilable = false },
				{ Name = "headerText", Type = "string", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ScenarioHeaderTimerWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "timerMin", Type = "number", Nilable = false },
				{ Name = "timerMax", Type = "number", Nilable = false },
				{ Name = "timerValue", Type = "number", Nilable = false },
				{ Name = "headerText", Type = "string", Nilable = false },
				{ Name = "timerTooltip", Type = "string", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SpacerVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "widgetWidth", Type = "number", Nilable = false },
				{ Name = "widgetHeight", Type = "number", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
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
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "StackedResourceTrackerWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "resources", Type = "table", InnerType = "UIWidgetCurrencyInfo", Nilable = false },
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
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
				{ Name = "colorTint", Type = "StatusBarColorTintValue", Nilable = false },
				{ Name = "partitionValues", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TextColumnRowEntryInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "enabledState", Type = "WidgetEnabledState", Nilable = false },
				{ Name = "hAlign", Type = "WidgetTextHorizontalAlignmentType", Nilable = false },
				{ Name = "columnWidth", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TextColumnRowVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "entries", Type = "table", InnerType = "TextColumnRowEntryInfo", Nilable = false },
				{ Name = "textSizeType", Type = "UIWidgetTextSizeType", Nilable = false },
				{ Name = "fontType", Type = "UIWidgetFontType", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "bottomPadding", Type = "number", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
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
				{ Name = "fontType", Type = "UIWidgetFontType", Nilable = false },
				{ Name = "bottomPadding", Type = "number", Nilable = false },
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "hAlign", Type = "WidgetTextHorizontalAlignmentType", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
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
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
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
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TextureWithAnimationVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
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
			Name = "UIWidgetInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
				{ Name = "widgetSetID", Type = "number", Nilable = false },
				{ Name = "widgetType", Type = "UIWidgetVisualizationType", Nilable = false },
				{ Name = "unitToken", Type = "string", Nilable = true },
			},
		},
		{
			Name = "UIWidgetSetInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "layoutDirection", Type = "UIWidgetSetLayoutDirection", Nilable = false },
				{ Name = "verticalPadding", Type = "number", Nilable = false },
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
				{ Name = "textShownState", Type = "SpellDisplayTextShownStateType", Nilable = false },
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
			Name = "ZoneControlVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "mode", Type = "ZoneControlMode", Nilable = false },
				{ Name = "leadingEdgeType", Type = "ZoneControlLeadingEdgeType", Nilable = false },
				{ Name = "dangerFlashType", Type = "ZoneControlDangerFlashType", Nilable = false },
				{ Name = "zoneEntries", Type = "table", InnerType = "ZoneEntry", Nilable = false },
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "frameTextureKit", Type = "string", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
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
	},
};

APIDocumentation:AddDocumentationTable(UIWidgetManager);