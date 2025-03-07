local EventSchedulerUI =
{
	Name = "EventSchedulerUI",
	Type = "System",
	Namespace = "C_EventScheduler",

	Functions =
	{
		{
			Name = "ClearReminder",
			Type = "Function",
			Documentation = { "Clears reminder on a scheduled event. Must use endTime to identify which specific instance in the case of repeating ones." },

			Arguments =
			{
				{ Name = "eventKey", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetActiveContinentName",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Returns the name of the continent with current events" },

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetEventUiMapID",
			Type = "Function",
			Documentation = { "Will try to figure out a UiMap for an areaPOI." },

			Arguments =
			{
				{ Name = "areaPoiID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "uiMapID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetEventZoneName",
			Type = "Function",
			Documentation = { "Will try to figure out a map zone name for an areaPOI" },

			Arguments =
			{
				{ Name = "areaPoiID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetOngoingEvents",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Will request data from the server on a throttle" },

			Returns =
			{
				{ Name = "events", Type = "table", InnerType = "OngoingEventInfo", Nilable = false },
			},
		},
		{
			Name = "GetScheduledEvents",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Will request data from the server on a throttle" },

			Returns =
			{
				{ Name = "events", Type = "table", InnerType = "ScheduledEventInfo", Nilable = false },
			},
		},
		{
			Name = "HasData",
			Type = "Function",
			Documentation = { "True if the server sent a list, even if the list had 0 events." },

			Returns =
			{
				{ Name = "hasData", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasSavedReminders",
			Type = "Function",
			Documentation = { "Returns whether there are any event reminders saved. Can include reminders that have expired since set and haven't gotten removed yet. Has to be called after cvars are loaded." },

			Returns =
			{
				{ Name = "hasSavedReminders", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestEvents",
			Type = "Function",
			Documentation = { "Requests events from the server, subject to throttle" },
		},
		{
			Name = "SetReminder",
			Type = "Function",
			Documentation = { "Sets reminder on a scheduled event. Must use endTime to identify which specific instance in the case of repeating ones." },

			Arguments =
			{
				{ Name = "eventKey", Type = "string", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "EventSchedulerUpdate",
			Type = "Event",
			LiteralName = "EVENT_SCHEDULER_UPDATE",
		},
	},

	Tables =
	{
		{
			Name = "OngoingEventInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "areaPoiID", Type = "number", Nilable = false },
				{ Name = "rewardsClaimed", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "ScheduledEventInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "eventKey", Type = "string", Nilable = false },
				{ Name = "areaPoiID", Type = "number", Nilable = false },
				{ Name = "startTime", Type = "time_t", Nilable = false },
				{ Name = "endTime", Type = "time_t", Nilable = false },
				{ Name = "duration", Type = "time_t", Nilable = false },
				{ Name = "hasReminder", Type = "bool", Nilable = false, Default = false },
				{ Name = "rewardsClaimed", Type = "bool", Nilable = false, Default = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(EventSchedulerUI);