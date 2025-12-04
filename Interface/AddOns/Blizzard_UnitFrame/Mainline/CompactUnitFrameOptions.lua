
-- [[ UnitFrames ]]
DefaultCompactUnitFrameOptions = {
	useClassColors = true,
	healthBarColor = COMPACT_UNIT_FRAME_FRIENDLY_HEALTH_COLOR,
	displaySelectionHighlight = true,
	displayAggroHighlight = true,
	displayName = true,
	fadeOutOfRange = true,
	displayStatusText = true,
	displayHealPrediction = true,
	displayRoleIcon = true,
	displayRaidRoleIcon = true,
	displayDispelDebuffs = true,
	displayBuffs = true,
	displayDebuffs = true,
	displayOnlyDispellableDebuffs = false,
	displayLargerRoleSpecificDebuffs = true,
	raidFramesDispelIndicatorType = Enum.RaidDispelDisplayType.DisplayAll,
	raidFramesCenterBigDefensive = true,
	displayNonBossDebuffs = true,
	healthText = "none",
	displayIncomingResurrect = true,
	displayIncomingSummon = true,
	displayInOtherGroup = true,
	displayInOtherPhase = true,
	showDispelIndicatorOverlay = true,

	--If class colors are enabled also show the class colors for npcs in your raid frames or
	--raid-frame-style party frames.
	allowClassColorsForNPCs = true,
}

DefaultCompactUnitFrameSetupOptions = {
	displayPowerBar = true,
	displayOnlyHealerPowerBars = false,
}

-- [[ MiniFrames (e.g., pets on raid frames )]]
DefaultCompactMiniFrameOptions = {
	displaySelectionHighlight = true,
	displayAggroHighlight = true,
	displayName = true,
	fadeOutOfRange = true,
	--displayStatusText = true,
	displayHealPrediction = true,
	--displayDispelDebuffs = true,
	hideReadyCheckIcon = true,
}

DefaultCompactMiniFrameSetUpOptions = {
	displayBorder = true,
}

--[[ Nameplates ]]
DefaultCompactNamePlateFriendlyFrameOptions = {
	useClassColors = true,
	displaySelectionHighlight = true,
	highlightOnMouseover = false,
	highlightNameOnMouseover = false,
	highlightOverHealthBar = false,
	displayAggroHighlight = false,
	displayName = true,
	fadeOutOfRange = false,
	--displayStatusText = true,
	displayHealPrediction = true,
	--displayDispelDebuffs = true,
	colorNameBySelection = true,
	colorNameWithExtendedColors = true,
	colorHealthWithExtendedColors = true,
	colorHealthBySelection = true,
	considerSelectionInCombatAsHostile = true,
	brightenFriendlyPlayerHealth = true,
	smoothHealthUpdates = false,
	displayNameWhenSelected = true,
	displayNameByPlayerNameRules = true,
	showPvPClassificationIndicator = true,
	showLevel = false,

	selectedBorderColor = CreateColor(1, 1, 1, .35),
	softTargetBorderColor = CreateColor(.9, 1, .9, .25),
	tankBorderColor = CreateColor(1, 1, 0, .6),
	defaultBorderColor = CreateColor(0, 0, 0, .8),
}

DefaultCompactNamePlateEnemyFrameOptions = {
	displaySelectionHighlight = true,
	highlightOnMouseover = false,
	highlightNameOnMouseover = false,
	highlightOverHealthBar = false,
	displayAggroHighlight = false,
	playLoseAggroHighlight = true,
	displayName = true,
	fadeOutOfRange = false,
	displayHealPrediction = true,
	colorNameBySelection = true,
	colorHealthBySelection = true,
	considerSelectionInCombatAsHostile = true,
	brightenFriendlyPlayerHealth = true,
	smoothHealthUpdates = false,
	displayNameWhenSelected = true,
	displayNameByPlayerNameRules = true,
	greyOutWhenTapDenied = true,
	showClassificationIndicator = true,
	showPvPClassificationIndicator = true,
	showLevel = false,

	selectedBorderColor = CreateColor(1, 1, 1, .9),
	softTargetBorderColor = CreateColor(1, 1, 1, .4),
	tankBorderColor = CreateColor(1, 1, 0, .6),
	defaultBorderColor = CreateColor(0, 0, 0, 1),
}

DefaultCompactNamePlatePlayerFrameOptions = {
	displaySelectionHighlight = false,
	displayAggroHighlight = false,
	displayName = false,
	fadeOutOfRange = false,
	displayHealPrediction = true,
	colorNameBySelection = true,
	smoothHealthUpdates = false,
	displayNameWhenSelected = false,
	hideCastbar = true,
	healthBarColorOverride = CreateColor(0, 1, 0),

	defaultBorderColor = CreateColor(0, 0, 0, 1),
}

DefaultCompactNamePlateFrameSetUpOptions = {
	healthBarHeight = 4,
	healthBarAlpha = 0.75,
	castBarHeight = 8,
	castBarFontHeight = 10,
	useLargeNameFont = false,

	castBarShieldWidth = 10,
	castBarShieldHeight = 12,

	castIconWidth = 10,
	castIconHeight = 10,
}

DefaultCompactNamePlatePlayerFrameSetUpOptions = {
	healthBarHeight = 4,
	healthBarAlpha = 1,
	castBarHeight = 8,
	castBarFontHeight = 10,
	useLargeNameFont = false,

	castBarShieldWidth = 10,
	castBarShieldHeight = 12,

	castIconWidth = 10,
	castIconHeight = 10,
}
