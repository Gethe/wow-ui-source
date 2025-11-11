local CombatAudioAlert =
{
	Name = "CombatAudioAlert",
	Type = "System",
	Namespace = "C_CombatAudioAlert",

	Functions =
	{
		{
			Name = "GetCurrentUnitHealthFormat",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "CombatAudioAlertUnit", Nilable = false },
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
				{ Name = "unit", Type = "CombatAudioAlertUnit", Nilable = false },
			},

			Returns =
			{
				{ Name = "throttle", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCurrentUnitHealthFormat",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "CombatAudioAlertUnit", Nilable = false },
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
				{ Name = "unit", Type = "CombatAudioAlertUnit", Nilable = false },
				{ Name = "newVal", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
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