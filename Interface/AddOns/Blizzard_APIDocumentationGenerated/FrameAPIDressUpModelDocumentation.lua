local FrameAPIDressUpModel =
{
	Name = "FrameAPIDressUpModel",
	Type = "ScriptObject",
	Environment = "All",

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
			Name = "GetItemTransmogInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "allowed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSlotVisible",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "visible", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetAutoDress",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetItemTransmogInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "itemTransmogInfo", Type = "ItemTransmogInfo", Mixin = "ItemTransmogInfoMixin", Nilable = false },
				{ Name = "inventorySlot", Type = "luaIndex", Nilable = true },
				{ Name = "ignoreChildItems", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "result", Type = "ItemTryOnReason", Nilable = false },
			},
		},
		{
			Name = "SetObeyHideInTransmogFlag",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetSheathed",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "sheathed", Type = "bool", Nilable = false, Default = false },
				{ Name = "hideWeapons", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetUseTransmogChoices",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetUseTransmogSkin",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "TryOn",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "linkOrItemModifiedAppearanceID", Type = "IDOrLink", Nilable = false },
				{ Name = "handSlotName", Type = "cstring", Nilable = true },
				{ Name = "spellEnchantID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "ItemTryOnReason", Nilable = true },
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
			SecretArguments = "AllowedWhenUntainted",

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