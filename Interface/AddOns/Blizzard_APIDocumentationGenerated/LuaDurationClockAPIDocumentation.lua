local LuaDurationClockAPI =
{
	Name = "LuaDurationClockObjectAPI",
	Type = "ScriptObject",
	ObjectType = "Userdata",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetTime",
			Type = "Function",
			Documentation = { "Returns the current time value represented by this clock." },

			Arguments =
			{
			},

			Returns =
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

APIDocumentation:AddDocumentationTable(LuaDurationClockAPI);