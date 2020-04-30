local Covenants =
{
	Name = "Covenant",
	Type = "System",
	Namespace = "C_Covenants",

	Functions =
	{
		{
			Name = "GetActiveCovenantID",
			Type = "Function",

			Returns =
			{
				{ Name = "covenantID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCovenantData",
			Type = "Function",

			Arguments =
			{
				{ Name = "covenantID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "CovenantData", Nilable = false },
			},
		},
		{
			Name = "GetCovenantIDs",
			Type = "Function",

			Returns =
			{
				{ Name = "covenantID", Type = "table", InnerType = "number", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "CovenantData",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "soulbindIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Covenants);