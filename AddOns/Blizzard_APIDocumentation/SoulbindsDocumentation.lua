local Soulbinds =
{
	Name = "Soulbinds",
	Type = "System",
	Namespace = "C_Soulbinds",

	Functions =
	{
		{
			Name = "ActivateSoulbind",
			Type = "Function",

			Arguments =
			{
				{ Name = "soulbindID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CanActivateSoulbind",
			Type = "Function",

			Arguments =
			{
				{ Name = "soulbindID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
				{ Name = "errorDescription", Type = "string", Nilable = true },
			},
		},
		{
			Name = "CloseSoulbindForge",
			Type = "Function",
		},
		{
			Name = "EndInteraction",
			Type = "Function",
		},
		{
			Name = "GetActiveSoulbindID",
			Type = "Function",

			Returns =
			{
				{ Name = "soulbindID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetConduitCollection",
			Type = "Function",

			Arguments =
			{
				{ Name = "conduitType", Type = "SoulbindConduitType", Nilable = false },
			},

			Returns =
			{
				{ Name = "collectionData", Type = "table", InnerType = "ConduitCollectionData", Nilable = false },
			},
		},
		{
			Name = "GetConduitHyperlink",
			Type = "Function",

			Arguments =
			{
				{ Name = "conduitID", Type = "number", Nilable = false },
				{ Name = "rank", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "link", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetConduitID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "conduitID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetConduitSpellID",
			Type = "Function",

			Arguments =
			{
				{ Name = "conduitID", Type = "number", Nilable = false },
				{ Name = "conduitRank", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetItemConduitType",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "type", Type = "SoulbindConduitType", Nilable = true },
			},
		},
		{
			Name = "GetItemConduitTypeByItemID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "type", Type = "SoulbindConduitType", Nilable = true },
			},
		},
		{
			Name = "GetSoulbindData",
			Type = "Function",

			Arguments =
			{
				{ Name = "soulbindID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "SoulbindData", Nilable = false },
			},
		},
		{
			Name = "GetSoulbindIDs",
			Type = "Function",

			Arguments =
			{
				{ Name = "covenantID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "soulbindID", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetTree",
			Type = "Function",

			Arguments =
			{
				{ Name = "treeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "tree", Type = "SoulbindTree", Nilable = false },
			},
		},
		{
			Name = "HasInstalledConduit",
			Type = "Function",

			Arguments =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "InstallConduitInSlot",
			Type = "Function",

			Arguments =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
				{ Name = "conduitID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "SoulbindConduitInstallResult", Nilable = false },
			},
		},
		{
			Name = "IsAtSoulbindForge",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsItemConduit",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isConduit", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsItemConduitByItemInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ResetSoulbind",
			Type = "Function",

			Arguments =
			{
				{ Name = "soulbindID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SelectNode",
			Type = "Function",

			Arguments =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UninstallConduitInSlot",
			Type = "Function",

			Arguments =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "SoulbindActivated",
			Type = "Event",
			LiteralName = "SOULBIND_ACTIVATED",
			Payload =
			{
				{ Name = "soulbindID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SoulbindConduitCollectionRemoved",
			Type = "Event",
			LiteralName = "SOULBIND_CONDUIT_COLLECTION_REMOVED",
			Payload =
			{
				{ Name = "conduitID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SoulbindConduitCollectionUpdated",
			Type = "Event",
			LiteralName = "SOULBIND_CONDUIT_COLLECTION_UPDATED",
			Payload =
			{
				{ Name = "collectionData", Type = "ConduitCollectionData", Nilable = false },
			},
		},
		{
			Name = "SoulbindConduitInstalled",
			Type = "Event",
			LiteralName = "SOULBIND_CONDUIT_INSTALLED",
			Payload =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
				{ Name = "data", Type = "SoulbindConduitData", Nilable = false },
			},
		},
		{
			Name = "SoulbindConduitUninstalled",
			Type = "Event",
			LiteralName = "SOULBIND_CONDUIT_UNINSTALLED",
			Payload =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SoulbindForgeInteractionEnded",
			Type = "Event",
			LiteralName = "SOULBIND_FORGE_INTERACTION_ENDED",
		},
		{
			Name = "SoulbindForgeInteractionStarted",
			Type = "Event",
			LiteralName = "SOULBIND_FORGE_INTERACTION_STARTED",
		},
		{
			Name = "SoulbindNodeLearned",
			Type = "Event",
			LiteralName = "SOULBIND_NODE_LEARNED",
			Payload =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SoulbindNodeUnlearned",
			Type = "Event",
			LiteralName = "SOULBIND_NODE_UNLEARNED",
			Payload =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SoulbindNodeUpdated",
			Type = "Event",
			LiteralName = "SOULBIND_NODE_UPDATED",
			Payload =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SoulbindPathChanged",
			Type = "Event",
			LiteralName = "SOULBIND_PATH_CHANGED",
		},
	},

	Tables =
	{
		{
			Name = "ConduitCollectionData",
			Type = "Structure",
			Fields =
			{
				{ Name = "conduitID", Type = "number", Nilable = false },
				{ Name = "conduitRank", Type = "number", Nilable = false },
				{ Name = "conduitType", Type = "SoulbindConduitType", Nilable = false },
				{ Name = "conduitSpecID", Type = "number", Nilable = false },
				{ Name = "conduitSpecName", Type = "string", Nilable = true },
				{ Name = "covenantID", Type = "number", Nilable = true },
				{ Name = "conduitItemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SoulbindConduitData",
			Type = "Structure",
			Fields =
			{
				{ Name = "conduitID", Type = "number", Nilable = false },
				{ Name = "conduitRank", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SoulbindData",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "covenantID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "unlocked", Type = "bool", Nilable = false },
				{ Name = "cvarIndex", Type = "number", Nilable = false },
				{ Name = "tree", Type = "SoulbindTree", Nilable = false },
				{ Name = "modelSceneData", Type = "SoulbindModelSceneData", Nilable = false },
				{ Name = "resetData", Type = "SoulbindResetData", Nilable = false },
			},
		},
		{
			Name = "SoulbindModelSceneData",
			Type = "Structure",
			Fields =
			{
				{ Name = "creatureDisplayInfoID", Type = "number", Nilable = false },
				{ Name = "modelSceneActorID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SoulbindNode",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "row", Type = "number", Nilable = false },
				{ Name = "column", Type = "number", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "playerConditionReason", Type = "string", Nilable = true },
				{ Name = "conduitID", Type = "number", Nilable = false },
				{ Name = "conduitRank", Type = "number", Nilable = false },
				{ Name = "state", Type = "SoulbindNodeState", Nilable = false },
				{ Name = "conduitType", Type = "SoulbindConduitType", Nilable = true },
				{ Name = "parentNodeIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "SoulbindResetCurrencyData",
			Type = "Structure",
			Fields =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SoulbindResetData",
			Type = "Structure",
			Fields =
			{
				{ Name = "goldCost", Type = "number", Nilable = false },
				{ Name = "currencyCosts", Type = "table", InnerType = "SoulbindResetCurrencyData", Nilable = false },
			},
		},
		{
			Name = "SoulbindTree",
			Type = "Structure",
			Fields =
			{
				{ Name = "editable", Type = "bool", Nilable = false },
				{ Name = "nodes", Type = "table", InnerType = "SoulbindNode", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Soulbinds);