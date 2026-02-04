local SimpleObjectAPI =
{
	Name = "SimpleObjectAPI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "ClearParentKey",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "GetDebugName",
			Type = "Function",
			ConstSecretAccessor = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "preferParentKey", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "debugName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetParent",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.Hierarchy },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "parent", Type = "CScriptObject", Nilable = false },
			},
		},
		{
			Name = "GetParentKey",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "parentKey", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SetParentKey",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "parentKey", Type = "cstring", Nilable = false },
				{ Name = "clearOtherKeys", Type = "bool", Nilable = false, Default = false },
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

APIDocumentation:AddDocumentationTable(SimpleObjectAPI);