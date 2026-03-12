local AutoCompleteShared =
{
	Tables =
	{
		{
			Name = "AutoCompleteEntryFlag",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 1,
			MaxValue = 256,
			Fields =
			{
				{ Name = "InGroup", Type = "AutoCompleteEntryFlag", EnumValue = 1 },
				{ Name = "InGuild", Type = "AutoCompleteEntryFlag", EnumValue = 2 },
				{ Name = "Friend", Type = "AutoCompleteEntryFlag", EnumValue = 4 },
				{ Name = "Bnet", Type = "AutoCompleteEntryFlag", EnumValue = 8 },
				{ Name = "InteractedWith", Type = "AutoCompleteEntryFlag", EnumValue = 16 },
				{ Name = "Online", Type = "AutoCompleteEntryFlag", EnumValue = 32 },
				{ Name = "InAOI", Type = "AutoCompleteEntryFlag", EnumValue = 64 },
				{ Name = "AccountCharacter", Type = "AutoCompleteEntryFlag", EnumValue = 128 },
				{ Name = "RecentPlayer", Type = "AutoCompleteEntryFlag", EnumValue = 256 },
			},
		},
		{
			Name = "AutoCompletePriority",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "Other", Type = "AutoCompletePriority", EnumValue = 0 },
				{ Name = "Interacted", Type = "AutoCompletePriority", EnumValue = 1 },
				{ Name = "InGroup", Type = "AutoCompletePriority", EnumValue = 2 },
				{ Name = "Guild", Type = "AutoCompletePriority", EnumValue = 3 },
				{ Name = "Friend", Type = "AutoCompletePriority", EnumValue = 4 },
				{ Name = "AccountCharacter", Type = "AutoCompletePriority", EnumValue = 5 },
				{ Name = "AccountCharacterSameRealm", Type = "AutoCompletePriority", EnumValue = 6 },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(AutoCompleteShared);