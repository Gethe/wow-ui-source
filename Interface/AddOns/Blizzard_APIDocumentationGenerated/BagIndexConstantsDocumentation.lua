local BagIndexConstants =
{
	Name = "BagIndexConstants",
	Type = "System",

	Functions =
	{
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "BagIndex",
			Type = "Enumeration",
			NumValues = 20,
			MinValue = -3,
			MaxValue = 16,
			Fields =
			{
				{ Name = "Accountbanktab", Type = "BagIndex", EnumValue = -3 },
				{ Name = "Characterbanktab", Type = "BagIndex", EnumValue = -2 },
				{ Name = "Keyring", Type = "BagIndex", EnumValue = -1 },
				{ Name = "Backpack", Type = "BagIndex", EnumValue = 0 },
				{ Name = "Bag_1", Type = "BagIndex", EnumValue = 1 },
				{ Name = "Bag_2", Type = "BagIndex", EnumValue = 2 },
				{ Name = "Bag_3", Type = "BagIndex", EnumValue = 3 },
				{ Name = "Bag_4", Type = "BagIndex", EnumValue = 4 },
				{ Name = "ReagentBag", Type = "BagIndex", EnumValue = 5 },
				{ Name = "CharacterBankTab_1", Type = "BagIndex", EnumValue = 6 },
				{ Name = "CharacterBankTab_2", Type = "BagIndex", EnumValue = 7 },
				{ Name = "CharacterBankTab_3", Type = "BagIndex", EnumValue = 8 },
				{ Name = "CharacterBankTab_4", Type = "BagIndex", EnumValue = 9 },
				{ Name = "CharacterBankTab_5", Type = "BagIndex", EnumValue = 10 },
				{ Name = "CharacterBankTab_6", Type = "BagIndex", EnumValue = 11 },
				{ Name = "AccountBankTab_1", Type = "BagIndex", EnumValue = 12 },
				{ Name = "AccountBankTab_2", Type = "BagIndex", EnumValue = 13 },
				{ Name = "AccountBankTab_3", Type = "BagIndex", EnumValue = 14 },
				{ Name = "AccountBankTab_4", Type = "BagIndex", EnumValue = 15 },
				{ Name = "AccountBankTab_5", Type = "BagIndex", EnumValue = 16 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(BagIndexConstants);