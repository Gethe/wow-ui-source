local PlayerMentorship =
{
	Name = "PlayerMentorship",
	Type = "System",
	Namespace = "C_PlayerMentorship",

	Functions =
	{
		{
			Name = "ApplyForMentorshipStatus",
			Type = "Function",
		},
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
		{
			Name = "RelinquishMentorshipStatus",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "MentorshipApplicationResult",
			Type = "Event",
			LiteralName = "MENTORSHIP_APPLICATION_RESULT",
			Payload =
			{
				{ Name = "result", Type = "PlayerMentorshipApplicationResult", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(PlayerMentorship);