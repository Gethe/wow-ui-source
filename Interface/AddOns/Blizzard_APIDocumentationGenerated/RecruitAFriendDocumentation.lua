local RecruitAFriend =
{
	Name = "RecruitAFriend",
	Type = "System",
	Namespace = "C_RecruitAFriend",

	Functions =
	{
		{
			Name = "CanGrantLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanSummonFriend",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetSummonFriendCooldown",
			Type = "Function",

			Returns =
			{
				{ Name = "startTimeSeconds", Type = "number", Nilable = false },
				{ Name = "durationSeconds", Type = "number", Nilable = false },
				{ Name = "enableCooldownTimer", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsReferAFriendLinked",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SummonFriend",
			Type = "Function",

			Arguments =
			{
				{ Name = "target", Type = "WOWGUID", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "LevelGrantProposed",
			Type = "Event",
			LiteralName = "LEVEL_GRANT_PROPOSED",
			Payload =
			{
				{ Name = "senderName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "PartyReferAFriendUpdated",
			Type = "Event",
			LiteralName = "PARTY_REFER_A_FRIEND_UPDATED",
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitToken", Nilable = false },
			},
		},
		{
			Name = "RecruitAFriendCanEmail",
			Type = "Event",
			LiteralName = "RECRUIT_A_FRIEND_CAN_EMAIL",
			Payload =
			{
				{ Name = "resultCode", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RecruitAFriendInvitationFailed",
			Type = "Event",
			LiteralName = "RECRUIT_A_FRIEND_INVITATION_FAILED",
			Payload =
			{
				{ Name = "failureReason", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "RecruitAFriendInviterFriendAdded",
			Type = "Event",
			LiteralName = "RECRUIT_A_FRIEND_INVITER_FRIEND_ADDED",
			Payload =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "RecruitAFriendSystemStatus",
			Type = "Event",
			LiteralName = "RECRUIT_A_FRIEND_SYSTEM_STATUS",
		},
		{
			Name = "SorByTextUpdated",
			Type = "Event",
			LiteralName = "SOR_BY_TEXT_UPDATED",
		},
		{
			Name = "SorCountsUpdated",
			Type = "Event",
			LiteralName = "SOR_COUNTS_UPDATED",
		},
		{
			Name = "SorStartExperienceIncomplete",
			Type = "Event",
			LiteralName = "SOR_START_EXPERIENCE_INCOMPLETE",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(RecruitAFriend);