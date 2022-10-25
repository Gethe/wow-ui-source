local ReturningPlayerUI =
{
	Name = "ReturningPlayerUI",
	Type = "System",
	Namespace = "C_ReturningPlayerUI",

	Functions =
	{
		{
			Name = "AcceptPrompt",
			Type = "Function",
		},
		{
			Name = "DeclinePrompt",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "ReturningPlayerPrompt",
			Type = "Event",
			LiteralName = "RETURNING_PLAYER_PROMPT",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ReturningPlayerUI);