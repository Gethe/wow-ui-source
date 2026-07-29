local LuaDurationManualClockAPI =
{
	Name = "LuaDurationManualClockAPI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "AdvanceTime",
			Type = "Function",
			Documentation = { "Advances the clock by a specified number of seconds." },

			Arguments =
			{
				{ Name = "delta", Type = "DurationSeconds", Nilable = false },
			},
		},
		{
			Name = "ResetTime",
			Type = "Function",
			Documentation = { "Resets the clock to a zero time value." },

			Arguments =
			{
			},
		},
		{
			Name = "RewindTime",
			Type = "Function",
			Documentation = { "Rewinds the clock by a specified number of seconds." },

			Arguments =
			{
				{ Name = "delta", Type = "DurationSeconds", Nilable = false },
			},
		},
		{
			Name = "SetTime",
			Type = "Function",
			Documentation = { "Sets the current clock timestamp to a given value." },

			Arguments =
			{
				{ Name = "time", Type = "FrameTime", Nilable = false },
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

APIDocumentation:AddDocumentationTable(LuaDurationManualClockAPI);