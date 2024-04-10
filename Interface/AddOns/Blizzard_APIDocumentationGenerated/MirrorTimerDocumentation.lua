local MirrorTimer =
{
	Name = "MirrorTimer",
	Type = "System",

	Functions =
	{
		{
			Name = "GetMirrorTimerInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "timerIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "startValue", Type = "number", Nilable = false },
				{ Name = "maxValue", Type = "number", Nilable = false },
				{ Name = "scale", Type = "number", Nilable = false },
				{ Name = "paused", Type = "number", Nilable = false },
				{ Name = "label", Type = "cstring", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMirrorTimerProgress",
			Type = "Function",

			Arguments =
			{
				{ Name = "timerName", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "progress", Type = "number", Nilable = true },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "MirrorTimerInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "startValue", Type = "number", Nilable = false },
				{ Name = "maxValue", Type = "number", Nilable = false },
				{ Name = "scale", Type = "number", Nilable = false },
				{ Name = "paused", Type = "number", Nilable = false },
				{ Name = "label", Type = "cstring", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(MirrorTimer);