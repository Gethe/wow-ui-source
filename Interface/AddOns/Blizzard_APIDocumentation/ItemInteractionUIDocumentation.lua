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
			Name = "SetCorruptionReforgerItemTooltip",
			Type = "Function",
		},
		{
			Name = "SetPendingItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "item", Type = "table", Mixin = "ItemLocationMixin", Nilable = true },
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
			Name = "ItemInteractionClose",
			Type = "Event",
			LiteralName = "ITEM_INTERACTION_CLOSE",
		},
		{
			Name = "ItemInteractionItemSelectionUpdated",
			Type = "Event",
			LiteralName = "ITEM_INTERACTION_ITEM_SELECTION_UPDATED",
			Payload =
			{
				{ Name = "itemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = true },
			},
		},
		{
			Name = "ItemInteractionOpen",
			Type = "Event",
			LiteralName = "ITEM_INTERACTION_OPEN",
		},
	},

	Tables =
	{
		{
			Name = "ItemInteractionFrameType",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "CleanseCorruption", Type = "ItemInteractionFrameType", EnumValue = 0 },
			},
		},
		{
			Name = "ItemInteractionFrameInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "openSoundKitID", Type = "number", Nilable = false },
				{ Name = "closeSoundKitID", Type = "number", Nilable = false },
				{ Name = "titleText", Type = "string", Nilable = false },
				{ Name = "tutorialText", Type = "string", Nilable = false },
				{ Name = "buttonText", Type = "string", Nilable = false },
				{ Name = "frameType", Type = "ItemInteractionFrameType", Nilable = false },
				{ Name = "description", Type = "string", Nilable = true },
				{ Name = "cost", Type = "number", Nilable = true },
				{ Name = "currencyTypeId", Type = "number", Nilable = true },
				{ Name = "dropInSlotSoundKitId", Type = "number", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ItemInteractionUI);