local SimpleCheckboxAPI =
{
	Name = "SimpleCheckboxAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "GetChecked",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "checked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetCheckedTexture",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "texture", Type = "table", Nilable = false },
			},
		},
		{
			Name = "GetDisabledCheckedTexture",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "texture", Type = "table", Nilable = false },
			},
		},
		{
			Name = "SetChecked",
			Type = "Function",

			Arguments =
			{
				{ Name = "checked", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetCheckedTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetDisabledCheckedTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "string", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleCheckboxAPI);