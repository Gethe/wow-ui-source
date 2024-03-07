local BagConstants =
{
	Tables =
	{
		{
			Name = "BagSlotFlags",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 1,
			MaxValue = 127,
			Fields =
			{
				{ Name = "DisableAutoSort", Type = "BagSlotFlags", EnumValue = 1 },
				{ Name = "PriorityEquipment", Type = "BagSlotFlags", EnumValue = 2 },
				{ Name = "PriorityConsumables", Type = "BagSlotFlags", EnumValue = 4 },
				{ Name = "PriorityTradeGoods", Type = "BagSlotFlags", EnumValue = 8 },
				{ Name = "PriorityJunk", Type = "BagSlotFlags", EnumValue = 16 },
				{ Name = "PriorityQuestItems", Type = "BagSlotFlags", EnumValue = 32 },
				{ Name = "ExcludeJunkSell", Type = "BagSlotFlags", EnumValue = 64 },
				{ Name = "BagSlotValidFlagsAll", Type = "BagSlotFlags", EnumValue = 127 },
				{ Name = "BagSlotPriorityFlagsAll", Type = "BagSlotFlags", EnumValue = 62 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(BagConstants);