local MerchantFrame =
{
	Name = "MerchantFrame",
	Type = "System",
	Namespace = "C_MerchantFrame",

	Functions =
	{
		{
			Name = "GetBuybackItemID",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "buybackSlotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "buybackItemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetItemInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "MerchantItemInfo", Nilable = false },
			},
		},
		{
			Name = "GetNumJunkItems",
			Type = "Function",

			Returns =
			{
				{ Name = "numJunkItems", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsMerchantItemRefundable",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "refundable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSellAllJunkEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SellAllJunkItems",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "MerchantClosed",
			Type = "Event",
			LiteralName = "MERCHANT_CLOSED",
		},
		{
			Name = "MerchantFilterItemUpdate",
			Type = "Event",
			LiteralName = "MERCHANT_FILTER_ITEM_UPDATE",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "MerchantShow",
			Type = "Event",
			LiteralName = "MERCHANT_SHOW",
		},
		{
			Name = "MerchantUpdate",
			Type = "Event",
			LiteralName = "MERCHANT_UPDATE",
		},
	},

	Tables =
	{
		{
			Name = "MerchantItemInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "texture", Type = "fileID", Nilable = false },
				{ Name = "price", Type = "number", Nilable = false, Default = 0 },
				{ Name = "stackCount", Type = "number", Nilable = false, Default = 0 },
				{ Name = "numAvailable", Type = "number", Nilable = false, Default = 0 },
				{ Name = "isPurchasable", Type = "bool", Nilable = false, Default = false },
				{ Name = "isUsable", Type = "bool", Nilable = false, Default = false },
				{ Name = "hasExtendedCost", Type = "bool", Nilable = false, Default = false },
				{ Name = "currencyID", Type = "number", Nilable = true },
				{ Name = "spellID", Type = "number", Nilable = true },
				{ Name = "isQuestStartItem", Type = "bool", Nilable = false, Default = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(MerchantFrame);