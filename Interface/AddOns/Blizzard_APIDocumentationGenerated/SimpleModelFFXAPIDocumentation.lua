local SimpleModelFFXAPI =
{
	Name = "SimpleModelFFXAPI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "AddCharacterLight",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = true },
				{ Name = "light", Type = "ModelLight", Nilable = false },
			},
		},
		{
			Name = "AddLight",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = true },
				{ Name = "light", Type = "ModelLight", Nilable = false },
			},
		},
		{
			Name = "AddPetLight",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = true },
				{ Name = "light", Type = "ModelLight", Nilable = false },
			},
		},
		{
			Name = "ResetLights",
			Type = "Function",

			Arguments =
			{
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

APIDocumentation:AddDocumentationTable(SimpleModelFFXAPI);