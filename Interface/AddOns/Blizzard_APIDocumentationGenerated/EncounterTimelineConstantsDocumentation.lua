local EncounterTimelineConstants =
{
	Tables =
	{
		{
			Name = "EncounterTimelineEventSortDirection",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Descending", Type = "EncounterTimelineEventSortDirection", EnumValue = 0, Documentation = { "Events are sorted in descending order (longest time remaining to shortest)." } },
				{ Name = "Ascending", Type = "EncounterTimelineEventSortDirection", EnumValue = 1, Documentation = { "Events are sorted in ascending order (shortest time remaining to longest)." } },
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
			Name = "EncounterTimelineIconSet",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 1,
			MaxValue = 6,
			Fields =
			{
				{ Name = "TankAlert", Type = "EncounterTimelineIconSet", EnumValue = 1 },
				{ Name = "HealerAlert", Type = "EncounterTimelineIconSet", EnumValue = 2 },
				{ Name = "DamageAlert", Type = "EncounterTimelineIconSet", EnumValue = 3 },
				{ Name = "Deadly", Type = "EncounterTimelineIconSet", EnumValue = 4 },
				{ Name = "Dispel", Type = "EncounterTimelineIconSet", EnumValue = 5 },
				{ Name = "Enrage", Type = "EncounterTimelineIconSet", EnumValue = 6 },
			},
		},
		{
			Name = "EncounterTimelineTrack",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Documentation = { "Enumeration of all encounter timeline tracks., Tracks are not permitted to overlap (but may have a zero duration span), and are contiguously ordered from shortest maximum duration to longest." },
			Fields =
			{
				{ Name = "Queued", Type = "EncounterTimelineTrack", EnumValue = 0 },
				{ Name = "Short", Type = "EncounterTimelineTrack", EnumValue = 1, Documentation = { "This track always has a zero minimum duration." } },
				{ Name = "Medium", Type = "EncounterTimelineTrack", EnumValue = 2 },
				{ Name = "Long", Type = "EncounterTimelineTrack", EnumValue = 3 },
				{ Name = "Indeterminate", Type = "EncounterTimelineTrack", EnumValue = 4, Documentation = { "This track is used as a placeholder for events whose position is not calculated and shouldn't appear on the timeline." } },
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
		{
			Name = "EncounterTimelineIconMasks",
			Type = "Constants",
			Values =
			{
				{ Name = "EncounterTimelineTankAlertIcons", Type = "EncounterEventIconmask", Value = 128 },
				{ Name = "EncounterTimelineHealerAlertIcons", Type = "EncounterEventIconmask", Value = 256 },
				{ Name = "EncounterTimelineDamageAlertIcons", Type = "EncounterEventIconmask", Value = 512 },
				{ Name = "EncounterTimelineDeadlyIcons", Type = "EncounterEventIconmask", Value = 1 },
				{ Name = "EncounterTimelineDispelIcons", Type = "EncounterEventIconmask", Value = 124 },
				{ Name = "EncounterTimelineEnrageIcons", Type = "EncounterEventIconmask", Value = 2 },
				{ Name = "EncounterTimelineAllIcons", Type = "EncounterEventIconmask", Value = 1023 },
				{ Name = "EncounterTimelineRoleIcons", Type = "EncounterEventIconmask", Value = 896 },
				{ Name = "EncounterTimelineOtherIcons", Type = "EncounterEventIconmask", Value = 127 },
				{ Name = "EncounterTimelineNoIcons", Type = "EncounterEventIconmask", Value = 0 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(EncounterTimelineConstants);