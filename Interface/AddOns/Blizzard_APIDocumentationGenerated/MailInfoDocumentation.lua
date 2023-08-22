local MailInfo =
{
	Name = "MailInfo",
	Type = "System",
	Namespace = "C_Mail",

	Functions =
	{
		{
			Name = "HasInboxMoney",
			Type = "Function",

			Arguments =
			{
				{ Name = "inboxIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "inboxItemHasMoneyAttached", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsCommandPending",
			Type = "Function",

			Returns =
			{
				{ Name = "isCommandPending", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "CloseInboxItem",
			Type = "Event",
			LiteralName = "CLOSE_INBOX_ITEM",
			Payload =
			{
				{ Name = "mailIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "MailClosed",
			Type = "Event",
			LiteralName = "MAIL_CLOSED",
		},
		{
			Name = "MailFailed",
			Type = "Event",
			LiteralName = "MAIL_FAILED",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "MailInboxUpdate",
			Type = "Event",
			LiteralName = "MAIL_INBOX_UPDATE",
		},
		{
			Name = "MailLockSendItems",
			Type = "Event",
			LiteralName = "MAIL_LOCK_SEND_ITEMS",
			Payload =
			{
				{ Name = "attachSlot", Type = "luaIndex", Nilable = false },
				{ Name = "itemLink", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "MailSendInfoUpdate",
			Type = "Event",
			LiteralName = "MAIL_SEND_INFO_UPDATE",
		},
		{
			Name = "MailSendSuccess",
			Type = "Event",
			LiteralName = "MAIL_SEND_SUCCESS",
		},
		{
			Name = "MailShow",
			Type = "Event",
			LiteralName = "MAIL_SHOW",
		},
		{
			Name = "MailSuccess",
			Type = "Event",
			LiteralName = "MAIL_SUCCESS",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "MailUnlockSendItems",
			Type = "Event",
			LiteralName = "MAIL_UNLOCK_SEND_ITEMS",
		},
		{
			Name = "SendMailCodChanged",
			Type = "Event",
			LiteralName = "SEND_MAIL_COD_CHANGED",
		},
		{
			Name = "SendMailMoneyChanged",
			Type = "Event",
			LiteralName = "SEND_MAIL_MONEY_CHANGED",
		},
		{
			Name = "UpdatePendingMail",
			Type = "Event",
			LiteralName = "UPDATE_PENDING_MAIL",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(MailInfo);