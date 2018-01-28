local Calendar =
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
		{
			Name = "CalendarActionPending",
			Type = "Event",
			LiteralName = "CALENDAR_ACTION_PENDING",
			Payload =
			{
				{ Name = "pending", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CalendarCloseEvent",
			Type = "Event",
			LiteralName = "CALENDAR_CLOSE_EVENT",
		},
		{
			Name = "CalendarEventAlarm",
			Type = "Event",
			LiteralName = "CALENDAR_EVENT_ALARM",
			Payload =
			{
				{ Name = "title", Type = "string", Nilable = false },
				{ Name = "hour", Type = "number", Nilable = false },
				{ Name = "minute", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CalendarNewEvent",
			Type = "Event",
			LiteralName = "CALENDAR_NEW_EVENT",
			Payload =
			{
				{ Name = "isCopy", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CalendarOpenEvent",
			Type = "Event",
			LiteralName = "CALENDAR_OPEN_EVENT",
			Payload =
			{
				{ Name = "calendarType", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CalendarUpdateError",
			Type = "Event",
			LiteralName = "CALENDAR_UPDATE_ERROR",
			Payload =
			{
				{ Name = "errorReason", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CalendarUpdateEvent",
			Type = "Event",
			LiteralName = "CALENDAR_UPDATE_EVENT",
		},
		{
			Name = "CalendarUpdateEventList",
			Type = "Event",
			LiteralName = "CALENDAR_UPDATE_EVENT_LIST",
		},
		{
			Name = "CalendarUpdateGuildEvents",
			Type = "Event",
			LiteralName = "CALENDAR_UPDATE_GUILD_EVENTS",
		},
		{
			Name = "CalendarUpdateInviteList",
			Type = "Event",
			LiteralName = "CALENDAR_UPDATE_INVITE_LIST",
			Payload =
			{
				{ Name = "hasCompleteList", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "CalendarUpdatePendingInvites",
			Type = "Event",
			LiteralName = "CALENDAR_UPDATE_PENDING_INVITES",
		},
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

APIDocumentation:AddDocumentationTable(Calendar);