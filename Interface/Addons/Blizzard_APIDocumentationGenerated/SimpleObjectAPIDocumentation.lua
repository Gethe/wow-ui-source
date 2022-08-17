local SimpleObjectAPI =
{
	Name = "SimpleObjectAPI",
	Type = "ScriptObject",

	Functions =
	{
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
				{ Name = "parent", Type = "table", Nilable = false },
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