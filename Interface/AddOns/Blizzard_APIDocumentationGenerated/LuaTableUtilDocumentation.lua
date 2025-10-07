local LuaTableUtil =
{
	Name = "LuaTableUtil",
	Type = "System",
	Namespace = "table",

	Functions =
	{
		{
			Name = "count",
			Type = "Function",
			MayReturnNothing = true,

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
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(LuaTableUtil);