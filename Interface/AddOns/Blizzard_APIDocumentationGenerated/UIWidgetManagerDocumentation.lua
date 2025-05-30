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
			Name = "GetButtonHeaderWidgetVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "ButtonHeaderWidgetVisualizationInfo", Nilable = true },
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
			Name = "GetFillUpFramesWidgetVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "FillUpFramesWidgetVisualizationInfo", Nilable = true },
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
			Name = "GetItemDisplayVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "ItemDisplayVisualizationInfo", Nilable = true },
			},
		},
		{
			Name = "GetMapPinAnimationWidgetVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "MapPinAnimationWidgetVisualizationInfo", Nilable = true },
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
			Name = "GetScenarioHeaderDelvesWidgetVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "ScenarioHeaderDelvesWidgetVisualizationInfo", Nilable = true },
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
			Name = "GetTextWithSubtextWidgetVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "TextWithSubtextWidgetVisualizationInfo", Nilable = true },
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
			Name = "GetTugOfWarWidgetVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "TugOfWarWidgetVisualizationInfo", Nilable = true },
			},
		},
		{
			Name = "GetUnitPowerBarWidgetVisualizationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "widgetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "widgetInfo", Type = "UnitPowerBarWidgetVisualizationInfo", Nilable = true },
			},
		},
		{
			Name = "GetWidgetSetInfo",
			Type = "Function",
			MayReturnNothing = true,

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
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},
		},
		{
			Name = "SetProcessingUnitGuid",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "WOWGUID", Nilable = true },
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
			Name = "IconAndTextShiftTextType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "None", Type = "IconAndTextShiftTextType", EnumValue = 0 },
				{ Name = "ShiftText", Type = "IconAndTextShiftTextType", EnumValue = 1 },
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
			Name = "ItemDisplayTextDisplayStyle",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "WorldQuestReward", Type = "ItemDisplayTextDisplayStyle", EnumValue = 0 },
				{ Name = "ItemNameAndInfoText", Type = "ItemDisplayTextDisplayStyle", EnumValue = 1 },
				{ Name = "ItemNameOnlyCentered", Type = "ItemDisplayTextDisplayStyle", EnumValue = 2 },
				{ Name = "PlayerChoiceReward", Type = "ItemDisplayTextDisplayStyle", EnumValue = 3 },
			},
		},
		{
			Name = "ItemDisplayTooltipEnabledType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Enabled", Type = "ItemDisplayTooltipEnabledType", EnumValue = 0 },
				{ Name = "Disabled", Type = "ItemDisplayTooltipEnabledType", EnumValue = 1 },
			},
		},
		{
			Name = "MapPinAnimationType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "None", Type = "MapPinAnimationType", EnumValue = 0 },
				{ Name = "Pulse", Type = "MapPinAnimationType", EnumValue = 1 },
			},
		},
		{
			Name = "SpellDisplayIconDisplayType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Buff", Type = "SpellDisplayIconDisplayType", EnumValue = 0 },
				{ Name = "Debuff", Type = "SpellDisplayIconDisplayType", EnumValue = 1 },
				{ Name = "Circular", Type = "SpellDisplayIconDisplayType", EnumValue = 2 },
				{ Name = "NoBorder", Type = "SpellDisplayIconDisplayType", EnumValue = 3 },
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
			Name = "SpellDisplayTint",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "None", Type = "SpellDisplayTint", EnumValue = 0 },
				{ Name = "Red", Type = "SpellDisplayTint", EnumValue = 1 },
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
			Name = "TugOfWarMarkerArrowShownState",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Never", Type = "TugOfWarMarkerArrowShownState", EnumValue = 0 },
				{ Name = "Always", Type = "TugOfWarMarkerArrowShownState", EnumValue = 1 },
				{ Name = "FlashOnMove", Type = "TugOfWarMarkerArrowShownState", EnumValue = 2 },
			},
		},
		{
			Name = "TugOfWarStyleValue",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "DefaultYellow", Type = "TugOfWarStyleValue", EnumValue = 0 },
				{ Name = "ArchaeologyBrown", Type = "TugOfWarStyleValue", EnumValue = 1 },
			},
		},
		{
			Name = "UIWidgetBlendModeType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Opaque", Type = "UIWidgetBlendModeType", EnumValue = 0 },
				{ Name = "Additive", Type = "UIWidgetBlendModeType", EnumValue = 1 },
			},
		},
		{
			Name = "UIWidgetButtonEnabledState",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Disabled", Type = "UIWidgetButtonEnabledState", EnumValue = 0 },
				{ Name = "Enabled", Type = "UIWidgetButtonEnabledState", EnumValue = 1 },
			},
		},
		{
			Name = "UIWidgetButtonIconType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Exit", Type = "UIWidgetButtonIconType", EnumValue = 0 },
				{ Name = "Speak", Type = "UIWidgetButtonIconType", EnumValue = 1 },
				{ Name = "Undo", Type = "UIWidgetButtonIconType", EnumValue = 2 },
				{ Name = "Checkmark", Type = "UIWidgetButtonIconType", EnumValue = 3 },
				{ Name = "RedX", Type = "UIWidgetButtonIconType", EnumValue = 4 },
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
			Name = "UIWidgetMotionType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Instant", Type = "UIWidgetMotionType", EnumValue = 0 },
				{ Name = "Smooth", Type = "UIWidgetMotionType", EnumValue = 1 },
			},
		},
		{
			Name = "UIWidgetOverrideState",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Inactive", Type = "UIWidgetOverrideState", EnumValue = 0 },
				{ Name = "Active", Type = "UIWidgetOverrideState", EnumValue = 1 },
			},
		},
		{
			Name = "UIWidgetRewardShownState",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Hidden", Type = "UIWidgetRewardShownState", EnumValue = 0 },
				{ Name = "ShownEarned", Type = "UIWidgetRewardShownState", EnumValue = 1 },
				{ Name = "ShownUnearned", Type = "UIWidgetRewardShownState", EnumValue = 2 },
			},
		},
		{
			Name = "UIWidgetSpellButtonCooldownType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "HideCooldown", Type = "UIWidgetSpellButtonCooldownType", EnumValue = 0 },
				{ Name = "ShowCooldown", Type = "UIWidgetSpellButtonCooldownType", EnumValue = 1 },
				{ Name = "ShowCooldownAndDisableOnCooldown", Type = "UIWidgetSpellButtonCooldownType", EnumValue = 2 },
			},
		},
		{
			Name = "UIWidgetTextFormatType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "UIWidgetTextFormatType", EnumValue = 0 },
				{ Name = "TimeOneLevel", Type = "UIWidgetTextFormatType", EnumValue = 1 },
				{ Name = "TimeTwoLevel", Type = "UIWidgetTextFormatType", EnumValue = 2 },
				{ Name = "LeadingZeroesWithSixDigits", Type = "UIWidgetTextFormatType", EnumValue = 3 },
			},
		},
		{
			Name = "UIWidgetTextSizeType",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 0,
			MaxValue = 8,
			Fields =
			{
				{ Name = "Small12Pt", Type = "UIWidgetTextSizeType", EnumValue = 0 },
				{ Name = "Medium16Pt", Type = "UIWidgetTextSizeType", EnumValue = 1 },
				{ Name = "Large24Pt", Type = "UIWidgetTextSizeType", EnumValue = 2 },
				{ Name = "Huge27Pt", Type = "UIWidgetTextSizeType", EnumValue = 3 },
				{ Name = "Standard14Pt", Type = "UIWidgetTextSizeType", EnumValue = 4 },
				{ Name = "Small10Pt", Type = "UIWidgetTextSizeType", EnumValue = 5 },
				{ Name = "Small11Pt", Type = "UIWidgetTextSizeType", EnumValue = 6 },
				{ Name = "Medium18Pt", Type = "UIWidgetTextSizeType", EnumValue = 7 },
				{ Name = "Large20Pt", Type = "UIWidgetTextSizeType", EnumValue = 8 },
			},
		},
		{
			Name = "UIWidgetTextureAndTextSizeType",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Small", Type = "UIWidgetTextureAndTextSizeType", EnumValue = 0 },
				{ Name = "Medium", Type = "UIWidgetTextureAndTextSizeType", EnumValue = 1 },
				{ Name = "Large", Type = "UIWidgetTextureAndTextSizeType", EnumValue = 2 },
				{ Name = "Huge", Type = "UIWidgetTextureAndTextSizeType", EnumValue = 3 },
				{ Name = "Standard", Type = "UIWidgetTextureAndTextSizeType", EnumValue = 4 },
				{ Name = "Medium2", Type = "UIWidgetTextureAndTextSizeType", EnumValue = 5 },
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
			Name = "UIWidgetUpdateAnimType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "UIWidgetUpdateAnimType", EnumValue = 0 },
				{ Name = "Flash", Type = "UIWidgetUpdateAnimType", EnumValue = 1 },
				{ Name = "FlashAndAnimateNumber", Type = "UIWidgetUpdateAnimType", EnumValue = 2 },
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
			NumValues = 8,
			MinValue = 0,
			MaxValue = 7,
			Fields =
			{
				{ Name = "Disabled", Type = "WidgetEnabledState", EnumValue = 0 },
				{ Name = "Yellow", Type = "WidgetEnabledState", EnumValue = 1 },
				{ Name = "Red", Type = "WidgetEnabledState", EnumValue = 2 },
				{ Name = "White", Type = "WidgetEnabledState", EnumValue = 3 },
				{ Name = "Green", Type = "WidgetEnabledState", EnumValue = 4 },
				{ Name = "Artifact", Type = "WidgetEnabledState", EnumValue = 5 },
				{ Name = "Black", Type = "WidgetEnabledState", EnumValue = 6 },
				{ Name = "BrightBlue", Type = "WidgetEnabledState", EnumValue = 7 },
			},
		},
		{
			Name = "WidgetGlowAnimType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "None", Type = "WidgetGlowAnimType", EnumValue = 0 },
				{ Name = "Pulse", Type = "WidgetGlowAnimType", EnumValue = 1 },
			},
		},
		{
			Name = "WidgetIconSizeType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Small", Type = "WidgetIconSizeType", EnumValue = 0 },
				{ Name = "Medium", Type = "WidgetIconSizeType", EnumValue = 1 },
				{ Name = "Large", Type = "WidgetIconSizeType", EnumValue = 2 },
				{ Name = "Standard", Type = "WidgetIconSizeType", EnumValue = 3 },
			},
		},
		{
			Name = "WidgetIconSourceType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Spell", Type = "WidgetIconSourceType", EnumValue = 0 },
				{ Name = "Item", Type = "WidgetIconSourceType", EnumValue = 1 },
			},
		},
		{
			Name = "WidgetOpacityType",
			Type = "Enumeration",
			NumValues = 11,
			MinValue = 0,
			MaxValue = 10,
			Fields =
			{
				{ Name = "OneHundred", Type = "WidgetOpacityType", EnumValue = 0 },
				{ Name = "Ninety", Type = "WidgetOpacityType", EnumValue = 1 },
				{ Name = "Eighty", Type = "WidgetOpacityType", EnumValue = 2 },
				{ Name = "Seventy", Type = "WidgetOpacityType", EnumValue = 3 },
				{ Name = "Sixty", Type = "WidgetOpacityType", EnumValue = 4 },
				{ Name = "Fifty", Type = "WidgetOpacityType", EnumValue = 5 },
				{ Name = "Forty", Type = "WidgetOpacityType", EnumValue = 6 },
				{ Name = "Thirty", Type = "WidgetOpacityType", EnumValue = 7 },
				{ Name = "Twenty", Type = "WidgetOpacityType", EnumValue = 8 },
				{ Name = "Ten", Type = "WidgetOpacityType", EnumValue = 9 },
				{ Name = "Zero", Type = "WidgetOpacityType", EnumValue = 10 },
			},
		},
		{
			Name = "WidgetShowGlowState",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "HideGlow", Type = "WidgetShowGlowState", EnumValue = 0 },
				{ Name = "ShowGlow", Type = "WidgetShowGlowState", EnumValue = 1 },
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
			Name = "WidgetUnitPowerBarFlashMomentType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "FlashWhenMax", Type = "WidgetUnitPowerBarFlashMomentType", EnumValue = 0 },
				{ Name = "FlashWhenMin", Type = "WidgetUnitPowerBarFlashMomentType", EnumValue = 1 },
				{ Name = "NeverFlash", Type = "WidgetUnitPowerBarFlashMomentType", EnumValue = 2 },
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
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
			Name = "ButtonHeaderWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "headerText", Type = "string", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "buttons", Type = "table", InnerType = "UIWidgetSpellButtonInfo", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "glowAnimType", Type = "WidgetGlowAnimType", Nilable = false },
				{ Name = "fillDirectionType", Type = "CaptureBarWidgetFillDirectionType", Nilable = false },
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "fillMotionType", Type = "UIWidgetMotionType", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
			Name = "FillUpFramesWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "fillMin", Type = "number", Nilable = false },
				{ Name = "fillMax", Type = "number", Nilable = false },
				{ Name = "fillValue", Type = "number", Nilable = false },
				{ Name = "numTotalFrames", Type = "number", Nilable = false },
				{ Name = "numFullFrames", Type = "number", Nilable = false },
				{ Name = "pulseFillingFrame", Type = "bool", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "shiftTextType", Type = "IconAndTextShiftTextType", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
			Name = "ItemDisplayVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "itemInfo", Type = "UIWidgetItemInfo", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
			Name = "MapPinAnimationWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "animType", Type = "MapPinAnimationType", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
			Name = "ScenarioHeaderDelvesWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "headerText", Type = "string", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "tierText", Type = "string", Nilable = false },
				{ Name = "tierTooltipSpellID", Type = "number", Nilable = true },
				{ Name = "currencies", Type = "table", InnerType = "UIWidgetCurrencyInfo", Nilable = false },
				{ Name = "spells", Type = "table", InnerType = "UIWidgetSpellInfo", Nilable = false },
				{ Name = "rewardInfo", Type = "UIWidgetRewardInfo", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "spellInfo", Type = "UIWidgetSpellInfo", Nilable = false },
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "fillMotionType", Type = "UIWidgetMotionType", Nilable = false },
				{ Name = "barTextEnabledState", Type = "WidgetEnabledState", Nilable = false },
				{ Name = "barTextFontType", Type = "UIWidgetFontType", Nilable = false },
				{ Name = "barTextSizeType", Type = "UIWidgetTextSizeType", Nilable = false },
				{ Name = "textEnabledState", Type = "WidgetEnabledState", Nilable = false },
				{ Name = "textFontType", Type = "UIWidgetFontType", Nilable = false },
				{ Name = "textSizeType", Type = "UIWidgetTextSizeType", Nilable = false },
				{ Name = "glowAnimType", Type = "WidgetGlowAnimType", Nilable = false },
				{ Name = "showGlowState", Type = "WidgetShowGlowState", Nilable = false },
				{ Name = "fillMinOpacity", Type = "WidgetOpacityType", Nilable = false },
				{ Name = "fillMaxOpacity", Type = "WidgetOpacityType", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
			Name = "TextWithSubtextWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "enabledState", Type = "WidgetEnabledState", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "widgetWidth", Type = "number", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
				{ Name = "textSizeType", Type = "UIWidgetTextSizeType", Nilable = false },
				{ Name = "fontType", Type = "UIWidgetFontType", Nilable = false },
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "hAlign", Type = "WidgetTextHorizontalAlignmentType", Nilable = false },
				{ Name = "subText", Type = "string", Nilable = false },
				{ Name = "subTextSizeType", Type = "UIWidgetTextSizeType", Nilable = false },
				{ Name = "subTextFontType", Type = "UIWidgetFontType", Nilable = false },
				{ Name = "subTextHAlign", Type = "WidgetTextHorizontalAlignmentType", Nilable = false },
				{ Name = "subTextEnabledState", Type = "WidgetEnabledState", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
				{ Name = "hasTimer", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "widgetTag", Type = "string", Nilable = false },
				{ Name = "inAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "outAnimType", Type = "WidgetAnimationType", Nilable = false },
				{ Name = "widgetScale", Type = "UIWidgetScale", Nilable = false },
				{ Name = "layoutDirection", Type = "UIWidgetLayoutDirection", Nilable = false },
				{ Name = "modelSceneLayer", Type = "UIWidgetModelSceneLayer", Nilable = false },
				{ Name = "scriptedAnimationEffectID", Type = "number", Nilable = false },
				{ Name = "spacing", Type = "number", Nilable = false },
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
				{ Name = "textSizeType", Type = "UIWidgetTextureAndTextSizeType", Nilable = false },
				{ Name = "groupAlignment", Type = "UIWidgetHorizontalDirection", Nilable = false },
				{ Name = "fixedWidth", Type = "number", Nilable = true },
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "textSizeType", Type = "UIWidgetTextureAndTextSizeType", Nilable = false },
				{ Name = "textFormatType", Type = "UIWidgetTextFormatType", Nilable = false },
				{ Name = "updateAnimType", Type = "UIWidgetUpdateAnimType", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
			Name = "TugOfWarWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "minValue", Type = "number", Nilable = false },
				{ Name = "maxValue", Type = "number", Nilable = false },
				{ Name = "currentValue", Type = "number", Nilable = false },
				{ Name = "neutralZoneCenter", Type = "number", Nilable = false },
				{ Name = "neutralZoneSize", Type = "number", Nilable = false },
				{ Name = "leftIconInfo", Type = "UIWidgetIconInfo", Nilable = false },
				{ Name = "rightIconInfo", Type = "UIWidgetIconInfo", Nilable = false },
				{ Name = "glowAnimType", Type = "WidgetGlowAnimType", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "neutralFillStyle", Type = "TugOfWarStyleValue", Nilable = false },
				{ Name = "markerArrowShownState", Type = "TugOfWarMarkerArrowShownState", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "iconFileID", Type = "fileID", Nilable = false },
				{ Name = "leadingText", Type = "string", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
				{ Name = "isCurrencyMaxed", Type = "bool", Nilable = false },
				{ Name = "textFontType", Type = "UIWidgetFontType", Nilable = false },
				{ Name = "textSizeType", Type = "UIWidgetTextSizeType", Nilable = false },
				{ Name = "textEnabledState", Type = "WidgetEnabledState", Nilable = false },
				{ Name = "iconSizeType", Type = "WidgetIconSizeType", Nilable = false },
				{ Name = "updateAnimType", Type = "UIWidgetUpdateAnimType", Nilable = false },
			},
		},
		{
			Name = "UIWidgetIconInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "sourceType", Type = "WidgetIconSourceType", Nilable = false },
				{ Name = "sourceID", Type = "number", Nilable = false },
				{ Name = "sizeType", Type = "WidgetIconSizeType", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
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
			Name = "UIWidgetItemInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "stackCount", Type = "number", Nilable = true },
				{ Name = "overrideItemName", Type = "string", Nilable = true },
				{ Name = "infoText", Type = "string", Nilable = true },
				{ Name = "overrideTooltip", Type = "string", Nilable = true },
				{ Name = "textDisplayStyle", Type = "ItemDisplayTextDisplayStyle", Nilable = false },
				{ Name = "tooltipEnabled", Type = "bool", Nilable = false },
				{ Name = "iconSizeType", Type = "WidgetIconSizeType", Nilable = false },
				{ Name = "infoTextEnabledState", Type = "WidgetEnabledState", Nilable = false },
				{ Name = "showAsEarned", Type = "bool", Nilable = false },
				{ Name = "itemNameTextFontType", Type = "UIWidgetFontType", Nilable = false },
				{ Name = "itemNameTextSizeType", Type = "UIWidgetTextSizeType", Nilable = false },
				{ Name = "infoTextFontType", Type = "UIWidgetFontType", Nilable = false },
				{ Name = "infoTextSizeType", Type = "UIWidgetTextSizeType", Nilable = false },
				{ Name = "itemNameCustomColor", Type = "WidgetEnabledState", Nilable = false },
				{ Name = "itemNameCustomColorOverrideState", Type = "UIWidgetOverrideState", Nilable = false },
			},
		},
		{
			Name = "UIWidgetRewardInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "UIWidgetRewardShownState", Nilable = false },
				{ Name = "earnedTooltip", Type = "string", Nilable = false },
				{ Name = "unearnedTooltip", Type = "string", Nilable = false },
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
			Name = "UIWidgetSpellButtonInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
				{ Name = "icon", Type = "UIWidgetButtonIconType", Nilable = false },
				{ Name = "enabledState", Type = "UIWidgetButtonEnabledState", Nilable = false },
				{ Name = "cooldownType", Type = "UIWidgetSpellButtonCooldownType", Nilable = false },
			},
		},
		{
			Name = "UIWidgetSpellInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "enabledState", Type = "WidgetEnabledState", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "stackDisplay", Type = "number", Nilable = false },
				{ Name = "iconSizeType", Type = "WidgetIconSizeType", Nilable = false },
				{ Name = "iconDisplayType", Type = "SpellDisplayIconDisplayType", Nilable = false },
				{ Name = "textShownState", Type = "SpellDisplayTextShownStateType", Nilable = false },
				{ Name = "borderColor", Type = "SpellDisplayBorderColor", Nilable = false },
				{ Name = "textFontType", Type = "UIWidgetFontType", Nilable = false },
				{ Name = "textSizeType", Type = "UIWidgetTextSizeType", Nilable = false },
				{ Name = "hAlignType", Type = "WidgetTextHorizontalAlignmentType", Nilable = false },
				{ Name = "tint", Type = "SpellDisplayTint", Nilable = false },
				{ Name = "showGlowState", Type = "WidgetShowGlowState", Nilable = false },
				{ Name = "showAsEarned", Type = "bool", Nilable = false },
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
			Name = "UIWidgetTextTooltipPair",
			Type = "Structure",
			Fields =
			{
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
			},
		},
		{
			Name = "UnitPowerBarWidgetVisualizationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shownState", Type = "WidgetShownState", Nilable = false },
				{ Name = "barMin", Type = "number", Nilable = false },
				{ Name = "barMax", Type = "number", Nilable = false },
				{ Name = "barValue", Type = "number", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
				{ Name = "barValueTextType", Type = "StatusBarValueTextType", Nilable = false },
				{ Name = "overrideBarText", Type = "string", Nilable = false },
				{ Name = "overrideBarTextShownType", Type = "StatusBarOverrideBarTextShownType", Nilable = false },
				{ Name = "tooltipLoc", Type = "UIWidgetTooltipLocation", Nilable = false },
				{ Name = "fillMotionType", Type = "UIWidgetMotionType", Nilable = false },
				{ Name = "flashBlendModeType", Type = "UIWidgetBlendModeType", Nilable = false },
				{ Name = "sparkBlendModeType", Type = "UIWidgetBlendModeType", Nilable = false },
				{ Name = "flashMomentType", Type = "WidgetUnitPowerBarFlashMomentType", Nilable = false },
				{ Name = "widgetSizeSetting", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "frameTextureKit", Type = "textureKit", Nilable = false },
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