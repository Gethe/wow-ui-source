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
	},
};

APIDocumentation:AddDocumentationTable(PlayerInfo);