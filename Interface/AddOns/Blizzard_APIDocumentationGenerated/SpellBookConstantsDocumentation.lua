local SpellBookConstants =
{
	Tables =
	{
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
	},
};

APIDocumentation:AddDocumentationTable(SpellBookConstants);