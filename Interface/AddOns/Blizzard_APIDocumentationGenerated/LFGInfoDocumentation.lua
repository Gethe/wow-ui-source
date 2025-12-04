local LFGInfo =
{
	Name = "LFGInfo",
	Type = "System",
	Namespace = "C_LFGInfo",

	Functions =
	{
		{
			Name = "AreCrossFactionGroupQueuesAllowed",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "lfgDungeonID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "areCrossFactionGroupQueuesAllowed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanPlayerUseGroupFinder",
			Type = "Function",

			Returns =
			{
				{ Name = "canUse", Type = "bool", Nilable = false },
				{ Name = "failureReason", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CanPlayerUseLFD",
			Type = "Function",

			Returns =
			{
				{ Name = "canUse", Type = "bool", Nilable = false },
				{ Name = "failureReason", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CanPlayerUseLFR",
			Type = "Function",

			Returns =
			{
				{ Name = "canUse", Type = "bool", Nilable = false },
				{ Name = "failureReason", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CanPlayerUsePVP",
			Type = "Function",

			Returns =
			{
				{ Name = "canUse", Type = "bool", Nilable = false },
				{ Name = "failureReason", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CanPlayerUsePremadeGroup",
			Type = "Function",

			Returns =
			{
				{ Name = "canUse", Type = "bool", Nilable = false },
				{ Name = "failureReason", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CanPlayerUseScenarioFinder",
			Type = "Function",

			Returns =
			{
				{ Name = "canUse", Type = "bool", Nilable = false },
				{ Name = "failureReason", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ConfirmLfgExpandSearch",
			Type = "Function",
		},
		{
			Name = "DoesActivePartyMeetPremadeLaunchCount",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "lfgDungeonID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "doesActivePartyMeetPremadeLaunchCount", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "DoesCrossFactionQueueRequireFullPremade",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "lfgDungeonID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "doesCrossFactionQueueRequireFullPremade", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAllEntriesForCategory",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "category", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "lfgDungeonIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetDungeonInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "lfgDungeonID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "dungeonInfo", Type = "LFGDungeonInfo", Nilable = false },
			},
		},
		{
			Name = "GetLFDLockStates",
			Type = "Function",

			Returns =
			{
				{ Name = "lockInfo", Type = "table", InnerType = "LFGLockInfo", Nilable = false },
			},
		},
		{
			Name = "GetLevelUpInstances",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "currPlayerLevel", Type = "number", Nilable = false },
				{ Name = "isRaid", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "instances", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetRoleCheckDifficultyDetails",
			Type = "Function",

			Returns =
			{
				{ Name = "maxLevel", Type = "number", Nilable = true },
				{ Name = "isLevelReduced", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HideNameFromUI",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "dungeonID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "shouldHide", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsGroupFinderEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsInLFGFollowerDungeon",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsLFDEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsLFGFollowerDungeon",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "dungeonID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsLFREnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "IslandCompleted",
			Type = "Event",
			LiteralName = "ISLAND_COMPLETED",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
		{
			Name = "LfgCompletionReward",
			Type = "Event",
			LiteralName = "LFG_COMPLETION_REWARD",
			SynchronousEvent = true,
		},
		{
			Name = "LfgCooldownsUpdated",
			Type = "Event",
			LiteralName = "LFG_COOLDOWNS_UPDATED",
			SynchronousEvent = true,
		},
		{
			Name = "LfgEnabledStateChanged",
			Type = "Event",
			LiteralName = "LFG_ENABLED_STATE_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "LfgInvalidErrorMessage",
			Type = "Event",
			LiteralName = "LFG_INVALID_ERROR_MESSAGE",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
		{
			Name = "LfgOfferContinue",
			Type = "Event",
			LiteralName = "LFG_OFFER_CONTINUE",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "dungeonID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LfgProposalDone",
			Type = "Event",
			LiteralName = "LFG_PROPOSAL_DONE",
			SynchronousEvent = true,
		},
		{
			Name = "LfgProposalFailed",
			Type = "Event",
			LiteralName = "LFG_PROPOSAL_FAILED",
			SynchronousEvent = true,
		},
		{
			Name = "LfgProposalShow",
			Type = "Event",
			LiteralName = "LFG_PROPOSAL_SHOW",
			SynchronousEvent = true,
		},
		{
			Name = "LfgProposalSucceeded",
			Type = "Event",
			LiteralName = "LFG_PROPOSAL_SUCCEEDED",
			SynchronousEvent = true,
		},
		{
			Name = "LfgProposalUpdate",
			Type = "Event",
			LiteralName = "LFG_PROPOSAL_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "LfgQueueStatusUpdate",
			Type = "Event",
			LiteralName = "LFG_QUEUE_STATUS_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "LfgReadyCheckDeclined",
			Type = "Event",
			LiteralName = "LFG_READY_CHECK_DECLINED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "LfgReadyCheckHide",
			Type = "Event",
			LiteralName = "LFG_READY_CHECK_HIDE",
			SynchronousEvent = true,
		},
		{
			Name = "LfgReadyCheckPlayerIsReady",
			Type = "Event",
			LiteralName = "LFG_READY_CHECK_PLAYER_IS_READY",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "LfgReadyCheckShow",
			Type = "Event",
			LiteralName = "LFG_READY_CHECK_SHOW",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "isRequeue", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LfgReadyCheckUpdate",
			Type = "Event",
			LiteralName = "LFG_READY_CHECK_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "LfgRoleCheckDeclined",
			Type = "Event",
			LiteralName = "LFG_ROLE_CHECK_DECLINED",
			SynchronousEvent = true,
		},
		{
			Name = "LfgRoleCheckHide",
			Type = "Event",
			LiteralName = "LFG_ROLE_CHECK_HIDE",
			SynchronousEvent = true,
		},
		{
			Name = "LfgRoleCheckRoleChosen",
			Type = "Event",
			LiteralName = "LFG_ROLE_CHECK_ROLE_CHOSEN",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "isRequeue", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LfgRoleCheckUpdate",
			Type = "Event",
			LiteralName = "LFG_ROLE_CHECK_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "LfgRoleUpdate",
			Type = "Event",
			LiteralName = "LFG_ROLE_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "LfgUpdate",
			Type = "Event",
			LiteralName = "LFG_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "LfgUpdateRandomInfo",
			Type = "Event",
			LiteralName = "LFG_UPDATE_RANDOM_INFO",
			SynchronousEvent = true,
		},
		{
			Name = "ShowLfgExpandSearchPrompt",
			Type = "Event",
			LiteralName = "SHOW_LFG_EXPAND_SEARCH_PROMPT",
			SynchronousEvent = true,
		},
		{
			Name = "UpdateLfgList",
			Type = "Event",
			LiteralName = "UPDATE_LFG_LIST",
			SynchronousEvent = true,
		},
		{
			Name = "WarfrontCompleted",
			Type = "Event",
			LiteralName = "WARFRONT_COMPLETED",
			SynchronousEvent = true,
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