local CommentatorShared =
{
	Tables =
	{
		{
			Name = "TrackedSpellCategory",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "TrackedSpellCategory", EnumValue = 0 },
				{ Name = "Offensive", Type = "TrackedSpellCategory", EnumValue = 1 },
				{ Name = "Defensive", Type = "TrackedSpellCategory", EnumValue = 2 },
				{ Name = "Debuff", Type = "TrackedSpellCategory", EnumValue = 3 },
				{ Name = "RacialAbility", Type = "TrackedSpellCategory", EnumValue = 4 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CommentatorShared);