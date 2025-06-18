local EventSchedulerConstants =
{
	Tables =
	{
		{
			Name = "EventScheduler",
			Type = "Constants",
			Values =
			{
				{ Name = "SCHEDULED_EVENT_REMINDER_WARNING_SECONDS", Type = "number", Value = 300 },
				{ Name = "SCHEDULED_EVENT_FUTURE_LIMIT", Type = "number", Value = 12 },
				{ Name = "SCHEDULED_EVENT_REMINDER_DEAD_SECONDS", Type = "number", Value = 10 },
				{ Name = "SCHEDULED_EVENT_PAST_LIMIT_SECONDS", Type = "number", Value = 3600 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(EventSchedulerConstants);