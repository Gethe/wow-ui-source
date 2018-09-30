local SummonInfo =
{
	Name = "SummonInfo",
	Type = "System",
	Namespace = "C_SummonInfo",

	Functions =
	{
		{
			Name = "CancelSummon",
			Type = "Function",
		},
		{
			Name = "ConfirmSummon",
			Type = "Function",
		},
		{
			Name = "GetSummonConfirmAreaName",
			Type = "Function",

			Returns =
			{
				{ Name = "areaName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetSummonConfirmSummoner",
			Type = "Function",

			Returns =
			{
				{ Name = "summoner", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetSummonConfirmTimeLeft",
			Type = "Function",

			Returns =
			{
				{ Name = "timeLeft", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSummonReason",
			Type = "Function",

			Returns =
			{
				{ Name = "summonReason", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsSummonSkippingStartExperience",
			Type = "Function",

			Returns =
			{
				{ Name = "isSummonSkippingStartExperience", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SummonInfo);