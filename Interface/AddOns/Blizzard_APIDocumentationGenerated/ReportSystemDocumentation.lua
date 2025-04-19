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
				{ Name = "playerLocation", Type = "PlayerLocation", Mixin = "PlayerLocationMixin", Nilable = false },
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
				{ Name = "playerLocation", Type = "PlayerLocation", Mixin = "PlayerLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "canReport", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetMajorCategoriesForReportType",
			Type = "Function",

			Arguments =
			{
				{ Name = "reportType", Type = "ReportType", Nilable = false },
			},

			Returns =
			{
				{ Name = "majorCategories", Type = "table", InnerType = "ReportMajorCategory", Nilable = false },
			},
		},
		{
			Name = "GetMajorCategoryString",
			Type = "Function",

			Arguments =
			{
				{ Name = "majorCategory", Type = "ReportMajorCategory", Nilable = false },
			},

			Returns =
			{
				{ Name = "majorCategoryString", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetMinorCategoriesForReportTypeAndMajorCategory",
			Type = "Function",

			Arguments =
			{
				{ Name = "reportType", Type = "ReportType", Nilable = false },
				{ Name = "majorCategory", Type = "ReportMajorCategory", Nilable = false },
			},

			Returns =
			{
				{ Name = "minorCategories", Type = "table", InnerType = "ReportMinorCategory", Nilable = false },
			},
		},
		{
			Name = "GetMinorCategoryString",
			Type = "Function",

			Arguments =
			{
				{ Name = "minorCategory", Type = "ReportMinorCategory", Nilable = false },
			},

			Returns =
			{
				{ Name = "minorCategoryString", Type = "cstring", Nilable = false },
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
			Name = "SendReport",
			Type = "Function",
			Documentation = { "Not allowed to be called by addons" },

			Arguments =
			{
				{ Name = "reportInfo", Type = "ReportInfo", Mixin = "ReportInfoMixin", Nilable = false },
				{ Name = "playerLocation", Type = "PlayerLocation", Mixin = "PlayerLocationMixin", Nilable = true },
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
				{ Name = "reportType", Type = "ReportType", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ReportSystem);