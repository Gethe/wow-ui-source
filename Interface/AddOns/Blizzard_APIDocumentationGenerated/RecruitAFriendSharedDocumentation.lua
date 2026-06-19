local RecruitAFriendShared =
{
	Tables =
	{
		{
			Name = "RafLinkType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "RafLinkType", EnumValue = 0 },
				{ Name = "Recruit", Type = "RafLinkType", EnumValue = 1 },
				{ Name = "Friend", Type = "RafLinkType", EnumValue = 2 },
				{ Name = "Both", Type = "RafLinkType", EnumValue = 3 },
			},
		},
		{
			Name = "RecruitAFriendFailure",
			Type = "Enumeration",
			NumValues = 11,
			MinValue = 0,
			MaxValue = 10,
			Fields =
			{
				{ Name = "Success", Type = "RecruitAFriendFailure", EnumValue = 0 },
				{ Name = "NotLinked", Type = "RecruitAFriendFailure", EnumValue = 1 },
				{ Name = "NotNow", Type = "RecruitAFriendFailure", EnumValue = 2 },
				{ Name = "NoTarget", Type = "RecruitAFriendFailure", EnumValue = 3 },
				{ Name = "NotInParty", Type = "RecruitAFriendFailure", EnumValue = 4 },
				{ Name = "SummonLevelMax", Type = "RecruitAFriendFailure", EnumValue = 5 },
				{ Name = "SummonCooldown", Type = "RecruitAFriendFailure", EnumValue = 6 },
				{ Name = "InsufExpanLvl", Type = "RecruitAFriendFailure", EnumValue = 7 },
				{ Name = "Offline", Type = "RecruitAFriendFailure", EnumValue = 8 },
				{ Name = "MapIncomingTransferNotAllowed", Type = "RecruitAFriendFailure", EnumValue = 9 },
				{ Name = "NotInClassic", Type = "RecruitAFriendFailure", EnumValue = 10 },
			},
		},
		{
			Name = "RecruitAFriendRewardsVersion",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "InvalidVersion", Type = "RecruitAFriendRewardsVersion", EnumValue = 0 },
				{ Name = "UnusedVersionOne", Type = "RecruitAFriendRewardsVersion", EnumValue = 1 },
				{ Name = "VersionTwo", Type = "RecruitAFriendRewardsVersion", EnumValue = 2 },
				{ Name = "VersionThree", Type = "RecruitAFriendRewardsVersion", EnumValue = 3 },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(RecruitAFriendShared);