local UIMacros =
{
	Name = "UIMacros",
	Type = "System",
	Namespace = "C_Macro",

	Functions =
	{
		{
			Name = "GetNumIcons",
			Type = "Function",

			Returns =
			{
				{ Name = "numIcons", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetMacroExecuteLineCallback",
			Type = "Function",

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