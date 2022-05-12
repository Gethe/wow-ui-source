local GossipInfo =
{
	Name = "GossipInfo",
	Type = "System",
	Namespace = "C_GossipInfo",

	Functions =
	{
		{
			Name = "GetCustomGossipDescriptionString",
			Type = "Function",

			Returns =
			{
				{ Name = "description", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetPoiForUiMapID",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "gossipPoiID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetPoiInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
				{ Name = "gossipPoiID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "gossipPoiInfo", Type = "GossipPoiInfo", Nilable = true },
			},
		},
	},

	Events =
	{
		{
			Name = "DynamicGossipPoiUpdated",
			Type = "Event",
			LiteralName = "DYNAMIC_GOSSIP_POI_UPDATED",
		},
		{
			Name = "GossipClosed",
			Type = "Event",
			LiteralName = "GOSSIP_CLOSED",
		},
		{
			Name = "GossipConfirm",
			Type = "Event",
			LiteralName = "GOSSIP_CONFIRM",
			Payload =
			{
				{ Name = "gossipIndex", Type = "number", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "cost", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GossipConfirmCancel",
			Type = "Event",
			LiteralName = "GOSSIP_CONFIRM_CANCEL",
		},
		{
			Name = "GossipEnterCode",
			Type = "Event",
			LiteralName = "GOSSIP_ENTER_CODE",
			Payload =
			{
				{ Name = "gossipIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GossipShow",
			Type = "Event",
			LiteralName = "GOSSIP_SHOW",
		},
	},

	Tables =
	{
		{
			Name = "GossipPoiInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "textureIndex", Type = "number", Nilable = false },
				{ Name = "position", Type = "table", Mixin = "Vector2DMixin", Nilable = false },
				{ Name = "inBattleMap", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(GossipInfo);