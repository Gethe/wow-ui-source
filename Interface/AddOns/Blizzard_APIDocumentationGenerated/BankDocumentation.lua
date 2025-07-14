local Bank =
{
	Name = "Bank",
	Type = "System",
	Namespace = "C_Bank",

	Functions =
	{
		{
			Name = "AreAnyBankTypesViewable",
			Type = "Function",

			Returns =
			{
				{ Name = "areAnyBankTypesViewable", Type = "bool", Nilable = false },
			},
		},
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
			Name = "DoesBankTypeSupportAutoDeposit",
			Type = "Function",

			Arguments =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
			},

			Returns =
			{
				{ Name = "doesBankTypeSupportAutoDeposit", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "DoesBankTypeSupportMoneyTransfer",
			Type = "Function",

			Arguments =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
			},

			Returns =
			{
				{ Name = "doesBankTypeSupportMoneyTransfer", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "FetchBankLockedReason",
			Type = "Function",

			Arguments =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
			},

			Returns =
			{
				{ Name = "reason", Type = "BankLockedReason", Nilable = true },
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
			Name = "FetchNextPurchasableBankTabData",
			Type = "Function",

			Arguments =
			{
				{ Name = "bankType", Type = "BankType", Nilable = false },
			},

			Returns =
			{
				{ Name = "nextPurchasableTabData", Type = "PurchasableBankTabData", Nilable = true },
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
			Name = "FetchViewableBankTypes",
			Type = "Function",

			Returns =
			{
				{ Name = "viewableBankTypes", Type = "table", InnerType = "BankType", Nilable = false },
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
			HasRestrictions = true,

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
			Name = "PlayerbankslotsChanged",
			Type = "Event",
			LiteralName = "PLAYERBANKSLOTS_CHANGED",
			Payload =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "BankLockedReason",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "BankLockedReason", EnumValue = 0 },
				{ Name = "NoAccountInventoryLock", Type = "BankLockedReason", EnumValue = 1 },
				{ Name = "BankDisabled", Type = "BankLockedReason", EnumValue = 2 },
				{ Name = "BankConversionFailed", Type = "BankLockedReason", EnumValue = 3 },
			},
		},
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
				{ Name = "tabCleanupConfirmation", Type = "cstring", Nilable = false },
				{ Name = "tabNameEditBoxHeader", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "PurchasableBankTabData",
			Type = "Structure",
			Fields =
			{
				{ Name = "tabCost", Type = "BigUInteger", Nilable = false },
				{ Name = "canAfford", Type = "bool", Nilable = false },
				{ Name = "purchasePromptTitle", Type = "cstring", Nilable = false },
				{ Name = "purchasePromptBody", Type = "cstring", Nilable = false },
				{ Name = "purchasePromptConfirmation", Type = "cstring", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Bank);