local AuctionHouse =
{
	Name = "AuctionHouse",
	Type = "System",
	Namespace = "C_AuctionHouse",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "AuctionBidderListUpdate",
			Type = "Event",
			LiteralName = "AUCTION_BIDDER_LIST_UPDATE",
		},
		{
			Name = "AuctionHouseClosed",
			Type = "Event",
			LiteralName = "AUCTION_HOUSE_CLOSED",
		},
		{
			Name = "AuctionHouseDisabled",
			Type = "Event",
			LiteralName = "AUCTION_HOUSE_DISABLED",
		},
		{
			Name = "AuctionHousePostError",
			Type = "Event",
			LiteralName = "AUCTION_HOUSE_POST_ERROR",
		},
		{
			Name = "AuctionHousePostWarning",
			Type = "Event",
			LiteralName = "AUCTION_HOUSE_POST_WARNING",
		},
		{
			Name = "AuctionHouseScriptDeprecated",
			Type = "Event",
			LiteralName = "AUCTION_HOUSE_SCRIPT_DEPRECATED",
		},
		{
			Name = "AuctionHouseShow",
			Type = "Event",
			LiteralName = "AUCTION_HOUSE_SHOW",
		},
		{
			Name = "AuctionItemListUpdate",
			Type = "Event",
			LiteralName = "AUCTION_ITEM_LIST_UPDATE",
		},
		{
			Name = "AuctionMultisellFailure",
			Type = "Event",
			LiteralName = "AUCTION_MULTISELL_FAILURE",
		},
		{
			Name = "AuctionMultisellStart",
			Type = "Event",
			LiteralName = "AUCTION_MULTISELL_START",
			Payload =
			{
				{ Name = "numRepetitions", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AuctionMultisellUpdate",
			Type = "Event",
			LiteralName = "AUCTION_MULTISELL_UPDATE",
			Payload =
			{
				{ Name = "createdCount", Type = "number", Nilable = false },
				{ Name = "totalToCreate", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AuctionOwnedListUpdate",
			Type = "Event",
			LiteralName = "AUCTION_OWNED_LIST_UPDATE",
		},
		{
			Name = "NewAuctionUpdate",
			Type = "Event",
			LiteralName = "NEW_AUCTION_UPDATE",
		},
	},

	Tables =
	{
		{
			Name = "ItemKey",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "itemLevel", Type = "number", Nilable = false, Default = 0 },
				{ Name = "itemSuffix", Type = "number", Nilable = false, Default = 0 },
				{ Name = "battlePetSpeciesID", Type = "number", Nilable = false, Default = 0 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AuctionHouse);