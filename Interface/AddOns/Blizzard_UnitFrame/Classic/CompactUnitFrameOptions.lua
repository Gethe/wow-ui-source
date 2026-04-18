
-- [[ UnitFrames ]]
DefaultCompactUnitFrameOptions = {
	useClassColors = true,
	healthBarColor = COMPACT_UNIT_FRAME_FRIENDLY_HEALTH_COLOR,
	healthBarColorBG = COMPACT_UNIT_FRAME_FRIENDLY_HEALTH_COLOR_BG,
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
	displayLargerRoleSpecificDebuffs = true, -- There's no setting for this in classic yet
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
	useClassColors = false,
	displaySelectionHighlight = true,
	highlightOnMouseover = true,
	highlightNameOnMouseover = true,
	highlightOverHealthBar = true,
	displayAggroHighlight = false,
	displayName = true,
	fadeOutOfRange = false,
	--displayStatusText = true,
	displayHealPrediction = false,
	--displayDispelDebuffs = true,
	colorNameBySelection = false,
	colorNameWithExtendedColors = false,
	colorHealthWithExtendedColors = false,
	colorHealthBySelection = true,
	considerSelectionInCombatAsHostile = false,
	brightenFriendlyPlayerHealth = false,
	smoothHealthUpdates = false,
	displayNameWhenSelected = false,
	displayNameByPlayerNameRules = false,
	showPvPClassificationIndicator = true,
	showLevel = true,

	selectedBorderColor = CreateColor(1, 1, 1, .35),
	softTargetBorderColor = CreateColor(.9, 1, .9, .25),
	tankBorderColor = CreateColor(1, 1, 0, .6),
	defaultBorderColor = CreateColor(0, 0, 0, .8),
}

DefaultCompactNamePlateEnemyFrameOptions = {
	displaySelectionHighlight = true,
	highlightOnMouseover = true,
	highlightNameOnMouseover = true,
	highlightOverHealthBar = true,
	displayAggroHighlight = false,
	playLoseAggroHighlight = false,
	displayName = true,
	fadeOutOfRange = false,
	displayHealPrediction = false,
	colorNameBySelection = false,
	colorHealthBySelection = true,
	considerSelectionInCombatAsHostile = false,
	brightenFriendlyPlayerHealth = false,
	smoothHealthUpdates = false,
	displayNameWhenSelected = false,
	displayNameByPlayerNameRules = false,
	greyOutWhenTapDenied = true,
	showClassificationIndicator = false,
	showPvPClassificationIndicator = false,
	showLevel = true,

	selectedBorderColor = CreateColor(1, 1, 1, .55),
	softTargetBorderColor = CreateColor(1, 1, 1, .4),
	tankBorderColor = CreateColor(1, 1, 0, .6),
	defaultBorderColor = CreateColor(0, 0, 0, .8),
}

DefaultCompactNamePlatePlayerFrameOptions = {
	-- Not used by Classic.
}

DefaultCompactNamePlateFrameSetUpOptions = {
	healthBarHeight = 10,
	healthBarAlpha = 0.75,
	castBarHeight = 10,
	castBarFontHeight = 10,
	useLargeNameFont = false,

	castBarShieldWidth = 0, -- Handled by Nameplate_CastBar_AdjustPosition for Classic.
	castBarShieldHeight = 0,

	castIconWidth = 0,
	castIconHeight = 0,
}

DefaultCompactNamePlatePlayerFrameSetUpOptions = {
	healthBarHeight = 10,
	healthBarAlpha = 0.75,
	castBarHeight = 10,
	castBarFontHeight = 10,
	useLargeNameFont = false,

	castBarShieldWidth = 0, -- Handled by Nameplate_CastBar_AdjustPosition for Classic.
	castBarShieldHeight = 0,

	castIconWidth = 0,
	castIconHeight = 0,
}
