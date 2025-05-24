local AuctionHouseEnums =
{
	Tables =
	{
		{
			Name = "AuctionHouseCommoditySortOrder",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "UnitPrice", Type = "AuctionHouseCommoditySortOrder", EnumValue = 0 },
				{ Name = "Quantity", Type = "AuctionHouseCommoditySortOrder", EnumValue = 1 },
			},
		},
		{
			Name = "AuctionHouseError",
			Type = "Enumeration",
			NumValues = 27,
			MinValue = 0,
			MaxValue = 26,
			Fields =
			{
				{ Name = "NotEnoughMoney", Type = "AuctionHouseError", EnumValue = 0 },
				{ Name = "HigherBid", Type = "AuctionHouseError", EnumValue = 1 },
				{ Name = "BidIncrement", Type = "AuctionHouseError", EnumValue = 2 },
				{ Name = "BidOwn", Type = "AuctionHouseError", EnumValue = 3 },
				{ Name = "ItemNotFound", Type = "AuctionHouseError", EnumValue = 4 },
				{ Name = "RestrictedAccountTrial", Type = "AuctionHouseError", EnumValue = 5 },
				{ Name = "HasRestriction", Type = "AuctionHouseError", EnumValue = 6 },
				{ Name = "IsBusy", Type = "AuctionHouseError", EnumValue = 7 },
				{ Name = "Unavailable", Type = "AuctionHouseError", EnumValue = 8 },
				{ Name = "ItemHasQuote", Type = "AuctionHouseError", EnumValue = 9 },
				{ Name = "DatabaseError", Type = "AuctionHouseError", EnumValue = 10 },
				{ Name = "MinBid", Type = "AuctionHouseError", EnumValue = 11 },
				{ Name = "NotEnoughItems", Type = "AuctionHouseError", EnumValue = 12 },
				{ Name = "RepairItem", Type = "AuctionHouseError", EnumValue = 13 },
				{ Name = "UsedCharges", Type = "AuctionHouseError", EnumValue = 14 },
				{ Name = "QuestItem", Type = "AuctionHouseError", EnumValue = 15 },
				{ Name = "BoundItem", Type = "AuctionHouseError", EnumValue = 16 },
				{ Name = "ConjuredItem", Type = "AuctionHouseError", EnumValue = 17 },
				{ Name = "LimitedDurationItem", Type = "AuctionHouseError", EnumValue = 18 },
				{ Name = "IsBag", Type = "AuctionHouseError", EnumValue = 19 },
				{ Name = "EquippedBag", Type = "AuctionHouseError", EnumValue = 20 },
				{ Name = "WrappedItem", Type = "AuctionHouseError", EnumValue = 21 },
				{ Name = "LootItem", Type = "AuctionHouseError", EnumValue = 22 },
				{ Name = "DoubleBid", Type = "AuctionHouseError", EnumValue = 23 },
				{ Name = "FavoritesMaxed", Type = "AuctionHouseError", EnumValue = 24 },
				{ Name = "ItemNotAvailable", Type = "AuctionHouseError", EnumValue = 25 },
				{ Name = "ItemBoundToAccountUntilEquip", Type = "AuctionHouseError", EnumValue = 26 },
			},
		},
		{
			Name = "AuctionHouseExtraColumn",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "AuctionHouseExtraColumn", EnumValue = 0 },
				{ Name = "Ilvl", Type = "AuctionHouseExtraColumn", EnumValue = 1 },
				{ Name = "Slots", Type = "AuctionHouseExtraColumn", EnumValue = 2 },
				{ Name = "Level", Type = "AuctionHouseExtraColumn", EnumValue = 3 },
				{ Name = "Skill", Type = "AuctionHouseExtraColumn", EnumValue = 4 },
			},
		},
		{
			Name = "AuctionHouseFilter",
			Type = "Enumeration",
			NumValues = 14,
			MinValue = 0,
			MaxValue = 13,
			Fields =
			{
				{ Name = "None", Type = "AuctionHouseFilter", EnumValue = 0 },
				{ Name = "UncollectedOnly", Type = "AuctionHouseFilter", EnumValue = 1 },
				{ Name = "UsableOnly", Type = "AuctionHouseFilter", EnumValue = 2 },
				{ Name = "CurrentExpansionOnly", Type = "AuctionHouseFilter", EnumValue = 3 },
				{ Name = "UpgradesOnly", Type = "AuctionHouseFilter", EnumValue = 4 },
				{ Name = "ExactMatch", Type = "AuctionHouseFilter", EnumValue = 5 },
				{ Name = "PoorQuality", Type = "AuctionHouseFilter", EnumValue = 6 },
				{ Name = "CommonQuality", Type = "AuctionHouseFilter", EnumValue = 7 },
				{ Name = "UncommonQuality", Type = "AuctionHouseFilter", EnumValue = 8 },
				{ Name = "RareQuality", Type = "AuctionHouseFilter", EnumValue = 9 },
				{ Name = "EpicQuality", Type = "AuctionHouseFilter", EnumValue = 10 },
				{ Name = "LegendaryQuality", Type = "AuctionHouseFilter", EnumValue = 11 },
				{ Name = "ArtifactQuality", Type = "AuctionHouseFilter", EnumValue = 12 },
				{ Name = "LegendaryCraftedItemOnly", Type = "AuctionHouseFilter", EnumValue = 13 },
			},
		},
		{
			Name = "AuctionHouseItemSortOrder",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Bid", Type = "AuctionHouseItemSortOrder", EnumValue = 0 },
				{ Name = "Buyout", Type = "AuctionHouseItemSortOrder", EnumValue = 1 },
			},
		},
		{
			Name = "AuctionHouseNotification",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "BidPlaced", Type = "AuctionHouseNotification", EnumValue = 0 },
				{ Name = "AuctionRemoved", Type = "AuctionHouseNotification", EnumValue = 1 },
				{ Name = "AuctionWon", Type = "AuctionHouseNotification", EnumValue = 2 },
				{ Name = "AuctionOutbid", Type = "AuctionHouseNotification", EnumValue = 3 },
				{ Name = "AuctionSold", Type = "AuctionHouseNotification", EnumValue = 4 },
				{ Name = "AuctionExpired", Type = "AuctionHouseNotification", EnumValue = 5 },
			},
		},
		{
			Name = "AuctionHouseSortOrder",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Price", Type = "AuctionHouseSortOrder", EnumValue = 0 },
				{ Name = "Name", Type = "AuctionHouseSortOrder", EnumValue = 1 },
				{ Name = "Level", Type = "AuctionHouseSortOrder", EnumValue = 2 },
				{ Name = "Bid", Type = "AuctionHouseSortOrder", EnumValue = 3 },
				{ Name = "Buyout", Type = "AuctionHouseSortOrder", EnumValue = 4 },
				{ Name = "TimeRemaining", Type = "AuctionHouseSortOrder", EnumValue = 5 },
			},
		},
		{
			Name = "AuctionHouseTimeLeftBand",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Short", Type = "AuctionHouseTimeLeftBand", EnumValue = 0 },
				{ Name = "Medium", Type = "AuctionHouseTimeLeftBand", EnumValue = 1 },
				{ Name = "Long", Type = "AuctionHouseTimeLeftBand", EnumValue = 2 },
				{ Name = "VeryLong", Type = "AuctionHouseTimeLeftBand", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AuctionHouseEnums);