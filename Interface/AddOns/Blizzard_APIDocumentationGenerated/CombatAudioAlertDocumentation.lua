local CombatAudioAlert =
{
	Name = "CombatAudioAlert",
	Type = "System",
	Namespace = "C_CombatAudioAlert",

	Functions =
	{
		{
			Name = "GetFormatSetting",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetResourceSettingForCurrentSpec",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "setting", Type = "CombatAudioAlertResourceSetting", Nilable = false },
			},

			Returns =
			{
				{ Name = "value", Type = "number", Nilable = false },
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
			Name = "GetSpeakerVolume",
			Type = "Function",

			Returns =
			{
				{ Name = "volume", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetThrottle",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "SetFormatSetting",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "CombatAudioAlertUnit", Nilable = false },
				{ Name = "alertType", Type = "CombatAudioAlertType", Nilable = false },
				{ Name = "newVal", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetResourceSettingForCurrentSpec",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "setting", Type = "CombatAudioAlertResourceSetting", Nilable = false },
				{ Name = "newVal", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetSpeakerSpeed",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "newVal", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetSpeakerVolume",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "newVal", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetThrottle",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "throttleType", Type = "CombatAudioAlertThrottle", Nilable = false },
				{ Name = "newVal", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SpeakText",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "text", Type = "string", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "CombatAudioAlertCastState",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Off", Type = "CombatAudioAlertCastState", EnumValue = 0 },
				{ Name = "OnCastStart", Type = "CombatAudioAlertCastState", EnumValue = 1 },
				{ Name = "OnCastEnd", Type = "CombatAudioAlertCastState", EnumValue = 2 },
			},
		},
		{
			Name = "CombatAudioAlertResourceSetting",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Resource1Percent", Type = "CombatAudioAlertResourceSetting", EnumValue = 0 },
				{ Name = "Resource1Format", Type = "CombatAudioAlertResourceSetting", EnumValue = 1 },
				{ Name = "Resource2Percent", Type = "CombatAudioAlertResourceSetting", EnumValue = 2 },
				{ Name = "Resource2Format", Type = "CombatAudioAlertResourceSetting", EnumValue = 3 },
			},
		},
		{
			Name = "CombatAudioAlertTargetDeathBehavior",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Default", Type = "CombatAudioAlertTargetDeathBehavior", EnumValue = 0 },
				{ Name = "SayTargetDead", Type = "CombatAudioAlertTargetDeathBehavior", EnumValue = 1 },
			},
		},
		{
			Name = "CombatAudioAlertThrottle",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "Sample", Type = "CombatAudioAlertThrottle", EnumValue = 0 },
				{ Name = "PlayerHealth", Type = "CombatAudioAlertThrottle", EnumValue = 1 },
				{ Name = "TargetHealth", Type = "CombatAudioAlertThrottle", EnumValue = 2 },
				{ Name = "PlayerCast", Type = "CombatAudioAlertThrottle", EnumValue = 3 },
				{ Name = "TargetCast", Type = "CombatAudioAlertThrottle", EnumValue = 4 },
				{ Name = "PlayerResource1", Type = "CombatAudioAlertThrottle", EnumValue = 5 },
				{ Name = "PlayerResource2", Type = "CombatAudioAlertThrottle", EnumValue = 6 },
			},
		},
		{
			Name = "CombatAudioAlertType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Health", Type = "CombatAudioAlertType", EnumValue = 0 },
				{ Name = "Cast", Type = "CombatAudioAlertType", EnumValue = 1 },
			},
		},
		{
			Name = "CombatAudioAlertUnit",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Player", Type = "CombatAudioAlertUnit", EnumValue = 0 },
				{ Name = "Target", Type = "CombatAudioAlertUnit", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CombatAudioAlert);