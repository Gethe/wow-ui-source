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
			Name = "AuctionHouseFilter",
			Type = "Enumeration",
			NumValues = 12,
			MinValue = 0,
			MaxValue = 11,
			Fields =
			{
				{ Name = "UncollectedOnly", Type = "AuctionHouseFilter", EnumValue = 0 },
				{ Name = "UsableOnly", Type = "AuctionHouseFilter", EnumValue = 1 },
				{ Name = "UpgradesOnly", Type = "AuctionHouseFilter", EnumValue = 2 },
				{ Name = "ExactMatch", Type = "AuctionHouseFilter", EnumValue = 3 },
				{ Name = "PoorQuality", Type = "AuctionHouseFilter", EnumValue = 4 },
				{ Name = "CommonQuality", Type = "AuctionHouseFilter", EnumValue = 5 },
				{ Name = "UncommonQuality", Type = "AuctionHouseFilter", EnumValue = 6 },
				{ Name = "RareQuality", Type = "AuctionHouseFilter", EnumValue = 7 },
				{ Name = "EpicQuality", Type = "AuctionHouseFilter", EnumValue = 8 },
				{ Name = "LegendaryQuality", Type = "AuctionHouseFilter", EnumValue = 9 },
				{ Name = "ArtifactQuality", Type = "AuctionHouseFilter", EnumValue = 10 },
				{ Name = "LegendaryCraftedItemOnly", Type = "AuctionHouseFilter", EnumValue = 11 },
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