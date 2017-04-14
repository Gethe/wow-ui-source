local MailInfoLua =
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
				{ Name = "inboxIndex", Type = "number", Nilable = false },
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
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(MailInfoLua);