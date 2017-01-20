local PvpInfoLua =
{
	Name = "PvpInfo",
	Namespace = "C_PvP",

	Functions =
	{
		{
			Name = "GetArenaCrowdControlInfo",

			Arguments =
			{
				{ Name = "playerToken", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "startTime", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetArenaRewards",

			Arguments =
			{
				{ Name = "teamSize", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "honor", Type = "number", Nilable = false },
				{ Name = "experience", Type = "number", Nilable = false },
				{ Name = "rewards", Type = "table", InnerType = "BattlefieldReward", Nilable = true },
			},
		},
		{
			Name = "GetArenaSkirmishRewards",

			Returns =
			{
				{ Name = "honor", Type = "number", Nilable = false },
				{ Name = "experience", Type = "number", Nilable = false },
				{ Name = "rewards", Type = "table", InnerType = "BattlefieldReward", Nilable = true },
			},
		},
		{
			Name = "GetBrawlInfo",

			Returns =
			{
				{ Name = "brawlInfo", Type = "PvpBrawlInfo", Nilable = false },
			},
		},
		{
			Name = "GetGlobalPvpScalingInfoForSpecID",

			Arguments =
			{
				{ Name = "specializationID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "pvpScalingData", Type = "table", InnerType = "PvpScalingData", Nilable = false },
			},
		},
		{
			Name = "GetRandomBGRewards",

			Returns =
			{
				{ Name = "honor", Type = "number", Nilable = false },
				{ Name = "experience", Type = "number", Nilable = false },
				{ Name = "rewards", Type = "table", InnerType = "BattlefieldReward", Nilable = true },
			},
		},
		{
			Name = "GetRatedBGRewards",

			Returns =
			{
				{ Name = "honor", Type = "number", Nilable = false },
				{ Name = "experience", Type = "number", Nilable = false },
				{ Name = "rewards", Type = "table", InnerType = "BattlefieldReward", Nilable = true },
			},
		},
		{
			Name = "HasArenaSkirmishWinToday",

			Returns =
			{
				{ Name = "hasArenaSkirmishWinToday", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "JoinBrawl",
		},
		{
			Name = "RequestBrawlInfo",
		},
		{
			Name = "RequestCrowdControlSpell",

			Arguments =
			{
				{ Name = "playerToken", Type = "string", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "BattlefieldReward",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "texture", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PvpBrawlInfo",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "shortDescription", Type = "string", Nilable = false },
				{ Name = "longDescrition", Type = "string", Nilable = false },
				{ Name = "active", Type = "bool", Nilable = false },
				{ Name = "timeLeftUntilNextChange", Type = "number", Nilable = false },
				{ Name = "mapNames", Type = "table", InnerType = "string", Nilable = false },
			},
		},
		{
			Name = "PvpScalingData",
			Fields =
			{
				{ Name = "scalingDataID", Type = "number", Nilable = false },
				{ Name = "specializationID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "value", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PvpInfoLua);