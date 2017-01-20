local Transmogrify =
{
	Name = "Transmogrify",
	Namespace = "C_TransmogSets",

	Functions =
	{
		{
			Name = "GetBaseSetsFilter",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isChecked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetBaseSetsFilter",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
				{ Name = "isChecked", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Transmogrify);