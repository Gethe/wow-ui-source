local BlackMarketInfo =
{
	Name = "BlackMarketInfo",
	Type = "System",
	Namespace = "C_BlackMarketInfo",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "BlackMarketBidResult",
			Type = "Event",
			LiteralName = "BLACK_MARKET_BID_RESULT",
			Payload =
			{
				{ Name = "marketID", Type = "number", Nilable = false },
				{ Name = "resultCode", Type = "number", Nilable = false },
			},
		},
		{
			Name = "BlackMarketClose",
			Type = "Event",
			LiteralName = "BLACK_MARKET_CLOSE",
		},
		{
			Name = "BlackMarketItemUpdate",
			Type = "Event",
			LiteralName = "BLACK_MARKET_ITEM_UPDATE",
		},
		{
			Name = "BlackMarketOpen",
			Type = "Event",
			LiteralName = "BLACK_MARKET_OPEN",
		},
		{
			Name = "BlackMarketOutbid",
			Type = "Event",
			LiteralName = "BLACK_MARKET_OUTBID",
			Payload =
			{
				{ Name = "marketID", Type = "number", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "BlackMarketUnavailable",
			Type = "Event",
			LiteralName = "BLACK_MARKET_UNAVAILABLE",
		},
		{
			Name = "BlackMarketWon",
			Type = "Event",
			LiteralName = "BLACK_MARKET_WON",
			Payload =
			{
				{ Name = "marketID", Type = "number", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(BlackMarketInfo);