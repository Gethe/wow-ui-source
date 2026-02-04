local BlackMarketInfo =
{
	Name = "BlackMarketInfo",
	Type = "System",
	Namespace = "C_BlackMarketInfo",
	Environment = "All",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "BlackMarketBidResult",
			Type = "Event",
			LiteralName = "BLACK_MARKET_BID_RESULT",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
		{
			Name = "BlackMarketItemUpdate",
			Type = "Event",
			LiteralName = "BLACK_MARKET_ITEM_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "BlackMarketOpen",
			Type = "Event",
			LiteralName = "BLACK_MARKET_OPEN",
			SynchronousEvent = true,
		},
		{
			Name = "BlackMarketOutbid",
			Type = "Event",
			LiteralName = "BLACK_MARKET_OUTBID",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
		{
			Name = "BlackMarketWon",
			Type = "Event",
			LiteralName = "BLACK_MARKET_WON",
			SynchronousEvent = true,
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