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
	},
};

APIDocumentation:AddDocumentationTable(ReportSystem);