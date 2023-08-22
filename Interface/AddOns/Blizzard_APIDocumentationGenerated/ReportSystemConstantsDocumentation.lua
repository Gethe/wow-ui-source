local ReportSystemConstants =
{
	Tables =
	{
		{
			Name = "ReportMajorCategory",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "InappropriateCommunication", Type = "ReportMajorCategory", EnumValue = 0 },
				{ Name = "GameplaySabotage", Type = "ReportMajorCategory", EnumValue = 1 },
				{ Name = "Cheating", Type = "ReportMajorCategory", EnumValue = 2 },
				{ Name = "InappropriateName", Type = "ReportMajorCategory", EnumValue = 3 },
			},
		},
		{
			Name = "ReportMinorCategory",
			Type = "Enumeration",
			NumValues = 15,
			MinValue = 1,
			MaxValue = 16384,
			Fields =
			{
				{ Name = "TextChat", Type = "ReportMinorCategory", EnumValue = 1 },
				{ Name = "Boosting", Type = "ReportMinorCategory", EnumValue = 2 },
				{ Name = "Spam", Type = "ReportMinorCategory", EnumValue = 4 },
				{ Name = "Afk", Type = "ReportMinorCategory", EnumValue = 8 },
				{ Name = "IntentionallyFeeding", Type = "ReportMinorCategory", EnumValue = 16 },
				{ Name = "BlockingProgress", Type = "ReportMinorCategory", EnumValue = 32 },
				{ Name = "Hacking", Type = "ReportMinorCategory", EnumValue = 64 },
				{ Name = "Botting", Type = "ReportMinorCategory", EnumValue = 128 },
				{ Name = "Advertisement", Type = "ReportMinorCategory", EnumValue = 256 },
				{ Name = "BTag", Type = "ReportMinorCategory", EnumValue = 512 },
				{ Name = "GroupName", Type = "ReportMinorCategory", EnumValue = 1024 },
				{ Name = "CharacterName", Type = "ReportMinorCategory", EnumValue = 2048 },
				{ Name = "GuildName", Type = "ReportMinorCategory", EnumValue = 4096 },
				{ Name = "Description", Type = "ReportMinorCategory", EnumValue = 8192 },
				{ Name = "Name", Type = "ReportMinorCategory", EnumValue = 16384 },
			},
		},
		{
			Name = "ReportSubComplaintTypes",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Inappropriate", Type = "ReportSubComplaintTypes", EnumValue = 0 },
				{ Name = "Advertising", Type = "ReportSubComplaintTypes", EnumValue = 1 },
			},
		},
		{
			Name = "ReportType",
			Type = "Enumeration",
			NumValues = 17,
			MinValue = 0,
			MaxValue = 16,
			Fields =
			{
				{ Name = "Chat", Type = "ReportType", EnumValue = 0 },
				{ Name = "InWorld", Type = "ReportType", EnumValue = 1 },
				{ Name = "ClubFinderPosting", Type = "ReportType", EnumValue = 2 },
				{ Name = "ClubFinderApplicant", Type = "ReportType", EnumValue = 3 },
				{ Name = "GroupFinderPosting", Type = "ReportType", EnumValue = 4 },
				{ Name = "GroupFinderApplicant", Type = "ReportType", EnumValue = 5 },
				{ Name = "ClubMember", Type = "ReportType", EnumValue = 6 },
				{ Name = "GroupMember", Type = "ReportType", EnumValue = 7 },
				{ Name = "Friend", Type = "ReportType", EnumValue = 8 },
				{ Name = "Pet", Type = "ReportType", EnumValue = 9 },
				{ Name = "BattlePet", Type = "ReportType", EnumValue = 10 },
				{ Name = "Calendar", Type = "ReportType", EnumValue = 11 },
				{ Name = "Mail", Type = "ReportType", EnumValue = 12 },
				{ Name = "PvP", Type = "ReportType", EnumValue = 13 },
				{ Name = "PvPScoreboard", Type = "ReportType", EnumValue = 14 },
				{ Name = "PvPGroupMember", Type = "ReportType", EnumValue = 15 },
				{ Name = "CraftingOrder", Type = "ReportType", EnumValue = 16 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ReportSystemConstants);