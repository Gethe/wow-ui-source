local EncounterEvents =
{
	Name = "EncounterEvents",
	Type = "System",
	Namespace = "C_EncounterEvents",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetEventColor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns any custom color override applied for an encounter event." },

			Arguments =
			{
				{ Name = "encounterEventID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "color", Type = "colorRGB", Mixin = "ColorMixin", Nilable = true },
			},
		},
		{
			Name = "GetEventInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns information about an encounter event." },

			Arguments =
			{
				{ Name = "encounterEventID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "encounterEventInfo", Type = "EncounterEventInfo", Nilable = false },
			},
		},
		{
			Name = "GetEventList",
			Type = "Function",
			Documentation = { "Returns a list of all encounter event IDs." },

			Returns =
			{
				{ Name = "encounterEventIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetEventSound",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns information on a custom sound file to be played when an encounter event trigger occurs." },

			Arguments =
			{
				{ Name = "encounterEventID", Type = "number", Nilable = false },
				{ Name = "trigger", Type = "EncounterEventSoundTrigger", Nilable = false },
			},

			Returns =
			{
				{ Name = "sound", Type = "EncounterEventSoundInfo", Nilable = false },
			},
		},
		{
			Name = "HasEventInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if an encounter event record with a specified ID exists." },

			Arguments =
			{
				{ Name = "encounterEventID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "exists", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PlayEventSound",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Plays any registered custom sound file for a given encounter event trigger." },

			Arguments =
			{
				{ Name = "encounterEventID", Type = "number", Nilable = false },
				{ Name = "trigger", Type = "EncounterEventSoundTrigger", Nilable = false },
			},

			Returns =
			{
				{ Name = "handle", Type = "SoundHandle", Nilable = false },
			},
		},
		{
			Name = "SetEventColor",
			Type = "Function",
			SecretArguments = "NotAllowed",
			Documentation = { "Sets a custom color override for an encounter event. This can be used to colorize text or timer bars individually." },

			Arguments =
			{
				{ Name = "encounterEventID", Type = "number", Nilable = false },
				{ Name = "color", Type = "colorRGB", Mixin = "ColorMixin", Nilable = true },
			},
		},
		{
			Name = "SetEventSound",
			Type = "Function",
			SecretArguments = "NotAllowed",
			Documentation = { "Sets a custom sound file to be played when an encounter event trigger occurs." },

			Arguments =
			{
				{ Name = "encounterEventID", Type = "number", Nilable = false },
				{ Name = "trigger", Type = "EncounterEventSoundTrigger", Nilable = false },
				{ Name = "sound", Type = "EncounterEventSoundInfo", Nilable = true },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(EncounterEvents);