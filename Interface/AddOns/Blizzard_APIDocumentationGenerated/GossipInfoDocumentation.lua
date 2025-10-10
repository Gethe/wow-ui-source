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
			Name = "GetActiveDelveGossip",
			Type = "Function",

			Returns =
			{
				{ Name = "gossip", Type = "GossipOptionUIInfo", Nilable = false },
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
			Name = "GetCompletedOptionDescriptionString",
			Type = "Function",

			Returns =
			{
				{ Name = "description", Type = "string", Nilable = true },
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
			Name = "GetFriendshipReputation",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "friendshipFactionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "reputationInfo", Type = "FriendshipReputationInfo", Nilable = false },
			},
		},
		{
			Name = "GetFriendshipReputationRanks",
			Type = "Function",

			Arguments =
			{
				{ Name = "friendshipFactionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "rankInfo", Type = "FriendshipReputationRankInfo", Nilable = false },
			},
		},
		{
			Name = "GetGossipDelveMapID",
			Type = "Function",

			Returns =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
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
			Name = "GetOptionUIWidgetSetsAndTypesByOptionID",
			Type = "Function",

			Arguments =
			{
				{ Name = "gossipOptionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "gossipOptionUIWidgetSetsAndTypes", Type = "table", InnerType = "GossipOptionUIWidgetSetAndType", Nilable = true },
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
				{ Name = "gossipText", Type = "cstring", Nilable = false },
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
				{ Name = "optionID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SelectAvailableQuest",
			Type = "Function",

			Arguments =
			{
				{ Name = "optionID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SelectOption",
			Type = "Function",

			Arguments =
			{
				{ Name = "optionID", Type = "number", Nilable = false },
				{ Name = "text", Type = "cstring", Nilable = true },
				{ Name = "confirmed", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "SelectOptionByIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "optionID", Type = "number", Nilable = false },
				{ Name = "text", Type = "cstring", Nilable = true },
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
			Payload =
			{
				{ Name = "interactionIsContinuing", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GossipConfirm",
			Type = "Event",
			LiteralName = "GOSSIP_CONFIRM",
			Payload =
			{
				{ Name = "gossipID", Type = "number", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "cost", Type = "WOWMONEY", Nilable = false },
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
				{ Name = "gossipID", Type = "number", Nilable = false },
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
				{ Name = "uiTextureKit", Type = "textureKit", Nilable = true },
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
			Name = "GossipOptionUIWidgetSetTypes",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Modifiers", Type = "GossipOptionUIWidgetSetTypes", EnumValue = 0 },
				{ Name = "Background", Type = "GossipOptionUIWidgetSetTypes", EnumValue = 1 },
			},
		},
		{
			Name = "FriendshipReputationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "friendshipFactionID", Type = "number", Nilable = false },
				{ Name = "standing", Type = "number", Nilable = false },
				{ Name = "maxRep", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "texture", Type = "number", Nilable = false },
				{ Name = "reaction", Type = "string", Nilable = false },
				{ Name = "reactionThreshold", Type = "number", Nilable = false },
				{ Name = "nextThreshold", Type = "number", Nilable = true },
				{ Name = "reversedColor", Type = "bool", Nilable = false },
				{ Name = "overrideColor", Type = "number", Nilable = true },
			},
		},
		{
			Name = "FriendshipReputationRankInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "currentLevel", Type = "number", Nilable = false },
				{ Name = "maxLevel", Type = "number", Nilable = false },
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
				{ Name = "context", Type = "ItemCreationContext", Nilable = false },
			},
		},
		{
			Name = "GossipOptionUIInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "gossipOptionID", Type = "number", Nilable = true },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "rewards", Type = "table", InnerType = "GossipOptionRewardInfo", Nilable = false },
				{ Name = "status", Type = "GossipOptionStatus", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = true },
				{ Name = "flags", Type = "number", Nilable = false },
				{ Name = "overrideIconID", Type = "fileID", Nilable = true },
				{ Name = "selectOptionWhenOnlyOption", Type = "bool", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "failureDescription", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GossipOptionUIWidgetSetAndType",
			Type = "Structure",
			Fields =
			{
				{ Name = "widgetType", Type = "number", Nilable = false },
				{ Name = "uiWidgetSetID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GossipPoiInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "textureIndex", Type = "number", Nilable = false },
				{ Name = "position", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
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
				{ Name = "isImportant", Type = "bool", Nilable = false },
				{ Name = "isMeta", Type = "bool", Nilable = false },
				{ Name = "questInfoID", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(GossipInfo);