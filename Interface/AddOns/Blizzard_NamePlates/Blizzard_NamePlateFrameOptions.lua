-- All values listed here can be updated from NamePlateDriverMixin:UpdateNamePlateOptions.
-- Default values are just present to show the complete list of available options.
NamePlateSetupOptions = {
	healthBarHeight = 20,
	healthBarFontHeight = 16,
	castBarHeight = 16,
	castBarFontHeight = 12,
	castBarShieldWidth = 10,
	castBarShieldHeight = 12,
	castIconWidth = 12,
	castIconHeight = 12,
	unitNameInsideHealthBar = true,
	spellNameInsideCastBar = false,
	classificationScale = 1.0,
}

-- Some values listed here can be updated from NamePlateDriverMixin:UpdateNamePlateOptions.
-- Others are just 'constants' for nameplates attached to friendly units.
NamePlateFriendlyFrameOptions = {
	useClassColors = true,
	displaySelectionHighlight = true,
	displayAggroHighlight = false,
	displayName = true,
	fadeOutOfRange = false,
	displayHealPrediction = true,
	colorNameBySelection = true,
	colorNameWithExtendedColors = true,
	colorHealthWithExtendedColors = true,
	colorHealthBySelection = true,
	considerSelectionInCombatAsHostile = true,
	smoothHealthUpdates = false,
	displayNameWhenSelected = true,
	displayNameByPlayerNameRules = true,
	showPvPClassificationIndicator = true,
	selectedBorderColor = CreateColor(1, 1, 1, .35),
	softTargetBorderColor = CreateColor(.9, 1, .9, .25),
	tankBorderColor = CreateColor(1, 1, 0, .6),
	defaultBorderColor = CreateColor(0, 0, 0, .8),
}

-- Some values listed here can be updated from NamePlateDriverMixin:UpdateNamePlateOptions.
-- Others are just 'constants' for nameplates attached to enemy units.
NamePlateEnemyFrameOptions = {
	displaySelectionHighlight = true,
	displayAggroHighlight = false,
	usePlayerForAggroHighlightThreat = true;
	displayName = true,
	fadeOutOfRange = false,
	displayHealPrediction = true,
	colorNameBySelection = true,
	colorHealthBySelection = true,
	considerSelectionInCombatAsHostile = true,
	smoothHealthUpdates = false,
	displayNameWhenSelected = true,
	displayNameByPlayerNameRules = true,
	greyOutWhenTapDenied = true,
	showClassificationIndicator = true,
	showPvPClassificationIndicator = true,
	selectedBorderColor = CreateColor(1, 1, 1, .9),
	softTargetBorderColor = CreateColor(1, 1, 1, .4),
	tankBorderColor = CreateColor(1, 1, 0, .6),
	defaultBorderColor = CreateColor(0, 0, 0, 1),
}
