local HousingNeighborhoodUI =
{
	Name = "HousingNeighborhoodUI",
	Type = "System",
	Namespace = "C_HousingNeighborhood",

	Functions =
	{
		{
			Name = "CanEditCharter",
			Type = "Function",

			Returns =
			{
				{ Name = "canEditCharter", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CancelInviteToNeighborhood",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerName", Type = "cstring", Nilable = false },
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
			Name = "DemoteToResident",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerGUID", Type = "WOWGUID", Nilable = false },
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
			Name = "GetCornerstoneHouseInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "houseInfo", Type = "HouseInfo", Nilable = false },
			},
		},
		{
			Name = "GetCornerstoneNeighborhoodInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "neighborhoodInfo", Type = "NeighborhoodInfo", Nilable = false },
			},
		},
		{
			Name = "GetCornerstonePurchaseMode",
			Type = "Function",

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

			Returns =
			{
				{ Name = "movePrice", Type = "number", Nilable = false, Documentation = { "Can be negative if the refund from moving is more than the cost of the new house" } },
			},
		},
		{
			Name = "GetMoveCooldownTime",
			Type = "Function",

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

			Returns =
			{
				{ Name = "previousHouseIdentifier", Type = "cstring", Nilable = false },
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
			Name = "HasPermissionToPurchase",
			Type = "Function",

			Returns =
			{
				{ Name = "cantPurchaseReason", Type = "PurchaseHouseDisabledReason", Nilable = false },
			},
		},
		{
			Name = "InvitePlayerToNeighborhood",
			Type = "Function",

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
			Name = "IsPlotAvailableForPurchase",
			Type = "Function",

			Returns =
			{
				{ Name = "isAvailable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPlotOwnedByPlayer",
			Type = "Function",

			Returns =
			{
				{ Name = "isPlayerOwned", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LeaveHouse",
			Type = "Function",
		},
		{
			Name = "OnBulletinBoardClosed",
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
			Name = "PromoteToManager",
			Type = "Function",

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
		},
		{
			Name = "RequestPendingNeighborhoodInvites",
			Type = "Function",
		},
		{
			Name = "ReturnAfterVisitingHouse",
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
			Name = "TransferNeighborhoodOwnership",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "TryEvictPlayer",
			Type = "Function",

			Arguments =
			{
				{ Name = "plotID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TryMoveHouse",
			Type = "Function",
		},
		{
			Name = "TryPurchasePlot",
			Type = "Function",
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
			Name = "CancelNeighborhoodInviteResponse",
			Type = "Event",
			LiteralName = "CANCEL_NEIGHBORHOOD_INVITE_RESPONSE",
			Payload =
			{
				{ Name = "result", Type = "NeighborhoodInviteResult", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = true },
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
			Name = "ClosePlotCornerstone",
			Type = "Event",
			LiteralName = "CLOSE_PLOT_CORNERSTONE",
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
			Name = "NeighborhoodGuildSizeValidated",
			Type = "Event",
			LiteralName = "NEIGHBORHOOD_GUILD_SIZE_VALIDATED",
			Payload =
			{
				{ Name = "approved", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "NeighborhoodInfoUpdated",
			Type = "Event",
			LiteralName = "NEIGHBORHOOD_INFO_UPDATED",
			Payload =
			{
				{ Name = "neighborhoodInfo", Type = "NeighborhoodInfo", Nilable = false },
			},
		},
		{
			Name = "NeighborhoodInviteResponse",
			Type = "Event",
			LiteralName = "NEIGHBORHOOD_INVITE_RESPONSE",
			Payload =
			{
				{ Name = "result", Type = "NeighborhoodInviteResult", Nilable = false },
			},
		},
		{
			Name = "NeighborhoodMapDataUpdated",
			Type = "Event",
			LiteralName = "NEIGHBORHOOD_MAP_DATA_UPDATED",
		},
		{
			Name = "NeighborhoodNameUpdated",
			Type = "Event",
			LiteralName = "NEIGHBORHOOD_NAME_UPDATED",
			Payload =
			{
				{ Name = "neighborhoodGuid", Type = "WOWGUID", Nilable = false },
				{ Name = "neighborhoodName", Type = "cstring", Nilable = false },
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
			Name = "NeighborhoodTypeChanged",
			Type = "Event",
			LiteralName = "NEIGHBORHOOD_TYPE_CHANGED",
			Payload =
			{
				{ Name = "result", Type = "HousingResult", Nilable = false },
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
			Name = "OpenPlotCornerstone",
			Type = "Event",
			LiteralName = "OPEN_PLOT_CORNERSTONE",
		},
		{
			Name = "PendingNeighborhoodInvitesRecieved",
			Type = "Event",
			LiteralName = "PENDING_NEIGHBORHOOD_INVITES_RECIEVED",
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
			Payload =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ShowPlayerEvictedDialog",
			Type = "Event",
			LiteralName = "SHOW_PLAYER_EVICTED_DIALOG",
		},
		{
			Name = "UpdateBulletinBoardRoster",
			Type = "Event",
			LiteralName = "UPDATE_BULLETIN_BOARD_ROSTER",
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
	},
};

APIDocumentation:AddDocumentationTable(HousingNeighborhoodUI);