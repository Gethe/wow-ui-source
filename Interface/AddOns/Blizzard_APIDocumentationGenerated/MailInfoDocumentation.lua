local MailInfo =
{
	Name = "MailInfo",
	Type = "System",
	Namespace = "C_Mail",

	Functions =
	{
		{
			Name = "CanCheckInbox",
			Type = "Function",

			Returns =
			{
				{ Name = "canCheckInbox", Type = "bool", Nilable = false },
				{ Name = "secondsUntilAllowed", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCraftingOrderMailInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "inboxIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "CraftingOrderMailInfo", Nilable = true },
			},
		},
		{
			Name = "HasInboxMoney",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
		{
			Name = "SetOpeningAll",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "openingAll", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "CloseInboxItem",
			Type = "Event",
			LiteralName = "CLOSE_INBOX_ITEM",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "mailIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "MailClosed",
			Type = "Event",
			LiteralName = "MAIL_CLOSED",
			SynchronousEvent = true,
		},
		{
			Name = "MailFailed",
			Type = "Event",
			LiteralName = "MAIL_FAILED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "MailInboxUpdate",
			Type = "Event",
			LiteralName = "MAIL_INBOX_UPDATE",
			SynchronousEvent = true,
			UniqueEvent = true,
		},
		{
			Name = "MailLockSendItems",
			Type = "Event",
			LiteralName = "MAIL_LOCK_SEND_ITEMS",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
			UniqueEvent = true,
		},
		{
			Name = "MailSendSuccess",
			Type = "Event",
			LiteralName = "MAIL_SEND_SUCCESS",
			SynchronousEvent = true,
		},
		{
			Name = "MailShow",
			Type = "Event",
			LiteralName = "MAIL_SHOW",
			SynchronousEvent = true,
		},
		{
			Name = "MailSuccess",
			Type = "Event",
			LiteralName = "MAIL_SUCCESS",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "MailUnlockSendItems",
			Type = "Event",
			LiteralName = "MAIL_UNLOCK_SEND_ITEMS",
			SynchronousEvent = true,
		},
		{
			Name = "SendMailCodChanged",
			Type = "Event",
			LiteralName = "SEND_MAIL_COD_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "SendMailMoneyChanged",
			Type = "Event",
			LiteralName = "SEND_MAIL_MONEY_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "UpdatePendingMail",
			Type = "Event",
			LiteralName = "UPDATE_PENDING_MAIL",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(MailInfo);