local FrameAPIModelSceneFrameActor =
{
	Name = "FrameAPIModelSceneFrameActor",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "AttachToMount",
			Type = "Function",

			Arguments =
			{
				{ Name = "rider", Type = "ModelSceneFrameActor", Nilable = false },
				{ Name = "animation", Type = "AnimationDataEnum", Nilable = false },
				{ Name = "spellKitVisualID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CalculateMountScale",
			Type = "Function",

			Arguments =
			{
				{ Name = "rider", Type = "ModelSceneFrameActor", Nilable = false },
			},

			Returns =
			{
				{ Name = "scale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "Dress",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "DressPlayerSlot",
			Type = "Function",

			Arguments =
			{
				{ Name = "invSlot", Type = "luaIndex", Nilable = false },
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
				{ Name = "autoDress", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetItemTransmogInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "inventorySlots", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemTransmogInfo", Type = "ItemTransmogInfo", Mixin = "ItemTransmogInfoMixin", Nilable = true },
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
				{ Name = "obey", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetPaused",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "paused", Type = "bool", Nilable = false },
				{ Name = "globalPaused", Type = "bool", Nilable = false },
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
				{ Name = "use", Type = "bool", Nilable = false },
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
				{ Name = "use", Type = "bool", Nilable = false },
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
				{ Name = "isReady", Type = "bool", Nilable = false },
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
			Name = "ReleaseFrontEndCharacterDisplays",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ResetNextHandSlot",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "SetAutoDress",
			Type = "Function",

			Arguments =
			{
				{ Name = "autoDress", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetFrontEndLobbyModelFromDefaultCharacterDisplay",
			Type = "Function",

			Arguments =
			{
				{ Name = "characterIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetItemTransmogInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogInfo", Type = "ItemTransmogInfo", Mixin = "ItemTransmogInfoMixin", Nilable = false },
				{ Name = "inventorySlots", Type = "number", Nilable = true },
				{ Name = "ignoreChildItems", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "result", Type = "ItemTryOnReason", Nilable = false },
			},
		},
		{
			Name = "SetModelByHyperlink",
			Type = "Function",

			Arguments =
			{
				{ Name = "link", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetObeyHideInTransmogFlag",
			Type = "Function",

			Arguments =
			{
				{ Name = "obey", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetPaused",
			Type = "Function",

			Arguments =
			{
				{ Name = "paused", Type = "bool", Nilable = false },
				{ Name = "affectsGlobalPause", Type = "bool", Nilable = false, Default = true },
			},
		},
		{
			Name = "SetPlayerModelFromGlues",
			Type = "Function",

			Arguments =
			{
				{ Name = "characterIndex", Type = "number", Nilable = true },
				{ Name = "sheatheWeapons", Type = "bool", Nilable = false, Default = false },
				{ Name = "autoDress", Type = "bool", Nilable = false, Default = true },
				{ Name = "hideWeapons", Type = "bool", Nilable = false, Default = false },
				{ Name = "usePlayerNativeForm", Type = "bool", Nilable = false, Default = true },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetSheathed",
			Type = "Function",

			Arguments =
			{
				{ Name = "sheathed", Type = "bool", Nilable = false },
				{ Name = "hidden", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetUseTransmogChoices",
			Type = "Function",

			Arguments =
			{
				{ Name = "use", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetUseTransmogSkin",
			Type = "Function",

			Arguments =
			{
				{ Name = "use", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TryOn",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLinkOrItemModifiedAppearanceID", Type = "cstring", Nilable = false },
				{ Name = "handSlotName", Type = "cstring", Nilable = true },
				{ Name = "spellEnchantmentID", Type = "number", Nilable = false, Default = 0 },
			},

			Returns =
			{
				{ Name = "reason", Type = "ItemTryOnReason", Nilable = true },
			},
		},
		{
			Name = "Undress",
			Type = "Function",

			Arguments =
			{
				{ Name = "includeWeapons", Type = "bool", Nilable = false, Default = true },
			},
		},
		{
			Name = "UndressSlot",
			Type = "Function",

			Arguments =
			{
				{ Name = "inventorySlots", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(FrameAPIModelSceneFrameActor);