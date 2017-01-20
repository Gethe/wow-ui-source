local MailInfoLua =
{
	Name = "MailInfo",
	Namespace = "C_Mail",

	Functions =
	{
		{
			Name = "HasInboxMoney",

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

			Returns =
			{
				{ Name = "isCommandPending", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(MailInfoLua);