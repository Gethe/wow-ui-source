local ItemSocketInfo =
{
	Name = "ItemSocketInfo",
	Type = "System",
	Namespace = "C_ItemSocketInfo",

	Functions =
	{
		{
			Name = "AcceptSockets",
			Type = "Function",
		},
		{
			Name = "ClickSocketButton",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "CloseSocketInfo",
			Type = "Function",
		},
		{
			Name = "CompleteSocketing",
			Type = "Function",
		},
		{
			Name = "GetCurrUIType",
			Type = "Function",

			Returns =
			{
				{ Name = "uiType", Type = "ItemSocketInfoUIType", Nilable = false },
			},
		},
		{
			Name = "GetExistingSocketInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "icon", Type = "fileID", Nilable = true },
				{ Name = "gemMatchesSocket", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetExistingSocketLink",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "existingSocketLink", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetNewSocketInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "icon", Type = "fileID", Nilable = true },
				{ Name = "gemMatchesSocket", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetNewSocketLink",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "newSocketLink", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetNumSockets",
			Type = "Function",

			Returns =
			{
				{ Name = "numSockets", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSocketItemBoundTradeable",
			Type = "Function",

			Returns =
			{
				{ Name = "socketItemTradeable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetSocketItemInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "icon", Type = "fileID", Nilable = true },
				{ Name = "quality", Type = "ItemQuality", Nilable = false },
			},
		},
		{
			Name = "GetSocketItemRefundable",
			Type = "Function",

			Returns =
			{
				{ Name = "socketItemRefundable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetSocketTypes",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "socketType", Type = "string", Nilable = true },
			},
		},
		{
			Name = "HasBoundGemProposed",
			Type = "Function",

			Returns =
			{
				{ Name = "hasBoundGemProposed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsArtifactRelicItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "info", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "isArtifactRelicItem", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "SocketInfoAccept",
			Type = "Event",
			LiteralName = "SOCKET_INFO_ACCEPT",
		},
		{
			Name = "SocketInfoBindConfirm",
			Type = "Event",
			LiteralName = "SOCKET_INFO_BIND_CONFIRM",
		},
		{
			Name = "SocketInfoClose",
			Type = "Event",
			LiteralName = "SOCKET_INFO_CLOSE",
		},
		{
			Name = "SocketInfoFailure",
			Type = "Event",
			LiteralName = "SOCKET_INFO_FAILURE",
		},
		{
			Name = "SocketInfoRefundableConfirm",
			Type = "Event",
			LiteralName = "SOCKET_INFO_REFUNDABLE_CONFIRM",
		},
		{
			Name = "SocketInfoSuccess",
			Type = "Event",
			LiteralName = "SOCKET_INFO_SUCCESS",
		},
		{
			Name = "SocketInfoUiEventRegistrationUpdate",
			Type = "Event",
			LiteralName = "SOCKET_INFO_UI_EVENT_REGISTRATION_UPDATE",
			Payload =
			{
				{ Name = "uiType", Type = "ItemSocketInfoUIType", Nilable = false },
			},
		},
		{
			Name = "SocketInfoUpdate",
			Type = "Event",
			LiteralName = "SOCKET_INFO_UPDATE",
		},
	},

	Tables =
	{
		{
			Name = "ItemSocketInfoUIType",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "Default", Type = "ItemSocketInfoUIType", EnumValue = 0 },
			},
		},
		{
			Name = "SocketInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "icon", Type = "fileID", Nilable = true },
				{ Name = "gemMatchesSocket", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SocketItemInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "icon", Type = "fileID", Nilable = true },
				{ Name = "quality", Type = "ItemQuality", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ItemSocketInfo);