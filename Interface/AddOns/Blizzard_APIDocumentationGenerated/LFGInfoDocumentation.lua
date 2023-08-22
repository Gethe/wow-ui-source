local LFGInfo =
{
	Name = "LFGInfo",
	Type = "System",
	Namespace = "C_LFGInfo",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "IslandCompleted",
			Type = "Event",
			LiteralName = "ISLAND_COMPLETED",
			Payload =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "winner", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LfgBootProposalUpdate",
			Type = "Event",
			LiteralName = "LFG_BOOT_PROPOSAL_UPDATE",
		},
		{
			Name = "LfgCompletionReward",
			Type = "Event",
			LiteralName = "LFG_COMPLETION_REWARD",
		},
		{
			Name = "LfgInvalidErrorMessage",
			Type = "Event",
			LiteralName = "LFG_INVALID_ERROR_MESSAGE",
			Payload =
			{
				{ Name = "reason", Type = "number", Nilable = false },
				{ Name = "subReason1", Type = "number", Nilable = false },
				{ Name = "subReason2", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LfgLockInfoReceived",
			Type = "Event",
			LiteralName = "LFG_LOCK_INFO_RECEIVED",
		},
		{
			Name = "LfgOfferContinue",
			Type = "Event",
			LiteralName = "LFG_OFFER_CONTINUE",
			Payload =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "lfgDungeonsID", Type = "number", Nilable = false },
				{ Name = "typeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LfgOpenFromGossip",
			Type = "Event",
			LiteralName = "LFG_OPEN_FROM_GOSSIP",
			Payload =
			{
				{ Name = "dungeonID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LfgProposalDone",
			Type = "Event",
			LiteralName = "LFG_PROPOSAL_DONE",
		},
		{
			Name = "LfgProposalFailed",
			Type = "Event",
			LiteralName = "LFG_PROPOSAL_FAILED",
		},
		{
			Name = "LfgProposalShow",
			Type = "Event",
			LiteralName = "LFG_PROPOSAL_SHOW",
		},
		{
			Name = "LfgProposalSucceeded",
			Type = "Event",
			LiteralName = "LFG_PROPOSAL_SUCCEEDED",
		},
		{
			Name = "LfgProposalUpdate",
			Type = "Event",
			LiteralName = "LFG_PROPOSAL_UPDATE",
		},
		{
			Name = "LfgQueueStatusUpdate",
			Type = "Event",
			LiteralName = "LFG_QUEUE_STATUS_UPDATE",
		},
		{
			Name = "LfgReadyCheckDeclined",
			Type = "Event",
			LiteralName = "LFG_READY_CHECK_DECLINED",
			Payload =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "LfgReadyCheckHide",
			Type = "Event",
			LiteralName = "LFG_READY_CHECK_HIDE",
		},
		{
			Name = "LfgReadyCheckPlayerIsReady",
			Type = "Event",
			LiteralName = "LFG_READY_CHECK_PLAYER_IS_READY",
			Payload =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "LfgReadyCheckShow",
			Type = "Event",
			LiteralName = "LFG_READY_CHECK_SHOW",
			Payload =
			{
				{ Name = "isRequeue", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LfgReadyCheckUpdate",
			Type = "Event",
			LiteralName = "LFG_READY_CHECK_UPDATE",
		},
		{
			Name = "LfgRoleCheckDeclined",
			Type = "Event",
			LiteralName = "LFG_ROLE_CHECK_DECLINED",
		},
		{
			Name = "LfgRoleCheckHide",
			Type = "Event",
			LiteralName = "LFG_ROLE_CHECK_HIDE",
		},
		{
			Name = "LfgRoleCheckRoleChosen",
			Type = "Event",
			LiteralName = "LFG_ROLE_CHECK_ROLE_CHOSEN",
			Payload =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "isTank", Type = "bool", Nilable = false },
				{ Name = "isHealer", Type = "bool", Nilable = false },
				{ Name = "isDamage", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LfgRoleCheckShow",
			Type = "Event",
			LiteralName = "LFG_ROLE_CHECK_SHOW",
			Payload =
			{
				{ Name = "isRequeue", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LfgRoleCheckUpdate",
			Type = "Event",
			LiteralName = "LFG_ROLE_CHECK_UPDATE",
		},
		{
			Name = "LfgRoleUpdate",
			Type = "Event",
			LiteralName = "LFG_ROLE_UPDATE",
		},
		{
			Name = "LfgUpdate",
			Type = "Event",
			LiteralName = "LFG_UPDATE",
		},
		{
			Name = "LfgUpdateRandomInfo",
			Type = "Event",
			LiteralName = "LFG_UPDATE_RANDOM_INFO",
		},
		{
			Name = "ShowLfgExpandSearchPrompt",
			Type = "Event",
			LiteralName = "SHOW_LFG_EXPAND_SEARCH_PROMPT",
		},
		{
			Name = "UpdateLfgList",
			Type = "Event",
			LiteralName = "UPDATE_LFG_LIST",
		},
		{
			Name = "WarfrontCompleted",
			Type = "Event",
			LiteralName = "WARFRONT_COMPLETED",
			Payload =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "winner", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "LFGDungeonInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "iconID", Type = "fileID", Nilable = false },
				{ Name = "link", Type = "string", Nilable = true },
			},
		},
		{
			Name = "LFGLockInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "lfgID", Type = "number", Nilable = false },
				{ Name = "reason", Type = "number", Nilable = false },
				{ Name = "hideEntry", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LFGInfo);