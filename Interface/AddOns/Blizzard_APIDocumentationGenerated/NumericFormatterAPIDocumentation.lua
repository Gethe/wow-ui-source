local NumericFormatterAPI =
{
	Name = "NumericFormatterAPI",
	Type = "ScriptObject",
	ObjectType = "Userdata",
	Environment = "All",

	Functions =
	{
		{
			Name = "FormatNumber",
			Type = "Function",
			ConstSecretAccessor = true,
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