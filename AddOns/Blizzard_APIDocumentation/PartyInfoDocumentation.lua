local PartyInfo =
{
	Name = "PartyInfo",
	Type = "System",
	Namespace = "C_PartyInfo",

	Functions =
	{
		{
			Name = "AllowedToDoPartyConversion",
			Type = "Function",

			Arguments =
			{
				{ Name = "toRaid", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "allowed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanInvite",
			Type = "Function",

			Returns =
			{
				{ Name = "allowedToInvite", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ConfirmConvertToRaid",
			Type = "Function",
			Documentation = { "Immediately convert to raid with no regard for potentially destructive actions." },
		},
		{
			Name = "ConfirmInviteTravelPass",
			Type = "Function",

			Arguments =
			{
				{ Name = "targetName", Type = "string", Nilable = false },
				{ Name = "targetGUID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ConfirmInviteUnit",
			Type = "Function",
			Documentation = { "Immediately invites the named unit to a party, with no regard for potentially destructive actions." },

			Arguments =
			{
				{ Name = "targetName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ConfirmLeaveParty",
			Type = "Function",
			Documentation = { "Immediately leave the party with no regard for potentially destructive actions" },

			Arguments =
			{
				{ Name = "category", Type = "number", Nilable = true },
			},
		},
		{
			Name = "ConfirmRequestInviteFromUnit",
			Type = "Function",
			Documentation = { "Immediately request an invite into the target party, this is the confirmation function to call after RequestInviteFromUnit, or if you would like to skip the confirmation process." },

			Arguments =
			{
				{ Name = "targetName", Type = "string", Nilable = false },
				{ Name = "tank", Type = "bool", Nilable = true },
				{ Name = "healer", Type = "bool", Nilable = true },
				{ Name = "dps", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "ConvertToParty",
			Type = "Function",
		},
		{
			Name = "ConvertToRaid",
			Type = "Function",
			Documentation = { "Usually this will convert to raid immediately. In some cases (e.g. PartySync) the user will be prompted to confirm converting to raid, because it's potentially destructive." },
		},
		{
			Name = "DoCountdown",
			Type = "Function",

			Arguments =
			{
				{ Name = "seconds", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetActiveCategories",
			Type = "Function",

			Returns =
			{
				{ Name = "categories", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetInviteConfirmationInvalidQueues",
			Type = "Function",

			Arguments =
			{
				{ Name = "inviteGUID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "invalidQueues", Type = "table", InnerType = "QueueSpecificInfo", Nilable = false },
			},
		},
		{
			Name = "GetInviteReferralInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "inviteGUID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "outReferredByGuid", Type = "string", Nilable = false },
				{ Name = "outReferredByName", Type = "string", Nilable = false },
				{ Name = "outRelationType", Type = "PartyRequestJoinRelation", Nilable = false },
				{ Name = "outIsQuickJoin", Type = "bool", Nilable = false },
				{ Name = "outClubId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetMinLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "category", Type = "number", Nilable = true, Documentation = { "If not provided, the active party is used" } },
			},

			Returns =
			{
				{ Name = "minLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "InviteUnit",
			Type = "Function",
			Documentation = { "Attempt to invite the named unit to a party, requires confirmation in some cases (e.g. the party will convert to a raid, or if there is a party sync in progress)." },

			Arguments =
			{
				{ Name = "targetName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "IsPartyFull",
			Type = "Function",

			Arguments =
			{
				{ Name = "category", Type = "number", Nilable = true, Documentation = { "If not provided, the active party is used" } },
			},

			Returns =
			{
				{ Name = "isFull", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPartyInJailersTower",
			Type = "Function",

			Returns =
			{
				{ Name = "isPartyInJailersTower", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LeaveParty",
			Type = "Function",
			Documentation = { "Usually this will leave the party immediately. In some cases (e.g. PartySync) the user will be prompted to confirm leaving the party, because it's potentially destructive" },

			Arguments =
			{
				{ Name = "category", Type = "number", Nilable = true },
			},
		},
		{
			Name = "RequestInviteFromUnit",
			Type = "Function",
			Documentation = { "Attempt to request an invite into the target party, requires confirmation in some cases (e.g. there is a party sync in progress)." },

			Arguments =
			{
				{ Name = "targetName", Type = "string", Nilable = false },
				{ Name = "tank", Type = "bool", Nilable = true },
				{ Name = "healer", Type = "bool", Nilable = true },
				{ Name = "dps", Type = "bool", Nilable = true },
			},
		},
	},

	Events =
	{
		{
			Name = "BnetRequestInviteConfirmation",
			Type = "Event",
			LiteralName = "BNET_REQUEST_INVITE_CONFIRMATION",
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
			Name = "ConvertToRaidConfirmation",
			Type = "Event",
			LiteralName = "CONVERT_TO_RAID_CONFIRMATION",
		},
		{
			Name = "EnteredDifferentInstanceFromParty",
			Type = "Event",
			LiteralName = "ENTERED_DIFFERENT_INSTANCE_FROM_PARTY",
		},
		{
			Name = "GroupFormed",
			Type = "Event",
			LiteralName = "GROUP_FORMED",
			Payload =
			{
				{ Name = "category", Type = "number", Nilable = false },
				{ Name = "partyGUID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GroupInviteConfirmation",
			Type = "Event",
			LiteralName = "GROUP_INVITE_CONFIRMATION",
		},
		{
			Name = "GroupJoined",
			Type = "Event",
			LiteralName = "GROUP_JOINED",
			Payload =
			{
				{ Name = "category", Type = "number", Nilable = false },
				{ Name = "partyGUID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GroupLeft",
			Type = "Event",
			LiteralName = "GROUP_LEFT",
			Payload =
			{
				{ Name = "category", Type = "number", Nilable = false },
				{ Name = "partyGUID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GroupRosterUpdate",
			Type = "Event",
			LiteralName = "GROUP_ROSTER_UPDATE",
		},
		{
			Name = "InstanceBootStart",
			Type = "Event",
			LiteralName = "INSTANCE_BOOT_START",
		},
		{
			Name = "InstanceBootStop",
			Type = "Event",
			LiteralName = "INSTANCE_BOOT_STOP",
		},
		{
			Name = "InstanceGroupSizeChanged",
			Type = "Event",
			LiteralName = "INSTANCE_GROUP_SIZE_CHANGED",
		},
		{
			Name = "InviteToPartyConfirmation",
			Type = "Event",
			LiteralName = "INVITE_TO_PARTY_CONFIRMATION",
			Payload =
			{
				{ Name = "targetName", Type = "string", Nilable = false },
				{ Name = "willConvertToRaid", Type = "bool", Nilable = false },
				{ Name = "questSessionActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "InviteTravelPassConfirmation",
			Type = "Event",
			LiteralName = "INVITE_TRAVEL_PASS_CONFIRMATION",
			Payload =
			{
				{ Name = "targetName", Type = "string", Nilable = false },
				{ Name = "targetGUID", Type = "string", Nilable = false },
				{ Name = "willConvertToRaid", Type = "bool", Nilable = false },
				{ Name = "questSessionActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LeavePartyConfirmation",
			Type = "Event",
			LiteralName = "LEAVE_PARTY_CONFIRMATION",
		},
		{
			Name = "PartyInviteCancel",
			Type = "Event",
			LiteralName = "PARTY_INVITE_CANCEL",
		},
		{
			Name = "PartyInviteRequest",
			Type = "Event",
			LiteralName = "PARTY_INVITE_REQUEST",
			Payload =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "isTank", Type = "bool", Nilable = false },
				{ Name = "isHealer", Type = "bool", Nilable = false },
				{ Name = "isDamage", Type = "bool", Nilable = false },
				{ Name = "isNativeRealm", Type = "bool", Nilable = false },
				{ Name = "allowMultipleRoles", Type = "bool", Nilable = false },
				{ Name = "inviterGUID", Type = "string", Nilable = false },
				{ Name = "questSessionActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PartyLeaderChanged",
			Type = "Event",
			LiteralName = "PARTY_LEADER_CHANGED",
		},
		{
			Name = "PartyLfgRestricted",
			Type = "Event",
			LiteralName = "PARTY_LFG_RESTRICTED",
		},
		{
			Name = "PartyLootMethodChanged",
			Type = "Event",
			LiteralName = "PARTY_LOOT_METHOD_CHANGED",
		},
		{
			Name = "PartyMemberDisable",
			Type = "Event",
			LiteralName = "PARTY_MEMBER_DISABLE",
			Payload =
			{
				{ Name = "unitTarget", Type = "string", Nilable = false },
			},
		},
		{
			Name = "PartyMemberEnable",
			Type = "Event",
			LiteralName = "PARTY_MEMBER_ENABLE",
			Payload =
			{
				{ Name = "unitTarget", Type = "string", Nilable = false },
			},
		},
		{
			Name = "PlayerDifficultyChanged",
			Type = "Event",
			LiteralName = "PLAYER_DIFFICULTY_CHANGED",
		},
		{
			Name = "PlayerRolesAssigned",
			Type = "Event",
			LiteralName = "PLAYER_ROLES_ASSIGNED",
		},
		{
			Name = "RaidRosterUpdate",
			Type = "Event",
			LiteralName = "RAID_ROSTER_UPDATE",
		},
		{
			Name = "ReadyCheck",
			Type = "Event",
			LiteralName = "READY_CHECK",
			Payload =
			{
				{ Name = "initiatorName", Type = "string", Nilable = false },
				{ Name = "readyCheckTimeLeft", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ReadyCheckConfirm",
			Type = "Event",
			LiteralName = "READY_CHECK_CONFIRM",
			Payload =
			{
				{ Name = "unitTarget", Type = "string", Nilable = false },
				{ Name = "isReady", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ReadyCheckFinished",
			Type = "Event",
			LiteralName = "READY_CHECK_FINISHED",
			Payload =
			{
				{ Name = "preempted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestInviteConfirmation",
			Type = "Event",
			LiteralName = "REQUEST_INVITE_CONFIRMATION",
			Payload =
			{
				{ Name = "targetName", Type = "string", Nilable = false },
				{ Name = "partyLevelLink", Type = "number", Nilable = false },
				{ Name = "questSessionActive", Type = "bool", Nilable = false },
				{ Name = "tank", Type = "bool", Nilable = true },
				{ Name = "healer", Type = "bool", Nilable = true },
				{ Name = "dps", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "RoleChangedInform",
			Type = "Event",
			LiteralName = "ROLE_CHANGED_INFORM",
			Payload =
			{
				{ Name = "changedName", Type = "string", Nilable = false },
				{ Name = "fromName", Type = "string", Nilable = false },
				{ Name = "oldRole", Type = "string", Nilable = false },
				{ Name = "newRole", Type = "string", Nilable = false },
			},
		},
		{
			Name = "RolePollBegin",
			Type = "Event",
			LiteralName = "ROLE_POLL_BEGIN",
			Payload =
			{
				{ Name = "fromName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "VoteKickReasonNeeded",
			Type = "Event",
			LiteralName = "VOTE_KICK_REASON_NEEDED",
			Payload =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "resultGUID", Type = "string", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "PartyRequestJoinRelation",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "PartyRequestJoinRelation", EnumValue = 0 },
				{ Name = "Friend", Type = "PartyRequestJoinRelation", EnumValue = 1 },
				{ Name = "Guild", Type = "PartyRequestJoinRelation", EnumValue = 2 },
				{ Name = "Club", Type = "PartyRequestJoinRelation", EnumValue = 3 },
				{ Name = "NumPartyRequestJoinRelations", Type = "PartyRequestJoinRelation", EnumValue = 4 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PartyInfo);