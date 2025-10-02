local EncounterTimeline =
{
	Name = "EncounterTimeline",
	Type = "System",
	Namespace = "C_EncounterTimeline",

	Functions =
	{
		{
			Name = "AddEditModeEvents",
			Type = "Function",
			Documentation = { "Adds a predefined set of events to the timeline for display in Edit Mode." },

			Returns =
			{
				{ Name = "loopTimerDuration", Type = "DurationSeconds", Nilable = false },
			},
		},
		{
			Name = "AddScriptEvent",
			Type = "Function",
			SecretArguments = "NotAllowed",
			Documentation = { "Adds a custom event to the timeline." },

			Arguments =
			{
				{ Name = "eventInfo", Type = "EncounterTimelineScriptEventRequest", Nilable = false },
			},

			Returns =
			{
				{ Name = "eventID", Type = "EncounterTimelineEventID", Nilable = false },
			},
		},
		{
			Name = "CancelAllScriptEvents",
			Type = "Function",
			Documentation = { "Cancels all custom timeline events, removing them from the timeline." },
		},
		{
			Name = "CancelEditModeEvents",
			Type = "Function",
			Documentation = { "Removes all Edit Mode events from the timeline." },
		},
		{
			Name = "CancelScriptEvent",
			Type = "Function",
			RequiresValidTimelineEvent = true,
			SecretArguments = "NotAllowed",
			Documentation = { "Cancels a custom timeline event, removing it from the timeline." },

			Arguments =
			{
				{ Name = "eventID", Type = "EncounterTimelineEventID", Nilable = false },
			},
		},
		{
			Name = "GetCurrentTime",
			Type = "Function",
			Documentation = { "Returns the current timestamp used for rendering the timeline display." },

			Returns =
			{
				{ Name = "currentTime", Type = "DurationSeconds", Nilable = false },
			},
		},
		{
			Name = "GetEventInfo",
			Type = "Function",
			RequiresValidTimelineEvent = true,
			SecretArguments = "NotAllowed",
			Documentation = { "Returns information about a timeline event. This data is generally expected to be static for the lifetime of an event." },

			Arguments =
			{
				{ Name = "eventID", Type = "EncounterTimelineEventID", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "EncounterTimelineEventInfo", Nilable = false },
			},
		},
		{
			Name = "GetEventList",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Returns an unsorted list of event IDs present in the timeline." },

			Returns =
			{
				{ Name = "events", Type = "table", InnerType = "EncounterTimelineEventID", Nilable = false },
			},
		},
		{
			Name = "GetEventPosition",
			Type = "Function",
			RequiresValidTimelineEvent = true,
			SecretArguments = "NotAllowed",
			Documentation = { "Returns information about the position of an event on the timeline. This API should be preferred when events updating state or track information fire as it queries all dynamic positioning attributes in one trip." },

			Arguments =
			{
				{ Name = "eventID", Type = "EncounterTimelineEventID", Nilable = false },
			},

			Returns =
			{
				{ Name = "eventPosition", Type = "EncounterTimelineEventPosition", Nilable = true },
			},
		},
		{
			Name = "GetEventState",
			Type = "Function",
			RequiresValidTimelineEvent = true,
			SecretArguments = "NotAllowed",
			Documentation = { "Returns the current state of a timeline event." },

			Arguments =
			{
				{ Name = "eventID", Type = "EncounterTimelineEventID", Nilable = false },
			},

			Returns =
			{
				{ Name = "state", Type = "EncounterTimelineEventState", Nilable = false },
			},
		},
		{
			Name = "GetEventTimeElapsed",
			Type = "Function",
			RequiresValidTimelineEvent = true,
			SecretArguments = "NotAllowed",
			Documentation = { "Returns the elapsed duration of a timeline event." },

			Arguments =
			{
				{ Name = "eventID", Type = "EncounterTimelineEventID", Nilable = false },
			},

			Returns =
			{
				{ Name = "timeElapsed", Type = "DurationSeconds", Nilable = false },
			},
		},
		{
			Name = "GetEventTimeRemaining",
			Type = "Function",
			RequiresValidTimelineEvent = true,
			SecretArguments = "NotAllowed",
			Documentation = { "Returns the remaining duration of a timeline event." },

			Arguments =
			{
				{ Name = "eventID", Type = "EncounterTimelineEventID", Nilable = false },
			},

			Returns =
			{
				{ Name = "timeRemaining", Type = "DurationSeconds", Nilable = false },
			},
		},
		{
			Name = "GetTrackInfo",
			Type = "Function",
			SecretArguments = "NotAllowed",
			Documentation = { "Returns information for a single timeline track." },

			Arguments =
			{
				{ Name = "track", Type = "EncounterTimelineTrack", Nilable = false },
			},

			Returns =
			{
				{ Name = "trackInfo", Type = "EncounterTimelineTrackInfo", Nilable = false },
			},
		},
		{
			Name = "GetTrackList",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Returns information about all timeline tracks." },

			Returns =
			{
				{ Name = "tracks", Type = "table", InnerType = "EncounterTimelineTrackInfo", Nilable = false },
			},
		},
		{
			Name = "GetTrackSectionInfo",
			Type = "Function",
			SecretArguments = "NotAllowed",
			Documentation = { "Returns information about a track subsection." },

			Arguments =
			{
				{ Name = "section", Type = "EncounterTimelineSection", Nilable = false },
			},

			Returns =
			{
				{ Name = "sectionInfo", Type = "EncounterTimelineSectionInfo", Nilable = false },
			},
		},
		{
			Name = "HasActiveEvents",
			Type = "Function",
			Documentation = { "Returns true if the timeline contains any events in the active state." },

			Returns =
			{
				{ Name = "hasActiveEvents", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasAnyEvents",
			Type = "Function",
			Documentation = { "Returns true if the timeline contains any events in any state." },

			Returns =
			{
				{ Name = "hasAnyEvents", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasPausedEvents",
			Type = "Function",
			Documentation = { "Returns true if the timeline contains any events in the paused state." },

			Returns =
			{
				{ Name = "hasPausedEvents", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsTimelineEnabled",
			Type = "Function",
			Documentation = { "Returns true if the encounter timeline feature has been enabled by the player. This function will always return false if the feature is not supported." },

			Returns =
			{
				{ Name = "isSupportedAndEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsTimelineSupported",
			Type = "Function",
			Documentation = { "Returns true if the encounter timeline feature is supported on this client. This function always returns a static value." },

			Returns =
			{
				{ Name = "isSupported", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PauseScriptEvent",
			Type = "Function",
			RequiresValidTimelineEvent = true,
			SecretArguments = "NotAllowed",
			Documentation = { "Pauses a custom timeline event, hiding it from the timeline. A paused event can later be resumed to show it again, or canceled." },

			Arguments =
			{
				{ Name = "eventID", Type = "EncounterTimelineEventID", Nilable = false },
			},
		},
		{
			Name = "ResumeScriptEvent",
			Type = "Function",
			RequiresValidTimelineEvent = true,
			SecretArguments = "NotAllowed",
			Documentation = { "Resumes a custom timeline event, showing it on the timeline again if it is currently paused." },

			Arguments =
			{
				{ Name = "eventID", Type = "EncounterTimelineEventID", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "EncounterTimelineEventAdded",
			Type = "Event",
			LiteralName = "ENCOUNTER_TIMELINE_EVENT_ADDED",
			Documentation = { "Fired when an event has been added to the timeline." },
			Payload =
			{
				{ Name = "eventInfo", Type = "EncounterTimelineEventInfo", Nilable = false },
				{ Name = "initialState", Type = "EncounterTimelineEventState", Nilable = false, Documentation = { "Newly added events always begin in either the Active or Paused state." } },
			},
		},
		{
			Name = "EncounterTimelineEventPositionChanged",
			Type = "Event",
			LiteralName = "ENCOUNTER_TIMELINE_EVENT_POSITION_CHANGED",
			Documentation = { "Fired when an event position has changed substantially - eg. transitioning to a new track or subsection, or has changed sort order." },
			Payload =
			{
				{ Name = "eventID", Type = "EncounterTimelineEventID", Nilable = false },
			},
		},
		{
			Name = "EncounterTimelineEventRemoved",
			Type = "Event",
			LiteralName = "ENCOUNTER_TIMELINE_EVENT_REMOVED",
			Documentation = { "Fired when an event has been removed from the timeline. This is guaranteed to occur after all other timeline events within a single tick have fired. This is fired post-removal of the event, and so queries using the supplied event ID will return nil." },
			Payload =
			{
				{ Name = "eventID", Type = "EncounterTimelineEventID", Nilable = false },
			},
		},
		{
			Name = "EncounterTimelineEventStateChanged",
			Type = "Event",
			LiteralName = "ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED",
			Documentation = { "Fired when an event has changed state." },
			Payload =
			{
				{ Name = "eventID", Type = "EncounterTimelineEventID", Nilable = false },
				{ Name = "newState", Type = "EncounterTimelineEventState", Nilable = false },
			},
		},
		{
			Name = "EncounterTimelineLayoutUpdated",
			Type = "Event",
			LiteralName = "ENCOUNTER_TIMELINE_LAYOUT_UPDATED",
			Documentation = { "Fired when the layout of tracks on the timeline has been updated. This can include changes to the minimum or maximum durations of tracks." },
		},
		{
			Name = "EncounterTimelineStateUpdated",
			Type = "Event",
			LiteralName = "ENCOUNTER_TIMELINE_STATE_UPDATED",
			Documentation = { "Signaled when conditions controlling the visibility of the encounter timeline are updated." },
		},
	},

	Tables =
	{
		{
			Name = "EncounterTimelineEventInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "EncounterTimelineEventID", Nilable = false },
				{ Name = "source", Type = "EncounterTimelineEventSource", Nilable = false },
				{ Name = "tooltipSpellID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "iconFileID", Type = "fileID", Nilable = false, ConditionalSecret = true },
				{ Name = "duration", Type = "DurationSeconds", Nilable = false },
				{ Name = "priority", Type = "EncounterTimelineEventPriority", Nilable = false, ConditionalSecret = true },
				{ Name = "role", Type = "EncounterTimelineEventRole", Nilable = false, ConditionalSecret = true },
				{ Name = "dispelType", Type = "EncounterTimelineEventDispelType", Nilable = false, ConditionalSecret = true },
			},
		},
		{
			Name = "EncounterTimelineEventPosition",
			Type = "Structure",
			Fields =
			{
				{ Name = "state", Type = "EncounterTimelineEventState", Nilable = false },
				{ Name = "track", Type = "EncounterTimelineTrack", Nilable = false },
				{ Name = "section", Type = "EncounterTimelineSection", Nilable = false },
				{ Name = "order", Type = "luaIndex", Nilable = true },
				{ Name = "timeRemaining", Type = "DurationSeconds", Nilable = false },
			},
		},
		{
			Name = "EncounterTimelineScriptEventRequest",
			Type = "Structure",
			Fields =
			{
				{ Name = "tooltipSpellID", Type = "number", Nilable = false },
				{ Name = "iconFileID", Type = "fileID", Nilable = false },
				{ Name = "duration", Type = "DurationSeconds", Nilable = false },
				{ Name = "priority", Type = "EncounterTimelineEventPriority", Nilable = false, Default = "Normal" },
				{ Name = "role", Type = "EncounterTimelineEventRole", Nilable = false, Default = "None" },
				{ Name = "dispelType", Type = "EncounterTimelineEventDispelType", Nilable = false, Default = "None" },
				{ Name = "paused", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "EncounterTimelineSectionInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "track", Type = "EncounterTimelineTrack", Nilable = false },
				{ Name = "trackType", Type = "EncounterTimelineTrackType", Nilable = false },
				{ Name = "section", Type = "EncounterTimelineSection", Nilable = false },
				{ Name = "minEventDuration", Type = "DurationSeconds", Nilable = true },
				{ Name = "maxEventDuration", Type = "DurationSeconds", Nilable = true },
			},
		},
		{
			Name = "EncounterTimelineTrackInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "track", Type = "EncounterTimelineTrack", Nilable = false },
				{ Name = "trackType", Type = "EncounterTimelineTrackType", Nilable = false },
				{ Name = "minEventDuration", Type = "DurationSeconds", Nilable = true, Documentation = { "The exclusive lower bound of durations for events on this track. If zero, this should be treated as an inclusive lower bound. This bound is ignored by the timeline sequence in circumstances where an adjacent Sorted track would exceed its maximum event count, requiring events be pushed 'to the left' by one track." } },
				{ Name = "maxEventDuration", Type = "DurationSeconds", Nilable = true, Documentation = { "The inclusive upper bound of durations for events on this track." } },
				{ Name = "minEventIntroDuration", Type = "DurationSeconds", Nilable = true, Documentation = { "Lower duration bound for events that want to transition onto this track from an Indeterminate position. Events below this duration are artificially kept in the indeterminate track state until they can transition into a later track in the timeline sequence." } },
				{ Name = "minEventGapDuration", Type = "DurationSeconds", Nilable = true, Documentation = { "Minimum duration gap that must exist between two sequential candidate events for this track. If two event durations have a distance under this figure, the later of the two events will be artifically kept in the indeterminate track state until it can transition into a later track in the timeline sequence." } },
				{ Name = "maxEventCount", Type = "number", Nilable = true, Documentation = { "The maximum number of events permitted within this track. This only applies to Sorted tracks." } },
				{ Name = "sections", Type = "table", InnerType = "EncounterTimelineSection", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(EncounterTimeline);