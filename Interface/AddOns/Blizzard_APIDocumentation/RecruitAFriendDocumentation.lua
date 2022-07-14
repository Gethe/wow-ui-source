local RecruitAFriend =
{
	Name = "RecruitAFriend",
	Type = "System",
	Namespace = "C_RecruitAFriend",

	Functions =
	{
		{
			Name = "ClaimActivityReward",
			Type = "Function",

			Arguments =
			{
				{ Name = "activityID", Type = "number", Nilable = false },
				{ Name = "acceptanceID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ClaimNextReward",
			Type = "Function",

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GenerateRecruitmentLink",
			Type = "Function",

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetRAFInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "RafInfo", Nilable = false },
			},
		},
		{
			Name = "GetRAFSystemInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "systemInfo", Type = "RafSystemInfo", Nilable = false },
			},
		},
		{
			Name = "GetRecruitActivityRequirementsText",
			Type = "Function",

			Arguments =
			{
				{ Name = "activityID", Type = "number", Nilable = false },
				{ Name = "acceptanceID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "requirementsText", Type = "table", InnerType = "string", Nilable = false },
			},
		},
		{
			Name = "GetRecruitInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "active", Type = "bool", Nilable = false },
				{ Name = "faction", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRecruitingEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RemoveRAFRecruit",
			Type = "Function",

			Arguments =
			{
				{ Name = "wowAccountGUID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestUpdatedRecruitmentInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "RafInfoUpdated",
			Type = "Event",
			LiteralName = "RAF_INFO_UPDATED",
			Payload =
			{
				{ Name = "info", Type = "RafInfo", Nilable = false },
			},
		},
		{
			Name = "RafRecruitingEnabledStatus",
			Type = "Event",
			LiteralName = "RAF_RECRUITING_ENABLED_STATUS",
			Payload =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RafSystemEnabledStatus",
			Type = "Event",
			LiteralName = "RAF_SYSTEM_ENABLED_STATUS",
			Payload =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RafSystemInfoUpdated",
			Type = "Event",
			LiteralName = "RAF_SYSTEM_INFO_UPDATED",
			Payload =
			{
				{ Name = "systemInfo", Type = "RafSystemInfo", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "RafRecruitActivityState",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Incomplete", Type = "RafRecruitActivityState", EnumValue = 0 },
				{ Name = "Complete", Type = "RafRecruitActivityState", EnumValue = 1 },
				{ Name = "RewardClaimed", Type = "RafRecruitActivityState", EnumValue = 2 },
			},
		},
		{
			Name = "RafRecruitSubStatus",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Trial", Type = "RafRecruitSubStatus", EnumValue = 0 },
				{ Name = "Active", Type = "RafRecruitSubStatus", EnumValue = 1 },
				{ Name = "Inactive", Type = "RafRecruitSubStatus", EnumValue = 2 },
			},
		},
		{
			Name = "RafRewardType",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 0,
			MaxValue = 7,
			Fields =
			{
				{ Name = "Pet", Type = "RafRewardType", EnumValue = 0 },
				{ Name = "Mount", Type = "RafRewardType", EnumValue = 1 },
				{ Name = "Appearance", Type = "RafRewardType", EnumValue = 2 },
				{ Name = "Title", Type = "RafRewardType", EnumValue = 3 },
				{ Name = "GameTime", Type = "RafRewardType", EnumValue = 4 },
				{ Name = "AppearanceSet", Type = "RafRewardType", EnumValue = 5 },
				{ Name = "Illusion", Type = "RafRewardType", EnumValue = 6 },
				{ Name = "Invalid", Type = "RafRewardType", EnumValue = 7 },
			},
		},
		{
			Name = "RafAppearanceInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "appearanceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RafAppearanceSetInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "setID", Type = "number", Nilable = false },
				{ Name = "setName", Type = "string", Nilable = false },
				{ Name = "appearanceIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "RafIllusionInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "spellItemEnchantmentID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RafInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "lifetimeMonths", Type = "number", Nilable = false },
				{ Name = "spentMonths", Type = "number", Nilable = false },
				{ Name = "availableMonths", Type = "number", Nilable = false },
				{ Name = "claimInProgress", Type = "bool", Nilable = false },
				{ Name = "rewards", Type = "table", InnerType = "RafReward", Nilable = false },
				{ Name = "nextReward", Type = "RafReward", Nilable = true },
				{ Name = "recruitmentInfo", Type = "RafRecruitmentinfo", Nilable = true },
				{ Name = "recruits", Type = "table", InnerType = "RafRecruit", Nilable = false },
			},
		},
		{
			Name = "RafMountInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "mountID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RafPetInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "creatureID", Type = "number", Nilable = false },
				{ Name = "speciesID", Type = "number", Nilable = false },
				{ Name = "displayID", Type = "number", Nilable = false },
				{ Name = "speciesName", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
			},
		},
		{
			Name = "RafRecruit",
			Type = "Structure",
			Fields =
			{
				{ Name = "bnetAccountID", Type = "number", Nilable = false },
				{ Name = "wowAccountGUID", Type = "string", Nilable = false },
				{ Name = "battleTag", Type = "string", Nilable = false },
				{ Name = "monthsRemaining", Type = "number", Nilable = false },
				{ Name = "subStatus", Type = "RafRecruitSubStatus", Nilable = false },
				{ Name = "acceptanceID", Type = "string", Nilable = false },
				{ Name = "activities", Type = "table", InnerType = "RafRecruitActivity", Nilable = false },
			},
		},
		{
			Name = "RafRecruitActivity",
			Type = "Structure",
			Fields =
			{
				{ Name = "activityID", Type = "number", Nilable = false },
				{ Name = "rewardQuestID", Type = "number", Nilable = false },
				{ Name = "state", Type = "RafRecruitActivityState", Nilable = false },
			},
		},
		{
			Name = "RafRecruitmentinfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "recruitmentCode", Type = "string", Nilable = false },
				{ Name = "recruitmentURL", Type = "string", Nilable = false },
				{ Name = "expireTime", Type = "number", Nilable = false },
				{ Name = "remainingTimeSeconds", Type = "number", Nilable = false },
				{ Name = "totalUses", Type = "number", Nilable = false },
				{ Name = "remainingUses", Type = "number", Nilable = false },
				{ Name = "sourceRealm", Type = "string", Nilable = false },
				{ Name = "sourceFaction", Type = "string", Nilable = false },
			},
		},
		{
			Name = "RafReward",
			Type = "Structure",
			Fields =
			{
				{ Name = "rewardID", Type = "number", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "rewardType", Type = "RafRewardType", Nilable = false },
				{ Name = "petInfo", Type = "RafPetInfo", Nilable = true },
				{ Name = "mountInfo", Type = "RafMountInfo", Nilable = true },
				{ Name = "appearanceInfo", Type = "RafAppearanceInfo", Nilable = true },
				{ Name = "titleInfo", Type = "RafTitleInfo", Nilable = true },
				{ Name = "appearanceSetInfo", Type = "RafAppearanceSetInfo", Nilable = true },
				{ Name = "illusionInfo", Type = "RafIllusionInfo", Nilable = true },
				{ Name = "canClaim", Type = "bool", Nilable = false },
				{ Name = "claimed", Type = "bool", Nilable = false },
				{ Name = "repeatable", Type = "bool", Nilable = false },
				{ Name = "repeatableClaimCount", Type = "number", Nilable = false },
				{ Name = "monthsRequired", Type = "number", Nilable = false },
				{ Name = "monthCost", Type = "number", Nilable = false },
				{ Name = "availableInMonths", Type = "number", Nilable = false },
				{ Name = "iconID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RafSystemInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "maxRecruits", Type = "number", Nilable = false },
				{ Name = "maxRecruitMonths", Type = "number", Nilable = false },
				{ Name = "maxRecruitmentUses", Type = "number", Nilable = false },
				{ Name = "daysInCycle", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RafTitleInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "titleMaskID", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(RecruitAFriend);