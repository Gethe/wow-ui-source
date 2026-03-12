local NumericFormatterAPI =
{
	Name = "NumericFormatterAPI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "FormatNumber",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "number", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "formatted", Type = "string", Nilable = false },
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

APIDocumentation:AddDocumentationTable(NumericFormatterAPI);