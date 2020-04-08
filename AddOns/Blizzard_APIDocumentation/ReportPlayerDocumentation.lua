local ReportPlayer =
{
	Name = "ReportSystem",
	Type = "System",
	Namespace = "C_ReportPlayer",

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
			Name = "ReportPlayer",
			Type = "Function",

			Arguments =
			{
				{ Name = "complaintType", Type = "string", Nilable = false },
				{ Name = "playerLocation", Type = "table", Mixin = "PlayerLocationMixin", Nilable = true },
				{ Name = "comment", Type = "string", Nilable = true },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ReportPlayer);