EncounterWarningsConstants = {
	DefaultMessageHoldTime = 10,
};

EncounterWarningsSystemSeverity = {
	[Enum.EditModeEncounterEventsSystemIndices.CriticalWarnings] = Enum.EncounterEventSeverity.High,
	[Enum.EditModeEncounterEventsSystemIndices.MediumWarnings] = Enum.EncounterEventSeverity.Medium,
	[Enum.EditModeEncounterEventsSystemIndices.NormalWarnings] = Enum.EncounterEventSeverity.Low,
};

EncounterWarningsSeveritySoundKits = {
	[Enum.EncounterEventSeverity.High] = function() return SOUNDKIT.UI_ENCOUNTEREVENT_SEVERITY_HIGH; end,
	[Enum.EncounterEventSeverity.Medium] = function() return SOUNDKIT.UI_ENCOUNTEREVENT_SEVERITY_MEDIUM; end,
	[Enum.EncounterEventSeverity.Low] = function() return SOUNDKIT.UI_ENCOUNTEREVENT_SEVERITY_LOW; end,
};

EncounterWarningsSeverityTextSizeLimits = {
	-- These should be about ~110 less than the minimumWidths set up in XML
	-- for the per-severity frames to keep the icons from escaping the bounds
	-- of the region as previewed in edit mode.
	[Enum.EncounterEventSeverity.High] = { width = 490, height = 48 },
	[Enum.EncounterEventSeverity.Medium] = { width = 440, height = 36 },
	[Enum.EncounterEventSeverity.Low] = { width = 390, height = 36 },
};

EncounterWarningsSeverityFonts = {
	[Enum.EncounterEventSeverity.High] = function() return SystemFont_Outline_Slug_Huge2; end,
	[Enum.EncounterEventSeverity.Medium] = function() return SystemFont_Huge1_Outline_Slug; end,
	[Enum.EncounterEventSeverity.Low] = function() return SystemFont_Outline_Slug_Large2; end,
};

EncounterWarningsSeverityColors = {
	[Enum.EncounterEventSeverity.High] = function() return ENCOUNTER_WARNINGS_CRITICAL_FONT_COLOR; end,
	[Enum.EncounterEventSeverity.Medium] = function() return ENCOUNTER_WARNINGS_MEDIUM_FONT_COLOR; end,
	[Enum.EncounterEventSeverity.Low] = function() return ENCOUNTER_WARNINGS_MINOR_FONT_COLOR; end,
};

-- All CVars in the following list are imported into the CVarCallbackRegistry
-- cache on load and if changed will result in visibility of encounter warning
-- frames being re-evaluated.
EncounterWarningsVisibilityCVars = {
	"encounterWarningsEnabled",
	"encounterWarningsHideMediumWarnings",
	"encounterWarningsHideMinorWarnings",
};
