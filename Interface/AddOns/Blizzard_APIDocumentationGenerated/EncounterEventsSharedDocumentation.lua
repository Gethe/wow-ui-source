local EncounterEventsShared =
{
	Tables =
	{
		{
			Name = "EncounterEventSoundTrigger",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "OnTextWarningShown", Type = "EncounterEventSoundTrigger", EnumValue = 0, Documentation = { "Trigger to be activated when an text warning is initially shown for an encounter event." } },
				{ Name = "OnTimelineEventFinished", Type = "EncounterEventSoundTrigger", EnumValue = 1, Documentation = { "Trigger to be activated when an encounter event on the timeline transitions to a finished (ie. casted, or resolved) state." } },
				{ Name = "OnTimelineEventHighlight", Type = "EncounterEventSoundTrigger", EnumValue = 2, Documentation = { "Trigger to be activated when an encounter event reaches its 'highlight' duration on the timeline (typically, ~5s before the cast is due)." } },
			},
		},
		{
			Name = "EncounterEventInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "encounterEventID", Type = "number", Nilable = false, Documentation = { "ID of the encounter event record." } },
				{ Name = "enabled", Type = "bool", Nilable = false, Documentation = { "If true, this event should be displayed on boss ability HUD elements." } },
				{ Name = "spellID", Type = "number", Nilable = false, Documentation = { "Spell ID that triggers this event. A single spell may be used by multiple encounter events." } },
				{ Name = "iconFileID", Type = "number", Nilable = false, Documentation = { "Icon file ID for the event. Typically the same as the spell icon, but may be overridden." } },
				{ Name = "severity", Type = "EncounterEventSeverity", Nilable = false, Documentation = { "Severity level of this event." } },
				{ Name = "icons", Type = "EncounterEventIconmask", Nilable = false, Documentation = { "Bitmask of spell support icons to show for this event." } },
				{ Name = "color", Type = "colorRGB", Mixin = "ColorMixin", Nilable = true, Documentation = { "Color associated with this event. At present, only set if an override has been applied via the SetEventColor function." } },
			},
		},
		{
			Name = "EncounterEventSoundInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "file", Type = "fileID", Nilable = false, Documentation = { "Sound file to be played when triggered." } },
				{ Name = "channel", Type = "UISoundSubType", Nilable = false, Default = "g_defaultSI3UISoundSubTypeForLua", Documentation = { "Sound channel to play this file on." } },
				{ Name = "volume", Type = "number", Nilable = false, Default = 1, Documentation = { "Volume scalar for the sound file." } },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(EncounterEventsShared);