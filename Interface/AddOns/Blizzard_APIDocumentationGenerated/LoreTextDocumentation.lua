local LoreText =
{
	Name = "LoreText",
	Type = "System",
	Namespace = "C_LoreText",
	Environment = "All",

	Functions =
	{
		{
			Name = "RequestLoreTextForCampaignID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "campaignID", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "LoreTextUpdatedCampaign",
			Type = "Event",
			LiteralName = "LORE_TEXT_UPDATED_CAMPAIGN",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "campaignID", Type = "number", Nilable = false },
				{ Name = "textEntries", Type = "table", InnerType = "LoreTextEntry", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "LoreTextEntry",
			Type = "Structure",
			Fields =
			{
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "isHeader", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LoreText);