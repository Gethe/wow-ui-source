local MerchantFrameLua =
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
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(MerchantFrameLua);