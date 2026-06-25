local SimpleFrameScriptObjectAPI =
{
	Name = "SimpleFrameScriptObjectAPI",
	Type = "ScriptObject",
	Environment = "All",

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
			Name = "HasAnySecretAspect",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "hasSecretAspect", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasSecretAspect",
			Type = "Function",

			Arguments =
			{
				{ Name = "aspect", Type = "SecretAspect", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasSecretAspect", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasSecretValues",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "hasSecretValues", Type = "bool", Nilable = false },
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
			Name = "IsPreventingSecretValues",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isPreventingSecretValues", Type = "bool", Nilable = false },
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
			IsProtectedFunction = true,
			Documentation = { "Reset all script accessible values to their default values. If possible, clears secret states." },

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
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(SimpleFrameScriptObjectAPI);