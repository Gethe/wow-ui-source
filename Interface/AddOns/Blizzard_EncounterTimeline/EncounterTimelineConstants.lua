EncounterTimelineViewSetting = {
	BackgroundTransparency = "BackgroundTransparency",
	ContainerScale = "containerScale",
	CrossAxisExtent = "crossAxisExtent",
	CrossAxisOffset = "crossAxisOffset",
	DividerOffset = "dividerOffset",
	EventIntroDuration = "eventIntroDuration",
	EventIntroOffsetStart = "eventIntroOffsetStart",
	EventOutroDuration = "eventOutroDuration",
	EventOutroOffsetEnd = "eventOutroOffsetEnd",
	IconDirection = "iconDirection",
	IconSize = "iconSize",
	IconSizeMultiplier = "iconSizeMultiplier",
	LongTrackEventExtent = "longTrackEventExtent",
	LongTrackEventLimit = "longTrackEventLimit",
	LongTrackEventSpacing = "longTrackEventSpacing",
	LongTrackMinimumDurationOverride = "longTrackMinimumDurationOverride",
	LongTrackOrderDuration = "longTrackOrderDuration",
	LongTrackStartPadding = "longTrackStartPadding",
	MediumTrackExtent = "mediumTrackExtent",
	PipDuration = "pipDuration",
	PipShown = "pipShown",
	PipTextHorizontalAnchorPoint = "pipTextHorizontalAnchorPoint",
	PipTextHorizontalOffsetX = "pipTextHorizontalOffsetX",
	PipTextHorizontalOffsetY = "pipTextHorizontalOffsetY",
	PipTextHorizontalRelativePoint = "pipTextHorizontalRelativePoint",
	PipTextShown = "pipTextShown",
	PipTextVerticalAnchorPoint = "pipTextVerticalAnchorPoint",
	PipTextVerticalOffsetX = "pipTextVerticalOffsetX",
	PipTextVerticalOffsetY = "pipTextVerticalOffsetY",
	PipTextVerticalRelativePoint = "pipTextVerticalRelativePoint",
	PrimaryAxisEndPadding = "primaryAxisEndPadding",
	PrimaryAxisStartPadding = "primaryAxisStartPadding",
	ShortTrackEndPadding = "shortTrackEndPadding",
	ShortTrackExtent = "shortTrackExtent",
	SpellNamesEnabled = "spellNamesEnabled",
	SpellTimersEnabled = "spellTimersEnabled",
	SpellTooltipsEnabled = "spellTooltipsEnabled",
	TimelineVisibility = "timelineVisibility",
	ViewOrientation = "viewOrientation",
	ViewTransparency = "viewTransparency",
};

-- This map also defines what settings attributes are valid, so nil values are not allowed.
EncounterTimelineDefaultViewSettings = {
	-- The following settings correspond to Edit Mode configuration.

	[EncounterTimelineViewSetting.BackgroundTransparency] = 0,
	[EncounterTimelineViewSetting.IconDirection] = Enum.EncounterEventsIconDirection.Right,
	[EncounterTimelineViewSetting.IconSizeMultiplier] = 100,
	[EncounterTimelineViewSetting.ViewOrientation] = Enum.EncounterEventsOrientation.Horizontal,
	[EncounterTimelineViewSetting.ContainerScale] = 100,
	[EncounterTimelineViewSetting.ViewTransparency] = 100,
	[EncounterTimelineViewSetting.SpellTooltipsEnabled] = true,
	[EncounterTimelineViewSetting.SpellTimersEnabled] = true,
	[EncounterTimelineViewSetting.SpellNamesEnabled] = true,
	[EncounterTimelineViewSetting.TimelineVisibility] = Enum.EncounterEventsVisibility.InCombat,

	-- For the below settings we'll describe them in terms of their effects
	-- on a default left-to-right horizontal bar.
	--
	-- These settings are not exposed in the UI but are made available for
	-- design tweaks. Addons can adjust these via the SetViewSetting APIs
	-- on the EncounterTimeline frame.

	-- Base extent of event frames.
	[EncounterTimelineViewSetting.IconSize] = 44,

	-- Amount of padding to apply to the start of the timeline.
	[EncounterTimelineViewSetting.PrimaryAxisStartPadding] = 30,

	-- Amount of padding to apply to the end of the timeline.
	[EncounterTimelineViewSetting.PrimaryAxisEndPadding] = 30,

	-- Offsets the timeline bar and all events up or down along the timeline.
	[EncounterTimelineViewSetting.CrossAxisOffset] = 0,

	-- Controls the height of the timeline.
	[EncounterTimelineViewSetting.CrossAxisExtent] = 55,

	-- Amount of padding to apply to the start of the long event track.
	[EncounterTimelineViewSetting.LongTrackStartPadding] = 0,

	-- Controls the size allocated to events in the long event track.
	[EncounterTimelineViewSetting.LongTrackEventExtent] = 50,

	-- Controls the maximum number of events we'll show in the long track.
	[EncounterTimelineViewSetting.LongTrackEventLimit] = 2,

	-- Controls the minimum duration that a newly added event to the Long
	-- timeline track must have in order to be made visible. Events under
	-- this duration will remain hidden until they transition to the Short
	-- track.
	[EncounterTimelineViewSetting.LongTrackMinimumDurationOverride] = 13,

	-- Controls the duration that events will spend moving from one spot in
	-- the long track to another. This is intentionally a bit longer than
	-- other transitions because if it's too fast, they "chase" events moving
	-- through the medium track a bit too eagerly and overlap.
	[EncounterTimelineViewSetting.LongTrackOrderDuration] = 0.45,

	-- Amount of spacing to apply between events in the long track.
	[EncounterTimelineViewSetting.LongTrackEventSpacing] = 0,

	-- Controls the total width of the medium track. The medium track is a
	-- short transitionary linear segment of the bar between the long and
	-- short tracks that basically makes the events go real fast.
	[EncounterTimelineViewSetting.MediumTrackExtent] = 55,

	-- Controls the total width of the short track. The short track comes
	-- after the medium track is used until the end of the timeline when
	-- events reach a zero duration.
	[EncounterTimelineViewSetting.ShortTrackExtent] = 386,

	-- Amount of padding to apply to the end of the short track.
	[EncounterTimelineViewSetting.ShortTrackEndPadding] = 0,

	-- Controls the offset of the long-to-short track divider art asset. This
	-- must be adjusted if any padding or extent values above are adjusted,
	-- as it represents an absolute position on the timeline frame.
	[EncounterTimelineViewSetting.DividerOffset] = 163,

	-- Controls what duration the timeline pip will be shown at.

	[EncounterTimelineViewSetting.PipDuration] = 5,
	[EncounterTimelineViewSetting.PipShown] = true,

	-- Anchor points and offsets for the text shown underneath the pip.
	-- These can be configured independent of the timeline orientation.

	[EncounterTimelineViewSetting.PipTextHorizontalAnchorPoint] = "TOP",
	[EncounterTimelineViewSetting.PipTextHorizontalRelativePoint] = "BOTTOM",
	[EncounterTimelineViewSetting.PipTextHorizontalOffsetX] = 0,
	[EncounterTimelineViewSetting.PipTextHorizontalOffsetY] = -19,

	[EncounterTimelineViewSetting.PipTextVerticalAnchorPoint] = "LEFT",
	[EncounterTimelineViewSetting.PipTextVerticalRelativePoint] = "RIGHT",
	[EncounterTimelineViewSetting.PipTextVerticalOffsetX] = 20,
	[EncounterTimelineViewSetting.PipTextVerticalOffsetY] = 0,
	[EncounterTimelineViewSetting.PipTextShown] = true,

	-- Controls the duration and offsets of various timeline event transitions.
	[EncounterTimelineViewSetting.EventIntroOffsetStart] = -25,
	[EncounterTimelineViewSetting.EventIntroDuration] = 0.35,
	[EncounterTimelineViewSetting.EventOutroOffsetEnd] = -25,
	[EncounterTimelineViewSetting.EventOutroDuration] = 0.35,
};

EncounterTimelineViewOrientations = {
	[Enum.EncounterEventsOrientation.Horizontal] = {
		[Enum.EncounterEventsIconDirection.Right] = {
			pointMappings = { START = "LEFT", END = "RIGHT", CROSS_START = "TOP", CROSS_END = "BOTTOM" },
			primaryAxisVertical = false,
			primaryAxisDirection = 1,
			crossAxisDirection = -1,
			texCoordTranslator = function(x1, y1, x2, y2, x3, y3, x4, y4) return x1, y1, x2, y2, x3, y3, x4, y4; end,
		};

		[Enum.EncounterEventsIconDirection.Left] = {
			pointMappings = { START = "RIGHT", END = "LEFT", CROSS_START = "TOP", CROSS_END = "BOTTOM" },
			primaryAxisVertical = false,
			primaryAxisDirection = -1,
			crossAxisDirection = -1,
			-- Rotated such that the shadow of the timeline bar is on the bottom edge.
			texCoordTranslator = function(x1, y1, x2, y2, x3, y3, x4, y4) return x3, y3, x4, y4, x1, y1, x2, y2; end,
		};
	};

	[Enum.EncounterEventsOrientation.Vertical] = {
		[Enum.EncounterEventsIconDirection.Bottom] = {
			pointMappings = { START = "TOP", END = "BOTTOM", CROSS_START = "RIGHT", CROSS_END = "LEFT" },
			primaryAxisVertical = true,
			primaryAxisDirection = -1,
			crossAxisDirection = -1,
			-- Rotated such that the shadow of the timeline bar is on the right edge.
			texCoordTranslator = function(x1, y1, x2, y2, x3, y3, x4, y4) return x2, y3, x4, y1, x1, y4, x3, y2; end,
		};

		[Enum.EncounterEventsIconDirection.Top] = {
			pointMappings = { START = "BOTTOM", END = "TOP", CROSS_START = "RIGHT", CROSS_END = "LEFT" },
			primaryAxisVertical = true,
			primaryAxisDirection = 1,
			crossAxisDirection = -1,
			-- Rotated such that the shadow of the timeline bar is on the right edge.
			texCoordTranslator = function(x1, y1, x2, y2, x3, y3, x4, y4) return x3, y3, x1, y1, x4, y4, x2, y2; end,
		};
	};
};

EncounterTimelineViewNormalizedOffsets = {
	PrimaryAxisStart = -math.huge,
	PrimaryAxisStartMedium = -1,
	PrimaryAxisStartShort = 0,
	PrimaryAxisEnd = 1,
};

EncounterTimelineViewDirtyFlag = FlagsUtil.MakeFlags("LayoutInvalidated");
