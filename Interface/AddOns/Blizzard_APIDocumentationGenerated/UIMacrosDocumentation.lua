local UIMacros =
{
	Name = "UIMacros",
	Type = "System",
	Namespace = "C_Macro",

	Functions =
	{
		{
			Name = "GetMacroName",
			Type = "Function",

			Arguments =
			{
				{ Name = "macroId", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "GetNumIcons",
			Type = "Function",

			Returns =
			{
				{ Name = "numIcons", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSelectedMacroIcon",
			Type = "Function",

			Arguments =
			{
				{ Name = "macroId", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "textureNum", Type = "fileID", Nilable = false },
			},
		},
		{
			Name = "RunMacroText",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "button", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SetMacroExecuteLineCallback",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "cb", Type = "MacroExecuteLineCallback", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "UpdateMacros",
			Type = "Event",
			LiteralName = "UPDATE_MACROS",
		},
	},

	Tables =
	{
		{
			Name = "MacroExecuteLineCallback",
			Type = "CallbackType",

			Arguments =
			{
				{ Name = "macroLine", Type = "cstring", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIMacros);