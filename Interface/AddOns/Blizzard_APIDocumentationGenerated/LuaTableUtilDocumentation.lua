local LuaTableUtil =
{
	Name = "LuaTableUtil",
	Type = "System",
	Namespace = "table",

	Functions =
	{
		{
			Name = "create",
			Type = "Function",

			Arguments =
			{
				{ Name = "arraySizeHint", Type = "number", Nilable = false },
				{ Name = "nodeSizeHint", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "table", Type = "LuaValueVariant", Nilable = false },
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