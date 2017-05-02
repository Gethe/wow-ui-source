local ChatBubblesLua =
{
	Name = "ChatBubbles",
	Type = "System",
	Namespace = "C_ChatBubbles",

	Functions =
	{
		{
			Name = "GetAllChatBubbles",
			Type = "Function",

			Arguments =
			{
				{ Name = "includeForbidden", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "chatBubbles", Type = "table", InnerType = "ScriptObject", Nilable = false },
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

APIDocumentation:AddDocumentationTable(ChatBubblesLua);