
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
