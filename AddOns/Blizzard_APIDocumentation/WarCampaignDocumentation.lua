local WarCampaign =
{
	Name = "WarCampaign",
	Type = "System",
	Namespace = "C_CampaignInfo",

	Functions =
	{
		{
			Name = "GetCampaignChapterInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "campaignChapterID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "campaignChapterInfo", Type = "CampaignChapterInfo", Nilable = true },
			},
		},
		{
			Name = "GetCampaignInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "campaignID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "campaignInfo", Type = "CampaignInfo", Nilable = true },
			},
		},
		{
			Name = "GetCurrentCampaignChapterID",
			Type = "Function",

			Returns =
			{
				{ Name = "campaignChapterID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetCurrentCampaignID",
			Type = "Function",

			Returns =
			{
				{ Name = "campaignID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "IsCampaignQuest",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isCampaignQuest", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "CampaignChapterInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "rewardQuestID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CampaignInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "uiTextureKitID", Type = "number", Nilable = false },
				{ Name = "visibilityConditionMatched", Type = "bool", Nilable = false },
				{ Name = "playerConditionFailedReason", Type = "string", Nilable = true },
				{ Name = "complete", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(WarCampaign);