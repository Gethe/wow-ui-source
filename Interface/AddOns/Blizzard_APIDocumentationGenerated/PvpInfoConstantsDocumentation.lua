local PvpInfoConstants =
{
	Tables =
	{
		{
			Name = "PvPRanks",
			Type = "Enumeration",
			NumValues = 19,
			MinValue = 0,
			MaxValue = 18,
			Fields =
			{
				{ Name = "RankNone", Type = "PvPRanks", EnumValue = 0 },
				{ Name = "RankPariah", Type = "PvPRanks", EnumValue = 1 },
				{ Name = "RankOutlaw", Type = "PvPRanks", EnumValue = 2 },
				{ Name = "RankExiled", Type = "PvPRanks", EnumValue = 3 },
				{ Name = "RankDishonored", Type = "PvPRanks", EnumValue = 4 },
				{ Name = "Rank_1", Type = "PvPRanks", EnumValue = 5 },
				{ Name = "Rank_2", Type = "PvPRanks", EnumValue = 6 },
				{ Name = "Rank_3", Type = "PvPRanks", EnumValue = 7 },
				{ Name = "Rank_4", Type = "PvPRanks", EnumValue = 8 },
				{ Name = "Rank_5", Type = "PvPRanks", EnumValue = 9 },
				{ Name = "Rank_6", Type = "PvPRanks", EnumValue = 10 },
				{ Name = "Rank_7", Type = "PvPRanks", EnumValue = 11 },
				{ Name = "Rank_8", Type = "PvPRanks", EnumValue = 12 },
				{ Name = "Rank_9", Type = "PvPRanks", EnumValue = 13 },
				{ Name = "Rank_10", Type = "PvPRanks", EnumValue = 14 },
				{ Name = "Rank_11", Type = "PvPRanks", EnumValue = 15 },
				{ Name = "Rank_12", Type = "PvPRanks", EnumValue = 16 },
				{ Name = "Rank_13", Type = "PvPRanks", EnumValue = 17 },
				{ Name = "Rank_14", Type = "PvPRanks", EnumValue = 18 },
			},
		},
		{
			Name = "PvpInfoConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "MaxPlayersPerInstance", Type = "number", Value = 80 },
				{ Name = "MAX_PVP_LOCK_LIST_MAP", Type = "number", Value = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PvpInfoConstants);