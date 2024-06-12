local Reforge =
{
	Name = "Reforge",
	Type = "System",
	Namespace = "C_Reforge",

	Functions =
	{
		{
			Name = "CloseReforge",
			Type = "Function",
		},
		{
			Name = "GetDestinationReforgeStats",
			Type = "Function",

			Arguments =
			{
				{ Name = "srcStat", Type = "number", Nilable = false },
				{ Name = "srcStatValue", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "dstStatsInfo", Type = "table", InnerType = "dstReforgeStats", Nilable = false },
			},
		},
		{
			Name = "GetNumReforgeOptions",
			Type = "Function",

			Returns =
			{
				{ Name = "numOptions", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetReforgeItemInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "index", Type = "number", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "itemName", Type = "string", Nilable = false },
				{ Name = "itemQualityID", Type = "number", Nilable = false },
				{ Name = "soulbound", Type = "string", Nilable = false },
				{ Name = "reforgeCost", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetReforgeItemStats",
			Type = "Function",

			Returns =
			{
				{ Name = "reforgeStats", Type = "table", InnerType = "reforgeStatsInfo", Nilable = false },
			},
		},
		{
			Name = "GetReforgeOptionInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "srcStatName", Type = "string", Nilable = false },
				{ Name = "srcStat", Type = "number", Nilable = false },
				{ Name = "srcStatReduction", Type = "number", Nilable = false },
				{ Name = "dstStatName", Type = "string", Nilable = false },
				{ Name = "dstStat", Type = "number", Nilable = false },
				{ Name = "dstStatAddition", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSourceReforgeStats",
			Type = "Function",

			Returns =
			{
				{ Name = "srcStatsInfo", Type = "table", InnerType = "srcReforgeStats", Nilable = false },
			},
		},
		{
			Name = "ReforgeItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetReforgeFromCursorItem",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "ForgeMasterClosed",
			Type = "Event",
			LiteralName = "FORGE_MASTER_CLOSED",
		},
		{
			Name = "ForgeMasterItemChanged",
			Type = "Event",
			LiteralName = "FORGE_MASTER_ITEM_CHANGED",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ForgeMasterOpened",
			Type = "Event",
			LiteralName = "FORGE_MASTER_OPENED",
		},
		{
			Name = "ForgeMasterSetItem",
			Type = "Event",
			LiteralName = "FORGE_MASTER_SET_ITEM",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "dstReforgeStats",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "stat", Type = "number", Nilable = false },
				{ Name = "statAddition", Type = "number", Nilable = false },
				{ Name = "reforgeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "reforgeStatsInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "stat", Type = "number", Nilable = false },
				{ Name = "statValue", Type = "number", Nilable = false },
			},
		},
		{
			Name = "srcReforgeStats",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "stat", Type = "number", Nilable = false },
				{ Name = "statReduction", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Reforge);