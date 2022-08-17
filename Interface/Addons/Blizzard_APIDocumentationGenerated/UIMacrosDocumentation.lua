local UIMacros =
{
	Name = "UIMacros",
	Type = "System",
	Namespace = "C_Macro",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "ExecuteChatLine",
			Type = "Event",
			LiteralName = "EXECUTE_CHAT_LINE",
			Payload =
			{
				{ Name = "chatLine", Type = "string", Nilable = false },
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