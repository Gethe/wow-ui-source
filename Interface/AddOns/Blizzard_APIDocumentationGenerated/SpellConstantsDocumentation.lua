local SpellConstants =
{
	Tables =
	{
		{
			Name = "ConfirmationPromptUIType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "StaticText", Type = "ConfirmationPromptUIType", EnumValue = 0 },
				{ Name = "BonusRoll", Type = "ConfirmationPromptUIType", EnumValue = 1 },
				{ Name = "SimpleWarning", Type = "ConfirmationPromptUIType", EnumValue = 2 },
				{ Name = "StaticTextAlert", Type = "ConfirmationPromptUIType", EnumValue = 3 },
				{ Name = "SimpleWarningAlert", Type = "ConfirmationPromptUIType", EnumValue = 4 },
			},
		},
		{
			Name = "SpellAuraVisibilityType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "RaidInCombat", Type = "SpellAuraVisibilityType", EnumValue = 0 },
				{ Name = "RaidOutOfCombat", Type = "SpellAuraVisibilityType", EnumValue = 1 },
				{ Name = "EnemyTarget", Type = "SpellAuraVisibilityType", EnumValue = 2 },
			},
		},
		{
			Name = "SpellCooldownConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "GLOBAL_RECOVERY_CATEGORY", Type = "number", Value = 133 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SpellConstants);