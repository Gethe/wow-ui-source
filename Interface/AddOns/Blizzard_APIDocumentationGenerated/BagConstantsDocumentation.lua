local BagConstants =
{
	Tables =
	{
		{
			Name = "BagFlag",
			Type = "Enumeration",
			NumValues = 28,
			MinValue = 1,
			MaxValue = 134217728,
			Fields =
			{
				{ Name = "DontFindStack", Type = "BagFlag", EnumValue = 1 },
				{ Name = "AlreadyOwner", Type = "BagFlag", EnumValue = 2 },
				{ Name = "AlreadyBound", Type = "BagFlag", EnumValue = 4 },
				{ Name = "Swap", Type = "BagFlag", EnumValue = 8 },
				{ Name = "BagIsEmpty", Type = "BagFlag", EnumValue = 16 },
				{ Name = "LookInInventory", Type = "BagFlag", EnumValue = 32 },
				{ Name = "IgnoreBoundItemCheck", Type = "BagFlag", EnumValue = 64 },
				{ Name = "StackOnly", Type = "BagFlag", EnumValue = 128 },
				{ Name = "RecurseQuivers", Type = "BagFlag", EnumValue = 256 },
				{ Name = "IgnoreBankcheck", Type = "BagFlag", EnumValue = 512 },
				{ Name = "AllowBagsInNonBagSlots", Type = "BagFlag", EnumValue = 1024 },
				{ Name = "PreferQuivers", Type = "BagFlag", EnumValue = 2048 },
				{ Name = "SwapBags", Type = "BagFlag", EnumValue = 4096 },
				{ Name = "IgnoreExisting", Type = "BagFlag", EnumValue = 8192 },
				{ Name = "AllowPartialStack", Type = "BagFlag", EnumValue = 16384 },
				{ Name = "LookInBankOnly", Type = "BagFlag", EnumValue = 32768 },
				{ Name = "AllowBuyback", Type = "BagFlag", EnumValue = 65536 },
				{ Name = "IgnorePetBankcheck", Type = "BagFlag", EnumValue = 131072 },
				{ Name = "PreferPriorityBags", Type = "BagFlag", EnumValue = 262144 },
				{ Name = "PreferNeutralPriorityBags", Type = "BagFlag", EnumValue = 524288 },
				{ Name = "AsymmetricSwap", Type = "BagFlag", EnumValue = 1048576 },
				{ Name = "PreferReagentBags", Type = "BagFlag", EnumValue = 2097152 },
				{ Name = "IgnoreSoulbound", Type = "BagFlag", EnumValue = 4194304 },
				{ Name = "IgnoreReagentBags", Type = "BagFlag", EnumValue = 8388608 },
				{ Name = "LookInAccountBankOnly", Type = "BagFlag", EnumValue = 16777216 },
				{ Name = "HasRefund", Type = "BagFlag", EnumValue = 33554432 },
				{ Name = "SkipValidCountCheck", Type = "BagFlag", EnumValue = 67108864 },
				{ Name = "AllowSoulboundItemInAccountBank", Type = "BagFlag", EnumValue = 134217728 },
			},
		},
		{
			Name = "BagSlotFlags",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 1,
			MaxValue = 512,
			Fields =
			{
				{ Name = "DisableAutoSort", Type = "BagSlotFlags", EnumValue = 1 },
				{ Name = "ClassEquipment", Type = "BagSlotFlags", EnumValue = 2 },
				{ Name = "ClassConsumables", Type = "BagSlotFlags", EnumValue = 4 },
				{ Name = "ClassProfessionGoods", Type = "BagSlotFlags", EnumValue = 8 },
				{ Name = "ClassJunk", Type = "BagSlotFlags", EnumValue = 16 },
				{ Name = "ClassQuestItems", Type = "BagSlotFlags", EnumValue = 32 },
				{ Name = "ExcludeJunkSell", Type = "BagSlotFlags", EnumValue = 64 },
				{ Name = "ClassReagents", Type = "BagSlotFlags", EnumValue = 128 },
				{ Name = "ExpansionCurrent", Type = "BagSlotFlags", EnumValue = 256 },
				{ Name = "ExpansionLegacy", Type = "BagSlotFlags", EnumValue = 512 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(BagConstants);