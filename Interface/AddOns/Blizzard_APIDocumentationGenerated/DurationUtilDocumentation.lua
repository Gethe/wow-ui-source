local DurationUtil =
{
	Name = "DurationUtil",
	Type = "System",
	Namespace = "C_DurationUtil",
	Environment = "All",

	Functions =
	{
		{
			Name = "CreateDuration",
			Type = "Function",
			Documentation = { "Creates a zero duration container that can represent a time span." },

			Returns =
			{
				{ Name = "duration", Type = "LuaDurationObject", Nilable = false },
			},
		},
		{
			Name = "GetCurrentTime",
			Type = "Function",
			Documentation = { "Returns the current time used by duration objects. Equivalent to GetTime() in public builds." },

			Returns =
			{
				{ Name = "currentTime", Type = "FrameTime", Nilable = false },
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

APIDocumentation:AddDocumentationTable(DurationUtil);