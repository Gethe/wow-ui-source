local Tutorial =
{
	Name = "Tutorial",
	Type = "System",
	Namespace = "C_Tutorial",

	Functions =
	{
		{
			Name = "AbandonTutorialArea",
			Type = "Function",
		},
		{
			Name = "ReturnToTutorialArea",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "LeavingTutorialArea",
			Type = "Event",
			LiteralName = "LEAVING_TUTORIAL_AREA",
		},
		{
			Name = "NpeTutorialUpdate",
			Type = "Event",
			LiteralName = "NPE_TUTORIAL_UPDATE",
		},
		{
			Name = "TutorialHighlightSpell",
			Type = "Event",
			LiteralName = "TUTORIAL_HIGHLIGHT_SPELL",
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "tutorialGlobalStringTag", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "TutorialTrigger",
			Type = "Event",
			LiteralName = "TUTORIAL_TRIGGER",
			Payload =
			{
				{ Name = "tutorialIndex", Type = "number", Nilable = false },
				{ Name = "forceShow", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TutorialUnhighlightSpell",
			Type = "Event",
			LiteralName = "TUTORIAL_UNHIGHLIGHT_SPELL",
		},
	},

	Tables =
	{
		{
			Name = "FrameTutorialAccount",
			Type = "Enumeration",
			NumValues = 37,
			MinValue = 1,
			MaxValue = 37,
			Fields =
			{
				{ Name = "HudRevampBagChanges", Type = "FrameTutorialAccount", EnumValue = 1 },
				{ Name = "PerksProgramActivitiesIntro", Type = "FrameTutorialAccount", EnumValue = 2 },
				{ Name = "EditModeManager", Type = "FrameTutorialAccount", EnumValue = 3 },
				{ Name = "TransmogSetsTab", Type = "FrameTutorialAccount", EnumValue = 4 },
				{ Name = "MountCollectionDragonriding", Type = "FrameTutorialAccount", EnumValue = 5 },
				{ Name = "LFGList", Type = "FrameTutorialAccount", EnumValue = 6 },
				{ Name = "HeirloomJournalLevel", Type = "FrameTutorialAccount", EnumValue = 7 },
				{ Name = "TimerunnersAdvantage", Type = "FrameTutorialAccount", EnumValue = 8 },
				{ Name = "AccountWideReputation", Type = "FrameTutorialAccount", EnumValue = 9 },
				{ Name = "TransferableCurrencies", Type = "FrameTutorialAccount", EnumValue = 10 },
				{ Name = "BindToAccountUntilEquip", Type = "FrameTutorialAccount", EnumValue = 11 },
				{ Name = "CompletedQuestsFilter", Type = "FrameTutorialAccount", EnumValue = 12 },
				{ Name = "CompletedQuestsFilterSeen", Type = "FrameTutorialAccount", EnumValue = 13 },
				{ Name = "ConcentrationCurrency", Type = "FrameTutorialAccount", EnumValue = 14 },
				{ Name = "MapLegendOpened", Type = "FrameTutorialAccount", EnumValue = 15 },
				{ Name = "NpcCraftingOrders", Type = "FrameTutorialAccount", EnumValue = 16 },
				{ Name = "NpcCraftingOrderCreateButton", Type = "FrameTutorialAccount", EnumValue = 17 },
				{ Name = "NpcCraftingOrderTabNew", Type = "FrameTutorialAccount", EnumValue = 18 },
				{ Name = "LocalStoriesFilterSeen", Type = "FrameTutorialAccount", EnumValue = 19 },
				{ Name = "EventSchedulerTabSeen", Type = "FrameTutorialAccount", EnumValue = 20 },
				{ Name = "AssistedCombatRotationDragSpell", Type = "FrameTutorialAccount", EnumValue = 21 },
				{ Name = "AssistedCombatRotationActionButton", Type = "FrameTutorialAccount", EnumValue = 22 },
				{ Name = "HousingDecorCleanup", Type = "FrameTutorialAccount", EnumValue = 23 },
				{ Name = "HousingDecorPlace", Type = "FrameTutorialAccount", EnumValue = 24 },
				{ Name = "HousingDecorClippingGrid", Type = "FrameTutorialAccount", EnumValue = 25 },
				{ Name = "HousingDecorCustomization", Type = "FrameTutorialAccount", EnumValue = 26 },
				{ Name = "HousingDecorLayout", Type = "FrameTutorialAccount", EnumValue = 27 },
				{ Name = "HousingHouseFinderMap", Type = "FrameTutorialAccount", EnumValue = 28 },
				{ Name = "HousingHouseFinderVisitHouse", Type = "FrameTutorialAccount", EnumValue = 29 },
				{ Name = "HousingItemAcquisition", Type = "FrameTutorialAccount", EnumValue = 30 },
				{ Name = "HousingNewPip", Type = "FrameTutorialAccount", EnumValue = 31 },
				{ Name = "PerksProgramActivitiesOpen", Type = "FrameTutorialAccount", EnumValue = 32 },
				{ Name = "EnconterJournalTutorialsTabSeen", Type = "FrameTutorialAccount", EnumValue = 33 },
				{ Name = "HousingMarketTab", Type = "FrameTutorialAccount", EnumValue = 34 },
				{ Name = "HousingTeleportButton", Type = "FrameTutorialAccount", EnumValue = 35 },
				{ Name = "RPETalentStarterBuild", Type = "FrameTutorialAccount", EnumValue = 36 },
				{ Name = "HousingInvalidCollision", Type = "FrameTutorialAccount", EnumValue = 37 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Tutorial);