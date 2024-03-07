local CVar =
{
	Name = "CVarScripts",
	Type = "System",
	Namespace = "C_CVar",

	Functions =
	{
		{
			Name = "GetCVar",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "value", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetCVarBitfield",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "value", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "GetCVarBool",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "value", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "GetCVarDefault",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "defaultValue", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetCVarInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "value", Type = "cstring", Nilable = false },
				{ Name = "defaultValue", Type = "cstring", Nilable = false },
				{ Name = "isStoredServerAccount", Type = "bool", Nilable = false },
				{ Name = "isStoredServerCharacter", Type = "bool", Nilable = false },
				{ Name = "isLockedFromUser", Type = "bool", Nilable = false },
				{ Name = "isSecure", Type = "bool", Nilable = false },
				{ Name = "isReadOnly", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RegisterCVar",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "value", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "ResetTestCVars",
			Type = "Function",
		},
		{
			Name = "SetCVar",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "value", Type = "cstring", Nilable = true },
				{ Name = "scriptCVar", Type = "cstring", Nilable = true },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCVarBitfield",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "value", Type = "bool", Nilable = false },
				{ Name = "scriptCVar", Type = "cstring", Nilable = true },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "CVarInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "value", Type = "cstring", Nilable = false },
				{ Name = "defaultValue", Type = "cstring", Nilable = false },
				{ Name = "isStoredServerAccount", Type = "bool", Nilable = false },
				{ Name = "isStoredServerCharacter", Type = "bool", Nilable = false },
				{ Name = "isLockedFromUser", Type = "bool", Nilable = false },
				{ Name = "isSecure", Type = "bool", Nilable = false },
				{ Name = "isReadOnly", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CVar);