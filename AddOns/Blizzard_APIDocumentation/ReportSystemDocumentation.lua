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
			Name = "InitiateReportPlayer",
			Type = "Function",

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
			Name = "ReportServerLag",
			Type = "Function",
		},
		{
			Name = "SendReportPlayer",
			Type = "Function",

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