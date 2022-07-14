local WarCampaign =
{
	Name = "WarCampaign",
	Type = "System",
	Namespace = "C_CampaignInfo",

	Functions =
	{
		{
			Name = "GetAvailableCampaigns",
			Type = "Function",

			Returns =
			{
				{ Name = "campaignIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
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
			Name = "GetCampaignID",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "campaignID", Type = "number", Nilable = false },
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
			Name = "GetChapterIDs",
			Type = "Function",

			Arguments =
			{
				{ Name = "campaignID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "chapterIDs", Type = "table", InnerType = "number", Nilable = true },
			},
		},
		{
			Name = "GetCurrentChapterID",
			Type = "Function",

			Arguments =
			{
				{ Name = "campaignID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "currentChapterID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetFailureReason",
			Type = "Function",

			Arguments =
			{
				{ Name = "campaignID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "failureReason", Type = "CampaignFailureReason", Nilable = true },
			},
		},
		{
			Name = "GetState",
			Type = "Function",

			Arguments =
			{
				{ Name = "campaignID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "state", Type = "CampaignState", Nilable = false },
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
		{
			Name = "UsesNormalQuestIcons",
			Type = "Function",

			Arguments =
			{
				{ Name = "campaignID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "useNormalQuestIcons", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "CampaignState",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Invalid", Type = "CampaignState", EnumValue = 0 },
				{ Name = "Complete", Type = "CampaignState", EnumValue = 1 },
				{ Name = "InProgress", Type = "CampaignState", EnumValue = 2 },
				{ Name = "Stalled", Type = "CampaignState", EnumValue = 3 },
			},
		},
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
			Name = "CampaignFailureReason",
			Type = "Structure",
			Fields =
			{
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "questID", Type = "number", Nilable = true },
				{ Name = "mapID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "CampaignInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "uiTextureKit", Type = "string", Nilable = false },
				{ Name = "isWarCampaign", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(WarCampaign);