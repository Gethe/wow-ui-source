local PlayerMentorship =
{
	Name = "PlayerMentorship",
	Type = "System",
	Namespace = "C_PlayerMentorship",

	Functions =
	{
		{
			Name = "GetMentorshipStatus",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerLocation", Type = "table", Mixin = "PlayerLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "status", Type = "PlayerMentorshipStatus", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "NewcomerGraduation",
			Type = "Event",
			LiteralName = "NEWCOMER_GRADUATION",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(PlayerMentorship);