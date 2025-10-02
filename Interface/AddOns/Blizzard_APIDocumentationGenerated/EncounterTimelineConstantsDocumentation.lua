local EncounterTimelineConstants =
{
	Tables =
	{
		{
			Name = "EncounterTimelineEventDispelType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "EncounterTimelineEventDispelType", EnumValue = 0 },
				{ Name = "Poison", Type = "EncounterTimelineEventDispelType", EnumValue = 1 },
				{ Name = "Magic", Type = "EncounterTimelineEventDispelType", EnumValue = 2 },
				{ Name = "Curse", Type = "EncounterTimelineEventDispelType", EnumValue = 3 },
				{ Name = "Disease", Type = "EncounterTimelineEventDispelType", EnumValue = 4 },
			},
		},
		{
			Name = "EncounterTimelineEventPriority",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Normal", Type = "EncounterTimelineEventPriority", EnumValue = 0 },
				{ Name = "Deadly", Type = "EncounterTimelineEventPriority", EnumValue = 1 },
			},
		},
		{
			Name = "EncounterTimelineEventRole",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "EncounterTimelineEventRole", EnumValue = 0 },
				{ Name = "Tank", Type = "EncounterTimelineEventRole", EnumValue = 1 },
				{ Name = "Healer", Type = "EncounterTimelineEventRole", EnumValue = 2 },
				{ Name = "Damager", Type = "EncounterTimelineEventRole", EnumValue = 3 },
			},
		},
		{
			Name = "EncounterTimelineEventSource",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Documentation = { "Enumeration of all encounter timeline event sources." },
			Fields =
			{
				{ Name = "Encounter", Type = "EncounterTimelineEventSource", EnumValue = 0, Documentation = { "Source used for events added by an instance encounter." } },
				{ Name = "Script", Type = "EncounterTimelineEventSource", EnumValue = 1, Documentation = { "Source used for events added by Lua scripting APIs. This is used to apply API restrictions; the Pause/Cancel/ResumeScriptEvent functions only work on Script events." } },
				{ Name = "EditMode", Type = "EncounterTimelineEventSource", EnumValue = 2, Documentation = { "Source used for events added by the AddEditModeEvents script API." } },
			},
		},
		{
			Name = "EncounterTimelineEventState",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Documentation = { "Enumeration of all encounter timeline event states." },
			Fields =
			{
				{ Name = "Active", Type = "EncounterTimelineEventState", EnumValue = 0 },
				{ Name = "Paused", Type = "EncounterTimelineEventState", EnumValue = 1 },
				{ Name = "Finished", Type = "EncounterTimelineEventState", EnumValue = 2 },
				{ Name = "Canceled", Type = "EncounterTimelineEventState", EnumValue = 3 },
			},
		},
		{
			Name = "EncounterTimelineSection",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Documentation = { "Enumeration of all encounter timeline track sections. Each track section has its own length and min/max event durations., Sections are not permitted to overlap (but may have a zero duration span), and are contiguously ordered from shortest maximum duration to longest." },
			Fields =
			{
				{ Name = "Finishing", Type = "EncounterTimelineSection", EnumValue = 0 },
				{ Name = "Imminent", Type = "EncounterTimelineSection", EnumValue = 1 },
				{ Name = "Short", Type = "EncounterTimelineSection", EnumValue = 2 },
				{ Name = "Medium", Type = "EncounterTimelineSection", EnumValue = 3 },
				{ Name = "Long", Type = "EncounterTimelineSection", EnumValue = 4 },
				{ Name = "Indeterminate", Type = "EncounterTimelineSection", EnumValue = 5 },
			},
		},
		{
			Name = "EncounterTimelineTrack",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Documentation = { "Enumeration of all encounter timeline tracks. Each track is a span of zero or more sections with an accumulated length and min/max duration., Tracks are not permitted to overlap (but may have a zero duration span), and are contiguously ordered from shortest maximum duration to longest." },
			Fields =
			{
				{ Name = "Short", Type = "EncounterTimelineTrack", EnumValue = 0, Documentation = { "This track always has a zero minimum duration." } },
				{ Name = "Medium", Type = "EncounterTimelineTrack", EnumValue = 1 },
				{ Name = "Long", Type = "EncounterTimelineTrack", EnumValue = 2 },
				{ Name = "Indeterminate", Type = "EncounterTimelineTrack", EnumValue = 3, Documentation = { "This track is used as a placeholder for events whose position is not calculated and shouldn't appear on the timeline." } },
			},
		},
		{
			Name = "EncounterTimelineTrackType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Documentation = { "Enumeration of all encounter timeline track types. Track types infer behavioral aspects of the track, for example whether or not we associate sort orders to events in the track." },
			Fields =
			{
				{ Name = "Hidden", Type = "EncounterTimelineTrackType", EnumValue = 0 },
				{ Name = "Sorted", Type = "EncounterTimelineTrackType", EnumValue = 1 },
				{ Name = "Linear", Type = "EncounterTimelineTrackType", EnumValue = 2 },
			},
		},
		{
			Name = "EncounterTimelineEventConstants",
			Type = "Constants",
			Values =
			{
				{ Name = "ENCOUNTER_TIMELINE_INVALID_EVENT", Type = "number", Value = 0, Documentation = { "Constant used for invalid event IDs. Script APIs are guaranteed to always return nil data if supplied this ID, and events will never be added to the timeline with this ID." } },
				{ Name = "ENCOUNTER_TIMELINE_RESERVED_EVENT_COUNT", Type = "number", Value = 40, Documentation = { "Minimum size of internal arrays that are preallocated for event storage." } },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(EncounterTimelineConstants);