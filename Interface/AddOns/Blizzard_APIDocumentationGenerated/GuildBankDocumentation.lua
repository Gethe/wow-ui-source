local GuildBank =
{
	Name = "GuildBank",
	Type = "System",
	Namespace = "C_GuildBank",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "GuildbankItemLockChanged",
			Type = "Event",
			LiteralName = "GUILDBANK_ITEM_LOCK_CHANGED",
		},
		{
			Name = "GuildbankTextChanged",
			Type = "Event",
			LiteralName = "GUILDBANK_TEXT_CHANGED",
			Payload =
			{
				{ Name = "guildBankTab", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GuildbankUpdateMoney",
			Type = "Event",
			LiteralName = "GUILDBANK_UPDATE_MONEY",
		},
		{
			Name = "GuildbankUpdateTabs",
			Type = "Event",
			LiteralName = "GUILDBANK_UPDATE_TABS",
		},
		{
			Name = "GuildbankUpdateText",
			Type = "Event",
			LiteralName = "GUILDBANK_UPDATE_TEXT",
			Payload =
			{
				{ Name = "guildBankTab", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GuildbankUpdateWithdrawmoney",
			Type = "Event",
			LiteralName = "GUILDBANK_UPDATE_WITHDRAWMONEY",
		},
		{
			Name = "GuildbankbagslotsChanged",
			Type = "Event",
			LiteralName = "GUILDBANKBAGSLOTS_CHANGED",
		},
		{
			Name = "GuildbankframeClosed",
			Type = "Event",
			LiteralName = "GUILDBANKFRAME_CLOSED",
		},
		{
			Name = "GuildbankframeOpened",
			Type = "Event",
			LiteralName = "GUILDBANKFRAME_OPENED",
		},
		{
			Name = "GuildbanklogUpdate",
			Type = "Event",
			LiteralName = "GUILDBANKLOG_UPDATE",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(GuildBank);