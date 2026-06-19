local SimpleAnimRadialProgressAPI =
{
	Name = "SimpleAnimRadialProgressAPI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetFromPercent",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "percent", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetToPercent",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "percent", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFromPercent",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "percent", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetToPercent",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "percent", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleAnimRadialProgressAPI);