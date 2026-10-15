local NameUtil =
{
	Name = "NameUtil",
	Type = "System",
	Namespace = "C_NameUtil",
	Environment = "All",

	Functions =
	{
		{
			Name = "ReplaceSurnameSeparatorWithLinkSeparator",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Replaces the character surname separator with a link separator in a full name string." },

			Arguments =
			{
				{ Name = "fullName", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false },
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

APIDocumentation:AddDocumentationTable(NameUtil);