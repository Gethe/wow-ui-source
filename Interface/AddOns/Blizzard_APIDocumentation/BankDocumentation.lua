local Bank =
{
	Name = "Bank",
	Type = "System",
	Namespace = "C_Bank",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "BankBagSlotFlagsUpdated",
			Type = "Event",
			LiteralName = "BANK_BAG_SLOT_FLAGS_UPDATED",
			Payload =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},
		},
		{
			Name = "BankframeClosed",
			Type = "Event",
			LiteralName = "BANKFRAME_CLOSED",
		},
		{
			Name = "BankframeOpened",
			Type = "Event",
			LiteralName = "BANKFRAME_OPENED",
		},
		{
			Name = "PlayerbankbagslotsChanged",
			Type = "Event",
			LiteralName = "PLAYERBANKBAGSLOTS_CHANGED",
		},
		{
			Name = "PlayerbankslotsChanged",
			Type = "Event",
			LiteralName = "PLAYERBANKSLOTS_CHANGED",
			Payload =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PlayerreagentbankslotsChanged",
			Type = "Event",
			LiteralName = "PLAYERREAGENTBANKSLOTS_CHANGED",
			Payload =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ReagentbankPurchased",
			Type = "Event",
			LiteralName = "REAGENTBANK_PURCHASED",
		},
		{
			Name = "ReagentbankUpdate",
			Type = "Event",
			LiteralName = "REAGENTBANK_UPDATE",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Bank);