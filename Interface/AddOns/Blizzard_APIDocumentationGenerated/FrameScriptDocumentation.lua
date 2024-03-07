local FrameScript =
{
	Name = "FrameScript",
	Type = "System",

	Functions =
	{
		{
			Name = "CreateWindow",
			Type = "Function",

			Arguments =
			{
				{ Name = "popupStyle", Type = "bool", Nilable = false, Default = true },
			},

			Returns =
			{
				{ Name = "window", Type = "SimpleWindow", Nilable = true },
			},
		},
		{
			Name = "GetCurrentEventID",
			Type = "Function",

			Returns =
			{
				{ Name = "eventID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetEventTime",
			Type = "Function",

			Arguments =
			{
				{ Name = "eventProfileIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "totalElapsedTime", Type = "number", Nilable = false },
				{ Name = "numExecutedHandlers", Type = "number", Nilable = false },
				{ Name = "slowestHandlerName", Type = "cstring", Nilable = false },
				{ Name = "slowestHandlerTime", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RunScript",
			Type = "Function",

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
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

APIDocumentation:AddDocumentationTable(FrameScript);