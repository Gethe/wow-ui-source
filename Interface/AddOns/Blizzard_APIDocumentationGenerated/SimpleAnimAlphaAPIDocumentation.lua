local SimpleAnimAlphaAPI =
{
	Name = "SimpleAnimAlphaAPI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetFromAlpha",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "normalizedAlpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetToAlpha",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "normalizedAlpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFromAlpha",
			Type = "Function",
			SecretArguments = "NotAllowed",

			Arguments =
			{
				{ Name = "normalizedAlpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetToAlpha",
			Type = "Function",
			SecretArguments = "NotAllowed",

			Arguments =
			{
				{ Name = "normalizedAlpha", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleAnimAlphaAPI);