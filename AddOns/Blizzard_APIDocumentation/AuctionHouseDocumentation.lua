local AuctionHouse =
{
	Name = "AuctionHouse",
	Type = "System",
	Namespace = "C_AuctionHouse",

	Functions =
	{
		{
			Name = "CalculateCommodityDeposit",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "depositCost", Type = "number", Nilable = true },
			},
		},
		{
			Name = "CalculateItemDeposit",
			Type = "Function",

			Arguments =
			{
				{ Name = "item", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "depositCost", Type = "number", Nilable = true },
			},
		},
		{
			Name = "CanCancelAuction",
			Type = "Function",

			Arguments =
			{
				{ Name = "ownedAuctionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canCancelAuction", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CancelAuction",
			Type = "Function",

			Arguments =
			{
				{ Name = "ownedAuctionID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CancelCommoditiesPurchase",
			Type = "Function",
		},
		{
			Name = "CancelSell",
			Type = "Function",
		},
		{
			Name = "CloseAuctionHouse",
			Type = "Function",
		},
		{
			Name = "ConfirmCommoditiesPurchase",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "FavoritesAreAvailable",
			Type = "Function",

			Returns =
			{
				{ Name = "favoritesAreAvailable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAuctionItemSubClasses",
			Type = "Function",

			Arguments =
			{
				{ Name = "classID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "subClasses", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetAvailablePostCount",
			Type = "Function",

			Arguments =
			{
				{ Name = "item", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "listCount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetBidInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "bidIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "bid", Type = "BidInfo", Nilable = true },
			},
		},
		{
			Name = "GetBidType",
			Type = "Function",

			Arguments =
			{
				{ Name = "bidTypeIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "typeItemKey", Type = "ItemKey", Nilable = true },
			},
		},
		{
			Name = "GetBrowseResults",
			Type = "Function",

			Returns =
			{
				{ Name = "browseResults", Type = "table", InnerType = "BrowseResultInfo", Nilable = false },
			},
		},
		{
			Name = "GetCancelCost",
			Type = "Function",

			Arguments =
			{
				{ Name = "ownedAuctionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "cancelCost", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCommoditySearchResultInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "commoditySearchResultIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "CommoditySearchResultInfo", Nilable = true },
			},
		},
		{
			Name = "GetCommoditySearchResultsQuantity",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "totalQuantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetExtraBrowseInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
			},

			Returns =
			{
				{ Name = "extraInfo", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFilterGroups",
			Type = "Function",

			Returns =
			{
				{ Name = "filterGroups", Type = "table", InnerType = "AuctionHouseFilterGroup", Nilable = false },
			},
		},
		{
			Name = "GetItemCommodityStatus",
			Type = "Function",

			Arguments =
			{
				{ Name = "item", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isCommodity", Type = "ItemCommodityStatus", Nilable = false },
			},
		},
		{
			Name = "GetItemKeyFromItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "item", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
			},
		},
		{
			Name = "GetItemKeyInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
				{ Name = "restrictQualityToFilter", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "itemKeyInfo", Type = "ItemKeyInfo", Nilable = true },
			},
		},
		{
			Name = "GetItemKeyRequiredLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
			},

			Returns =
			{
				{ Name = "requiredLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetItemSearchResultInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
				{ Name = "itemSearchResultIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "ItemSearchResultInfo", Nilable = true },
			},
		},
		{
			Name = "GetItemSearchResultsQuantity",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
			},

			Returns =
			{
				{ Name = "totalQuantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMaxBidItemBid",
			Type = "Function",

			Returns =
			{
				{ Name = "maxBid", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetMaxBidItemBuyout",
			Type = "Function",

			Returns =
			{
				{ Name = "maxBuyout", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetMaxCommoditySearchResultPrice",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "maxUnitPrice", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetMaxItemSearchResultBid",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
			},

			Returns =
			{
				{ Name = "maxBid", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetMaxItemSearchResultBuyout",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
			},

			Returns =
			{
				{ Name = "maxBuyout", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetMaxOwnedAuctionBid",
			Type = "Function",

			Returns =
			{
				{ Name = "maxBid", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetMaxOwnedAuctionBuyout",
			Type = "Function",

			Returns =
			{
				{ Name = "maxBuyout", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetNumBidTypes",
			Type = "Function",

			Returns =
			{
				{ Name = "numBidTypes", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumBids",
			Type = "Function",

			Returns =
			{
				{ Name = "numBids", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumCommoditySearchResults",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "numSearchResults", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumItemSearchResults",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
			},

			Returns =
			{
				{ Name = "numItemSearchResults", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumOwnedAuctionTypes",
			Type = "Function",

			Returns =
			{
				{ Name = "numOwnedAuctionTypes", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumOwnedAuctions",
			Type = "Function",

			Returns =
			{
				{ Name = "numOwnedAuctions", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumReplicateItems",
			Type = "Function",

			Returns =
			{
				{ Name = "numReplicateItems", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetOwnedAuctionInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "ownedAuctionIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "ownedAuction", Type = "OwnedAuctionInfo", Nilable = true },
			},
		},
		{
			Name = "GetOwnedAuctionType",
			Type = "Function",

			Arguments =
			{
				{ Name = "ownedAuctionTypeIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "typeItemKey", Type = "ItemKey", Nilable = true },
			},
		},
		{
			Name = "GetQuoteDurationRemaining",
			Type = "Function",

			Returns =
			{
				{ Name = "quoteDurationSeconds", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetReplicateItemBattlePetInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "creatureID", Type = "number", Nilable = false },
				{ Name = "displayID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetReplicateItemInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "texture", Type = "number", Nilable = true },
				{ Name = "count", Type = "number", Nilable = false },
				{ Name = "qualityID", Type = "number", Nilable = false },
				{ Name = "usable", Type = "bool", Nilable = true },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "levelType", Type = "string", Nilable = true },
				{ Name = "minBid", Type = "number", Nilable = false },
				{ Name = "minIncrement", Type = "number", Nilable = false },
				{ Name = "buyoutPrice", Type = "number", Nilable = false },
				{ Name = "bidAmount", Type = "number", Nilable = false },
				{ Name = "highBidder", Type = "string", Nilable = true },
				{ Name = "bidderFullName", Type = "string", Nilable = true },
				{ Name = "owner", Type = "string", Nilable = true },
				{ Name = "ownerFullName", Type = "string", Nilable = true },
				{ Name = "saleStatus", Type = "number", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "hasAllInfo", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "GetReplicateItemLink",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemLink", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetReplicateItemTimeLeft",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "timeLeft", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTimeLeftBandInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "timeLeftBand", Type = "AuctionHouseTimeLeftBand", Nilable = false },
			},

			Returns =
			{
				{ Name = "timeLeftMinSeconds", Type = "number", Nilable = false },
				{ Name = "timeLeftMaxSeconds", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HasFavorites",
			Type = "Function",

			Returns =
			{
				{ Name = "hasFavorites", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasFullBidResults",
			Type = "Function",

			Returns =
			{
				{ Name = "hasFullBidResults", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasFullBrowseResults",
			Type = "Function",

			Returns =
			{
				{ Name = "hasFullBrowseResults", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasFullCommoditySearchResults",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasFullResults", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasFullItemSearchResults",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasFullResults", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasFullOwnedAuctionResults",
			Type = "Function",

			Returns =
			{
				{ Name = "hasFullOwnedAuctionResults", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasMaxFavorites",
			Type = "Function",

			Returns =
			{
				{ Name = "hasMaxFavorites", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasSearchResults",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasSearchResults", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsFavoriteItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
			},

			Returns =
			{
				{ Name = "isFavorite", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSellItemValid",
			Type = "Function",

			Arguments =
			{
				{ Name = "item", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "displayError", Type = "bool", Nilable = false, Default = true },
			},

			Returns =
			{
				{ Name = "valid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsThrottledMessageSystemReady",
			Type = "Function",

			Returns =
			{
				{ Name = "canSendThrottledMessage", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "MakeItemKey",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "itemLevel", Type = "number", Nilable = false, Default = 0 },
				{ Name = "itemSuffix", Type = "number", Nilable = false, Default = 0 },
				{ Name = "battlePetSpeciesID", Type = "number", Nilable = false, Default = 0 },
			},

			Returns =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
			},
		},
		{
			Name = "PlaceBid",
			Type = "Function",

			Arguments =
			{
				{ Name = "auctionID", Type = "number", Nilable = false },
				{ Name = "bidAmount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PostCommodity",
			Type = "Function",

			Arguments =
			{
				{ Name = "item", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "unitPrice", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PostItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "item", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "bid", Type = "number", Nilable = true },
				{ Name = "buyout", Type = "number", Nilable = true },
			},
		},
		{
			Name = "QueryBids",
			Type = "Function",

			Arguments =
			{
				{ Name = "sorts", Type = "table", InnerType = "AuctionHouseSortType", Nilable = false },
				{ Name = "auctionIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "QueryOwnedAuctions",
			Type = "Function",

			Arguments =
			{
				{ Name = "sorts", Type = "table", InnerType = "AuctionHouseSortType", Nilable = false },
			},
		},
		{
			Name = "RefreshCommoditySearchResults",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RefreshItemSearchResults",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
				{ Name = "minLevelFilter", Type = "number", Nilable = true },
				{ Name = "maxLevelFilter", Type = "number", Nilable = true },
			},
		},
		{
			Name = "ReplicateItems",
			Type = "Function",
			Documentation = { "This function should be used in place of an 'allItem' QueryAuctionItems call to query the entire auction house." },
		},
		{
			Name = "RequestMoreBrowseResults",
			Type = "Function",
		},
		{
			Name = "RequestMoreCommoditySearchResults",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasFullResults", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestMoreItemSearchResults",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasFullResults", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestOwnedAuctionBidderInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "auctionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "bidderName", Type = "string", Nilable = true },
			},
		},
		{
			Name = "SearchForFavorites",
			Type = "Function",

			Arguments =
			{
				{ Name = "sorts", Type = "table", InnerType = "AuctionHouseSortType", Nilable = false },
			},
		},
		{
			Name = "SearchForItemKeys",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemKeys", Type = "table", InnerType = "ItemKey", Nilable = false },
				{ Name = "sorts", Type = "table", InnerType = "AuctionHouseSortType", Nilable = false },
			},
		},
		{
			Name = "SendBrowseQuery",
			Type = "Function",

			Arguments =
			{
				{ Name = "query", Type = "AuctionHouseBrowseQuery", Nilable = false },
			},
		},
		{
			Name = "SendSearchQuery",
			Type = "Function",
			Documentation = { "Search queries are restricted to 100 calls per minute. These should not be used to query the entire auction house. See ReplicateItems" },

			Arguments =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
				{ Name = "sorts", Type = "table", InnerType = "AuctionHouseSortType", Nilable = false },
				{ Name = "separateOwnerItems", Type = "bool", Nilable = false },
				{ Name = "minLevelFilter", Type = "number", Nilable = false, Default = 0 },
				{ Name = "maxLevelFilter", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "SendSellSearchQuery",
			Type = "Function",
			Documentation = { "Search queries are restricted to 100 calls per minute. These should not be used to query the entire auction house. See ReplicateItems" },

			Arguments =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
				{ Name = "sorts", Type = "table", InnerType = "AuctionHouseSortType", Nilable = false },
				{ Name = "separateOwnerItems", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetFavoriteItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
				{ Name = "setFavorite", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "StartCommoditiesPurchase",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AuctionCanceled",
			Type = "Event",
			LiteralName = "AUCTION_CANCELED",
			Payload =
			{
				{ Name = "auctionID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AuctionHouseAuctionCreated",
			Type = "Event",
			LiteralName = "AUCTION_HOUSE_AUCTION_CREATED",
			Documentation = { "This signal is not used in the base UI but is included for AddOn ease-of-use." },
			Payload =
			{
				{ Name = "auctionID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AuctionHouseBrowseFailure",
			Type = "Event",
			LiteralName = "AUCTION_HOUSE_BROWSE_FAILURE",
		},
		{
			Name = "AuctionHouseBrowseResultsAdded",
			Type = "Event",
			LiteralName = "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
			Payload =
			{
				{ Name = "addedBrowseResults", Type = "table", InnerType = "BrowseResultInfo", Nilable = false },
			},
		},
		{
			Name = "AuctionHouseBrowseResultsUpdated",
			Type = "Event",
			LiteralName = "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
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
			Name = "AuctionHouseFavoritesUpdated",
			Type = "Event",
			LiteralName = "AUCTION_HOUSE_FAVORITES_UPDATED",
		},
		{
			Name = "AuctionHouseNewBidReceived",
			Type = "Event",
			LiteralName = "AUCTION_HOUSE_NEW_BID_RECEIVED",
			Payload =
			{
				{ Name = "auctionID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AuctionHouseNewResultsReceived",
			Type = "Event",
			LiteralName = "AUCTION_HOUSE_NEW_RESULTS_RECEIVED",
			Documentation = { "This signal is not used in the base UI but is included for AddOn ease-of-use. Payload is nil for browse queries." },
			Payload =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = true },
			},
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
			Name = "AuctionHouseThrottledMessageDropped",
			Type = "Event",
			LiteralName = "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED",
		},
		{
			Name = "AuctionHouseThrottledMessageQueued",
			Type = "Event",
			LiteralName = "AUCTION_HOUSE_THROTTLED_MESSAGE_QUEUED",
		},
		{
			Name = "AuctionHouseThrottledMessageResponseReceived",
			Type = "Event",
			LiteralName = "AUCTION_HOUSE_THROTTLED_MESSAGE_RESPONSE_RECEIVED",
		},
		{
			Name = "AuctionHouseThrottledMessageSent",
			Type = "Event",
			LiteralName = "AUCTION_HOUSE_THROTTLED_MESSAGE_SENT",
		},
		{
			Name = "AuctionHouseThrottledSystemReady",
			Type = "Event",
			LiteralName = "AUCTION_HOUSE_THROTTLED_SYSTEM_READY",
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
			Name = "BidAdded",
			Type = "Event",
			LiteralName = "BID_ADDED",
			Payload =
			{
				{ Name = "bidID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "BidsUpdated",
			Type = "Event",
			LiteralName = "BIDS_UPDATED",
		},
		{
			Name = "CommodityPriceUnavailable",
			Type = "Event",
			LiteralName = "COMMODITY_PRICE_UNAVAILABLE",
		},
		{
			Name = "CommodityPriceUpdated",
			Type = "Event",
			LiteralName = "COMMODITY_PRICE_UPDATED",
			Payload =
			{
				{ Name = "updatedUnitPrice", Type = "number", Nilable = false },
				{ Name = "updatedTotalPrice", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CommodityPurchaseFailed",
			Type = "Event",
			LiteralName = "COMMODITY_PURCHASE_FAILED",
		},
		{
			Name = "CommodityPurchaseSucceeded",
			Type = "Event",
			LiteralName = "COMMODITY_PURCHASE_SUCCEEDED",
		},
		{
			Name = "CommodityPurchased",
			Type = "Event",
			LiteralName = "COMMODITY_PURCHASED",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CommoditySearchResultsAdded",
			Type = "Event",
			LiteralName = "COMMODITY_SEARCH_RESULTS_ADDED",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CommoditySearchResultsUpdated",
			Type = "Event",
			LiteralName = "COMMODITY_SEARCH_RESULTS_UPDATED",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ExtraBrowseInfoReceived",
			Type = "Event",
			LiteralName = "EXTRA_BROWSE_INFO_RECEIVED",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ItemKeyItemInfoReceived",
			Type = "Event",
			LiteralName = "ITEM_KEY_ITEM_INFO_RECEIVED",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ItemPurchased",
			Type = "Event",
			LiteralName = "ITEM_PURCHASED",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ItemSearchResultsAdded",
			Type = "Event",
			LiteralName = "ITEM_SEARCH_RESULTS_ADDED",
			Payload =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
			},
		},
		{
			Name = "ItemSearchResultsUpdated",
			Type = "Event",
			LiteralName = "ITEM_SEARCH_RESULTS_UPDATED",
			Payload =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
				{ Name = "newAuctionID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "OwnedAuctionBidderInfoReceived",
			Type = "Event",
			LiteralName = "OWNED_AUCTION_BIDDER_INFO_RECEIVED",
			Payload =
			{
				{ Name = "auctionID", Type = "number", Nilable = false },
				{ Name = "bidderName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "OwnedAuctionsUpdated",
			Type = "Event",
			LiteralName = "OWNED_AUCTIONS_UPDATED",
		},
		{
			Name = "ReplicateItemListUpdate",
			Type = "Event",
			LiteralName = "REPLICATE_ITEM_LIST_UPDATE",
		},
	},

	Tables =
	{
		{
			Name = "AuctionHouseFilterCategory",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Uncategorized", Type = "AuctionHouseFilterCategory", EnumValue = 0 },
				{ Name = "Equipment", Type = "AuctionHouseFilterCategory", EnumValue = 1 },
				{ Name = "Rarity", Type = "AuctionHouseFilterCategory", EnumValue = 2 },
			},
		},
		{
			Name = "AuctionStatus",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Active", Type = "AuctionStatus", EnumValue = 0 },
				{ Name = "Sold", Type = "AuctionStatus", EnumValue = 1 },
			},
		},
		{
			Name = "ItemCommodityStatus",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Unknown", Type = "ItemCommodityStatus", EnumValue = 0 },
				{ Name = "Item", Type = "ItemCommodityStatus", EnumValue = 1 },
				{ Name = "Commodity", Type = "ItemCommodityStatus", EnumValue = 2 },
			},
		},
		{
			Name = "AuctionHouseBrowseQuery",
			Type = "Structure",
			Fields =
			{
				{ Name = "searchString", Type = "string", Nilable = false },
				{ Name = "sorts", Type = "table", InnerType = "AuctionHouseSortType", Nilable = false },
				{ Name = "minLevel", Type = "number", Nilable = true },
				{ Name = "maxLevel", Type = "number", Nilable = true },
				{ Name = "filters", Type = "table", InnerType = "AuctionHouseFilter", Nilable = true },
				{ Name = "itemClassFilters", Type = "table", InnerType = "AuctionHouseItemClassFilter", Nilable = true },
			},
		},
		{
			Name = "AuctionHouseFilterGroup",
			Type = "Structure",
			Fields =
			{
				{ Name = "category", Type = "AuctionHouseFilterCategory", Nilable = false },
				{ Name = "filters", Type = "table", InnerType = "AuctionHouseFilter", Nilable = false },
			},
		},
		{
			Name = "AuctionHouseItemClassFilter",
			Type = "Structure",
			Fields =
			{
				{ Name = "classID", Type = "number", Nilable = false },
				{ Name = "subClassID", Type = "number", Nilable = true },
				{ Name = "inventoryType", Type = "number", Nilable = true },
			},
		},
		{
			Name = "AuctionHouseSortType",
			Type = "Structure",
			Fields =
			{
				{ Name = "sortOrder", Type = "AuctionHouseSortOrder", Nilable = false },
				{ Name = "reverseSort", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "BidInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "auctionID", Type = "number", Nilable = false },
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
				{ Name = "itemLink", Type = "string", Nilable = true },
				{ Name = "timeLeft", Type = "AuctionHouseTimeLeftBand", Nilable = false },
				{ Name = "minBid", Type = "number", Nilable = true },
				{ Name = "bidAmount", Type = "number", Nilable = true },
				{ Name = "buyoutAmount", Type = "number", Nilable = true },
				{ Name = "bidder", Type = "string", Nilable = true },
			},
		},
		{
			Name = "BrowseResultInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
				{ Name = "appearanceLink", Type = "string", Nilable = true },
				{ Name = "totalQuantity", Type = "number", Nilable = false },
				{ Name = "minPrice", Type = "number", Nilable = false },
				{ Name = "containsOwnerItem", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CommoditySearchResultInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "unitPrice", Type = "number", Nilable = false },
				{ Name = "auctionID", Type = "number", Nilable = false },
				{ Name = "owners", Type = "table", InnerType = "string", Nilable = false },
				{ Name = "totalNumberOfOwners", Type = "number", Nilable = false },
				{ Name = "timeLeftSeconds", Type = "number", Nilable = true },
				{ Name = "numOwnerItems", Type = "number", Nilable = false },
				{ Name = "containsOwnerItem", Type = "bool", Nilable = false },
				{ Name = "containsAccountItem", Type = "bool", Nilable = false },
			},
		},
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
		{
			Name = "ItemKeyInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemName", Type = "string", Nilable = false },
				{ Name = "battlePetLink", Type = "string", Nilable = true },
				{ Name = "appearanceLink", Type = "string", Nilable = true },
				{ Name = "quality", Type = "number", Nilable = false },
				{ Name = "iconFileID", Type = "number", Nilable = false },
				{ Name = "isPet", Type = "bool", Nilable = false },
				{ Name = "isCommodity", Type = "bool", Nilable = false },
				{ Name = "isEquipment", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ItemSearchResultInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
				{ Name = "owners", Type = "table", InnerType = "string", Nilable = false },
				{ Name = "totalNumberOfOwners", Type = "number", Nilable = false },
				{ Name = "timeLeft", Type = "AuctionHouseTimeLeftBand", Nilable = false },
				{ Name = "auctionID", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "itemLink", Type = "string", Nilable = true },
				{ Name = "containsOwnerItem", Type = "bool", Nilable = false },
				{ Name = "containsAccountItem", Type = "bool", Nilable = false },
				{ Name = "containsSocketedItem", Type = "bool", Nilable = false },
				{ Name = "bidder", Type = "string", Nilable = true },
				{ Name = "minBid", Type = "number", Nilable = true },
				{ Name = "bidAmount", Type = "number", Nilable = true },
				{ Name = "buyoutAmount", Type = "number", Nilable = true },
				{ Name = "timeLeftSeconds", Type = "number", Nilable = true },
			},
		},
		{
			Name = "OwnedAuctionInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "auctionID", Type = "number", Nilable = false },
				{ Name = "itemKey", Type = "ItemKey", Nilable = false },
				{ Name = "itemLink", Type = "string", Nilable = true },
				{ Name = "status", Type = "AuctionStatus", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "timeLeftSeconds", Type = "number", Nilable = true },
				{ Name = "timeLeft", Type = "AuctionHouseTimeLeftBand", Nilable = true },
				{ Name = "bidAmount", Type = "number", Nilable = true },
				{ Name = "buyoutAmount", Type = "number", Nilable = true },
				{ Name = "bidder", Type = "string", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AuctionHouse);