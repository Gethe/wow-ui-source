local SpellDiminishConstants =
{
	Tables =
	{
		{
			Name = "SpellDiminishCategory",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 0,
			MaxValue = 7,
			Fields =
			{
				{ Name = "Root", Type = "SpellDiminishCategory", EnumValue = 0 },
				{ Name = "Taunt", Type = "SpellDiminishCategory", EnumValue = 1 },
				{ Name = "Stun", Type = "SpellDiminishCategory", EnumValue = 2 },
				{ Name = "AoEKnockback", Type = "SpellDiminishCategory", EnumValue = 3 },
				{ Name = "Incapacitate", Type = "SpellDiminishCategory", EnumValue = 4 },
				{ Name = "Disorient", Type = "SpellDiminishCategory", EnumValue = 5 },
				{ Name = "Silence", Type = "SpellDiminishCategory", EnumValue = 6 },
				{ Name = "Disarm", Type = "SpellDiminishCategory", EnumValue = 7 },
			},
		},
		{
			Name = "SpellDiminishRuleset",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "SpellDiminishRuleset", EnumValue = 0 },
				{ Name = "PvE", Type = "SpellDiminishRuleset", EnumValue = 1 },
				{ Name = "PvP", Type = "SpellDiminishRuleset", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SpellDiminishConstants);