EncounterTimelineConstants = {
	-- Scaling multiplier used to convert Edit Mode size settings to scale values.
	SizeToScaleMultiplier = 0.01,
	-- Scaling multiplier used to convert Edit Mode size transparency to alpha values.
	TransparencyToAlphaMultiplier = 0.01,

	-- Durations of various animations applied by the timeline view when
	-- moving event frames around. For sorted tracks the duration is a bit
	-- longer to prevent issues where events too-eagerly chase events moving
	-- from the Long track to the Medium track and visually overlap.

	CrossAxisIntroDuration = 0.35;
	CrossAxisIntroDistance = 25;
	CrossAxisOutroDuration = 0.35;
	CrossAxisOutroDistance = 25;
	SortedTrackTranslationDuration = 0.45;

	-- Art constants used to offset the divider textures from tracks on the
	-- timeline.
	LongTrackDividerOffsetTrack = Enum.EncounterTimelineTrack.Medium;
	LongTrackDividerOffsetExtra = -22;
	QueuedTrackDividerOffsetTrack = Enum.EncounterTimelineTrack.Short;
	QueuedTrackDividerOffsetExtra = 18;

	-- 'amount' parameter passed to FrameDeltaLerp to fade out the trail texture
	-- that follows timeline events when it's no longer needed.
	TrailAlphaFadeRate = 0.4;
};

-- Anchor definitions for timeline pip text. These can't be trivially handled
-- with our orientation mixin as the offsets need adjusting a little bit with
-- different orientations.
--
-- The 'relativeTo' parameter is ignored and will always evaluate to the
-- timeline view frame.
EncounterTimelinePipTextAnchors = {
	Horizontal = AnchorUtil.CreateAnchor("TOP", nil, "BOTTOM", 0, -19);
	Vertical = AnchorUtil.CreateAnchor("LEFT", nil, "RIGHT", 20, 0);
	VerticalFlipped = AnchorUtil.CreateAnchor("RIGHT", nil, "LEFT", -20, 0);
};

EncounterTimelineTimerLayoutDirection = {
	-- Anchor timers to the top of the timer list and grow downwards.
	TopToBottom = 1,
	-- Anchor timers to the bottom of the timer list and grow upwards.
	BottomToTop = 2,
};

EncounterTimelineSettingDefaults = {
	-- If true, flip timeline orientation across the horizontal axis.
	FlipHorizontally = false,
	-- Time point at which animation effects for imminent events should be applied.
	HighlightTime = 5.0,
	-- Scale of icons for event displays.
	IconScale = 1.0,
	-- Bitmask of permitted spell support iconography indicators.
	IndicatorIconMask = Constants.EncounterTimelineIconMasks.EncounterTimelineAllIcons,
	-- If true, show countdown text or swipes.
	ShowCountdown = true,
	-- If true, show spell name or status texts.
	ShowText = false,
	-- Anchor mode for tooltips on hover.
	TooltipAnchor = Enum.EncounterEventsTooltipAnchor.Default,
};

EncounterTimelineViewSettingDefaults = {
	-- Alpha for background art assets.
	BackgroundAlpha = 0.0,
};

EncounterTimelineTrackSettingDefaults = {
	-- Offsets the track view and all events up or down along the timeline.
	CrossAxisOffset = 0,
	-- Icon travel direction for timeline events.
	IconDirection = Enum.EncounterEventsIconDirection.Right,
	-- General orientation of the track view.
	Orientation = Enum.EncounterEventsOrientation.Horizontal,
};

EncounterTimelineTimerSettingDefaults = {
	ShowIcon = true,
	ShowTimerSpark = true,
	TimerFillDirection = Enum.StatusBarTimerDirection.RemainingTime,
};

EncounterTimelineTrackViewSettingDefaults = {
	-- Size allocated to the cross-axis of the timeline view (eg. if horizontal, this is the height).
	CrossAxisExtent = 55,
	-- AnchorMixin for positioning the pip text.
	PipTextAnchor = EncounterTimelinePipTextAnchors.Horizontal,
	-- If true, show a diamond on the timeline at the event highlight time point.
	ShowPipIcon = true,
	-- If true, show text below the pip diamond with the event highlight time as text (eg. "5").
	ShowPipText = true,
};

EncounterTimelineTimerViewSettingDefaults = {
	-- Flow direction for timer bars.
	TimerLayoutDirection = EncounterTimelineTimerLayoutDirection.BottomToTop,
	-- Spacing between elements in the timer bar display.
	TimerSpacing = 2,
	-- Width scaling to apply to the timer view display.
	TimerWidthScale = 1.0,
};

EncounterTimelineTrackLayoutDefaults = {
	-- Amount of padding to apply to the end of the timeline.
	PrimaryAxisEndPadding = 20;
	-- Amount of padding to apply to the start of the timeline.
	PrimaryAxisStartPadding = 20;
	-- Controls the size allocated to events in sorted tracks (eg. long or queued).
	SortedEventExtent = 38;
};

EncounterTimelineTrackOrientationSetup = {
	[Enum.EncounterEventsOrientation.Horizontal] = {
		[Enum.EncounterEventsIconDirection.Right] = {
			primaryAxisOffsetMultiplier = 1;
			primaryAxisStartPoint = "LEFT";
			primaryAxisEndPoint = "RIGHT";
			primaryAxisIsVertical = false;
			texCoordTranslator = function(x1, y1, x2, y2, x3, y3, x4, y4) return x1, y1, x2, y2, x3, y3, x4, y4; end;
		};

		[Enum.EncounterEventsIconDirection.Left] = {
			primaryAxisOffsetMultiplier = -1;
			primaryAxisStartPoint = "RIGHT";
			primaryAxisEndPoint = "LEFT";
			primaryAxisIsVertical = false;
			-- Rotated such that the shadow of the timeline bar is on the bottom edge.
			texCoordTranslator = function(x1, y1, x2, y2, x3, y3, x4, y4) return x3, y3, x4, y4, x1, y1, x2, y2; end,
		};
	};

	[Enum.EncounterEventsOrientation.Vertical] = {
		[Enum.EncounterEventsIconDirection.Bottom] = {
			primaryAxisOffsetMultiplier = -1;
			primaryAxisStartPoint = "TOP";
			primaryAxisEndPoint = "BOTTOM";
			primaryAxisIsVertical = true;
			-- Rotated such that the shadow of the timeline bar is on the right edge.
			texCoordTranslator = function(x1, y1, x2, y2, x3, y3, x4, y4) return x2, y3, x4, y1, x1, y4, x3, y2; end;
		};

		[Enum.EncounterEventsIconDirection.Top] = {
			primaryAxisOffsetMultiplier = 1;
			primaryAxisStartPoint = "BOTTOM";
			primaryAxisEndPoint = "TOP";
			primaryAxisIsVertical = true;
			-- Rotated such that the shadow of the timeline bar is on the right edge.
			texCoordTranslator = function(x1, y1, x2, y2, x3, y3, x4, y4) return x3, y3, x1, y1, x4, y4, x2, y2; end;
		};
	};
};

-- All CVars in the following list are imported into the CVarCallbackRegistry
-- cache on load and if changed will result in visibility of the encounter
-- timeline being re-evaluated.
EncounterTimelineVisibilityCVars = {
	"combatWarningsEnabled",
	"encounterTimelineEnabled",
};

EncounterTimelineIndicatorIconCVars = {
	Enabled = "encounterTimelineIconographyEnabled";
	HiddenIconMask = "encounterTimelineIconographyHiddenMask";
};

EncounterTimelineIconSetMasks = {
	[Enum.EncounterTimelineIconSet.TankAlert] = Constants.EncounterTimelineIconMasks.EncounterTimelineTankAlertIcons;
	[Enum.EncounterTimelineIconSet.HealerAlert] = Constants.EncounterTimelineIconMasks.EncounterTimelineHealerAlertIcons;
	[Enum.EncounterTimelineIconSet.DamageAlert] = Constants.EncounterTimelineIconMasks.EncounterTimelineDamageAlertIcons;
	[Enum.EncounterTimelineIconSet.Deadly] = Constants.EncounterTimelineIconMasks.EncounterTimelineDeadlyIcons;
	[Enum.EncounterTimelineIconSet.Dispel] = Constants.EncounterTimelineIconMasks.EncounterTimelineDispelIcons;
	[Enum.EncounterTimelineIconSet.Enrage] = Constants.EncounterTimelineIconMasks.EncounterTimelineEnrageIcons;
};

-- Curve to apply alpha changes to encounter event icons based on their
-- current track. The 'x' coordinate is a track enum.

EncounterTimelineTrackAlphaCurve = C_CurveUtil.CreateCurve();
EncounterTimelineTrackAlphaCurve:AddPoint(Enum.EncounterTimelineTrack.Long, 0.6);
EncounterTimelineTrackAlphaCurve:AddPoint(Enum.EncounterTimelineTrack.Medium, 1.0);
EncounterTimelineTrackAlphaCurve:AddPoint(Enum.EncounterTimelineTrack.Short, 1.0);
EncounterTimelineTrackAlphaCurve:AddPoint(Enum.EncounterTimelineTrack.Queued, 1.0);
EncounterTimelineTrackAlphaCurve:AddPoint(Enum.EncounterTimelineTrack.Indeterminate, 1.0);

-- Curve used to animate alpha changes to the trail highlight behind event
-- icons as they move through linear timeline tracks. The 'x' coordinate is
-- the progress percentage of the current primary axis interpolation (which is
-- why this isn't just an animation - because that makes things harder).

EncounterTimelineTrailAlphaCurve = C_CurveUtil.CreateCurve();
EncounterTimelineTrailAlphaCurve:AddPoint(0.0, 0);
EncounterTimelineTrailAlphaCurve:AddPoint(0.1, 1);

-- Curve used to bump frame levels of overlapping events based upon their
-- established severity; the 'x' coordinate is a severity enum and the 'y'
-- coordinate a relative adjustment to make to the frame level.
--
-- Note that this adjustment is relative to the frame level of the parent
-- timeline view frame; so it's recommended to ensure that the minimum floor
-- in this curve is an adjustment of 1. Further, we may want to do extra
-- adjustments within event logic - so, make them multiples of 10.
--
-- Ideally, this curve will rarely ever be used - it's just to deal with
-- scenarios where event overlap in an encounter is unavoidable.

EncounterTimelineSeverityFrameLevelCurve = C_CurveUtil.CreateCurve();
EncounterTimelineSeverityFrameLevelCurve:AddPoint(Enum.EncounterEventSeverity.Low, 10);
EncounterTimelineSeverityFrameLevelCurve:AddPoint(Enum.EncounterEventSeverity.Medium, 20);
EncounterTimelineSeverityFrameLevelCurve:AddPoint(Enum.EncounterEventSeverity.High, 30);

-- Seconds formatter used for durations shown on timer bars.

EncounterTimelineSecondsFormatter = CreateFromMixins(SecondsFormatterMixin);
EncounterTimelineSecondsFormatter:Init(0, SecondsFormatter.Abbreviation.OneLetter, false, false);
EncounterTimelineSecondsFormatter:SetDesiredUnitCount(2);
EncounterTimelineSecondsFormatter:SetMinInterval(SecondsFormatter.Interval.Seconds);
EncounterTimelineSecondsFormatter:SetStripIntervalWhitespace(true);
