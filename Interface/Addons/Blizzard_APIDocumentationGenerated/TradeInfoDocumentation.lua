local TradeInfo =
{
	Name = "TradeInfo",
	Type = "System",
	Namespace = "C_TradeInfo",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "PlayerTradeMoney",
			Type = "Event",
			LiteralName = "PLAYER_TRADE_MONEY",
		},
		{
			Name = "TradeAcceptUpdate",
			Type = "Event",
			LiteralName = "TRADE_ACCEPT_UPDATE",
			Payload =
			{
				{ Name = "playerAccepted", Type = "number", Nilable = false },
				{ Name = "targetAccepted", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TradeClosed",
			Type = "Event",
			LiteralName = "TRADE_CLOSED",
		},
		{
			Name = "TradeMoneyChanged",
			Type = "Event",
			LiteralName = "TRADE_MONEY_CHANGED",
		},
		{
			Name = "TradePlayerItemChanged",
			Type = "Event",
			LiteralName = "TRADE_PLAYER_ITEM_CHANGED",
			Payload =
			{
				{ Name = "tradeSlotIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TradePotentialBindEnchant",
			Type = "Event",
			LiteralName = "TRADE_POTENTIAL_BIND_ENCHANT",
			Payload =
			{
				{ Name = "canBecomeBoundForTrade", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TradeRequest",
			Type = "Event",
			LiteralName = "TRADE_REQUEST",
			Payload =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "TradeRequestCancel",
			Type = "Event",
			LiteralName = "TRADE_REQUEST_CANCEL",
		},
		{
			Name = "TradeShow",
			Type = "Event",
			LiteralName = "TRADE_SHOW",
		},
		{
			Name = "TradeTargetItemChanged",
			Type = "Event",
			LiteralName = "TRADE_TARGET_ITEM_CHANGED",
			Payload =
			{
				{ Name = "tradeSlotIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TradeUpdate",
			Type = "Event",
			LiteralName = "TRADE_UPDATE",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(TradeInfo);