local SimpleControlPointAPI =
{
	Name = "SimpleControlPointAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "GetOffset",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "offsetX", Type = "uiUnit", Nilable = false },
				{ Name = "offsetY", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "GetOrder",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "order", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetOffset",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "offsetX", Type = "uiUnit", Nilable = false },
				{ Name = "offsetY", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetOrder",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "order", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetParent",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "parent", Type = "SimplePathAnim", Nilable = false },
				{ Name = "order", Type = "number", Nilable = true },
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

APIDocumentation:AddDocumentationTable(SimpleControlPointAPI);