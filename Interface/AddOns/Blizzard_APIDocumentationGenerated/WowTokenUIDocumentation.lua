local WowTokenUI =
{
	Name = "WowTokenUI",
	Type = "System",
	Namespace = "C_WowTokenUI",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "TokenAuctionSold",
			Type = "Event",
			LiteralName = "TOKEN_AUCTION_SOLD",
		},
		{
			Name = "TokenBuyConfirmRequired",
			Type = "Event",
			LiteralName = "TOKEN_BUY_CONFIRM_REQUIRED",
		},
		{
			Name = "TokenBuyResult",
			Type = "Event",
			LiteralName = "TOKEN_BUY_RESULT",
			Payload =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TokenCanVeteranBuyUpdate",
			Type = "Event",
			LiteralName = "TOKEN_CAN_VETERAN_BUY_UPDATE",
			Payload =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TokenDistributionsUpdated",
			Type = "Event",
			LiteralName = "TOKEN_DISTRIBUTIONS_UPDATED",
			Payload =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TokenMarketPriceUpdated",
			Type = "Event",
			LiteralName = "TOKEN_MARKET_PRICE_UPDATED",
			Payload =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TokenRedeemBalanceUpdated",
			Type = "Event",
			LiteralName = "TOKEN_REDEEM_BALANCE_UPDATED",
		},
		{
			Name = "TokenRedeemConfirmRequired",
			Type = "Event",
			LiteralName = "TOKEN_REDEEM_CONFIRM_REQUIRED",
			Payload =
			{
				{ Name = "choiceType", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "TokenRedeemFrameShow",
			Type = "Event",
			LiteralName = "TOKEN_REDEEM_FRAME_SHOW",
		},
		{
			Name = "TokenRedeemGameTimeUpdated",
			Type = "Event",
			LiteralName = "TOKEN_REDEEM_GAME_TIME_UPDATED",
		},
		{
			Name = "TokenRedeemResult",
			Type = "Event",
			LiteralName = "TOKEN_REDEEM_RESULT",
			Payload =
			{
				{ Name = "result", Type = "luaIndex", Nilable = false },
				{ Name = "choiceType", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "TokenSellConfirmRequired",
			Type = "Event",
			LiteralName = "TOKEN_SELL_CONFIRM_REQUIRED",
		},
		{
			Name = "TokenSellResult",
			Type = "Event",
			LiteralName = "TOKEN_SELL_RESULT",
			Payload =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TokenStatusChanged",
			Type = "Event",
			LiteralName = "TOKEN_STATUS_CHANGED",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(WowTokenUI);