local GuildBank =
{
	Name = "GuildBank",
	Type = "System",
	Namespace = "C_GuildBank",
	Environment = "All",

	Functions =
	{
		{
			Name = "IsGuildBankEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "GuildbankItemLockChanged",
			Type = "Event",
			LiteralName = "GUILDBANK_ITEM_LOCK_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "GuildbankTextChanged",
			Type = "Event",
			LiteralName = "GUILDBANK_TEXT_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "guildBankTab", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GuildbankUpdateMoney",
			Type = "Event",
			LiteralName = "GUILDBANK_UPDATE_MONEY",
			SynchronousEvent = true,
		},
		{
			Name = "GuildbankUpdateTabs",
			Type = "Event",
			LiteralName = "GUILDBANK_UPDATE_TABS",
			SynchronousEvent = true,
		},
		{
			Name = "GuildbankUpdateText",
			Type = "Event",
			LiteralName = "GUILDBANK_UPDATE_TEXT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "guildBankTab", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GuildbankUpdateWithdrawmoney",
			Type = "Event",
			LiteralName = "GUILDBANK_UPDATE_WITHDRAWMONEY",
			SynchronousEvent = true,
		},
		{
			Name = "GuildbankbagslotsChanged",
			Type = "Event",
			LiteralName = "GUILDBANKBAGSLOTS_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "GuildbankframeClosed",
			Type = "Event",
			LiteralName = "GUILDBANKFRAME_CLOSED",
			SynchronousEvent = true,
		},
		{
			Name = "GuildbankframeOpened",
			Type = "Event",
			LiteralName = "GUILDBANKFRAME_OPENED",
			SynchronousEvent = true,
		},
		{
			Name = "GuildbanklogUpdate",
			Type = "Event",
			LiteralName = "GUILDBANKLOG_UPDATE",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(GuildBank);