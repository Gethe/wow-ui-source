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
			Name = "CanEditCharter",
			Type = "Function",

			Returns =
			{
				{ Name = "canEditCharter", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanTakeReportScreenshot",
			Type = "Function",

			Arguments =
			{
				{ Name = "plotIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "reason", Type = "InvalidPlotScreenshotReason", Nilable = false },
			},
		},
		{
			Name = "CreateGuildNeighborhood",
			Type = "Function",

			Arguments =
			{
				{ Name = "neighborhoodName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "CreateNeighborhoodCharter",
			Type = "Function",

			Arguments =
			{
				{ Name = "neighborhoodName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "DeclineNeighborhoodOwnership",
			Type = "Function",
		},
		{
			Name = "DoesFactionMatchNeighborhood",
			Type = "Function",

			Arguments =
			{
				{ Name = "neighborhoodGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "factionMatches", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "EditNeighborhoodCharter",
			Type = "Function",

			Arguments =
			{
				{ Name = "neighborhoodName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetCurrentHouseInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "houseInfo", Type = "HouseInfo", Nilable = true },
			},
		},
		{
			Name = "GetCurrentHouseLevelFavor",
			Type = "Function",

			Arguments =
			{
				{ Name = "houseGuid", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "GetCurrentHouseRefundAmount",
			Type = "Function",

			Returns =
			{
				{ Name = "refundAmount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCurrentNeighborhoodGUID",
			Type = "Function",

			Returns =
			{
				{ Name = "neighborhoodGUID", Type = "WOWGUID", Nilable = true },
			},
		},
		{
			Name = "GetHouseLevelFavorForLevel",
			Type = "Function",

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
			Name = "GetVisitCooldownInfo",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "spellCooldownInfo", Type = "SpellCooldownInfo", Nilable = false },
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
			Name = "HouseFinderDeclineNeighborhoodInvitation",
			Type = "Function",
		},
		{
			Name = "HouseFinderRequestNeighborhoods",
			Type = "Function",
		},
		{
			Name = "HouseFinderRequestReservationAndPort",
			Type = "Function",

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
			Name = "IsInsideOwnHouse",
			Type = "Function",

			Returns =
			{
				{ Name = "isInsideOwnHouse", Type = "bool", Nilable = false },
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
			Name = "LeaveHouse",
			Type = "Function",
		},
		{
			Name = "OnCharterConfirmationAccepted",
			Type = "Function",
		},
		{
			Name = "OnCharterConfirmationClosed",
			Type = "Function",
		},
		{
			Name = "OnCreateCharterNeighborhoodClosed",
			Type = "Function",
		},
		{
			Name = "OnCreateGuildNeighborhoodClosed",
			Type = "Function",
		},
		{
			Name = "OnRequestSignatureClicked",
			Type = "Function",
		},
		{
			Name = "OnSignCharterClicked",
			Type = "Function",

			Arguments =
			{
				{ Name = "charterOwnerGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "RelinquishHouse",
			Type = "Function",

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
			Name = "ReturnAfterVisitingHouse",
			Type = "Function",
		},
		{
			Name = "SaveHouseSettings",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "accessFlags", Type = "HouseSettingFlags", Nilable = false },
			},
		},
		{
			Name = "SearchBNetFriendNeighborhoods",
			Type = "Function",

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
			Name = "TeleportHome",
			Type = "Function",

			Arguments =
			{
				{ Name = "neighborhoodGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "houseGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "plotID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TryRenameNeighborhood",
			Type = "Function",

			Arguments =
			{
				{ Name = "neighborhoodName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ValidateCreateGuildNeighborhoodSize",
			Type = "Function",
		},
		{
			Name = "ValidateNeighborhoodName",
			Type = "Function",

			Arguments =
			{
				{ Name = "neighborhoodName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "VisitHouse",
			Type = "Function",

			Arguments =
			{
				{ Name = "neighborhoodGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "houseGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "plotID", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AddNeighborhoodCharterSignature",
			Type = "Event",
			LiteralName = "ADD_NEIGHBORHOOD_CHARTER_SIGNATURE",
			Payload =
			{
				{ Name = "signature", Type = "cstring", Nilable = false },
			},
		},
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
			Name = "CloseCharterConfirmationUI",
			Type = "Event",
			LiteralName = "CLOSE_CHARTER_CONFIRMATION_UI",
		},
		{
			Name = "CloseCreateCharterNeighborhoodUI",
			Type = "Event",
			LiteralName = "CLOSE_CREATE_CHARTER_NEIGHBORHOOD_UI",
		},
		{
			Name = "CloseCreateGuildNeighborhoodUI",
			Type = "Event",
			LiteralName = "CLOSE_CREATE_GUILD_NEIGHBORHOOD_UI",
		},
		{
			Name = "CreateNeighborhoodResult",
			Type = "Event",
			LiteralName = "CREATE_NEIGHBORHOOD_RESULT",
			Payload =
			{
				{ Name = "result", Type = "HousingResult", Nilable = false },
				{ Name = "neighborhoodName", Type = "cstring", Nilable = true },
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
			Name = "DeclineNeighborhoodInvitationResponse",
			Type = "Event",
			LiteralName = "DECLINE_NEIGHBORHOOD_INVITATION_RESPONSE",
			Payload =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ForceRefreshHouseFinder",
			Type = "Event",
			LiteralName = "FORCE_REFRESH_HOUSE_FINDER",
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
			Name = "NeighborhoodGuildSizeValidated",
			Type = "Event",
			LiteralName = "NEIGHBORHOOD_GUILD_SIZE_VALIDATED",
			Payload =
			{
				{ Name = "approved", Type = "bool", Nilable = false },
			},
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
			Name = "NeighborhoodNameValidated",
			Type = "Event",
			LiteralName = "NEIGHBORHOOD_NAME_VALIDATED",
			Payload =
			{
				{ Name = "approved", Type = "bool", Nilable = false },
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
			Name = "OpenCharterConfirmationUI",
			Type = "Event",
			LiteralName = "OPEN_CHARTER_CONFIRMATION_UI",
			Payload =
			{
				{ Name = "neighborhoodName", Type = "string", Nilable = false },
				{ Name = "locationName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "OpenCreateCharterNeighborhoodUI",
			Type = "Event",
			LiteralName = "OPEN_CREATE_CHARTER_NEIGHBORHOOD_UI",
			Payload =
			{
				{ Name = "locationName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "OpenCreateGuildNeighborhoodUI",
			Type = "Event",
			LiteralName = "OPEN_CREATE_GUILD_NEIGHBORHOOD_UI",
			Payload =
			{
				{ Name = "locationName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "OpenNeighborhoodCharter",
			Type = "Event",
			LiteralName = "OPEN_NEIGHBORHOOD_CHARTER",
			Payload =
			{
				{ Name = "neighborhoodInfo", Type = "NeighborhoodInfo", Nilable = false },
				{ Name = "signatures", Type = "table", InnerType = "string", Nilable = false },
				{ Name = "requiredSignatures", Type = "number", Nilable = false },
			},
		},
		{
			Name = "OpenNeighborhoodCharterSignatureRequest",
			Type = "Event",
			LiteralName = "OPEN_NEIGHBORHOOD_CHARTER_SIGNATURE_REQUEST",
			Payload =
			{
				{ Name = "neighborhoodInfo", Type = "NeighborhoodInfo", Nilable = false },
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
			Name = "CreateNeighborhoodErrorType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "CreateNeighborhoodErrorType", EnumValue = 0 },
				{ Name = "Profanity", Type = "CreateNeighborhoodErrorType", EnumValue = 1 },
				{ Name = "UndersizedGuild", Type = "CreateNeighborhoodErrorType", EnumValue = 2 },
				{ Name = "OversizedGuild", Type = "CreateNeighborhoodErrorType", EnumValue = 3 },
			},
		},
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