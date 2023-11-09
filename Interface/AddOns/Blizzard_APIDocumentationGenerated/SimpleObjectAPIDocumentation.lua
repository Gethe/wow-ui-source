local SimpleObjectAPI =
{
	Name = "SimpleObjectAPI",
	Type = "ScriptObject",

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