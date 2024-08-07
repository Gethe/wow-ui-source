local AccountConstants =
{
	Tables =
	{
		{
			Name = "AccountData",
			Type = "Enumeration",
			NumValues = 17,
			MinValue = 0,
			MaxValue = 16,
			Fields =
			{
				{ Name = "Config", Type = "AccountData", EnumValue = 0 },
				{ Name = "Config2", Type = "AccountData", EnumValue = 1 },
				{ Name = "Bindings", Type = "AccountData", EnumValue = 2 },
				{ Name = "Bindings2", Type = "AccountData", EnumValue = 3 },
				{ Name = "Macros", Type = "AccountData", EnumValue = 4 },
				{ Name = "Macros2", Type = "AccountData", EnumValue = 5 },
				{ Name = "UILayout", Type = "AccountData", EnumValue = 6 },
				{ Name = "ChatSettings", Type = "AccountData", EnumValue = 7 },
				{ Name = "TtsSettings", Type = "AccountData", EnumValue = 8 },
				{ Name = "TtsSettings2", Type = "AccountData", EnumValue = 9 },
				{ Name = "FlaggedIDs", Type = "AccountData", EnumValue = 10 },
				{ Name = "FlaggedIDs2", Type = "AccountData", EnumValue = 11 },
				{ Name = "ClickBindings", Type = "AccountData", EnumValue = 12 },
				{ Name = "UIEditModeAccount", Type = "AccountData", EnumValue = 13 },
				{ Name = "UIEditModeChar", Type = "AccountData", EnumValue = 14 },
				{ Name = "FrontendChatSettings", Type = "AccountData", EnumValue = 15 },
				{ Name = "CharacterListOrder", Type = "AccountData", EnumValue = 16 },
			},
		},
		{
			Name = "AccountDataUpdateStatus",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "AccountDataUpdateSuccess", Type = "AccountDataUpdateStatus", EnumValue = 0 },
				{ Name = "AccountDataUpdateFailed", Type = "AccountDataUpdateStatus", EnumValue = 1 },
				{ Name = "AccountDataUpdateCorrupt", Type = "AccountDataUpdateStatus", EnumValue = 2 },
				{ Name = "AccountDataUpdateToobig", Type = "AccountDataUpdateStatus", EnumValue = 3 },
			},
		},
		{
			Name = "AccountExportResult",
			Type = "Enumeration",
			NumValues = 14,
			MinValue = 0,
			MaxValue = 13,
			Fields =
			{
				{ Name = "Success", Type = "AccountExportResult", EnumValue = 0 },
				{ Name = "UnknownError", Type = "AccountExportResult", EnumValue = 1 },
				{ Name = "Cancelled", Type = "AccountExportResult", EnumValue = 2 },
				{ Name = "ShuttingDown", Type = "AccountExportResult", EnumValue = 3 },
				{ Name = "TimedOut", Type = "AccountExportResult", EnumValue = 4 },
				{ Name = "NoAccountFound", Type = "AccountExportResult", EnumValue = 5 },
				{ Name = "RequestedInvalidCharacter", Type = "AccountExportResult", EnumValue = 6 },
				{ Name = "RpcError", Type = "AccountExportResult", EnumValue = 7 },
				{ Name = "FileInvalid", Type = "AccountExportResult", EnumValue = 8 },
				{ Name = "FileWriteFailed", Type = "AccountExportResult", EnumValue = 9 },
				{ Name = "Unavailable", Type = "AccountExportResult", EnumValue = 10 },
				{ Name = "AlreadyInProgress", Type = "AccountExportResult", EnumValue = 11 },
				{ Name = "FailedToLockAccount", Type = "AccountExportResult", EnumValue = 12 },
				{ Name = "FailedToGenerateFile", Type = "AccountExportResult", EnumValue = 13 },
			},
		},
		{
			Name = "AccountTransType",
			Type = "Enumeration",
			NumValues = 54,
			MinValue = 0,
			MaxValue = 53,
			Fields =
			{
				{ Name = "ProxyForwarder", Type = "AccountTransType", EnumValue = 0 },
				{ Name = "Purchase", Type = "AccountTransType", EnumValue = 1 },
				{ Name = "Distribution", Type = "AccountTransType", EnumValue = 2 },
				{ Name = "Battlepet", Type = "AccountTransType", EnumValue = 3 },
				{ Name = "Achievements", Type = "AccountTransType", EnumValue = 4 },
				{ Name = "Criteria", Type = "AccountTransType", EnumValue = 5 },
				{ Name = "Mounts", Type = "AccountTransType", EnumValue = 6 },
				{ Name = "Characters", Type = "AccountTransType", EnumValue = 7 },
				{ Name = "Purchases", Type = "AccountTransType", EnumValue = 8 },
				{ Name = "ArchivedPurchases", Type = "AccountTransType", EnumValue = 9 },
				{ Name = "Distributions", Type = "AccountTransType", EnumValue = 10 },
				{ Name = "CurrencyCaps", Type = "AccountTransType", EnumValue = 11 },
				{ Name = "QuestLog", Type = "AccountTransType", EnumValue = 12 },
				{ Name = "CriteriaNotif", Type = "AccountTransType", EnumValue = 13 },
				{ Name = "Settings", Type = "AccountTransType", EnumValue = 14 },
				{ Name = "FixedLicense", Type = "AccountTransType", EnumValue = 15 },
				{ Name = "AddLicense", Type = "AccountTransType", EnumValue = 16 },
				{ Name = "ItemCollections", Type = "AccountTransType", EnumValue = 17 },
				{ Name = "AuctionableToken", Type = "AccountTransType", EnumValue = 18 },
				{ Name = "ConsumableToken", Type = "AccountTransType", EnumValue = 19 },
				{ Name = "VasTransaction", Type = "AccountTransType", EnumValue = 20 },
				{ Name = "Productitem", Type = "AccountTransType", EnumValue = 21 },
				{ Name = "TrialBoostHistory", Type = "AccountTransType", EnumValue = 22 },
				{ Name = "TrialBoostHistories", Type = "AccountTransType", EnumValue = 23 },
				{ Name = "QuestCriteria", Type = "AccountTransType", EnumValue = 24 },
				{ Name = "BattlenetAccount", Type = "AccountTransType", EnumValue = 25 },
				{ Name = "AccountCurrencies", Type = "AccountTransType", EnumValue = 26 },
				{ Name = "RafRecruiterAcceptances", Type = "AccountTransType", EnumValue = 27 },
				{ Name = "RafFriendMonth", Type = "AccountTransType", EnumValue = 28 },
				{ Name = "RafReward", Type = "AccountTransType", EnumValue = 29 },
				{ Name = "DynamicCriteria", Type = "AccountTransType", EnumValue = 30 },
				{ Name = "RafActivity", Type = "AccountTransType", EnumValue = 31 },
				{ Name = "CreateOrderInfo", Type = "AccountTransType", EnumValue = 32 },
				{ Name = "ProxyHonorInitialConversion", Type = "AccountTransType", EnumValue = 33 },
				{ Name = "ProxyCreateAccountHonor", Type = "AccountTransType", EnumValue = 34 },
				{ Name = "ProxyValidateAccountHonor", Type = "AccountTransType", EnumValue = 35 },
				{ Name = "ProxyGmSetHonor", Type = "AccountTransType", EnumValue = 36 },
				{ Name = "ProxyGenerateBpayID", Type = "AccountTransType", EnumValue = 37 },
				{ Name = "AccountNotifications", Type = "AccountTransType", EnumValue = 38 },
				{ Name = "PerkItemHold", Type = "AccountTransType", EnumValue = 39 },
				{ Name = "PerkPendingRewards", Type = "AccountTransType", EnumValue = 40 },
				{ Name = "PerkRecentPurchases", Type = "AccountTransType", EnumValue = 41 },
				{ Name = "PerkPastRewards", Type = "AccountTransType", EnumValue = 42 },
				{ Name = "PerkTransaction", Type = "AccountTransType", EnumValue = 43 },
				{ Name = "OutstandingRpc", Type = "AccountTransType", EnumValue = 44 },
				{ Name = "LoadWowlabs", Type = "AccountTransType", EnumValue = 45 },
				{ Name = "UpgradeAccount", Type = "AccountTransType", EnumValue = 46 },
				{ Name = "GetOrderStatusByPurchaseID", Type = "AccountTransType", EnumValue = 47 },
				{ Name = "Items", Type = "AccountTransType", EnumValue = 48 },
				{ Name = "BankTab", Type = "AccountTransType", EnumValue = 49 },
				{ Name = "Factions", Type = "AccountTransType", EnumValue = 50 },
				{ Name = "BitVectors", Type = "AccountTransType", EnumValue = 51 },
				{ Name = "CombinedQuestLog", Type = "AccountTransType", EnumValue = 52 },
				{ Name = "PlayerDataElements", Type = "AccountTransType", EnumValue = 53 },
			},
		},
		{
			Name = "BnetAccountFlag",
			Type = "Enumeration",
			NumValues = 21,
			MinValue = 0,
			MaxValue = 524288,
			Fields =
			{
				{ Name = "None", Type = "BnetAccountFlag", EnumValue = 0 },
				{ Name = "BattlePetTrainer", Type = "BnetAccountFlag", EnumValue = 1 },
				{ Name = "RafVeteranNotified", Type = "BnetAccountFlag", EnumValue = 2 },
				{ Name = "TwitterLinked", Type = "BnetAccountFlag", EnumValue = 4 },
				{ Name = "TwitterHasTempSecret", Type = "BnetAccountFlag", EnumValue = 8 },
				{ Name = "Employee", Type = "BnetAccountFlag", EnumValue = 16 },
				{ Name = "EmployeeFlagIsManual", Type = "BnetAccountFlag", EnumValue = 32 },
				{ Name = "AccountQuestBitFixUp", Type = "BnetAccountFlag", EnumValue = 64 },
				{ Name = "AchievementsToBi", Type = "BnetAccountFlag", EnumValue = 128 },
				{ Name = "InvalidTransmogsFixUp", Type = "BnetAccountFlag", EnumValue = 256 },
				{ Name = "InvalidTransmogsFixUp2", Type = "BnetAccountFlag", EnumValue = 512 },
				{ Name = "GdprErased", Type = "BnetAccountFlag", EnumValue = 1024 },
				{ Name = "DarkRealmLightCopy", Type = "BnetAccountFlag", EnumValue = 2048 },
				{ Name = "QuestLogFlagsFixUp", Type = "BnetAccountFlag", EnumValue = 4096 },
				{ Name = "WasSecured", Type = "BnetAccountFlag", EnumValue = 8192 },
				{ Name = "LockedForExport", Type = "BnetAccountFlag", EnumValue = 16384 },
				{ Name = "CanBuyAhGameTimeTokens", Type = "BnetAccountFlag", EnumValue = 32768 },
				{ Name = "PetAchievementFixUp", Type = "BnetAccountFlag", EnumValue = 65536 },
				{ Name = "IsLegacy", Type = "BnetAccountFlag", EnumValue = 131072 },
				{ Name = "CataLegendaryMountChecked", Type = "BnetAccountFlag", EnumValue = 262144 },
				{ Name = "CataLegendaryMountObtained", Type = "BnetAccountFlag", EnumValue = 524288 },
			},
		},
		{
			Name = "DisableAccountProfilesFlags",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 16,
			Fields =
			{
				{ Name = "None", Type = "DisableAccountProfilesFlags", EnumValue = 0 },
				{ Name = "Document", Type = "DisableAccountProfilesFlags", EnumValue = 1 },
				{ Name = "SharedCollections", Type = "DisableAccountProfilesFlags", EnumValue = 2 },
				{ Name = "MountsCollections", Type = "DisableAccountProfilesFlags", EnumValue = 4 },
				{ Name = "PetsCollections", Type = "DisableAccountProfilesFlags", EnumValue = 8 },
				{ Name = "ItemsCollections", Type = "DisableAccountProfilesFlags", EnumValue = 16 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AccountConstants);