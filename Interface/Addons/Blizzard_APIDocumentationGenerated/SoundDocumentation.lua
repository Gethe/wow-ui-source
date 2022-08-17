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

			Arguments =
			{
				{ Name = "soundHandle", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isPlaying", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "SoundDeviceUpdate",
			Type = "Event",
			LiteralName = "SOUND_DEVICE_UPDATE",
		},
		{
			Name = "SoundkitFinished",
			Type = "Event",
			LiteralName = "SOUNDKIT_FINISHED",
			Payload =
			{
				{ Name = "soundHandle", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Sound);