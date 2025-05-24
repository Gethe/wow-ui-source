local UIWidgetManagerShared =
{
	Tables =
	{
		{
			Name = "MapIconUIWidgetSetType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Tooltip", Type = "MapIconUIWidgetSetType", EnumValue = 0 },
				{ Name = "BehindIcon", Type = "MapIconUIWidgetSetType", EnumValue = 1 },
			},
		},
		{
			Name = "SpellDisplayBorderColor",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 0,
			MaxValue = 8,
			Fields =
			{
				{ Name = "None", Type = "SpellDisplayBorderColor", EnumValue = 0 },
				{ Name = "Black", Type = "SpellDisplayBorderColor", EnumValue = 1 },
				{ Name = "White", Type = "SpellDisplayBorderColor", EnumValue = 2 },
				{ Name = "Red", Type = "SpellDisplayBorderColor", EnumValue = 3 },
				{ Name = "Yellow", Type = "SpellDisplayBorderColor", EnumValue = 4 },
				{ Name = "Orange", Type = "SpellDisplayBorderColor", EnumValue = 5 },
				{ Name = "Purple", Type = "SpellDisplayBorderColor", EnumValue = 6 },
				{ Name = "Green", Type = "SpellDisplayBorderColor", EnumValue = 7 },
				{ Name = "Blue", Type = "SpellDisplayBorderColor", EnumValue = 8 },
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
			Name = "UIWidgetHorizontalDirection",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "LeftToRight", Type = "UIWidgetHorizontalDirection", EnumValue = 0 },
				{ Name = "RightToLeft", Type = "UIWidgetHorizontalDirection", EnumValue = 1 },
			},
		},
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
			Name = "UIWidgetScale",
			Type = "Enumeration",
			NumValues = 16,
			MinValue = 0,
			MaxValue = 15,
			Fields =
			{
				{ Name = "OneHundred", Type = "UIWidgetScale", EnumValue = 0 },
				{ Name = "Ninty", Type = "UIWidgetScale", EnumValue = 1 },
				{ Name = "Eighty", Type = "UIWidgetScale", EnumValue = 2 },
				{ Name = "Seventy", Type = "UIWidgetScale", EnumValue = 3 },
				{ Name = "Sixty", Type = "UIWidgetScale", EnumValue = 4 },
				{ Name = "Fifty", Type = "UIWidgetScale", EnumValue = 5 },
				{ Name = "OneHundredTen", Type = "UIWidgetScale", EnumValue = 6 },
				{ Name = "OneHundredTwenty", Type = "UIWidgetScale", EnumValue = 7 },
				{ Name = "OneHundredThirty", Type = "UIWidgetScale", EnumValue = 8 },
				{ Name = "OneHundredForty", Type = "UIWidgetScale", EnumValue = 9 },
				{ Name = "OneHundredFifty", Type = "UIWidgetScale", EnumValue = 10 },
				{ Name = "OneHundredSixty", Type = "UIWidgetScale", EnumValue = 11 },
				{ Name = "OneHundredSeventy", Type = "UIWidgetScale", EnumValue = 12 },
				{ Name = "OneHundredEighty", Type = "UIWidgetScale", EnumValue = 13 },
				{ Name = "OneHundredNinety", Type = "UIWidgetScale", EnumValue = 14 },
				{ Name = "TwoHundred", Type = "UIWidgetScale", EnumValue = 15 },
			},
		},
		{
			Name = "UIWidgetSetLayoutDirection",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Vertical", Type = "UIWidgetSetLayoutDirection", EnumValue = 0 },
				{ Name = "Horizontal", Type = "UIWidgetSetLayoutDirection", EnumValue = 1 },
				{ Name = "Overlap", Type = "UIWidgetSetLayoutDirection", EnumValue = 2 },
			},
		},
		{
			Name = "UIWidgetVisualizationType",
			Type = "Enumeration",
			NumValues = 30,
			MinValue = 0,
			MaxValue = 29,
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
				{ Name = "TextureWithAnimation", Type = "UIWidgetVisualizationType", EnumValue = 18 },
				{ Name = "DiscreteProgressSteps", Type = "UIWidgetVisualizationType", EnumValue = 19 },
				{ Name = "ScenarioHeaderTimer", Type = "UIWidgetVisualizationType", EnumValue = 20 },
				{ Name = "TextColumnRow", Type = "UIWidgetVisualizationType", EnumValue = 21 },
				{ Name = "Spacer", Type = "UIWidgetVisualizationType", EnumValue = 22 },
				{ Name = "UnitPowerBar", Type = "UIWidgetVisualizationType", EnumValue = 23 },
				{ Name = "FillUpFrames", Type = "UIWidgetVisualizationType", EnumValue = 24 },
				{ Name = "TextWithSubtext", Type = "UIWidgetVisualizationType", EnumValue = 25 },
				{ Name = "MapPinAnimation", Type = "UIWidgetVisualizationType", EnumValue = 26 },
				{ Name = "ItemDisplay", Type = "UIWidgetVisualizationType", EnumValue = 27 },
				{ Name = "TugOfWar", Type = "UIWidgetVisualizationType", EnumValue = 28 },
				{ Name = "ScenarioHeaderDelves", Type = "UIWidgetVisualizationType", EnumValue = 29 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIWidgetManagerShared);