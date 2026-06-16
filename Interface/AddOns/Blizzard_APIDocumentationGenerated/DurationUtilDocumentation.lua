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
			Name = "CreateDurationTextBinding",
			Type = "Function",
			Documentation = { "Creates a duration text binding, which automatically updates a font string with formatted text derived from a duration object." },

			Returns =
			{
				{ Name = "binding", Type = "DurationTextBinding", Nilable = false },
			},
		},
		{
			Name = "CreateManualClock",
			Type = "Function",
			Documentation = { "Creates a manually driven time source for use with duration objects." },

			Returns =
			{
				{ Name = "clock", Type = "LuaDurationManualClock", Nilable = false },
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

APIDocumentation:AddDocumentationTable(DurationUtil);