local EventSchedulerUI =
{
	Name = "EventSchedulerUI",
	Type = "System",
	Namespace = "C_EventScheduler",

	Functions =
	{
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