local FrameAPIModelSceneFrameActor =
{
	Name = "FrameAPIModelSceneFrameActor",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "AttachToMount",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "DetachFromMount",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "rider", Type = "ModelSceneFrameActor", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "autoDress", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetFrontEndLobbyModelFromDefaultCharacterDisplay",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "obey", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetPaused",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "paused", Type = "bool", Nilable = false },
				{ Name = "affectsGlobalPause", Type = "bool", Nilable = false, Default = true },
			},
		},
		{
			Name = "SetSheathed",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "sheathed", Type = "bool", Nilable = false },
				{ Name = "hidden", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetUseTransmogChoices",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "use", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetUseTransmogSkin",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "use", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Undress",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "includeWeapons", Type = "bool", Nilable = false, Default = true },
			},
		},
		{
			Name = "UndressSlot",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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