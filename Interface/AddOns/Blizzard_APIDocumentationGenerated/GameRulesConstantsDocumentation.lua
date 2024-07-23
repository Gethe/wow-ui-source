local GameRulesConstants =
{
	Tables =
	{
		{
			Name = "GameRuleFlags",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "None", Type = "GameRuleFlags", EnumValue = 0 },
				{ Name = "AllowClient", Type = "GameRuleFlags", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(GameRulesConstants);