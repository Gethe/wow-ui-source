local Bank =
{
	Name = "Bank",
	Type = "System",
	Namespace = "C_Bank",

	Functions =
	{
		{
			Name = "AutoDepositItemsIntoBank",
			Type = "Function",

			Arguments =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
			},
		},
		{
			Name = "CanDepositMoney",
			Type = "Function",

			Arguments =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
			},

			Returns =
			{
				{ Name = "canDepositMoney", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanPurchaseBankTab",
			Type = "Function",

			Arguments =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
			},

			Returns =
			{
				{ Name = "canPurchaseBankTab", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanUseBank",
			Type = "Function",

			Arguments =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
			},

			Returns =
			{
				{ Name = "canUseBank", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanViewBank",
			Type = "Function",

			Arguments =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
			},

			Returns =
			{
				{ Name = "canViewBank", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanWithdrawMoney",
			Type = "Function",

			Arguments =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
			},

			Returns =
			{
				{ Name = "canWithdrawMoney", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CloseBankFrame",
			Type = "Function",
		},
		{
			Name = "DepositMoney",
			Type = "Function",

			Arguments =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
				{ Name = "amount", Type = "WOWMONEY", Nilable = false },
			},
		},
		{
			Name = "FetchDepositedMoney",
			Type = "Function",

			Arguments =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
			},

			Returns =
			{
				{ Name = "amount", Type = "WOWMONEY", Nilable = false },
			},
		},
		{
			Name = "FetchNextPurchasableBankTabCost",
			Type = "Function",

			Arguments =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
			},

			Returns =
			{
				{ Name = "nextPurchasableTabCost", Type = "BigUInteger", Nilable = true },
			},
		},
		{
			Name = "FetchNumPurchasedBankTabs",
			Type = "Function",

			Arguments =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
			},

			Returns =
			{
				{ Name = "numPurchasedBankTabs", Type = "number", Nilable = false },
			},
		},
		{
			Name = "FetchPurchasedBankTabData",
			Type = "Function",

			Arguments =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
			},

			Returns =
			{
				{ Name = "purchasedBankTabData", Type = "table", InnerType = "BankTabData", Nilable = false },
			},
		},
		{
			Name = "FetchPurchasedBankTabIDs",
			Type = "Function",

			Arguments =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
			},

			Returns =
			{
				{ Name = "purchasedBankTabIDs", Type = "table", InnerType = "BagIndex", Nilable = false },
			},
		},
		{
			Name = "HasMaxBankTabs",
			Type = "Function",

			Arguments =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasMaxBankTabs", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsItemAllowedInBankType",
			Type = "Function",

			Arguments =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isItemAllowedInBankType", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PurchaseBankTab",
			Type = "Function",

			Arguments =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
			},
		},
		{
			Name = "UpdateBankTabSettings",
			Type = "Function",

			Arguments =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
				{ Name = "tabID", Type = "BagIndex", Nilable = false },
				{ Name = "tabName", Type = "cstring", Nilable = false },
				{ Name = "tabIcon", Type = "cstring", Nilable = false },
				{ Name = "depositFlags", Type = "BagSlotFlags", Nilable = false },
			},
		},
		{
			Name = "WithdrawMoney",
			Type = "Function",

			Arguments =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
				{ Name = "amount", Type = "WOWMONEY", Nilable = false },
			},
		},
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
			Name = "BankTabSettingsUpdated",
			Type = "Event",
			LiteralName = "BANK_TAB_SETTINGS_UPDATED",
			Payload =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
			},
		},
		{
			Name = "BankTabsChanged",
			Type = "Event",
			LiteralName = "BANK_TABS_CHANGED",
			Payload =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
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
			Name = "PlayerAccountBankTabSlotsChanged",
			Type = "Event",
			LiteralName = "PLAYER_ACCOUNT_BANK_TAB_SLOTS_CHANGED",
			Payload =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},
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
		{
			Name = "BankTabData",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "bankType", Type = "BankType", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "depositFlags", Type = "BagSlotFlags", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Bank);