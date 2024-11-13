local FrameAPIDressUpModel =
{
	Name = "FrameAPIDressUpModel",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "Dress",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "GetAutoDress",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetItemModifiedAppearanceID",
			Type = "Function",

			Arguments =
			{
				{ Name = "invSlot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemModAppearanceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetItemTransmogInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "inventorySlot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemTransmogInfo", Type = "ItemTransmogInfo", Mixin = "ItemTransmogInfoMixin", Nilable = false },
			},
		},
		{
			Name = "GetItemTransmogInfoList",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "infoList", Type = "table", InnerType = "ItemTransmogInfo", Nilable = false },
			},
		},
		{
			Name = "GetObeyHideInTransmogFlag",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetSheathed",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "sheathed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetSpellItemEnchantmentID",
			Type = "Function",

			Arguments =
			{
				{ Name = "invSlot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellItemEnchantID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetUseTransmogChoices",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetUseTransmogSkin",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsGeoReady",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "ready", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSlotAllowed",
			Type = "Function",

			Arguments =
			{
				{ Name = "inventorySlots", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "allowed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSlotVisible",
			Type = "Function",

			Arguments =
			{
				{ Name = "inventorySlots", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "visible", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetAutoDress",
			Type = "Function",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetObeyHideInTransmogFlag",
			Type = "Function",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetSheathed",
			Type = "Function",

			Arguments =
			{
				{ Name = "sheathed", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetUseTransmogChoices",
			Type = "Function",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetUseTransmogSkin",
			Type = "Function",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "TryOn",
			Type = "Function",

			Arguments =
			{
				{ Name = "linkOrItemModifiedAppearanceID", Type = "IDOrLink", Nilable = false },
				{ Name = "handSlotName", Type = "cstring", Nilable = true },
				{ Name = "spellEnchantID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "Undress",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "UndressSlot",
			Type = "Function",

			Arguments =
			{
				{ Name = "inventorySlot", Type = "luaIndex", Nilable = false },
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

APIDocumentation:AddDocumentationTable(FrameAPIDressUpModel);