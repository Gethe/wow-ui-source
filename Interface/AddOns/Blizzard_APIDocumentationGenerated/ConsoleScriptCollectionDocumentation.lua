local ConsoleScriptCollection =
{
	Name = "ConsoleScriptCollection",
	Type = "System",
	Namespace = "C_ConsoleScriptCollection",

	Functions =
	{
		{
			Name = "GetCollectionDataByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "collectionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "ConsoleScriptCollectionData", Nilable = true },
			},
		},
		{
			Name = "GetCollectionDataByTag",
			Type = "Function",

			Arguments =
			{
				{ Name = "collectionTag", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "ConsoleScriptCollectionData", Nilable = true },
			},
		},
		{
			Name = "GetElements",
			Type = "Function",

			Arguments =
			{
				{ Name = "collectionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "elementIDs", Type = "table", InnerType = "ConsoleScriptCollectionElementData", Nilable = false },
			},
		},
		{
			Name = "GetScriptData",
			Type = "Function",

			Arguments =
			{
				{ Name = "consoleScriptID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "ConsoleScriptData", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "ConsoleScriptCollectionData",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ConsoleScriptCollectionElementData",
			Type = "Structure",
			Fields =
			{
				{ Name = "collectionID", Type = "number", Nilable = true },
				{ Name = "consoleScriptID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "ConsoleScriptData",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "help", Type = "cstring", Nilable = false },
				{ Name = "script", Type = "cstring", Nilable = false },
				{ Name = "params", Type = "cstring", Nilable = false },
				{ Name = "isLuaScript", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ConsoleScriptParameter",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ConsoleScriptCollection);