local CursorUtil =
{
	Name = "CursorUtil",
	Type = "System",
	Namespace = "C_CursorUtil",
	Environment = "All",

	Functions =
	{
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "CursorFileInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "hasBaseBlp", Type = "bool", Nilable = false },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(CursorUtil);