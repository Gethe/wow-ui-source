local MythicPlusInfoShared =
{
	Tables =
	{
		{
			Name = "MythicPlusAffixScoreInfo",
			Type = "Structure",
			Documentation = { "Information about a specific M+ run" },
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "score", Type = "number", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "durationSec", Type = "number", Nilable = false },
				{ Name = "overTime", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "MythicPlusLeaderboardPlayerResult",
			Type = "Structure",
			Fields =
			{
				{ Name = "playerGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "specID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "MythicPlusLeaderboardResult",
			Type = "Structure",
			Fields =
			{
				{ Name = "completionTime", Type = "number", Nilable = false },
				{ Name = "players", Type = "table", InnerType = "MythicPlusLeaderboardPlayerResult", Nilable = false },
			},
		},
		{
			Name = "MythicPlusRatingLinkInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "mapChallengeModeID", Type = "number", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "completedInTime", Type = "number", Nilable = false },
				{ Name = "dungeonScore", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(MythicPlusInfoShared);