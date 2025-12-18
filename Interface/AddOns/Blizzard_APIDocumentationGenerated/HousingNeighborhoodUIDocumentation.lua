local HousingNeighborhoodUI =
{
	Name = "HousingNeighborhoodUI",
	Type = "System",
	Namespace = "C_HousingNeighborhood",
	Environment = "All",

	Functions =
	{
		{
			Name = "CanReturnAfterVisitingHouse",
			Type = "Function",

			Returns =
			{
				{ Name = "canReturn", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CancelInviteToNeighborhood",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Only available when interacting with a bulletin board game object" },

			Arguments =
			{
				{ Name = "playerName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "DemoteToResident",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Only available when interacting with a bulletin board game object" },

			Arguments =
			{
				{ Name = "playerGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "GetCornerstoneHouseInfo",
			Type = "Function",
			Documentation = { "Only available when interacting with a cornerstone game object" },

			Returns =
			{
				{ Name = "houseInfo", Type = "HouseInfo", Nilable = false },
			},
		},
		{
			Name = "GetCornerstoneNeighborhoodInfo",
			Type = "Function",
			Documentation = { "Only available when interacting with a cornerstone game object" },

			Returns =
			{
				{ Name = "neighborhoodInfo", Type = "NeighborhoodInfo", Nilable = false },
			},
		},
		{
			Name = "GetCornerstonePurchaseMode",
			Type = "Function",
			Documentation = { "Only available when interacting with a cornerstone game object" },

			Returns =
			{
				{ Name = "purchaseMode", Type = "CornerstonePurchaseMode", Nilable = false },
			},
		},
		{
			Name = "GetCurrentNeighborhoodTextureSuffix",
			Type = "Function",

			Returns =
			{
				{ Name = "neighborhoodTextureSuffix", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetDiscountedMovePrice",
			Type = "Function",
			Documentation = { "Only available when interacting with a cornerstone game object" },

			Returns =
			{
				{ Name = "movePrice", Type = "number", Nilable = false, Documentation = { "Can be negative if the refund from moving is more than the cost of the new house" } },
			},
		},
		{
			Name = "GetMoveCooldownTime",
			Type = "Function",
			Documentation = { "Only available when interacting with a cornerstone game object" },

			Returns =
			{
				{ Name = "movecooldownTime", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNeighborhoodMapData",
			Type = "Function",

			Returns =
			{
				{ Name = "neighborhoodPlots", Type = "table", InnerType = "NeighborhoodPlotMapInfo", Nilable = false },
			},
		},
		{
			Name = "GetNeighborhoodName",
			Type = "Function",

			Returns =
			{
				{ Name = "neighborhoodName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetNeighborhoodPlotName",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "plotIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "neighborhoodName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetPreviousHouseIdentifier",
			Type = "Function",
			Documentation = { "Only available when interacting with a cornerstone game object" },

			Returns =
			{
				{ Name = "previousHouseIdentifier", Type = "string", Nilable = false },
			},
		},
		{
			Name = "HasPermissionToPurchase",
			Type = "Function",
			Documentation = { "Only available when interacting with a cornerstone game object" },

			Returns =
			{
				{ Name = "cantPurchaseReason", Type = "PurchaseHouseDisabledReason", Nilable = false },
			},
		},
		{
			Name = "InvitePlayerToNeighborhood",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Only available when interacting with a bulletin board game object" },

			Arguments =
			{
				{ Name = "playerName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "IsNeighborhoodManager",
			Type = "Function",

			Returns =
			{
				{ Name = "isManager", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsNeighborhoodOwner",
			Type = "Function",

			Returns =
			{
				{ Name = "isOwner", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPlayerInOtherPlayersPlot",
			Type = "Function",
			Documentation = { "This returns true if the player is in a plot that is owned by another player" },

			Returns =
			{
				{ Name = "isInUnownedPlot", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPlotAvailableForPurchase",
			Type = "Function",
			Documentation = { "Only available when interacting with a cornerstone game object" },

			Returns =
			{
				{ Name = "isAvailable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPlotOwnedByPlayer",
			Type = "Function",
			Documentation = { "Only available when interacting with a cornerstone game object" },

			Returns =
			{
				{ Name = "isPlayerOwned", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "OnBulletinBoardClosed",
			Type = "Function",
		},
		{
			Name = "PromoteToManager",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Only available when interacting with a bulletin board game object" },

			Arguments =
			{
				{ Name = "playerGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "RequestNeighborhoodInfo",
			Type = "Function",
		},
		{
			Name = "RequestNeighborhoodRoster",
			Type = "Function",
			Documentation = { "Only available when interacting with a bulletin board game object" },
		},
		{
			Name = "RequestPendingNeighborhoodInvites",
			Type = "Function",
			Documentation = { "Only available when interacting with a bulletin board game object" },
		},
		{
			Name = "TransferNeighborhoodOwnership",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Only available when interacting with a bulletin board game object" },

			Arguments =
			{
				{ Name = "playerGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "TryEvictPlayer",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Only available when interacting with a bulletin board game object" },

			Arguments =
			{
				{ Name = "plotID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TryMoveHouse",
			Type = "Function",
			Documentation = { "Only available when interacting with a cornerstone game object" },
		},
		{
			Name = "TryPurchasePlot",
			Type = "Function",
			Documentation = { "Only available when interacting with a cornerstone game object" },
		},
	},

	Events =
	{
		{
			Name = "CancelNeighborhoodInviteResponse",
			Type = "Event",
			LiteralName = "CANCEL_NEIGHBORHOOD_INVITE_RESPONSE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "result", Type = "NeighborhoodInviteResult", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "ClosePlotCornerstone",
			Type = "Event",
			LiteralName = "CLOSE_PLOT_CORNERSTONE",
			SynchronousEvent = true,
		},
		{
			Name = "NeighborhoodInfoUpdated",
			Type = "Event",
			LiteralName = "NEIGHBORHOOD_INFO_UPDATED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "neighborhoodInfo", Type = "NeighborhoodInfo", Nilable = false },
			},
		},
		{
			Name = "NeighborhoodInviteResponse",
			Type = "Event",
			LiteralName = "NEIGHBORHOOD_INVITE_RESPONSE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "result", Type = "NeighborhoodInviteResult", Nilable = false },
			},
		},
		{
			Name = "NeighborhoodMapDataUpdated",
			Type = "Event",
			LiteralName = "NEIGHBORHOOD_MAP_DATA_UPDATED",
			UniqueEvent = true,
		},
		{
			Name = "NeighborhoodNameUpdated",
			Type = "Event",
			LiteralName = "NEIGHBORHOOD_NAME_UPDATED",
			UniqueEvent = true,
			Payload =
			{
				{ Name = "neighborhoodGuid", Type = "WOWGUID", Nilable = false },
				{ Name = "neighborhoodName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "OpenPlotCornerstone",
			Type = "Event",
			LiteralName = "OPEN_PLOT_CORNERSTONE",
			SynchronousEvent = true,
		},
		{
			Name = "PendingNeighborhoodInvitesRecieved",
			Type = "Event",
			LiteralName = "PENDING_NEIGHBORHOOD_INVITES_RECIEVED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "result", Type = "NeighborhoodInviteResult", Nilable = false },
				{ Name = "pendingInviteList", Type = "table", InnerType = "string", Nilable = true },
			},
		},
		{
			Name = "PurchasePlotResult",
			Type = "Event",
			LiteralName = "PURCHASE_PLOT_RESULT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ShowPlayerEvictedDialog",
			Type = "Event",
			LiteralName = "SHOW_PLAYER_EVICTED_DIALOG",
			SynchronousEvent = true,
		},
		{
			Name = "UpdateBulletinBoardRoster",
			Type = "Event",
			LiteralName = "UPDATE_BULLETIN_BOARD_ROSTER",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "neighborhoodInfo", Type = "NeighborhoodInfo", Nilable = false },
				{ Name = "rosterMemberList", Type = "table", InnerType = "NeighborhoodRosterMemberInfo", Nilable = false },
			},
		},
		{
			Name = "UpdateBulletinBoardRosterStatuses",
			Type = "Event",
			LiteralName = "UPDATE_BULLETIN_BOARD_ROSTER_STATUSES",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "rosterMemberList", Type = "table", InnerType = "NeighborhoodRosterMemberUpdateInfo", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "CornerstonePurchaseMode",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Basic", Type = "CornerstonePurchaseMode", EnumValue = 0 },
				{ Name = "Import", Type = "CornerstonePurchaseMode", EnumValue = 1 },
				{ Name = "Move", Type = "CornerstonePurchaseMode", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(HousingNeighborhoodUI);