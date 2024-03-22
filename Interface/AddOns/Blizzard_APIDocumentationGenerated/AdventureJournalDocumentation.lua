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
			Payload =
			{
				{ Name = "lfgDungeonID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AjOpen",
			Type = "Event",
			LiteralName = "AJ_OPEN",
		},
		{
			Name = "AjOpenCollectionsAction",
			Type = "Event",
			LiteralName = "AJ_OPEN_COLLECTIONS_ACTION",
		},
		{
			Name = "AjPveLfgAction",
			Type = "Event",
			LiteralName = "AJ_PVE_LFG_ACTION",
		},
		{
			Name = "AjPvpAction",
			Type = "Event",
			LiteralName = "AJ_PVP_ACTION",
			Payload =
			{
				{ Name = "battleMasterListID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AjPvpLfgAction",
			Type = "Event",
			LiteralName = "AJ_PVP_LFG_ACTION",
		},
		{
			Name = "AjPvpRbgAction",
			Type = "Event",
			LiteralName = "AJ_PVP_RBG_ACTION",
		},
		{
			Name = "AjPvpSkirmishAction",
			Type = "Event",
			LiteralName = "AJ_PVP_SKIRMISH_ACTION",
		},
		{
			Name = "AjQuestLogOpen",
			Type = "Event",
			LiteralName = "AJ_QUEST_LOG_OPEN",
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
			Payload =
			{
				{ Name = "lfgDungeonID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AjRefreshDisplay",
			Type = "Event",
			LiteralName = "AJ_REFRESH_DISPLAY",
			Payload =
			{
				{ Name = "newAdventureNotice", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "AjRewardDataReceived",
			Type = "Event",
			LiteralName = "AJ_REWARD_DATA_RECEIVED",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(AdventureJournal);