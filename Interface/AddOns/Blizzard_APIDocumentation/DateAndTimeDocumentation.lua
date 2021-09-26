local DateAndTime =
{
	Name = "DateAndTime",
	Type = "System",
	Namespace = "C_DateAndTime",

	Functions =
	{
		{
			Name = "GetDateFromEpoch",
			Type = "Function",

			Arguments =
			{
				{ Name = "epoch", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "date", Type = "CalendarDate", Nilable = false },
			},
		},
		{
			Name = "GetTodaysDate",
			Type = "Function",

			Returns =
			{
				{ Name = "date", Type = "CalendarDate", Nilable = false },
			},
		},
		{
			Name = "GetYesterdaysDate",
			Type = "Function",

			Returns =
			{
				{ Name = "date", Type = "CalendarDate", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "CalendarDate",
			Type = "Structure",
			Fields =
			{
				{ Name = "day", Type = "number", Nilable = false },
				{ Name = "weekDay", Type = "number", Nilable = false },
				{ Name = "month", Type = "number", Nilable = false },
				{ Name = "year", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(DateAndTime);