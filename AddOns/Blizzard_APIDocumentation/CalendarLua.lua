local CalendarLua =
{
	Name = "Calendar",
	Type = "System",
	Namespace = "C_Calendar",

	Functions =
	{
		{
			Name = "GetDayEvent",
			Type = "Function",

			Arguments =
			{
				{ Name = "monthOffset", Type = "number", Nilable = false },
				{ Name = "monthDay", Type = "number", Nilable = false },
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "event", Type = "CalendarDayEvent", Nilable = false },
			},
		},
		{
			Name = "GetHolidayInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "monthOffset", Type = "number", Nilable = false },
				{ Name = "monthDay", Type = "number", Nilable = false },
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "event", Type = "CalendarHolidayInfo", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "CalendarTime",
			Type = "Structure",
			Fields =
			{
				{ Name = "monthDay", Type = "number", Nilable = false },
				{ Name = "month", Type = "number", Nilable = false },
				{ Name = "year", Type = "number", Nilable = false },
				{ Name = "hour", Type = "number", Nilable = false },
				{ Name = "minute", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CalendarDayEvent",
			Type = "Structure",
			Fields =
			{
				{ Name = "title", Type = "string", Nilable = false },
				{ Name = "startTime", Type = "CalendarTime", Nilable = false },
				{ Name = "endTime", Type = "CalendarTime", Nilable = false },
				{ Name = "calendarType", Type = "string", Nilable = false },
				{ Name = "sequenceType", Type = "string", Nilable = false },
				{ Name = "eventType", Type = "number", Nilable = false },
				{ Name = "iconTexture", Type = "number", Nilable = false },
				{ Name = "modStatus", Type = "string", Nilable = false },
				{ Name = "inviteStatus", Type = "number", Nilable = false },
				{ Name = "invitedBy", Type = "string", Nilable = false },
				{ Name = "difficulty", Type = "number", Nilable = false },
				{ Name = "inviteType", Type = "number", Nilable = false },
				{ Name = "sequenceIndex", Type = "number", Nilable = false },
				{ Name = "numSequenceDays", Type = "number", Nilable = false },
				{ Name = "difficultyName", Type = "string", Nilable = false },
				{ Name = "dontDisplayBanner", Type = "bool", Nilable = false },
				{ Name = "dontDisplayEnd", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CalendarHolidayInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "texture", Type = "number", Nilable = false },
				{ Name = "startTime", Type = "CalendarTime", Nilable = true },
				{ Name = "endTime", Type = "CalendarTime", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CalendarLua);