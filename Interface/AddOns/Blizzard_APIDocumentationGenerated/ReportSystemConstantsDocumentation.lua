local ReportSystemConstants =
{
	Tables =
	{
		{
			Name = "ReportEvidenceType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Invalid", Type = "ReportEvidenceType", EnumValue = 0 },
				{ Name = "HouseScreenshot", Type = "ReportEvidenceType", EnumValue = 1 },
				{ Name = "HouseLayoutJson", Type = "ReportEvidenceType", EnumValue = 2 },
			},
		},
		{
			Name = "ReportMajorCategory",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "InappropriateCommunication", Type = "ReportMajorCategory", EnumValue = 0 },
				{ Name = "GameplaySabotage", Type = "ReportMajorCategory", EnumValue = 1 },
				{ Name = "Cheating", Type = "ReportMajorCategory", EnumValue = 2 },
				{ Name = "InappropriateName", Type = "ReportMajorCategory", EnumValue = 3 },
				{ Name = "InappropriateDecor", Type = "ReportMajorCategory", EnumValue = 4 },
			},
		},
		{
			Name = "ReportMinorCategory",
			Type = "Enumeration",
			NumValues = 20,
			MinValue = 1,
			MaxValue = 524288,
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
				{ Name = "HarmfulToMinors", Type = "ReportMinorCategory", EnumValue = 32768 },
				{ Name = "Disruption", Type = "ReportMinorCategory", EnumValue = 65536 },
				{ Name = "TerroristAndViolentExtremistContent", Type = "ReportMinorCategory", EnumValue = 131072 },
				{ Name = "ChildSexualExploitationAndAbuse", Type = "ReportMinorCategory", EnumValue = 262144 },
				{ Name = "NeighborhoodName", Type = "ReportMinorCategory", EnumValue = 524288 },
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
			Name = "ReportThrottleType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Invalid", Type = "ReportThrottleType", EnumValue = 0 },
				{ Name = "General", Type = "ReportThrottleType", EnumValue = 1 },
				{ Name = "Expensive", Type = "ReportThrottleType", EnumValue = 2 },
			},
		},
		{
			Name = "ReportType",
			Type = "Enumeration",
			NumValues = 21,
			MinValue = 0,
			MaxValue = 20,
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
				{ Name = "RecentAlly", Type = "ReportType", EnumValue = 17 },
				{ Name = "HousingDecor", Type = "ReportType", EnumValue = 18 },
				{ Name = "Neighborhood", Type = "ReportType", EnumValue = 19 },
				{ Name = "NeighborhoodRoster", Type = "ReportType", EnumValue = 20 },
			},
		},
		{
			Name = "ScreenshotSource",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Automatic", Type = "ScreenshotSource", EnumValue = 0 },
				{ Name = "PlayerReport", Type = "ScreenshotSource", EnumValue = 1 },
				{ Name = "Cheat", Type = "ScreenshotSource", EnumValue = 2 },
			},
		},
		{
			Name = "SendReportResult",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Success", Type = "SendReportResult", EnumValue = 0 },
				{ Name = "GeneralError", Type = "SendReportResult", EnumValue = 1 },
				{ Name = "TooManyReports", Type = "SendReportResult", EnumValue = 2 },
				{ Name = "RequiresChatLine", Type = "SendReportResult", EnumValue = 3 },
				{ Name = "RequiresChatLineOrVoice", Type = "SendReportResult", EnumValue = 4 },
				{ Name = "RequiresScreenshot", Type = "SendReportResult", EnumValue = 5 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ReportSystemConstants);