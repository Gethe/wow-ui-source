local DateAndTime =
{
	Name = "DateAndTime",
	Type = "System",
	Namespace = "C_DateAndTime",

	Functions =
	{
		{
			Name = "AdjustTimeByDays",
			Type = "Function",

			Arguments =
			{
				{ Name = "date", Type = "CalendarTime", Nilable = false },
				{ Name = "days", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "newDate", Type = "CalendarTime", Nilable = false },
			},
		},
		{
			Name = "AdjustTimeByMinutes",
			Type = "Function",

			Arguments =
			{
				{ Name = "date", Type = "CalendarTime", Nilable = false },
				{ Name = "minutes", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "newDate", Type = "CalendarTime", Nilable = false },
			},
		},
		{
			Name = "CompareCalendarTime",
			Type = "Function",

			Arguments =
			{
				{ Name = "lhsCalendarTime", Type = "CalendarTime", Nilable = false },
				{ Name = "rhsCalendarTime", Type = "CalendarTime", Nilable = false },
			},

			Returns =
			{
				{ Name = "comparison", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCalendarTimeFromEpoch",
			Type = "Function",

			Arguments =
			{
				{ Name = "epoch", Type = "BigUInteger", Nilable = false },
			},

			Returns =
			{
				{ Name = "date", Type = "CalendarTime", Nilable = false },
			},
		},
		{
			Name = "GetCurrentCalendarTime",
			Type = "Function",

			Returns =
			{
				{ Name = "date", Type = "CalendarTime", Nilable = false },
			},
		},
		{
			Name = "GetSecondsUntilDailyReset",
			Type = "Function",

			Returns =
			{
				{ Name = "seconds", Type = "time_t", Nilable = false },
			},
		},
		{
			Name = "GetSecondsUntilWeeklyReset",
			Type = "Function",

			Returns =
			{
				{ Name = "seconds", Type = "time_t", Nilable = false },
			},
		},
		{
			Name = "GetServerTimeLocal",
			Type = "Function",

			Returns =
			{
				{ Name = "serverTimeLocal", Type = "time_t", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "TimeEventFlag",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "GlueScreenShortcut", Type = "TimeEventFlag", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(DateAndTime);