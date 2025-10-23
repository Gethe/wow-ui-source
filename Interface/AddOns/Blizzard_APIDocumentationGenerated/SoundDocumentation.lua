local Sound =
{
	Name = "Sound",
	Type = "System",
	Namespace = "C_Sound",

	Functions =
	{
		{
			Name = "GetSoundScaledVolume",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "soundHandle", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "scaledVolume", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsPlaying",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "soundHandle", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isPlaying", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PlayItemSound",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "soundType", Type = "ItemSoundType", Nilable = false },
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},
		},
		{
			Name = "PlaySound",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "soundKitID", Type = "number", Nilable = false },
				{ Name = "uiSoundSubType", Type = "UISoundSubType", Nilable = false, Default = "g_defaultSI3UISoundSubTypeForLua" },
				{ Name = "forceNoDuplicates", Type = "bool", Nilable = false, Default = false },
				{ Name = "runFinishCallback", Type = "bool", Nilable = false, Default = false },
				{ Name = "overridePriority", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
				{ Name = "soundHandle", Type = "SoundHandle", Nilable = false },
			},
		},
		{
			Name = "PlayVocalErrorSound",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "vocalErrorSoundID", Type = "Vocalerrorsounds", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "SoundDeviceUpdate",
			Type = "Event",
			LiteralName = "SOUND_DEVICE_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "SoundkitFinished",
			Type = "Event",
			LiteralName = "SOUNDKIT_FINISHED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "soundHandle", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "PlaySoundParams",
			Type = "Structure",
			Fields =
			{
				{ Name = "soundKitID", Type = "number", Nilable = false },
				{ Name = "uiSoundSubType", Type = "UISoundSubType", Nilable = false, Default = "g_defaultSI3UISoundSubTypeForLua" },
				{ Name = "forceNoDuplicates", Type = "bool", Nilable = false, Default = false },
				{ Name = "runFinishCallback", Type = "bool", Nilable = false, Default = false },
				{ Name = "overridePriority", Type = "number", Nilable = true },
			},
		},
		{
			Name = "PlaySoundResult",
			Type = "Structure",
			Fields =
			{
				{ Name = "success", Type = "bool", Nilable = false },
				{ Name = "soundHandle", Type = "SoundHandle", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Sound);