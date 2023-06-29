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
	},

	Events =
	{
		{
			Name = "ExecuteChatLine",
			Type = "Event",
			LiteralName = "EXECUTE_CHAT_LINE",
			Payload =
			{
				{ Name = "chatLine", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "UpdateMacros",
			Type = "Event",
			LiteralName = "UPDATE_MACROS",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(UIMacros);