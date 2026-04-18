local PartyInfo =
{
	Name = "PartyInfo",
	Type = "System",
	Namespace = "C_PartyInfo",
	Environment = "All",

	Functions =
	{
		{
			Name = "ChallengeModeRestrictionsActive",
			Type = "Function",

			Returns =
			{
				{ Name = "restrictionsActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ConfirmLeaveParty",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Immediately leave the party with no regard for potentially destructive actions" },

			Arguments =
			{
				{ Name = "category", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "ConfirmReadyCheck",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "isReady", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "DemoteAssistant",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "exactNameMatch", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "DoCountdown",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "seconds", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "DoReadyCheck",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "GetActiveCategories",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "categories", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetAvailableLootMethods",
			Type = "Function",

			Returns =
			{
				{ Name = "methods", Type = "table", InnerType = "LootMethod", Nilable = false },
			},
		},
		{
			Name = "GetInviteConfirmationInvalidQueues",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "inviteGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "invalidQueues", Type = "table", InnerType = "QueueSpecificInfo", Nilable = false },
			},
		},
		{
			Name = "GetLootMethod",
			Type = "Function",

			Returns =
			{
				{ Name = "method", Type = "LootMethod", Nilable = false },
				{ Name = "masterLootPartyID", Type = "number", Nilable = true },
				{ Name = "masterLooterRaidID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetLootMethodStyle",
			Type = "Function",

			Returns =
			{
				{ Name = "methodStyle", Type = "LootMethodStyles", Nilable = false },
			},
		},
		{
			Name = "GetMinLevel",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "category", Type = "luaIndex", Nilable = true, Documentation = { "If not provided, the active party is used" } },
			},

			Returns =
			{
				{ Name = "minLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "InviteUnit",
			Type = "Function",
			RequiresValidInviteTarget = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Attempt to invite the named unit to a party, requires confirmation in some cases (e.g. the party will convert to a raid, or if there is a party sync in progress)." },

			Arguments =
			{
				{ Name = "targetName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "IsCrossFactionParty",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "category", Type = "luaIndex", Nilable = true, Documentation = { "If not provided, the active party is used" } },
			},

			Returns =
			{
				{ Name = "isCrossFactionParty", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsGUIDInGroup",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "category", Type = "luaIndex", Nilable = true, Documentation = { "If not provided, the active party is used" } },
			},

			Returns =
			{
				{ Name = "isInGroup", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsLootMethodAvailable",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "method", Type = "LootMethod", Nilable = false },
			},

			Returns =
			{
				{ Name = "available", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPartyFull",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "category", Type = "luaIndex", Nilable = true, Documentation = { "If not provided, the active party is used" } },
			},

			Returns =
			{
				{ Name = "isFull", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPartyWalkIn",
			Type = "Function",

			Returns =
			{
				{ Name = "isPartyWalkIn", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PromoteToAssistant",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "exactNameMatch", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "PromoteToLeader",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "exactNameMatch", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "SetEveryoneIsAssistant",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "isAssistant", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "updated", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetLootMethod",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "method", Type = "LootMethod", Nilable = false },
				{ Name = "lootMaster", Type = "string", Nilable = true },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UninviteUnit",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "reason", Type = "cstring", Nilable = true },
				{ Name = "exactNameMatch", Type = "bool", Nilable = true },
			},
		},
	},

	Events =
	{
		{
			Name = "BnetRequestInviteConfirmation",
			Type = "Event",
			LiteralName = "BNET_REQUEST_INVITE_CONFIRMATION",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "gameAccountID", Type = "number", Nilable = false },
				{ Name = "questSessionActive", Type = "bool", Nilable = false },
				{ Name = "tank", Type = "bool", Nilable = false },
				{ Name = "healer", Type = "bool", Nilable = false },
				{ Name = "dps", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "EnteredDifferentInstanceFromParty",
			Type = "Event",
			LiteralName = "ENTERED_DIFFERENT_INSTANCE_FROM_PARTY",
			SynchronousEvent = true,
		},
		{
			Name = "GroupFormed",
			Type = "Event",
			LiteralName = "GROUP_FORMED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "category", Type = "number", Nilable = false },
				{ Name = "partyGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "GroupInviteConfirmation",
			Type = "Event",
			LiteralName = "GROUP_INVITE_CONFIRMATION",
			SynchronousEvent = true,
		},
		{
			Name = "GroupJoined",
			Type = "Event",
			LiteralName = "GROUP_JOINED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "category", Type = "number", Nilable = false },
				{ Name = "partyGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "GroupLeft",
			Type = "Event",
			LiteralName = "GROUP_LEFT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "category", Type = "number", Nilable = false },
				{ Name = "partyGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "GroupRosterUpdate",
			Type = "Event",
			LiteralName = "GROUP_ROSTER_UPDATE",
			UniqueEvent = true,
		},
		{
			Name = "InstanceAbandonVoteFinished",
			Type = "Event",
			LiteralName = "INSTANCE_ABANDON_VOTE_FINISHED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "votePassed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "InstanceAbandonVoteStarted",
			Type = "Event",
			LiteralName = "INSTANCE_ABANDON_VOTE_STARTED",
			SynchronousEvent = true,
		},
		{
			Name = "InstanceAbandonVoteUpdated",
			Type = "Event",
			LiteralName = "INSTANCE_ABANDON_VOTE_UPDATED",
			SynchronousEvent = true,
		},
		{
			Name = "InstanceBootStart",
			Type = "Event",
			LiteralName = "INSTANCE_BOOT_START",
			SynchronousEvent = true,
		},
		{
			Name = "InstanceBootStop",
			Type = "Event",
			LiteralName = "INSTANCE_BOOT_STOP",
			SynchronousEvent = true,
		},
		{
			Name = "InstanceGroupSizeChanged",
			Type = "Event",
			LiteralName = "INSTANCE_GROUP_SIZE_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "PartyInviteCancel",
			Type = "Event",
			LiteralName = "PARTY_INVITE_CANCEL",
			SynchronousEvent = true,
		},
		{
			Name = "PartyInviteRequest",
			Type = "Event",
			LiteralName = "PARTY_INVITE_REQUEST",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "isTank", Type = "bool", Nilable = false },
				{ Name = "isHealer", Type = "bool", Nilable = false },
				{ Name = "isDamage", Type = "bool", Nilable = false },
				{ Name = "isNativeRealm", Type = "bool", Nilable = false },
				{ Name = "allowMultipleRoles", Type = "bool", Nilable = false },
				{ Name = "inviterGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "PartyLeaderChanged",
			Type = "Event",
			LiteralName = "PARTY_LEADER_CHANGED",
			UniqueEvent = true,
		},
		{
			Name = "PartyLootMethodChanged",
			Type = "Event",
			LiteralName = "PARTY_LOOT_METHOD_CHANGED",
			UniqueEvent = true,
		},
		{
			Name = "PartyMemberDisable",
			Type = "Event",
			LiteralName = "PARTY_MEMBER_DISABLE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "PartyMemberEnable",
			Type = "Event",
			LiteralName = "PARTY_MEMBER_ENABLE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "PlayerDifficultyChanged",
			Type = "Event",
			LiteralName = "PLAYER_DIFFICULTY_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerRolesAssigned",
			Type = "Event",
			LiteralName = "PLAYER_ROLES_ASSIGNED",
			UniqueEvent = true,
		},
		{
			Name = "RaidRosterUpdate",
			Type = "Event",
			LiteralName = "RAID_ROSTER_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "ReadyCheck",
			Type = "Event",
			LiteralName = "READY_CHECK",
			SecretInChatMessagingLockdown = true,
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "initiatorName", Type = "cstring", Nilable = false },
				{ Name = "readyCheckTimeLeft", Type = "time_t", Nilable = false },
			},
		},
		{
			Name = "ReadyCheckConfirm",
			Type = "Event",
			LiteralName = "READY_CHECK_CONFIRM",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "isReady", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ReadyCheckFinished",
			Type = "Event",
			LiteralName = "READY_CHECK_FINISHED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "preempted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "VoteKickReasonNeeded",
			Type = "Event",
			LiteralName = "VOTE_KICK_REASON_NEEDED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "resultGUID", Type = "WOWGUID", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "LeavePartyConfirmReason",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "QuestSync", Type = "LeavePartyConfirmReason", EnumValue = 0 },
				{ Name = "RestrictedChallengeMode", Type = "LeavePartyConfirmReason", EnumValue = 1 },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(PartyInfo);