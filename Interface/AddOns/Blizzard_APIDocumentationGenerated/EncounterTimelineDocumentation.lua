local EncounterTimeline =
{
	Name = "EncounterTimeline",
	Type = "System",
	Namespace = "C_EncounterTimeline",
	Environment = "All",

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
			Name = "FinishScriptEvent",
			Type = "Function",
			RequiresValidTimelineEvent = true,
			SecretArguments = "NotAllowed",
			Documentation = { "Finishes a custom timeline event, removing it from the timeline." },

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
			Name = "GetEventCountBySource",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the number of present events in the timeline by their source type." },

			Arguments =
			{
				{ Name = "source", Type = "EncounterTimelineEventSource", Nilable = false },
			},

			Returns =
			{
				{ Name = "count", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetEventInfo",
			Type = "Function",
			RequiresValidTimelineEvent = true,
			SecretBasedOnTimelineEventSource = true,
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
			Documentation = { "Returns an unsorted list of event IDs present in the timeline." },

			Returns =
			{
				{ Name = "events", Type = "table", InnerType = "EncounterTimelineEventID", Nilable = false },
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
			Name = "GetEventTrack",
			Type = "Function",
			RequiresValidTimelineEvent = true,
			SecretArguments = "NotAllowed",
			Documentation = { "Returns information about the position of an event on the timeline." },

			Arguments =
			{
				{ Name = "eventID", Type = "EncounterTimelineEventID", Nilable = false },
			},

			Returns =
			{
				{ Name = "track", Type = "EncounterTimelineTrack", Nilable = false },
				{ Name = "trackSortIndex", Type = "luaIndex", Nilable = true },
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
			Documentation = { "Returns information about all timeline tracks." },

			Returns =
			{
				{ Name = "tracks", Type = "table", InnerType = "EncounterTimelineTrackInfo", Nilable = false },
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
			Name = "HasVisibleEvents",
			Type = "Function",
			Documentation = { "Returns true if the timeline contains any events that are on visible tracks." },

			Returns =
			{
				{ Name = "hasVisibleEvents", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEventBlocked",
			Type = "Function",
			RequiresValidTimelineEvent = true,
			SecretArguments = "NotAllowed",
			Documentation = { "Returns true if the event is in a 'blocked' state, where the cast for this event may not occur due to encounter conditions not being met." },

			Arguments =
			{
				{ Name = "eventID", Type = "EncounterTimelineEventID", Nilable = false },
			},

			Returns =
			{
				{ Name = "blocked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsFeatureAvailable",
			Type = "Function",
			Documentation = { "Returns true if the encounter timeline feature is available on this client." },

			Returns =
			{
				{ Name = "isAvailable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsFeatureEnabled",
			Type = "Function",
			Documentation = { "Returns true if the encounter timeline feature has been enabled by the player. This function will always return false if the feature is not available." },

			Returns =
			{
				{ Name = "isAvailableAndEnabled", Type = "bool", Nilable = false },
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
		{
			Name = "SetEventIconTextures",
			Type = "Function",
			RequiresValidTimelineEvent = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Updates a given vector of texture objects to reference art assets for icons associated with an event." },

			Arguments =
			{
				{ Name = "eventID", Type = "EncounterTimelineEventID", Nilable = false },
				{ Name = "includeIcons", Type = "EncounterEventIconmask", Nilable = false, Documentation = { "Mask to apply to candidate icons. Any icon bits not present in this set will not be assigned to textures." } },
				{ Name = "textures", Type = "table", InnerType = "SimpleTexture", Nilable = false, Documentation = { "Array of texture objects to update. This will change the assigned atlases and alpha values of the region, applying secret aspects to protect the data." } },
			},
		},
	},

	Events =
	{
		{
			Name = "EncounterTimelineEventAdded",
			Type = "Event",
			LiteralName = "ENCOUNTER_TIMELINE_EVENT_ADDED",
			SecretBasedOnTimelineEventSource = true,
			SynchronousEvent = true,
			Documentation = { "Fired when an event has been added to the timeline." },
			Payload =
			{
				{ Name = "eventInfo", Type = "EncounterTimelineEventInfo", Nilable = false },
			},
		},
		{
			Name = "EncounterTimelineEventBlockStateChanged",
			Type = "Event",
			LiteralName = "ENCOUNTER_TIMELINE_EVENT_BLOCK_STATE_CHANGED",
			UniqueEvent = true,
			Documentation = { "Fired when an event has transitioned into or out of a 'blocked' status." },
			Payload =
			{
				{ Name = "eventID", Type = "EncounterTimelineEventID", Nilable = false },
			},
		},
		{
			Name = "EncounterTimelineEventHighlight",
			Type = "Event",
			LiteralName = "ENCOUNTER_TIMELINE_EVENT_HIGHLIGHT",
			UniqueEvent = true,
			Documentation = { "Fired when an event has met a condition that should trigger its highlight glow animation." },
			Payload =
			{
				{ Name = "eventID", Type = "EncounterTimelineEventID", Nilable = false },
			},
		},
		{
			Name = "EncounterTimelineEventRemoved",
			Type = "Event",
			LiteralName = "ENCOUNTER_TIMELINE_EVENT_REMOVED",
			UniqueEvent = true,
			Documentation = { "Fired when an event has been removed from the timeline. This is guaranteed to fire after an event has transitioned to a 'final' state such as Canceled or Finished, and will be delayed at least one game tick to allow for API queries to still access event data in OnUpdate scripts. This is fired post-removal of the event, and so queries using the supplied event ID will return nil." },
			Payload =
			{
				{ Name = "eventID", Type = "EncounterTimelineEventID", Nilable = false },
			},
		},
		{
			Name = "EncounterTimelineEventStateChanged",
			Type = "Event",
			LiteralName = "ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED",
			UniqueEvent = true,
			Documentation = { "Fired when an event has changed state." },
			Payload =
			{
				{ Name = "eventID", Type = "EncounterTimelineEventID", Nilable = false },
			},
		},
		{
			Name = "EncounterTimelineEventTrackChanged",
			Type = "Event",
			LiteralName = "ENCOUNTER_TIMELINE_EVENT_TRACK_CHANGED",
			UniqueEvent = true,
			Documentation = { "Fired when an event has changed track, or has been re-ordered within its existing track." },
			Payload =
			{
				{ Name = "eventID", Type = "EncounterTimelineEventID", Nilable = false },
			},
		},
		{
			Name = "EncounterTimelineLayoutUpdated",
			Type = "Event",
			LiteralName = "ENCOUNTER_TIMELINE_LAYOUT_UPDATED",
			SynchronousEvent = true,
			Documentation = { "Fired when the layout of tracks on the timeline has been updated. This can include changes to the minimum or maximum durations of tracks." },
		},
		{
			Name = "EncounterTimelineStateUpdated",
			Type = "Event",
			LiteralName = "ENCOUNTER_TIMELINE_STATE_UPDATED",
			UniqueEvent = true,
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
				{ Name = "id", Type = "EncounterTimelineEventID", Nilable = false, NeverSecret = true, Documentation = { "Instance ID for this event." } },
				{ Name = "source", Type = "EncounterTimelineEventSource", Nilable = false, NeverSecret = true, Documentation = { "Source that this event came from." } },
				{ Name = "spellName", Type = "stringView", Nilable = false, Documentation = { "Spell name associated with this event. For script events, this may instead be the contents of the 'overrideName' field if it wasn't empty." } },
				{ Name = "spellID", Type = "number", Nilable = false, Documentation = { "Spell ID associated with this event." } },
				{ Name = "iconFileID", Type = "fileID", Nilable = false, Documentation = { "Icon file ID associated with this event." } },
				{ Name = "duration", Type = "DurationSeconds", Nilable = false, NeverSecret = true, Documentation = { "Base duration of this event at the point that it was queued onto the timeline." } },
				{ Name = "maxQueueDuration", Type = "DurationSeconds", Nilable = false, NeverSecret = true, Documentation = { "Hold duration for this event after it reaches the end of the timeline. During this period, the event will sit in the queued track of the timeline until manually finished or this added duration expires." } },
				{ Name = "icons", Type = "EncounterEventIconmask", Nilable = false, Documentation = { "Bitmask of active icon states for this event." } },
				{ Name = "severity", Type = "EncounterEventSeverity", Nilable = false, Documentation = { "Severity of this event." } },
				{ Name = "isApproximate", Type = "bool", Nilable = false, Documentation = { "If true, this event is an approximation and may not occur exactly when the timeline suggests it will." } },
			},
		},
		{
			Name = "EncounterTimelineScriptEventRequest",
			Type = "Structure",
			Fields =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "iconFileID", Type = "fileID", Nilable = false },
				{ Name = "duration", Type = "DurationSeconds", Nilable = false },
				{ Name = "maxQueueDuration", Type = "DurationSeconds", Nilable = false, Default = 0 },
				{ Name = "overrideName", Type = "stringView", Nilable = false, Default = "" },
				{ Name = "icons", Type = "EncounterEventIconmask", Nilable = true },
				{ Name = "severity", Type = "EncounterEventSeverity", Nilable = false, Default = "Medium" },
				{ Name = "paused", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "EncounterTimelineTrackInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "EncounterTimelineTrack", Nilable = false },
				{ Name = "type", Type = "EncounterTimelineTrackType", Nilable = false },
				{ Name = "minimumDuration", Type = "DurationSeconds", Nilable = true, Documentation = { "The exclusive lower bound of durations for events on this track. If zero, this should be treated as an inclusive lower bound. This bound is ignored by the timeline sequence in circumstances where an adjacent Sorted track would exceed its maximum event count, requiring events be pushed 'to the left' by one track." } },
				{ Name = "maximumDuration", Type = "DurationSeconds", Nilable = true, Documentation = { "The inclusive upper bound of durations for events on this track." } },
				{ Name = "minimumEventIntroDuration", Type = "DurationSeconds", Nilable = true, Documentation = { "Lower duration bound for events that want to transition onto this track from an Indeterminate position. Events below this duration are artificially kept in the indeterminate track state until they can transition into a later track in the timeline sequence." } },
				{ Name = "minimumEventGapDuration", Type = "DurationSeconds", Nilable = true, Documentation = { "Minimum duration gap that must exist between two sequential candidate events for this track. If two event durations have a distance under this figure, the later of the two events will be artifically kept in the indeterminate track state until it can transition into a later track in the timeline sequence." } },
				{ Name = "maximumEventCount", Type = "number", Nilable = true, Documentation = { "The maximum number of events permitted within this track. This only applies to Sorted tracks." } },
				{ Name = "sortDirection", Type = "EncounterTimelineEventSortDirection", Nilable = true, Documentation = { "Sort ordering for events within this track. This only applies to Sorted tracks." } },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(EncounterTimeline);