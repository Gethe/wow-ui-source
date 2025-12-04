local AdventureJournal =
{
	Name = "AdventureJournal",
	Type = "System",
	Namespace = "C_AdventureJournal",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "AjDungeonAction",
			Type = "Event",
			LiteralName = "AJ_DUNGEON_ACTION",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "lfgDungeonID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AjOpen",
			Type = "Event",
			LiteralName = "AJ_OPEN",
			SynchronousEvent = true,
		},
		{
			Name = "AjOpenCollectionsAction",
			Type = "Event",
			LiteralName = "AJ_OPEN_COLLECTIONS_ACTION",
			SynchronousEvent = true,
		},
		{
			Name = "AjPveLfgAction",
			Type = "Event",
			LiteralName = "AJ_PVE_LFG_ACTION",
			SynchronousEvent = true,
		},
		{
			Name = "AjPvpAction",
			Type = "Event",
			LiteralName = "AJ_PVP_ACTION",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "battleMasterListID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AjPvpLfgAction",
			Type = "Event",
			LiteralName = "AJ_PVP_LFG_ACTION",
			SynchronousEvent = true,
		},
		{
			Name = "AjPvpRbgAction",
			Type = "Event",
			LiteralName = "AJ_PVP_RBG_ACTION",
			SynchronousEvent = true,
		},
		{
			Name = "AjPvpSkirmishAction",
			Type = "Event",
			LiteralName = "AJ_PVP_SKIRMISH_ACTION",
			SynchronousEvent = true,
		},
		{
			Name = "AjPvpSpecialBgAction",
			Type = "Event",
			LiteralName = "AJ_PVP_SPECIAL_BG_ACTION",
			SynchronousEvent = true,
		},
		{
			Name = "AjQuestLogOpen",
			Type = "Event",
			LiteralName = "AJ_QUEST_LOG_OPEN",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AjRaidAction",
			Type = "Event",
			LiteralName = "AJ_RAID_ACTION",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "lfgDungeonID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AjRefreshDisplay",
			Type = "Event",
			LiteralName = "AJ_REFRESH_DISPLAY",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "newAdventureNotice", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "AjRewardDataReceived",
			Type = "Event",
			LiteralName = "AJ_REWARD_DATA_RECEIVED",
			UniqueEvent = true,
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(AdventureJournal);