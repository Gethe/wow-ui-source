local GMTicketInfo =
{
	Name = "GMTicketInfo",
	Type = "System",
	Namespace = "C_GMTicketInfo",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "GmPlayerInfo",
			Type = "Event",
			LiteralName = "GM_PLAYER_INFO",
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
		},
		{
			Name = "PetitionClosed",
			Type = "Event",
			LiteralName = "PETITION_CLOSED",
		},
		{
			Name = "PetitionShow",
			Type = "Event",
			LiteralName = "PETITION_SHOW",
		},
		{
			Name = "PlayerReportSubmitted",
			Type = "Event",
			LiteralName = "PLAYER_REPORT_SUBMITTED",
			Payload =
			{
				{ Name = "invitedByGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "QuickTicketSystemStatus",
			Type = "Event",
			LiteralName = "QUICK_TICKET_SYSTEM_STATUS",
		},
		{
			Name = "QuickTicketThrottleChanged",
			Type = "Event",
			LiteralName = "QUICK_TICKET_THROTTLE_CHANGED",
		},
		{
			Name = "UpdateWebTicket",
			Type = "Event",
			LiteralName = "UPDATE_WEB_TICKET",
			Payload =
			{
				{ Name = "hasTicket", Type = "bool", Nilable = false },
				{ Name = "numTickets", Type = "number", Nilable = true },
				{ Name = "ticketStatus", Type = "number", Nilable = true },
				{ Name = "caseIndex", Type = "number", Nilable = true },
				{ Name = "waitTimeMinutes", Type = "number", Nilable = true },
				{ Name = "waitMessage", Type = "cstring", Nilable = true },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(GMTicketInfo);