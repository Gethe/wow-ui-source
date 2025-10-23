local WowTokenUI =
{
	Name = "WowTokenUI",
	Type = "System",
	Namespace = "C_WowTokenUI",

	Functions =
	{
		{
			Name = "StartTokenSell",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "tokenGUID", Type = "WOWGUID", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "TokenAuctionSold",
			Type = "Event",
			LiteralName = "TOKEN_AUCTION_SOLD",
			SynchronousEvent = true,
		},
		{
			Name = "TokenBuyConfirmRequired",
			Type = "Event",
			LiteralName = "TOKEN_BUY_CONFIRM_REQUIRED",
			SynchronousEvent = true,
		},
		{
			Name = "TokenBuyResult",
			Type = "Event",
			LiteralName = "TOKEN_BUY_RESULT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TokenCanVeteranBuyUpdate",
			Type = "Event",
			LiteralName = "TOKEN_CAN_VETERAN_BUY_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TokenDistributionsUpdated",
			Type = "Event",
			LiteralName = "TOKEN_DISTRIBUTIONS_UPDATED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TokenMarketPriceUpdated",
			Type = "Event",
			LiteralName = "TOKEN_MARKET_PRICE_UPDATED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TokenRedeemBalanceUpdated",
			Type = "Event",
			LiteralName = "TOKEN_REDEEM_BALANCE_UPDATED",
			SynchronousEvent = true,
		},
		{
			Name = "TokenRedeemConfirmRequired",
			Type = "Event",
			LiteralName = "TOKEN_REDEEM_CONFIRM_REQUIRED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "choiceType", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "TokenRedeemFrameShow",
			Type = "Event",
			LiteralName = "TOKEN_REDEEM_FRAME_SHOW",
			SynchronousEvent = true,
		},
		{
			Name = "TokenRedeemGameTimeUpdated",
			Type = "Event",
			LiteralName = "TOKEN_REDEEM_GAME_TIME_UPDATED",
			SynchronousEvent = true,
		},
		{
			Name = "TokenRedeemResult",
			Type = "Event",
			LiteralName = "TOKEN_REDEEM_RESULT",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
		{
			Name = "TokenSellConfirmed",
			Type = "Event",
			LiteralName = "TOKEN_SELL_CONFIRMED",
			SynchronousEvent = true,
		},
		{
			Name = "TokenSellResult",
			Type = "Event",
			LiteralName = "TOKEN_SELL_RESULT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TokenStatusChanged",
			Type = "Event",
			LiteralName = "TOKEN_STATUS_CHANGED",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(WowTokenUI);