local GossipInfo =
{
	Name = "GossipInfo",
	Type = "System",
	Namespace = "C_GossipInfo",

	Functions =
	{
		{
			Name = "CloseGossip",
			Type = "Function",
		},
		{
			Name = "ForceGossip",
			Type = "Function",

			Returns =
			{
				{ Name = "forceGossip", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetActiveQuests",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "table", InnerType = "GossipQuestUIInfo", Nilable = false },
			},
		},
		{
			Name = "GetAvailableQuests",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "table", InnerType = "GossipQuestUIInfo", Nilable = false },
			},
		},
		{
			Name = "GetNumActiveQuests",
			Type = "Function",

			Returns =
			{
				{ Name = "numQuests", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumAvailableQuests",
			Type = "Function",

			Returns =
			{
				{ Name = "numQuests", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumOptions",
			Type = "Function",

			Returns =
			{
				{ Name = "numOptions", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetOptions",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "table", InnerType = "GossipOptionUIInfo", Nilable = false },
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
		{
			Name = "GetText",
			Type = "Function",

			Returns =
			{
				{ Name = "gossipText", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SelectActiveQuest",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SelectAvailableQuest",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SelectOption",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
				{ Name = "text", Type = "string", Nilable = true },
				{ Name = "confirmed", Type = "bool", Nilable = true },
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
			Name = "GossipOptionUIInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "type", Type = "string", Nilable = false },
			},
		},
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
		{
			Name = "GossipQuestUIInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "title", Type = "string", Nilable = false },
				{ Name = "questLevel", Type = "number", Nilable = false },
				{ Name = "isTrivial", Type = "bool", Nilable = false },
				{ Name = "frequency", Type = "number", Nilable = true },
				{ Name = "repeatable", Type = "bool", Nilable = true },
				{ Name = "isComplete", Type = "bool", Nilable = true },
				{ Name = "isLegendary", Type = "bool", Nilable = false },
				{ Name = "isIgnored", Type = "bool", Nilable = false },
				{ Name = "questID", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(GossipInfo);