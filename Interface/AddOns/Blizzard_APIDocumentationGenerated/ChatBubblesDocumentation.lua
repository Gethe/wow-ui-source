local ChatBubbles =
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
				{ Name = "chatBubbles", Type = "table", InnerType = "ChatBubbleFrame", Nilable = false },
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

APIDocumentation:AddDocumentationTable(ChatBubbles);