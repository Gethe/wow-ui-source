local SimpleModelFFXAPI =
{
	Name = "SimpleModelFFXAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "AddCharacterLight",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = true },
				{ Name = "light", Type = "ModelLight", Nilable = false },
			},
		},
		{
			Name = "AddLight",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = true },
				{ Name = "light", Type = "ModelLight", Nilable = false },
			},
		},
		{
			Name = "AddPetLight",
			Type = "Function",

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