local GMTicketInfo =
{
	Name = "GMTicketInfo",
	Type = "System",
	Namespace = "C_GMTicketInfo",
	Environment = "All",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "GmPlayerInfo",
			Type = "Event",
			LiteralName = "GM_PLAYER_INFO",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "info", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ItemRestorationButtonStatus",
			Type = "Event",
			LiteralName = "ITEM_RESTORATION_BUTTON_STATUS",
			SynchronousEvent = true,
		},
		{
			Name = "PetitionClosed",
			Type = "Event",
			LiteralName = "PETITION_CLOSED",
			SynchronousEvent = true,
		},
		{
			Name = "PetitionShow",
			Type = "Event",
			LiteralName = "PETITION_SHOW",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerReportSubmitted",
			Type = "Event",
			LiteralName = "PLAYER_REPORT_SUBMITTED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "invitedByGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "QuickTicketSystemStatus",
			Type = "Event",
			LiteralName = "QUICK_TICKET_SYSTEM_STATUS",
			SynchronousEvent = true,
		},
		{
			Name = "QuickTicketThrottleChanged",
			Type = "Event",
			LiteralName = "QUICK_TICKET_THROTTLE_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "UpdateWebTicket",
			Type = "Event",
			LiteralName = "UPDATE_WEB_TICKET",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "hasTicket", Type = "bool", Nilable = false },
				{ Name = "numTickets", Type = "number", Nilable = true },
				{ Name = "ticketStatus", Type = "number", Nilable = true },
				{ Name = "caseIndex", Type = "number", Nilable = true },
				{ Name = "waitTimeMinutes", Type = "number", Nilable = true },
				{ Name = "waitMessage", Type = "cstring", Nilable = true },
				{ Name = "caseTitle", Type = "cstring", Nilable = true },
				{ Name = "caseDescription", Type = "cstring", Nilable = true },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(GMTicketInfo);