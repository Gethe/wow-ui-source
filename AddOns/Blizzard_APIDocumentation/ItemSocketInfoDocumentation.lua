local ItemSocketInfo =
{
	Name = "ItemSocketInfo",
	Type = "System",
	Namespace = "C_ItemSocketInfo",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "SocketInfoAccept",
			Type = "Event",
			LiteralName = "SOCKET_INFO_ACCEPT",
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
			Name = "SocketInfoSuccess",
			Type = "Event",
			LiteralName = "SOCKET_INFO_SUCCESS",
		},
		{
			Name = "SocketInfoUpdate",
			Type = "Event",
			LiteralName = "SOCKET_INFO_UPDATE",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ItemSocketInfo);