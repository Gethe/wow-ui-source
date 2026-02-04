local LuaTableUtil =
{
	Name = "LuaTableUtil",
	Type = "System",
	Namespace = "C_TableUtil",
	Environment = "All",

	Functions =
	{
		{
			Name = "count",
			Type = "Function",
			MayReturnNothing = true,
			Namespace = "table",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "table", Type = "LuaValueReference", Nilable = false },
			},

			Returns =
			{
				{ Name = "numTableNodes", Type = "number", Nilable = false, Documentation = { "Total number of elements within the table" } },
				{ Name = "numArrayNodes", Type = "number", Nilable = false, Documentation = { "Total number of elements within the table that had integral keys in the range [1..numTableNodes]" } },
				{ Name = "maxArrayIndex", Type = "number", Nilable = false, Documentation = { "Largest integral key within the table, or zero if no such keys were found" } },
			},
		},
		{
			Name = "create",
			Type = "Function",
			Namespace = "table",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "arraySizeHint", Type = "number", Nilable = false },
				{ Name = "nodeSizeHint", Type = "number", Nilable = false, Default = 0 },
			},

			Returns =
			{
				{ Name = "table", Type = "LuaValueReference", Nilable = false },
			},
		},
		{
			Name = "FindIndexedMismatch",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Given two tables, finds the first index in the range (1, #t1) and (1, #t2) where two elements compare as inequal, or nil if no such elements are found." },

			Arguments =
			{
				{ Name = "t1", Type = "LuaValueReference", Nilable = false },
				{ Name = "t2", Type = "LuaValueReference", Nilable = false },
			},

			Returns =
			{
				{ Name = "index", Type = "number", Nilable = true },
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

APIDocumentation:AddDocumentationTable(LuaTableUtil);