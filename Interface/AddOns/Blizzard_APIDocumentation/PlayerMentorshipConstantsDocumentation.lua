local PlayerMentorshipConstants =
{
	Tables =
	{
		{
			Name = "PlayerMentorshipApplicationResult",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Success", Type = "PlayerMentorshipApplicationResult", EnumValue = 0 },
				{ Name = "AlreadyMentor", Type = "PlayerMentorshipApplicationResult", EnumValue = 1 },
				{ Name = "Ineligible", Type = "PlayerMentorshipApplicationResult", EnumValue = 2 },
			},
		},
		{
			Name = "PlayerMentorshipStatus",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "PlayerMentorshipStatus", EnumValue = 0 },
				{ Name = "Newcomer", Type = "PlayerMentorshipStatus", EnumValue = 1 },
				{ Name = "Mentor", Type = "PlayerMentorshipStatus", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PlayerMentorshipConstants);