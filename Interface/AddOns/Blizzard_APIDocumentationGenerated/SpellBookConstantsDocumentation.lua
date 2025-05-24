local SpellBookConstants =
{
	Tables =
	{
		{
			Name = "SpellBookSkillLineIndex",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 1,
			MaxValue = 4,
			Fields =
			{
				{ Name = "General", Type = "SpellBookSkillLineIndex", EnumValue = 1 },
				{ Name = "Class", Type = "SpellBookSkillLineIndex", EnumValue = 2 },
				{ Name = "MainSpec", Type = "SpellBookSkillLineIndex", EnumValue = 3 },
				{ Name = "OffSpecStart", Type = "SpellBookSkillLineIndex", EnumValue = 4 },
			},
		},
		{
			Name = "SpellBookItemType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "SpellBookItemType", EnumValue = 0 },
				{ Name = "Spell", Type = "SpellBookItemType", EnumValue = 1 },
				{ Name = "FutureSpell", Type = "SpellBookItemType", EnumValue = 2 },
				{ Name = "PetAction", Type = "SpellBookItemType", EnumValue = 3 },
				{ Name = "Flyout", Type = "SpellBookItemType", EnumValue = 4 },
			},
		},
		{
			Name = "SpellBookSpellBank",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Player", Type = "SpellBookSpellBank", EnumValue = 0 },
				{ Name = "Pet", Type = "SpellBookSpellBank", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SpellBookConstants);