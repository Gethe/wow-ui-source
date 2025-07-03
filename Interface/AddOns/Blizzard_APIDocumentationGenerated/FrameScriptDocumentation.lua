local FrameScript =
{
	Name = "FrameScript",
	Type = "System",

	Functions =
	{
		{
			Name = "CreateFromMixins",
			Type = "Function",

			Arguments =
			{
				{ Name = "unpackedPrimitiveType", Type = "number", Nilable = false, StrideIndex = 1 },
			},

			Returns =
			{
				{ Name = "object", Type = "LuaValueVariant", Nilable = false },
			},
		},
		{
			Name = "CreateWindow",
			Type = "Function",

			Arguments =
			{
				{ Name = "popupStyle", Type = "bool", Nilable = false, Default = true },
				{ Name = "topMost", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "window", Type = "SimpleWindow", Nilable = true },
			},
		},
		{
			Name = "GetCallstackHeight",
			Type = "Function",

			Returns =
			{
				{ Name = "height", Type = "number", Nilable = false },
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
			Name = "GetErrorCallstackHeight",
			Type = "Function",

			Returns =
			{
				{ Name = "height", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetEventTime",
			Type = "Function",
			MayReturnNothing = true,

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
			Name = "GetSourceLocation",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "location", Type = "string", Nilable = false },
			},
		},
		{
			Name = "Mixin",
			Type = "Function",

			Arguments =
			{
				{ Name = "object", Type = "LuaValueVariant", Nilable = false },
				{ Name = "unpackedPrimitiveType", Type = "number", Nilable = false, StrideIndex = 1 },
			},

			Returns =
			{
				{ Name = "outObject", Type = "LuaValueVariant", Nilable = false },
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
		{
			Name = "SetErrorCallstackHeight",
			Type = "Function",

			Arguments =
			{
				{ Name = "height", Type = "number", Nilable = true },
			},
		},
		{
			Name = "debugprofilestart",
			Type = "Function",
			Documentation = { "Starts a timer for profiling. The final time can be obtained by calling debugprofilestop." },
		},
		{
			Name = "debugprofilestop",
			Type = "Function",
			Documentation = { "Returns the time in milliseconds since the last debugprofilestart call." },

			Returns =
			{
				{ Name = "elapsedMilliseconds", Type = "number", Nilable = false },
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