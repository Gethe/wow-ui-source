
HOUSING_TUTORIAL_CVAR_BITFIELD = "closedInfoFramesAccountWide";

HousingTutorialQuestIDs = {
	CleanupQuest = 91968,
	DecorateQuest = 91969,
	BoughtHouseQuest = 91863,
}

HousingTutorialStates = {
	QuestTutorials = {
		QuestAccepted = "QuestAccepted",
		QuestInProgress = "QuestInProgress",
		ObjectivesComplete = "ObjectivesComplete",
	},

	CustomizationTutorial = {
		ActionButton = "CustomizationActionButton";
		ClickDecor = "ClickDecor";
	},

	LayoutTutorial = {
		ActionButton = "LayoutActionButton";
		Chest = "LayoutChest";
	},

	HouseFinderTutorial = {
		NeighborhoodList = "NeighborhoodList",
		NeighborhoodMap = "NeighborhoodMap",
	},

	TeleportToHouseTutorial = {
		MicroButton = "MicroButton",
		TeleportButton = "TeleportButton",
	},
};

HousingTutorialHelpTipSystems = {
	Clean = "CleanHouseHelpTips",
	Decorate = "DecorateHouseHelpTips",
	Customize = "CustomizeHouseHelpTips",
	ClippingGrid = "ClippingGridHouseHelpTips",
	MarketTab = "MarketTabHouseHelpTips",
	Layout = "LayoutHouseHelpTips",
	HouseFinderMap = "HouseFinderMapHelptips",
	HouseFinderVisitHouse = "HouseFinderVisitHouseHelptips",
	TeleportToHouse = "TeleportToHouseHelpTips",
};
------------------------------------------

HousingTutorialData = {
	HouseFinderTutorial = {
		NeighborhoodScrollFrame = "HouseFinderFrame.NeighborhoodListFrame.ScrollFrame",
		NeighborhoodMapFrame = "HouseFinderFrame.HouseFinderMapCanvasFrame",
		VisitHouseButton = "HouseFinderFrame.PlotInfoFrame.VisitHouseButton",

		MapHelpTipInfos = {
			[HousingTutorialStates.HouseFinderTutorial.NeighborhoodList] = {
				text = NEIGHBORHOOD_LIST_TUTORIAL_TEXT,
				buttonStyle = HelpTip.ButtonStyle.Next,
				targetPoint = HelpTip.Point.RightEdgeTop,
				alignment = HelpTip.Alignment.Center,
				offsetX = -20,
				offsetY = -30,
				autoHideWhenTargetHides = true,
				system = HousingTutorialHelpTipSystems.HouseFinderMap,
			},
			[HousingTutorialStates.HouseFinderTutorial.NeighborhoodMap] = {
				text = NEIGHBORHOOD_MAP_TUTORIAL_TEXT,
				buttonStyle = HelpTip.ButtonStyle.Exit,
				targetPoint = HelpTip.Point.RightEdgeTop,
				hideArrow = true,
				alignment = HelpTip.Alignment.Right,
				offsetX = -260,
				offsetY = -70,
				autoHideWhenTargetHides = true,
				system = HousingTutorialHelpTipSystems.HouseFinderMap,
			},
		},

		VisitHouseHelpTipInfo = {
			text = NEIGHBORHOOD_VISIT_HOUSE_TUTORIAL_TEXT,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			alignment = HelpTip.Alignment.Center,
			offsetX = 8,
			offsetY = 0,
			autoHideWhenTargetHides = true,
			system = HousingTutorialHelpTipSystems.HouseFinderVisitHouse,
			cvarBitfield = HOUSING_TUTORIAL_CVAR_BITFIELD,
			bitfieldFlag = Enum.FrameTutorialAccount.HousingHouseFinderVisitHouse,
		},
	},

	HouseDecorTutorial = {
		EnterDecorModeButton = "HousingControlsFrame.HouseEditorButton",
		DecorPlacementSubButtonBar = "HouseEditorFrame.BasicDecorModeFrame.SubButtonBar",
		DecorCustomizationButton = "HouseEditorFrame.ModeBar.CustomizeModeButton",
		DecorLayoutButton = "HouseEditorFrame.ModeBar.LayoutModeButton",
		LayoutStorageFrame = "HouseEditorFrame.StoragePanel",
		HouseChestTabSystem = "HouseEditorFrame.StoragePanel.TabSystem",

		QuestTutorials = {
			[HousingTutorialQuestIDs.CleanupQuest] = {
				helpTipInfos = {
					[HousingTutorialStates.QuestTutorials.QuestAccepted] = {
						text = ENTER_DECOR_MODE_TUTORIAL_TEXT,
						buttonStyle = HelpTip.ButtonStyle.None,
						targetPoint = HelpTip.Point.BottomEdgeCenter,
						alignment = HelpTip.Alignment.Center,
						offsetX = 0,
						offsetY = -6,
						autoHideWhenTargetHides = true,
						system = HousingTutorialHelpTipSystems.Clean,
					},
					[HousingTutorialStates.QuestTutorials.QuestInProgress] = {
						-- text field is specified in UpdateInProgressHelpTip
						formattingText = CLEAN_DECOR_TUTORIAL_TEXT,
						buttonStyle = HelpTip.ButtonStyle.None,
						targetPoint = HelpTip.Point.BottomEdgeCenter,
						alignment = HelpTip.Alignment.Center,
						offsetX = 0,
						offsetY = -6,
						autoHideWhenTargetHides = true,
						system = HousingTutorialHelpTipSystems.Clean,
						hideArrow = true,
					},
					[HousingTutorialStates.QuestTutorials.ObjectivesComplete] = {
						text = EXIT_DECOR_MODE_TUTORIAL_TEXT,
						buttonStyle = HelpTip.ButtonStyle.Close,
						targetPoint = HelpTip.Point.BottomEdgeCenter,
						alignment = HelpTip.Alignment.Center,
						offsetX = 0,
						offsetY = -6,
						autoHideWhenTargetHides = true,
						system = HousingTutorialHelpTipSystems.Clean,
					},
				},

				helpTipSystemName = HousingTutorialHelpTipSystems.Clean,
				bitfieldFlag = Enum.FrameTutorialAccount.HousingDecorCleanup,
			},

			[HousingTutorialQuestIDs.DecorateQuest] = {
				helpTipInfos = {
					[HousingTutorialStates.QuestTutorials.QuestAccepted] = {
						text = ENTER_DECOR_MODE_TUTORIAL_TEXT,
						buttonStyle = HelpTip.ButtonStyle.None,
						targetPoint = HelpTip.Point.BottomEdgeCenter,
						alignment = HelpTip.Alignment.Center,
						offsetX = 0,
						offsetY = -6,
						autoHideWhenTargetHides = true,
						system = HousingTutorialHelpTipSystems.Decorate,
					},
					[HousingTutorialStates.QuestTutorials.QuestInProgress] = {
						-- text field is specified in UpdateInProgressHelpTip
						formattingText = DECORATE_DECOR_TUTORIAL_TEXT,
						buttonStyle = HelpTip.ButtonStyle.None,
						targetPoint = HelpTip.Point.BottomEdgeCenter,
						alignment = HelpTip.Alignment.Center,
						offsetX = 0,
						offsetY = -6,
						autoHideWhenTargetHides = true,
						system = HousingTutorialHelpTipSystems.Decorate,
						hideArrow = true,
					},
					[HousingTutorialStates.QuestTutorials.ObjectivesComplete] = {
						text = EXIT_DECOR_MODE_TUTORIAL_TEXT,
						buttonStyle = HelpTip.ButtonStyle.Close,
						targetPoint = HelpTip.Point.BottomEdgeCenter,
						alignment = HelpTip.Alignment.Center,
						offsetX = 0,
						offsetY = -6,
						autoHideWhenTargetHides = true,
						system = HousingTutorialHelpTipSystems.Decorate,
					},
				},

				helpTipSystemName = HousingTutorialHelpTipSystems.Decorate,
				bitfieldFlag = Enum.FrameTutorialAccount.HousingDecorPlace,
			},
		},

		CustomizationHelptips = {
			[HousingTutorialStates.CustomizationTutorial.ActionButton] = {
				text = HOUSING_CUSTOMIZATION_BUTTON_TUTORIAL_TEXT,
				buttonStyle = HelpTip.ButtonStyle.Next,
				targetPoint = HelpTip.Point.TopEdgeCenter,
				alignment = HelpTip.Alignment.Center,
				offsetX = 0,
				offsetY = 0,
				autoHideWhenTargetHides = true,
				system = HousingTutorialHelpTipSystems.Customize,
			},
			[HousingTutorialStates.CustomizationTutorial.ClickDecor] = {
				text = HOUSING_CLICK_DECOR_TUTORIAL_TEXT,
				buttonStyle = HelpTip.ButtonStyle.Exit,
				targetPoint = HelpTip.Point.BottomEdgeCenter,
				alignment = HelpTip.Alignment.Center,
				hideArrow = true,
				offsetX = 0,
				offsetY = 0,
				autoHideWhenTargetHides = true,
				system = HousingTutorialHelpTipSystems.Customize,
			},
		},

		LayoutHelptips = {
			[HousingTutorialStates.LayoutTutorial.ActionButton] = {
				text = HOUSING_LAYOUT_BUTTON_TUTORIAL_TEXT,
				buttonStyle = HelpTip.ButtonStyle.Next,
				targetPoint = HelpTip.Point.TopEdgeCenter,
				alignment = HelpTip.Alignment.Center,
				offsetX = 0,
				offsetY = 0,
				autoHideWhenTargetHides = true,
				system = HousingTutorialHelpTipSystems.Layout,
			},
			[HousingTutorialStates.LayoutTutorial.Chest] = {
				text = HOUSING_LAYOUT_CHEST_TUTORIAL_TEXT,
				buttonStyle = HelpTip.ButtonStyle.Exit,
				targetPoint = HelpTip.Point.RightEdgeTop,
				alignment = HelpTip.Alignment.Center,
				offsetX = 0,
				offsetY = -30,
				autoHideWhenTargetHides = true,
				system = HousingTutorialHelpTipSystems.Layout,
			},
		}
	},

	HousingTeleportToHouseTutorial = {
		HousingMicroButton = "HousingMicroButton",
		TeleportButton = "HousingDashboardFrame.HouseInfoContent.ContentFrame.HouseUpgradeFrame.TeleportToHouseButton",

		HousingHouseTeleportHelpTipInfos = {
			[HousingTutorialStates.TeleportToHouseTutorial.MicroButton] = {
				text = HOUSING_DASHBOARD_MICRO_BUTTON_TUTORIAL_TEXT,
				buttonStyle = HelpTip.ButtonStyle.None,
				targetPoint = HelpTip.Point.TopEdgeCenter,
				alignment = HelpTip.Alignment.Center,
				offsetX = 0,
				offsetY = 2,
				autoHideWhenTargetHides = true,
				useParentStrata = true,
				system = HousingTutorialHelpTipSystems.TeleportToHouse,
			},
			[HousingTutorialStates.TeleportToHouseTutorial.TeleportButton] = {
				text = HOUSING_DASHBOARD_TELEPORT_TO_HOUSE_TUTORIAL_TEXT,
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = HelpTip.Point.RightEdgeCenter,
				alignment = HelpTip.Alignment.Right,
				offsetX = 10,
				offsetY = 0,
				autoHideWhenTargetHides = true,
				acknowledgeOnHide = true,
				system = HousingTutorialHelpTipSystems.TeleportToHouse,
			},
		},
	},
};
