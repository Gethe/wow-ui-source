local UIEventToastManager =
{
	Name = "UIEventToastManagerInfo",
	Type = "System",
	Namespace = "C_EventToastManager",

	Functions =
	{
		{
			Name = "GetLevelUpDisplayToastsFromLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "level", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "toastInfo", Type = "table", InnerType = "EventToastInfo", Nilable = false },
			},
		},
		{
			Name = "GetNextToastToDisplay",
			Type = "Function",

			Returns =
			{
				{ Name = "toastInfo", Type = "EventToastInfo", Nilable = false },
			},
		},
		{
			Name = "RemoveCurrentToast",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "DisplayEventToastLink",
			Type = "Event",
			LiteralName = "DISPLAY_EVENT_TOAST_LINK",
			Payload =
			{
				{ Name = "link", Type = "string", Nilable = false },
			},
		},
		{
			Name = "DisplayEventToasts",
			Type = "Event",
			LiteralName = "DISPLAY_EVENT_TOASTS",
		},
	},

	Tables =
	{
		{
			Name = "EventToastDisplayType",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 0,
			MaxValue = 8,
			Fields =
			{
				{ Name = "NormalSingleLine", Type = "EventToastDisplayType", EnumValue = 0 },
				{ Name = "NormalBlockText", Type = "EventToastDisplayType", EnumValue = 1 },
				{ Name = "NormalTitleAndSubTitle", Type = "EventToastDisplayType", EnumValue = 2 },
				{ Name = "NormalTextWithIcon", Type = "EventToastDisplayType", EnumValue = 3 },
				{ Name = "LargeTextWithIcon", Type = "EventToastDisplayType", EnumValue = 4 },
				{ Name = "NormalTextWithIconAndRarity", Type = "EventToastDisplayType", EnumValue = 5 },
				{ Name = "Scenario", Type = "EventToastDisplayType", EnumValue = 6 },
				{ Name = "ChallengeMode", Type = "EventToastDisplayType", EnumValue = 7 },
				{ Name = "ScenarioClickExpand", Type = "EventToastDisplayType", EnumValue = 8 },
			},
		},
		{
			Name = "EventToastEventType",
			Type = "Enumeration",
			NumValues = 19,
			MinValue = 0,
			MaxValue = 18,
			Fields =
			{
				{ Name = "LevelUp", Type = "EventToastEventType", EnumValue = 0 },
				{ Name = "LevelUpSpell", Type = "EventToastEventType", EnumValue = 1 },
				{ Name = "LevelUpDungeon", Type = "EventToastEventType", EnumValue = 2 },
				{ Name = "LevelUpRaid", Type = "EventToastEventType", EnumValue = 3 },
				{ Name = "LevelUpPvP", Type = "EventToastEventType", EnumValue = 4 },
				{ Name = "PetBattleNewAbility", Type = "EventToastEventType", EnumValue = 5 },
				{ Name = "PetBattleFinalRound", Type = "EventToastEventType", EnumValue = 6 },
				{ Name = "PetBattleCapture", Type = "EventToastEventType", EnumValue = 7 },
				{ Name = "BattlePetLevelChanged", Type = "EventToastEventType", EnumValue = 8 },
				{ Name = "BattlePetLevelUpAbility", Type = "EventToastEventType", EnumValue = 9 },
				{ Name = "QuestBossEmote", Type = "EventToastEventType", EnumValue = 10 },
				{ Name = "MythicPlusWeeklyRecord", Type = "EventToastEventType", EnumValue = 11 },
				{ Name = "QuestTurnedIn", Type = "EventToastEventType", EnumValue = 12 },
				{ Name = "WorldStateChange", Type = "EventToastEventType", EnumValue = 13 },
				{ Name = "Scenario", Type = "EventToastEventType", EnumValue = 14 },
				{ Name = "LevelUpOther", Type = "EventToastEventType", EnumValue = 15 },
				{ Name = "PlayerAuraAdded", Type = "EventToastEventType", EnumValue = 16 },
				{ Name = "PlayerAuraRemoved", Type = "EventToastEventType", EnumValue = 17 },
				{ Name = "SpellScript", Type = "EventToastEventType", EnumValue = 18 },
			},
		},
		{
			Name = "EventToastInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "eventToastID", Type = "number", Nilable = false },
				{ Name = "title", Type = "string", Nilable = false },
				{ Name = "subtitle", Type = "string", Nilable = false },
				{ Name = "instructionText", Type = "string", Nilable = false },
				{ Name = "iconFileID", Type = "number", Nilable = false },
				{ Name = "subIcon", Type = "string", Nilable = true },
				{ Name = "link", Type = "string", Nilable = false },
				{ Name = "qualityString", Type = "string", Nilable = true },
				{ Name = "quality", Type = "number", Nilable = true },
				{ Name = "eventType", Type = "EventToastEventType", Nilable = false },
				{ Name = "displayType", Type = "EventToastDisplayType", Nilable = false },
				{ Name = "uiTextureKit", Type = "string", Nilable = false },
				{ Name = "sortOrder", Type = "number", Nilable = false },
				{ Name = "time", Type = "number", Nilable = true },
				{ Name = "uiWidgetSetID", Type = "number", Nilable = true },
				{ Name = "extraUiWidgetSetID", Type = "number", Nilable = true },
				{ Name = "titleTooltip", Type = "string", Nilable = true },
				{ Name = "subtitleTooltip", Type = "string", Nilable = true },
				{ Name = "titleTooltipUiWidgetSetID", Type = "number", Nilable = true },
				{ Name = "subtitleTooltipUiWidgetSetID", Type = "number", Nilable = true },
				{ Name = "hideDefaultAtlas", Type = "bool", Nilable = true },
				{ Name = "showSoundKitID", Type = "number", Nilable = true },
				{ Name = "hideSoundKitID", Type = "number", Nilable = true },
				{ Name = "colorTint", Type = "table", Mixin = "ColorMixin", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIEventToastManager);