local EventSchedulerUI =
{
	Name = "EventSchedulerUI",
	Type = "System",
	Namespace = "C_EventScheduler",
	Environment = "All",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "EventSchedulerUpdate",
			Type = "Event",
			LiteralName = "EVENT_SCHEDULER_UPDATE",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
		{
			Name = "EventDisplayInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "hideTimeLeft", Type = "bool", Nilable = false, Default = false },
				{ Name = "hideDescription", Type = "bool", Nilable = false, Default = false },
				{ Name = "overrideAtlas", Type = "textureAtlas", Nilable = true },
				{ Name = "overrideTooltipWidgetSetID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "OngoingEventInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "areaPoiID", Type = "number", Nilable = false },
				{ Name = "rewardsClaimed", Type = "bool", Nilable = false, Default = false },
				{ Name = "displayInfo", Type = "EventDisplayInfo", Nilable = false },
			},
		},
		{
			Name = "ScheduledEventInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "eventKey", Type = "string", Nilable = false },
				{ Name = "eventID", Type = "number", Nilable = false },
				{ Name = "areaPoiID", Type = "number", Nilable = false },
				{ Name = "startTime", Type = "time_t", Nilable = false },
				{ Name = "endTime", Type = "time_t", Nilable = false },
				{ Name = "duration", Type = "time_t", Nilable = false },
				{ Name = "hasReminder", Type = "bool", Nilable = false, Default = false },
				{ Name = "rewardsClaimed", Type = "bool", Nilable = false, Default = false },
				{ Name = "displayInfo", Type = "EventDisplayInfo", Nilable = false },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(EventSchedulerUI);