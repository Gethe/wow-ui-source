local PlayerInfo =
{
	Name = "PlayerInfo",
	Type = "System",
	Namespace = "C_PlayerInfo",

	Functions =
	{
		{
			Name = "CanPlayerEnterChromieTime",
			Type = "Function",

			Returns =
			{
				{ Name = "canEnter", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanPlayerUseAreaLoot",
			Type = "Function",

			Returns =
			{
				{ Name = "canUseAreaLoot", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanPlayerUseMountEquipment",
			Type = "Function",

			Returns =
			{
				{ Name = "canUseMountEquipment", Type = "bool", Nilable = false },
				{ Name = "failureReason", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetAlternateFormInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "hasAlternateForm", Type = "bool", Nilable = false },
				{ Name = "inAlternateForm", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetContentDifficultyCreatureForPlayer",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "difficulty", Type = "RelativeContentDifficulty", Nilable = false },
			},
		},
		{
			Name = "GetContentDifficultyQuestForPlayer",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "difficulty", Type = "RelativeContentDifficulty", Nilable = false },
			},
		},
		{
			Name = "GetInstancesUnlockedAtLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "isRaid", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "dungeonID", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetPlayerMythicPlusRatingSummary",
			Type = "Function",
			Documentation = { "Returns the players mythic+ rating summary which includes the runs they've completed as well as their current season m+ rating" },

			Arguments =
			{
				{ Name = "playerToken", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "ratingSummary", Type = "MythicPlusRatingSummary", Nilable = false },
			},
		},
		{
			Name = "IsPlayerEligibleForNPE",
			Type = "Function",

			Returns =
			{
				{ Name = "isEligible", Type = "bool", Nilable = false },
				{ Name = "failureReason", Type = "string", Nilable = false },
			},
		},
		{
			Name = "IsPlayerEligibleForNPEv2",
			Type = "Function",

			Returns =
			{
				{ Name = "isEligible", Type = "bool", Nilable = false },
				{ Name = "failureReason", Type = "string", Nilable = false },
			},
		},
		{
			Name = "IsPlayerInChromieTime",
			Type = "Function",

			Returns =
			{
				{ Name = "inChromieTime", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPlayerNPERestricted",
			Type = "Function",

			Returns =
			{
				{ Name = "isRestricted", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "MythicPlusRatingMapSummary",
			Type = "Structure",
			Documentation = { "Specific information about a completed mythic plus run." },
			Fields =
			{
				{ Name = "challengeModeID", Type = "number", Nilable = false },
				{ Name = "mapScore", Type = "number", Nilable = false },
				{ Name = "bestRunLevel", Type = "number", Nilable = false },
				{ Name = "bestRunDurationMS", Type = "number", Nilable = false },
				{ Name = "finishedSuccess", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "MythicPlusRatingSummary",
			Type = "Structure",
			Documentation = { "The current season rating and well as a list of completed mythic plus runs." },
			Fields =
			{
				{ Name = "currentSeasonScore", Type = "number", Nilable = false },
				{ Name = "runs", Type = "table", InnerType = "MythicPlusRatingMapSummary", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PlayerInfo);