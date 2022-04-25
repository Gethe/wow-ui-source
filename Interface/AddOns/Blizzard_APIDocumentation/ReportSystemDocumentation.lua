local ReportSystem =
{
	Name = "ReportSystem",
	Type = "System",
	Namespace = "C_ReportSystem",

	Functions =
	{
		{
			Name = "CanReportPlayer",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerLocation", Type = "table", Mixin = "PlayerLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "canReport", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanReportPlayerForLanguage",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerLocation", Type = "table", Mixin = "PlayerLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "canReport", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "InitiateReportPlayer",
			Type = "Function",
			Documentation = { "Not allowed to be called by addons" },

			Arguments =
			{
				{ Name = "complaintType", Type = "string", Nilable = false },
				{ Name = "playerLocation", Type = "table", Mixin = "PlayerLocationMixin", Nilable = true },
			},

			Returns =
			{
				{ Name = "token", Type = "number", Nilable = false },
			},
		},
		{
			Name = "OpenReportPlayerDialog",
			Type = "Function",
			Documentation = { "Addons should use this to open the ReportPlayer dialog. InitiateReportPlayer and SendReportPlayer are no longer accessible to addons." },

			Arguments =
			{
				{ Name = "reportType", Type = "string", Nilable = false },
				{ Name = "playerName", Type = "string", Nilable = false },
				{ Name = "playerLocation", Type = "table", Mixin = "PlayerLocationMixin", Nilable = true },
			},
		},
		{
			Name = "ReportServerLag",
			Type = "Function",
		},
		{
			Name = "ReportStuckInCombat",
			Type = "Function",
		},
		{
			Name = "SendReportPlayer",
			Type = "Function",
			Documentation = { "Not allowed to be called by addons" },

			Arguments =
			{
				{ Name = "token", Type = "number", Nilable = false },
				{ Name = "comment", Type = "string", Nilable = true },
			},
		},
		{
			Name = "SetPendingReportPetTarget",
			Type = "Function",

			Arguments =
			{
				{ Name = "target", Type = "string", Nilable = true },
			},

			Returns =
			{
				{ Name = "set", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetPendingReportTarget",
			Type = "Function",

			Arguments =
			{
				{ Name = "target", Type = "string", Nilable = true },
			},

			Returns =
			{
				{ Name = "set", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetPendingReportTargetByGuid",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "string", Nilable = true },
			},

			Returns =
			{
				{ Name = "set", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "OpenReportPlayer",
			Type = "Event",
			LiteralName = "OPEN_REPORT_PLAYER",
			Payload =
			{
				{ Name = "token", Type = "number", Nilable = false },
				{ Name = "reportType", Type = "string", Nilable = false },
				{ Name = "playerName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ReportPlayerResult",
			Type = "Event",
			LiteralName = "REPORT_PLAYER_RESULT",
			Payload =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
	},

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
			NumValues = 14,
			MinValue = 0,
			MaxValue = 13,
			Fields =
			{
				{ Name = "TextChat", Type = "ReportMinorCategory", EnumValue = 0 },
				{ Name = "Boosting", Type = "ReportMinorCategory", EnumValue = 1 },
				{ Name = "Spam", Type = "ReportMinorCategory", EnumValue = 2 },
				{ Name = "Afk", Type = "ReportMinorCategory", EnumValue = 3 },
				{ Name = "IntentionallyFeeding", Type = "ReportMinorCategory", EnumValue = 4 },
				{ Name = "BlockingProgress", Type = "ReportMinorCategory", EnumValue = 5 },
				{ Name = "Hacking", Type = "ReportMinorCategory", EnumValue = 6 },
				{ Name = "Botting", Type = "ReportMinorCategory", EnumValue = 7 },
				{ Name = "Inaproppriate", Type = "ReportMinorCategory", EnumValue = 8 },
				{ Name = "Advertisement", Type = "ReportMinorCategory", EnumValue = 9 },
				{ Name = "BTag", Type = "ReportMinorCategory", EnumValue = 10 },
				{ Name = "GroupName", Type = "ReportMinorCategory", EnumValue = 11 },
				{ Name = "CustomGameName", Type = "ReportMinorCategory", EnumValue = 12 },
				{ Name = "VoiceChat", Type = "ReportMinorCategory", EnumValue = 13 },
			},
		},
		{
			Name = "ReportType",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "Chat", Type = "ReportType", EnumValue = 0 },
				{ Name = "InWorld", Type = "ReportType", EnumValue = 1 },
				{ Name = "ClubFinder", Type = "ReportType", EnumValue = 2 },
				{ Name = "GroupFinder", Type = "ReportType", EnumValue = 3 },
				{ Name = "ClubMember", Type = "ReportType", EnumValue = 4 },
				{ Name = "GroupMember", Type = "ReportType", EnumValue = 5 },
				{ Name = "Friend", Type = "ReportType", EnumValue = 6 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ReportSystem);