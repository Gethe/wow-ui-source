local CombatAudioAlert =
{
	Name = "CombatAudioAlert",
	Type = "System",
	Namespace = "C_CombatAudioAlert",
	Environment = "All",

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
			Name = "GetSpecSetting",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
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

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
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

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetSpecSetting",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "allowOverlap", Type = "bool", Nilable = false, Default = true },
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
			Name = "CombatAudioAlertPartyPercentValues",
			Type = "Enumeration",
			NumValues = 11,
			MinValue = 0,
			MaxValue = 10,
			Fields =
			{
				{ Name = "Off", Type = "CombatAudioAlertPartyPercentValues", EnumValue = 0 },
				{ Name = "Under100Percent", Type = "CombatAudioAlertPartyPercentValues", EnumValue = 1 },
				{ Name = "Under90Percent", Type = "CombatAudioAlertPartyPercentValues", EnumValue = 2 },
				{ Name = "Under80Percent", Type = "CombatAudioAlertPartyPercentValues", EnumValue = 3 },
				{ Name = "Under70Percent", Type = "CombatAudioAlertPartyPercentValues", EnumValue = 4 },
				{ Name = "Under60Percent", Type = "CombatAudioAlertPartyPercentValues", EnumValue = 5 },
				{ Name = "Under50Percent", Type = "CombatAudioAlertPartyPercentValues", EnumValue = 6 },
				{ Name = "Under40Percent", Type = "CombatAudioAlertPartyPercentValues", EnumValue = 7 },
				{ Name = "Under30Percent", Type = "CombatAudioAlertPartyPercentValues", EnumValue = 8 },
				{ Name = "Under20Percent", Type = "CombatAudioAlertPartyPercentValues", EnumValue = 9 },
				{ Name = "Under10Percent", Type = "CombatAudioAlertPartyPercentValues", EnumValue = 10 },
			},
		},
		{
			Name = "CombatAudioAlertPercentValues",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Off", Type = "CombatAudioAlertPercentValues", EnumValue = 0 },
				{ Name = "Every10Percent", Type = "CombatAudioAlertPercentValues", EnumValue = 1 },
				{ Name = "Every20Percent", Type = "CombatAudioAlertPercentValues", EnumValue = 2 },
				{ Name = "Every30Percent", Type = "CombatAudioAlertPercentValues", EnumValue = 3 },
				{ Name = "Every40Percent", Type = "CombatAudioAlertPercentValues", EnumValue = 4 },
				{ Name = "Every50Percent", Type = "CombatAudioAlertPercentValues", EnumValue = 5 },
			},
		},
		{
			Name = "CombatAudioAlertPlayerCastFormatValues",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "CastingSpellname", Type = "CombatAudioAlertPlayerCastFormatValues", EnumValue = 0 },
				{ Name = "CastSpellname", Type = "CombatAudioAlertPlayerCastFormatValues", EnumValue = 1 },
				{ Name = "Casting", Type = "CombatAudioAlertPlayerCastFormatValues", EnumValue = 2 },
				{ Name = "Cast", Type = "CombatAudioAlertPlayerCastFormatValues", EnumValue = 3 },
				{ Name = "Spellname", Type = "CombatAudioAlertPlayerCastFormatValues", EnumValue = 4 },
			},
		},
		{
			Name = "CombatAudioAlertPlayerHealthFormatValues",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "HealthFull", Type = "CombatAudioAlertPlayerHealthFormatValues", EnumValue = 0 },
				{ Name = "HealthNoPercent", Type = "CombatAudioAlertPlayerHealthFormatValues", EnumValue = 1 },
				{ Name = "HealthNoPercentDiv10", Type = "CombatAudioAlertPlayerHealthFormatValues", EnumValue = 2 },
				{ Name = "NoHealthFull", Type = "CombatAudioAlertPlayerHealthFormatValues", EnumValue = 3 },
				{ Name = "NoHealthNoPercent", Type = "CombatAudioAlertPlayerHealthFormatValues", EnumValue = 4 },
				{ Name = "NoHealthNoPercentDiv10", Type = "CombatAudioAlertPlayerHealthFormatValues", EnumValue = 5 },
			},
		},
		{
			Name = "CombatAudioAlertPlayerResourceFormatValues",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "ResourceFull", Type = "CombatAudioAlertPlayerResourceFormatValues", EnumValue = 0 },
				{ Name = "ResourceNoPercent", Type = "CombatAudioAlertPlayerResourceFormatValues", EnumValue = 1 },
				{ Name = "ResourceNoPercentDiv10", Type = "CombatAudioAlertPlayerResourceFormatValues", EnumValue = 2 },
				{ Name = "NoResourceFull", Type = "CombatAudioAlertPlayerResourceFormatValues", EnumValue = 3 },
				{ Name = "NoResourceNoPercent", Type = "CombatAudioAlertPlayerResourceFormatValues", EnumValue = 4 },
				{ Name = "NoResourceNoPercentDiv10", Type = "CombatAudioAlertPlayerResourceFormatValues", EnumValue = 5 },
			},
		},
		{
			Name = "CombatAudioAlertSayIfTargetedType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "CombatAudioAlertSayIfTargetedType", EnumValue = 0 },
				{ Name = "Aggro", Type = "CombatAudioAlertSayIfTargetedType", EnumValue = 1 },
				{ Name = "Targeted", Type = "CombatAudioAlertSayIfTargetedType", EnumValue = 2 },
				{ Name = "TargetedBy", Type = "CombatAudioAlertSayIfTargetedType", EnumValue = 3 },
			},
		},
		{
			Name = "CombatAudioAlertSpecSetting",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Resource1Percent", Type = "CombatAudioAlertSpecSetting", EnumValue = 0 },
				{ Name = "Resource1Format", Type = "CombatAudioAlertSpecSetting", EnumValue = 1 },
				{ Name = "Resource2Percent", Type = "CombatAudioAlertSpecSetting", EnumValue = 2 },
				{ Name = "Resource2Format", Type = "CombatAudioAlertSpecSetting", EnumValue = 3 },
				{ Name = "SayIfTargeted", Type = "CombatAudioAlertSpecSetting", EnumValue = 4 },
			},
		},
		{
			Name = "CombatAudioAlertTargetCastFormatValues",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "TargetCastingSpellname", Type = "CombatAudioAlertTargetCastFormatValues", EnumValue = 0 },
				{ Name = "TargetCastSpellname", Type = "CombatAudioAlertTargetCastFormatValues", EnumValue = 1 },
				{ Name = "CastingSpellname", Type = "CombatAudioAlertTargetCastFormatValues", EnumValue = 2 },
				{ Name = "CastSpellname", Type = "CombatAudioAlertTargetCastFormatValues", EnumValue = 3 },
				{ Name = "Casting", Type = "CombatAudioAlertTargetCastFormatValues", EnumValue = 4 },
				{ Name = "Cast", Type = "CombatAudioAlertTargetCastFormatValues", EnumValue = 5 },
				{ Name = "Spellname", Type = "CombatAudioAlertTargetCastFormatValues", EnumValue = 6 },
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
			Name = "CombatAudioAlertTargetHealthFormatValues",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 0,
			MaxValue = 8,
			Fields =
			{
				{ Name = "NoHealthFull", Type = "CombatAudioAlertTargetHealthFormatValues", EnumValue = 0 },
				{ Name = "NoHealthNoPercent", Type = "CombatAudioAlertTargetHealthFormatValues", EnumValue = 1 },
				{ Name = "NoHealthNoPercentDiv10", Type = "CombatAudioAlertTargetHealthFormatValues", EnumValue = 2 },
				{ Name = "HealthFull", Type = "CombatAudioAlertTargetHealthFormatValues", EnumValue = 3 },
				{ Name = "HealthNoPercent", Type = "CombatAudioAlertTargetHealthFormatValues", EnumValue = 4 },
				{ Name = "HealthNoPercentDiv10", Type = "CombatAudioAlertTargetHealthFormatValues", EnumValue = 5 },
				{ Name = "TargetFull", Type = "CombatAudioAlertTargetHealthFormatValues", EnumValue = 6 },
				{ Name = "TargetNoPercent", Type = "CombatAudioAlertTargetHealthFormatValues", EnumValue = 7 },
				{ Name = "TargetNoPercentDiv10", Type = "CombatAudioAlertTargetHealthFormatValues", EnumValue = 8 },
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