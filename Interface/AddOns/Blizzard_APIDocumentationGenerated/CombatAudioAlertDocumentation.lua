local CombatAudioAlert =
{
	Name = "CombatAudioAlert",
	Type = "System",
	Namespace = "C_CombatAudioAlert",
	Environment = "All",

	Functions =
	{
		{
			Name = "AddToKnownTargetingList",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "added", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetCategoryVoice",
			Type = "Function",

			Arguments =
			{
				{ Name = "category", Type = "CombatAudioAlertCategory", Nilable = false },
			},

			Returns =
			{
				{ Name = "voice", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCategoryVolume",
			Type = "Function",

			Arguments =
			{
				{ Name = "category", Type = "CombatAudioAlertCategory", Nilable = false },
			},

			Returns =
			{
				{ Name = "volume", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFormatSetting",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "CombatAudioAlertUnit", Nilable = false },
				{ Name = "alertType", Type = "CombatAudioAlertType", Nilable = false },
			},

			Returns =
			{
				{ Name = "formatVal", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpeakerSpeed",
			Type = "Function",

			Returns =
			{
				{ Name = "speed", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpecSetting",
			Type = "Function",

			Arguments =
			{
				{ Name = "setting", Type = "CombatAudioAlertSpecSetting", Nilable = false },
			},

			Returns =
			{
				{ Name = "value", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetThrottle",
			Type = "Function",

			Arguments =
			{
				{ Name = "throttleType", Type = "CombatAudioAlertThrottle", Nilable = false },
			},

			Returns =
			{
				{ Name = "throttle", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RemoveFromKnownTargetingList",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "removed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCategoryVoice",
			Type = "Function",

			Arguments =
			{
				{ Name = "category", Type = "CombatAudioAlertCategory", Nilable = false },
				{ Name = "newVal", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCategoryVolume",
			Type = "Function",

			Arguments =
			{
				{ Name = "category", Type = "CombatAudioAlertCategory", Nilable = false },
				{ Name = "newVal", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetFormatSetting",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "CombatAudioAlertUnit", Nilable = false },
				{ Name = "alertType", Type = "CombatAudioAlertType", Nilable = false },
				{ Name = "newVal", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetSpeakerSpeed",
			Type = "Function",

			Arguments =
			{
				{ Name = "newVal", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetSpecSetting",
			Type = "Function",

			Arguments =
			{
				{ Name = "setting", Type = "CombatAudioAlertSpecSetting", Nilable = false },
				{ Name = "newVal", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetThrottle",
			Type = "Function",

			Arguments =
			{
				{ Name = "throttleType", Type = "CombatAudioAlertThrottle", Nilable = false },
				{ Name = "newVal", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SpeakText",
			Type = "Function",

			Arguments =
			{
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "category", Type = "CombatAudioAlertCategory", Nilable = false },
				{ Name = "allowOverlap", Type = "bool", Nilable = false, Default = true },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(CombatAudioAlert);