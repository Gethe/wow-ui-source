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
			Name = "GetCustomGossipDescriptionString",
			Type = "Function",

			Returns =
			{
				{ Name = "description", Type = "string", Nilable = true },
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
			Name = "RefreshOptions",
			Type = "Function",
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
			Name = "GossipOptionsRefreshed",
			Type = "Event",
			LiteralName = "GOSSIP_OPTIONS_REFRESHED",
		},
		{
			Name = "GossipShow",
			Type = "Event",
			LiteralName = "GOSSIP_SHOW",
			Payload =
			{
				{ Name = "uiTextureKit", Type = "string", Nilable = true },
			},
		},
	},

	Tables =
	{
		{
			Name = "GossipOptionRewardType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Item", Type = "GossipOptionRewardType", EnumValue = 0 },
				{ Name = "Currency", Type = "GossipOptionRewardType", EnumValue = 1 },
			},
		},
		{
			Name = "GossipOptionStatus",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Available", Type = "GossipOptionStatus", EnumValue = 0 },
				{ Name = "Unavailable", Type = "GossipOptionStatus", EnumValue = 1 },
				{ Name = "Locked", Type = "GossipOptionStatus", EnumValue = 2 },
				{ Name = "AlreadyComplete", Type = "GossipOptionStatus", EnumValue = 3 },
			},
		},
		{
			Name = "GossipOptionRewardInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "rewardType", Type = "GossipOptionRewardType", Nilable = false },
			},
		},
		{
			Name = "GossipOptionUIInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "type", Type = "string", Nilable = false },
				{ Name = "rewards", Type = "table", InnerType = "GossipOptionRewardInfo", Nilable = false },
				{ Name = "status", Type = "GossipOptionStatus", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = true },
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