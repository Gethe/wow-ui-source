local HousingUI =
{
	Name = "HousingUI",
	Type = "System",
	Namespace = "C_Housing",

	Functions =
	{
		{
			Name = "AcceptNeighborhoodOwnership",
			Type = "Function",
		},
		{
			Name = "DeclineNeighborhoodOwnership",
			Type = "Function",
		},
		{
			Name = "GetCurrentHouseLevelFavor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "houseGuid", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "GetHouseLevelFavorForLevel",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "level", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "houseFavor", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetHouseLevelRewardsForLevel",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "level", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetHousingAccessFlags",
			Type = "Function",

			Returns =
			{
				{ Name = "accessFlags", Type = "HouseSettingFlags", Nilable = false },
			},
		},
		{
			Name = "GetMaxHouseLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "level", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNeighborhoodTextureSuffix",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "neighborhoodGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "neighborhoodTextureSuffix", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetOthersOwnedHouses",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "playerGUID", Type = "WOWGUID", Nilable = true },
				{ Name = "bnetID", Type = "number", Nilable = true },
				{ Name = "isInPlayersGuild", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetPlayerOwnedHouses",
			Type = "Function",
		},
		{
			Name = "GetTrackedHouseGuid",
			Type = "Function",

			Returns =
			{
				{ Name = "trackedHouse", Type = "WOWGUID", Nilable = true },
			},
		},
		{
			Name = "GetUIMapIDForNeighborhood",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "neighborhoodGuid", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "uiMapID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "HasHousingExpansionAccess",
			Type = "Function",

			Returns =
			{
				{ Name = "hasAccess", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HouseFinderRequestNeighborhoods",
			Type = "Function",
		},
		{
			Name = "HouseFinderRequestReservationAndPort",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "neighborhoodGuid", Type = "WOWGUID", Nilable = false },
				{ Name = "plotID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsHousingMarketEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isHousingMarketEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsHousingServiceEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isAvailable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsInsideHouse",
			Type = "Function",

			Returns =
			{
				{ Name = "isInside", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsInsideHouseOrPlot",
			Type = "Function",

			Returns =
			{
				{ Name = "isInside", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsInsidePlot",
			Type = "Function",

			Returns =
			{
				{ Name = "isInside", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsOnNeighborhoodMap",
			Type = "Function",

			Returns =
			{
				{ Name = "isOnNeighborhoodMap", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RelinquishHouse",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "houseGuid", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "RequestCurrentHouseInfo",
			Type = "Function",
		},
		{
			Name = "RequestHouseFinderNeighborhoodData",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "neighborhoodGuid", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "RequestPlayerCharacterList",
			Type = "Function",
		},
		{
			Name = "SaveHouseSettings",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "playerGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "accessFlags", Type = "HouseSettingFlags", Nilable = false },
			},
		},
		{
			Name = "SearchBNetFriendNeighborhoods",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "bnetName", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "isValidBnetFriend", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SearchBNetFriendNeighborhoodsByID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "bnetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isValidBnetFriend", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetTrackedHouseGuid",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "trackedHouse", Type = "WOWGUID", Nilable = true },
			},
		},
		{
			Name = "StartTutorial",
			Type = "Function",
		},
		{
			Name = "ValidateReportScreenshot",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "plotIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isValid", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "BNetNeighborhoodListUpdated",
			Type = "Event",
			LiteralName = "B_NET_NEIGHBORHOOD_LIST_UPDATED",
			Payload =
			{
				{ Name = "result", Type = "HousingResult", Nilable = false },
				{ Name = "neighborhoodInfos", Type = "table", InnerType = "NeighborhoodInfo", Nilable = true },
			},
		},
		{
			Name = "CurrentHouseInfoRecieved",
			Type = "Event",
			LiteralName = "CURRENT_HOUSE_INFO_RECIEVED",
			Payload =
			{
				{ Name = "houseInfo", Type = "HouseInfo", Nilable = false },
			},
		},
		{
			Name = "CurrentHouseInfoUpdated",
			Type = "Event",
			LiteralName = "CURRENT_HOUSE_INFO_UPDATED",
			Payload =
			{
				{ Name = "houseInfo", Type = "HouseInfo", Nilable = false },
			},
		},
		{
			Name = "HouseFinderNeighborhoodDataRecieved",
			Type = "Event",
			LiteralName = "HOUSE_FINDER_NEIGHBORHOOD_DATA_RECIEVED",
			Payload =
			{
				{ Name = "neighborhoodPlots", Type = "table", InnerType = "NeighborhoodPlotMapInfo", Nilable = false },
			},
		},
		{
			Name = "HouseInfoUpdated",
			Type = "Event",
			LiteralName = "HOUSE_INFO_UPDATED",
		},
		{
			Name = "HouseLevelFavorUpdated",
			Type = "Event",
			LiteralName = "HOUSE_LEVEL_FAVOR_UPDATED",
			Payload =
			{
				{ Name = "houseLevelFavor", Type = "HouseLevelFavor", Nilable = false },
			},
		},
		{
			Name = "HousePlotEntered",
			Type = "Event",
			LiteralName = "HOUSE_PLOT_ENTERED",
		},
		{
			Name = "HousePlotExited",
			Type = "Event",
			LiteralName = "HOUSE_PLOT_EXITED",
		},
		{
			Name = "HouseReservationResponseRecieved",
			Type = "Event",
			LiteralName = "HOUSE_RESERVATION_RESPONSE_RECIEVED",
			Payload =
			{
				{ Name = "result", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HousingMarketAvailabilityUpdated",
			Type = "Event",
			LiteralName = "HOUSING_MARKET_AVAILABILITY_UPDATED",
		},
		{
			Name = "HousingServicesAvailabilityUpdated",
			Type = "Event",
			LiteralName = "HOUSING_SERVICES_AVAILABILITY_UPDATED",
		},
		{
			Name = "MoveOutReservationUpdated",
			Type = "Event",
			LiteralName = "MOVE_OUT_RESERVATION_UPDATED",
		},
		{
			Name = "NeighborhoodListUpdated",
			Type = "Event",
			LiteralName = "NEIGHBORHOOD_LIST_UPDATED",
			Payload =
			{
				{ Name = "result", Type = "HousingResult", Nilable = false },
				{ Name = "neighborhoodInfos", Type = "table", InnerType = "NeighborhoodInfo", Nilable = true },
			},
		},
		{
			Name = "NewHousingItemAcquired",
			Type = "Event",
			LiteralName = "NEW_HOUSING_ITEM_ACQUIRED",
			Payload =
			{
				{ Name = "itemType", Type = "HousingItemToastType", Nilable = false },
				{ Name = "itemName", Type = "cstring", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = true },
			},
		},
		{
			Name = "PlayerCharacterListUpdated",
			Type = "Event",
			LiteralName = "PLAYER_CHARACTER_LIST_UPDATED",
			Payload =
			{
				{ Name = "characterInfos", Type = "table", InnerType = "HouseOwnerCharacterInfo", Nilable = false },
				{ Name = "ownerListIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PlayerHouseListUpdated",
			Type = "Event",
			LiteralName = "PLAYER_HOUSE_LIST_UPDATED",
			Payload =
			{
				{ Name = "houseInfos", Type = "table", InnerType = "HouseInfo", Nilable = false },
			},
		},
		{
			Name = "ReceivedHouseLevelRewards",
			Type = "Event",
			LiteralName = "RECEIVED_HOUSE_LEVEL_REWARDS",
			Payload =
			{
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "rewards", Type = "table", InnerType = "HouseLevelReward", Nilable = false },
			},
		},
		{
			Name = "ShowNeighborhoodOwnershipTransferDialog",
			Type = "Event",
			LiteralName = "SHOW_NEIGHBORHOOD_OWNERSHIP_TRANSFER_DIALOG",
			Payload =
			{
				{ Name = "neighborhoodName", Type = "cstring", Nilable = false },
				{ Name = "cosmeticOwnerName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "TrackedHouseChanged",
			Type = "Event",
			LiteralName = "TRACKED_HOUSE_CHANGED",
			Payload =
			{
				{ Name = "trackedHouse", Type = "WOWGUID", Nilable = true },
			},
		},
		{
			Name = "ViewHousesListRecieved",
			Type = "Event",
			LiteralName = "VIEW_HOUSES_LIST_RECIEVED",
			Payload =
			{
				{ Name = "houseInfos", Type = "table", InnerType = "HouseInfo", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "HousingItemToastType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Room", Type = "HousingItemToastType", EnumValue = 0 },
				{ Name = "Fixture", Type = "HousingItemToastType", EnumValue = 1 },
				{ Name = "Customization", Type = "HousingItemToastType", EnumValue = 2 },
				{ Name = "Decor", Type = "HousingItemToastType", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(HousingUI);