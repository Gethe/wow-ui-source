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
			SecretReturnsForAspect = { Enum.SecretAspect.Alpha },

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
			SecretReturnsForAspect = { Enum.SecretAspect.Alpha },

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
			SecretArgumentsAddAspect = { Enum.SecretAspect.Alpha },
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "normalizedAlpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetToAlpha",
			Type = "Function",
			SecretArgumentsAddAspect = { Enum.SecretAspect.Alpha },
			SecretArguments = "AllowedWhenUntainted",

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
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(SimpleAnimAlphaAPI);