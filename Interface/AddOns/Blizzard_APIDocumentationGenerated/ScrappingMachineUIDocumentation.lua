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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCurrentPendingScrapItemLocationByIndex",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemLoc", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
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
			MayReturnNothing = true,

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
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "ValidateScrappingList",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "ScrappingMachineItemAdded",
			Type = "Event",
			LiteralName = "SCRAPPING_MACHINE_ITEM_ADDED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ScrappingMachineItemRemoved",
			Type = "Event",
			LiteralName = "SCRAPPING_MACHINE_ITEM_REMOVED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ScrappingMachinePendingItemChanged",
			Type = "Event",
			LiteralName = "SCRAPPING_MACHINE_PENDING_ITEM_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "ScrappingMachineScrappingFinished",
			Type = "Event",
			LiteralName = "SCRAPPING_MACHINE_SCRAPPING_FINISHED",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ScrappingMachineUI);