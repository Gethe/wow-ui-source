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

			Arguments =
			{
				{ Name = "buybackSlotIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "buybackItemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsMerchantItemRefundable",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "refundable", Type = "bool", Nilable = false },
			},
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
	},
};

APIDocumentation:AddDocumentationTable(MerchantFrame);