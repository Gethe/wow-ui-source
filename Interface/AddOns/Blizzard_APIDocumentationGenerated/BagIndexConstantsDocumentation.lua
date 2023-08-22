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
			NumValues = 17,
			MinValue = -4,
			MaxValue = 12,
			Fields =
			{
				{ Name = "Bankbag", Type = "BagIndex", EnumValue = -4 },
				{ Name = "Reagentbank", Type = "BagIndex", EnumValue = -3 },
				{ Name = "Keyring", Type = "BagIndex", EnumValue = -2 },
				{ Name = "Bank", Type = "BagIndex", EnumValue = -1 },
				{ Name = "Backpack", Type = "BagIndex", EnumValue = 0 },
				{ Name = "Bag_1", Type = "BagIndex", EnumValue = 1 },
				{ Name = "Bag_2", Type = "BagIndex", EnumValue = 2 },
				{ Name = "Bag_3", Type = "BagIndex", EnumValue = 3 },
				{ Name = "Bag_4", Type = "BagIndex", EnumValue = 4 },
				{ Name = "ReagentBag", Type = "BagIndex", EnumValue = 5 },
				{ Name = "BankBag_1", Type = "BagIndex", EnumValue = 6 },
				{ Name = "BankBag_2", Type = "BagIndex", EnumValue = 7 },
				{ Name = "BankBag_3", Type = "BagIndex", EnumValue = 8 },
				{ Name = "BankBag_4", Type = "BagIndex", EnumValue = 9 },
				{ Name = "BankBag_5", Type = "BagIndex", EnumValue = 10 },
				{ Name = "BankBag_6", Type = "BagIndex", EnumValue = 11 },
				{ Name = "BankBag_7", Type = "BagIndex", EnumValue = 12 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(BagIndexConstants);