local TransmogShared =
{
	Tables =
	{
		{
			Name = "TransmogCollectionType",
			Type = "Enumeration",
			NumValues = 30,
			MinValue = 0,
			MaxValue = 29,
			Fields =
			{
				{ Name = "None", Type = "TransmogCollectionType", EnumValue = 0 },
				{ Name = "Head", Type = "TransmogCollectionType", EnumValue = 1 },
				{ Name = "Shoulder", Type = "TransmogCollectionType", EnumValue = 2 },
				{ Name = "Back", Type = "TransmogCollectionType", EnumValue = 3 },
				{ Name = "Chest", Type = "TransmogCollectionType", EnumValue = 4 },
				{ Name = "Shirt", Type = "TransmogCollectionType", EnumValue = 5 },
				{ Name = "Tabard", Type = "TransmogCollectionType", EnumValue = 6 },
				{ Name = "Wrist", Type = "TransmogCollectionType", EnumValue = 7 },
				{ Name = "Hands", Type = "TransmogCollectionType", EnumValue = 8 },
				{ Name = "Waist", Type = "TransmogCollectionType", EnumValue = 9 },
				{ Name = "Legs", Type = "TransmogCollectionType", EnumValue = 10 },
				{ Name = "Feet", Type = "TransmogCollectionType", EnumValue = 11 },
				{ Name = "Wand", Type = "TransmogCollectionType", EnumValue = 12 },
				{ Name = "OneHAxe", Type = "TransmogCollectionType", EnumValue = 13 },
				{ Name = "OneHSword", Type = "TransmogCollectionType", EnumValue = 14 },
				{ Name = "OneHMace", Type = "TransmogCollectionType", EnumValue = 15 },
				{ Name = "Dagger", Type = "TransmogCollectionType", EnumValue = 16 },
				{ Name = "Fist", Type = "TransmogCollectionType", EnumValue = 17 },
				{ Name = "Shield", Type = "TransmogCollectionType", EnumValue = 18 },
				{ Name = "Holdable", Type = "TransmogCollectionType", EnumValue = 19 },
				{ Name = "TwoHAxe", Type = "TransmogCollectionType", EnumValue = 20 },
				{ Name = "TwoHSword", Type = "TransmogCollectionType", EnumValue = 21 },
				{ Name = "TwoHMace", Type = "TransmogCollectionType", EnumValue = 22 },
				{ Name = "Staff", Type = "TransmogCollectionType", EnumValue = 23 },
				{ Name = "Polearm", Type = "TransmogCollectionType", EnumValue = 24 },
				{ Name = "Bow", Type = "TransmogCollectionType", EnumValue = 25 },
				{ Name = "Gun", Type = "TransmogCollectionType", EnumValue = 26 },
				{ Name = "Crossbow", Type = "TransmogCollectionType", EnumValue = 27 },
				{ Name = "Warglaives", Type = "TransmogCollectionType", EnumValue = 28 },
				{ Name = "Paired", Type = "TransmogCollectionType", EnumValue = 29 },
			},
		},
		{
			Name = "TransmogModification",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Main", Type = "TransmogModification", EnumValue = 0 },
				{ Name = "Secondary", Type = "TransmogModification", EnumValue = 1 },
			},
		},
		{
			Name = "TransmogSearchType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 1,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Items", Type = "TransmogSearchType", EnumValue = 1 },
				{ Name = "BaseSets", Type = "TransmogSearchType", EnumValue = 2 },
				{ Name = "UsableSets", Type = "TransmogSearchType", EnumValue = 3 },
			},
		},
		{
			Name = "TransmogSource",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 0,
			MaxValue = 9,
			Fields =
			{
				{ Name = "None", Type = "TransmogSource", EnumValue = 0 },
				{ Name = "JournalEncounter", Type = "TransmogSource", EnumValue = 1 },
				{ Name = "Quest", Type = "TransmogSource", EnumValue = 2 },
				{ Name = "Vendor", Type = "TransmogSource", EnumValue = 3 },
				{ Name = "WorldDrop", Type = "TransmogSource", EnumValue = 4 },
				{ Name = "HiddenUntilCollected", Type = "TransmogSource", EnumValue = 5 },
				{ Name = "CantCollect", Type = "TransmogSource", EnumValue = 6 },
				{ Name = "Achievement", Type = "TransmogSource", EnumValue = 7 },
				{ Name = "Profession", Type = "TransmogSource", EnumValue = 8 },
				{ Name = "NotValidForTransmog", Type = "TransmogSource", EnumValue = 9 },
			},
		},
		{
			Name = "TransmogType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Appearance", Type = "TransmogType", EnumValue = 0 },
				{ Name = "Illusion", Type = "TransmogType", EnumValue = 1 },
			},
		},
		{
			Name = "TransmogUseErrorType",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "None", Type = "TransmogUseErrorType", EnumValue = 0 },
				{ Name = "PlayerCondition", Type = "TransmogUseErrorType", EnumValue = 1 },
				{ Name = "Skill", Type = "TransmogUseErrorType", EnumValue = 2 },
				{ Name = "Ability", Type = "TransmogUseErrorType", EnumValue = 3 },
				{ Name = "Faction", Type = "TransmogUseErrorType", EnumValue = 4 },
				{ Name = "Holiday", Type = "TransmogUseErrorType", EnumValue = 5 },
				{ Name = "HotRecheckFailed", Type = "TransmogUseErrorType", EnumValue = 6 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(TransmogShared);