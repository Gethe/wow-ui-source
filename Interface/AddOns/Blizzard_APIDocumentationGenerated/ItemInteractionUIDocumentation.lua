local ItemInteractionUI =
{
	Name = "ItemInteractionUI",
	Type = "System",
	Namespace = "C_ItemInteraction",

	Functions =
	{
		{
			Name = "ClearPendingItem",
			Type = "Function",
		},
		{
			Name = "CloseUI",
			Type = "Function",
		},
		{
			Name = "GetChargeInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "chargeInfo", Type = "ItemInteractionChargeInfo", Nilable = false },
			},
		},
		{
			Name = "GetItemConversionCurrencyCost",
			Type = "Function",

			Arguments =
			{
				{ Name = "item", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "conversionCost", Type = "ConversionCurrencyCost", Nilable = false },
			},
		},
		{
			Name = "GetItemInteractionInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "ItemInteractionFrameInfo", Nilable = true },
			},
		},
		{
			Name = "GetItemInteractionSpellId",
			Type = "Function",

			Returns =
			{
				{ Name = "spellId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "InitializeFrame",
			Type = "Function",
		},
		{
			Name = "PerformItemInteraction",
			Type = "Function",
		},
		{
			Name = "Reset",
			Type = "Function",
		},
		{
			Name = "SetPendingItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "item", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = true },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "ItemInteractionChargeInfoUpdated",
			Type = "Event",
			LiteralName = "ITEM_INTERACTION_CHARGE_INFO_UPDATED",
		},
		{
			Name = "ItemInteractionItemSelectionUpdated",
			Type = "Event",
			LiteralName = "ITEM_INTERACTION_ITEM_SELECTION_UPDATED",
			Payload =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = true },
			},
		},
	},

	Tables =
	{
		{
			Name = "ConversionCurrencyCost",
			Type = "Structure",
			Fields =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
				{ Name = "amount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ItemInteractionChargeInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "newChargeAmount", Type = "number", Nilable = false },
				{ Name = "rechargeRate", Type = "number", Nilable = false },
				{ Name = "timeToNextCharge", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ItemInteractionFrameInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "openSoundKitID", Type = "number", Nilable = false },
				{ Name = "closeSoundKitID", Type = "number", Nilable = false },
				{ Name = "titleText", Type = "string", Nilable = false },
				{ Name = "tutorialText", Type = "string", Nilable = false },
				{ Name = "buttonText", Type = "string", Nilable = false },
				{ Name = "interactionType", Type = "UIItemInteractionType", Nilable = false },
				{ Name = "flags", Type = "number", Nilable = false },
				{ Name = "description", Type = "string", Nilable = true },
				{ Name = "buttonTooltip", Type = "string", Nilable = true },
				{ Name = "confirmationDescription", Type = "string", Nilable = true },
				{ Name = "slotTooltip", Type = "string", Nilable = true },
				{ Name = "cost", Type = "number", Nilable = true },
				{ Name = "currencyTypeId", Type = "number", Nilable = true },
				{ Name = "dropInSlotSoundKitId", Type = "number", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ItemInteractionUI);