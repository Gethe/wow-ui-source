local GameRulesConstants =
{
	Tables =
	{
		{
			Name = "GameRuleFlags",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "GameRuleFlags", EnumValue = 0 },
				{ Name = "AllowClient", Type = "GameRuleFlags", EnumValue = 1 },
				{ Name = "RequiresDefault", Type = "GameRuleFlags", EnumValue = 2 },
			},
		},
		{
			Name = "GameRuleType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Int", Type = "GameRuleType", EnumValue = 0 },
				{ Name = "Float", Type = "GameRuleType", EnumValue = 1 },
				{ Name = "Bool", Type = "GameRuleType", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(GameRulesConstants);