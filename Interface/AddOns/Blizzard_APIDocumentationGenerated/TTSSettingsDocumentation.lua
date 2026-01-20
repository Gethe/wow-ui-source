local TTSSettings =
{
	Name = "TTSSettings",
	Type = "System",
	Namespace = "C_TTSSettings",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetChannelEnabled",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "channelInfo", Type = "ChatChannelInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetCharacterSettingsSaved",
			Type = "Function",

			Returns =
			{
				{ Name = "settingsBeenSaved", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetChatTypeEnabled",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "chatName", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetSetting",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "setting", Type = "TtsBoolSetting", Nilable = false },
			},

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetSpeechRate",
			Type = "Function",

			Returns =
			{
				{ Name = "rate", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpeechVolume",
			Type = "Function",

			Returns =
			{
				{ Name = "volume", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetVoiceOptionID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "voiceType", Type = "TtsVoiceType", Nilable = false },
			},

			Returns =
			{
				{ Name = "voiceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetVoiceOptionName",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "voiceType", Type = "TtsVoiceType", Nilable = false },
			},

			Returns =
			{
				{ Name = "voiceName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "MarkCharacterSettingsSaved",
			Type = "Function",
		},
		{
			Name = "SetChannelEnabled",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "channelInfo", Type = "ChatChannelInfo", Nilable = false },
				{ Name = "newVal", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetChannelKeyEnabled",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "channelKey", Type = "string", Nilable = false },
				{ Name = "newVal", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetChatTypeEnabled",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "chatName", Type = "cstring", Nilable = false },
				{ Name = "newVal", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetDefaultSettings",
			Type = "Function",
		},
		{
			Name = "SetSetting",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "setting", Type = "TtsBoolSetting", Nilable = false },
				{ Name = "newVal", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetSpeechRate",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "newVal", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetSpeechVolume",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "newVal", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetVoiceOption",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "voiceType", Type = "TtsVoiceType", Nilable = false },
				{ Name = "voiceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetVoiceOptionName",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "voiceType", Type = "TtsVoiceType", Nilable = false },
				{ Name = "voiceName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ShouldOverrideMessage",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "language", Type = "number", Nilable = false },
				{ Name = "messageText", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "overrideMessage", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(TTSSettings);