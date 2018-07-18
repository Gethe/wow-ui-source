local ScrappingMachineUI =
{
	Name = "ScrappingMachineUI",
	Type = "System",
	Namespace = "C_ScrappingMachineUI",

	Functions =
	{
		{
			Name = "CloseScrappingMachine",
			Type = "Function",
		},
		{
			Name = "DropPendingScrapItemFromCursor",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCurrentPendingScrapItemLocationByIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemLoc", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},
		},
		{
			Name = "GetScrapSpellID",
			Type = "Function",

			Returns =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetScrappingMachineName",
			Type = "Function",

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
			},
		},
		{
			Name = "HasScrappableItems",
			Type = "Function",

			Returns =
			{
				{ Name = "hasScrappableItems", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RemoveAllScrapItems",
			Type = "Function",
		},
		{
			Name = "RemoveCurrentScrappingItem",
			Type = "Function",
		},
		{
			Name = "RemoveItemToScrap",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ScrapItems",
			Type = "Function",
		},
		{
			Name = "SetScrappingMachine",
			Type = "Function",

			Arguments =
			{
				{ Name = "gameObject", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ValidateScrappingList",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "ScrappingMachineClose",
			Type = "Event",
			LiteralName = "SCRAPPING_MACHINE_CLOSE",
		},
		{
			Name = "ScrappingMachineItemRemovedOrCancelled",
			Type = "Event",
			LiteralName = "SCRAPPING_MACHINE_ITEM_REMOVED_OR_CANCELLED",
			Payload =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ScrappingMachinePendingItemChanged",
			Type = "Event",
			LiteralName = "SCRAPPING_MACHINE_PENDING_ITEM_CHANGED",
		},
		{
			Name = "ScrappingMachineScrappingFinished",
			Type = "Event",
			LiteralName = "SCRAPPING_MACHINE_SCRAPPING_FINISHED",
		},
		{
			Name = "ScrappingMachineShow",
			Type = "Event",
			LiteralName = "SCRAPPING_MACHINE_SHOW",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ScrappingMachineUI);