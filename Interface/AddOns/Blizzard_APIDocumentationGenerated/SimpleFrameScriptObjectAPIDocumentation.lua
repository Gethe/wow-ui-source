local SimpleFrameScriptObjectAPI =
{
	Name = "SimpleFrameScriptObjectAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "GetName",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetObjectType",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "objectType", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "IsForbidden",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isForbidden", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsObjectType",
			Type = "Function",

			Arguments =
			{
				{ Name = "objectType", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "isType", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetForbidden",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "SetToDefaults",
			Type = "Function",
			Documentation = { "Reset all script accessible values to their default values." },

			Arguments =
			{
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

APIDocumentation:AddDocumentationTable(SimpleFrameScriptObjectAPI);