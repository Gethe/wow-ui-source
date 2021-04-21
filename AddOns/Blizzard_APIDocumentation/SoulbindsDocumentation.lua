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
			Name = "CanModifySoulbind",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanResetConduitsInSoulbind",
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
			Name = "CanSwitchActiveSoulbindTreeBranch",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CloseUI",
			Type = "Function",
		},
		{
			Name = "CommitPendingConduitsInSoulbind",
			Type = "Function",

			Arguments =
			{
				{ Name = "soulbindID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "FindNodeIDActuallyInstalled",
			Type = "Function",

			Arguments =
			{
				{ Name = "soulbindID", Type = "number", Nilable = false },
				{ Name = "conduitID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "FindNodeIDAppearingInstalled",
			Type = "Function",

			Arguments =
			{
				{ Name = "soulbindID", Type = "number", Nilable = false },
				{ Name = "conduitID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "FindNodeIDPendingInstall",
			Type = "Function",

			Arguments =
			{
				{ Name = "soulbindID", Type = "number", Nilable = false },
				{ Name = "conduitID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "FindNodeIDPendingUninstall",
			Type = "Function",

			Arguments =
			{
				{ Name = "soulbindID", Type = "number", Nilable = false },
				{ Name = "conduitID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
			},
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
			Name = "GetConduitCharges",
			Type = "Function",

			Returns =
			{
				{ Name = "charges", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetConduitChargesCapacity",
			Type = "Function",

			Returns =
			{
				{ Name = "charges", Type = "number", Nilable = false },
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
			Name = "GetConduitCollectionCount",
			Type = "Function",

			Returns =
			{
				{ Name = "count", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetConduitCollectionData",
			Type = "Function",

			Arguments =
			{
				{ Name = "conduitID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "collectionData", Type = "ConduitCollectionData", Nilable = true },
			},
		},
		{
			Name = "GetConduitCollectionDataAtCursor",
			Type = "Function",

			Returns =
			{
				{ Name = "collectionData", Type = "ConduitCollectionData", Nilable = true },
			},
		},
		{
			Name = "GetConduitCollectionDataByVirtualID",
			Type = "Function",

			Arguments =
			{
				{ Name = "virtualID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "collectionData", Type = "ConduitCollectionData", Nilable = true },
			},
		},
		{
			Name = "GetConduitDisplayed",
			Type = "Function",

			Arguments =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "conduitID", Type = "number", Nilable = false },
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
			Name = "GetConduitIDPendingInstall",
			Type = "Function",

			Arguments =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "conduitID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetConduitQuality",
			Type = "Function",

			Arguments =
			{
				{ Name = "conduitID", Type = "number", Nilable = false },
				{ Name = "rank", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "quality", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetConduitRank",
			Type = "Function",

			Arguments =
			{
				{ Name = "conduitID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "conduitRank", Type = "number", Nilable = false },
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
			Name = "GetInstalledConduitID",
			Type = "Function",

			Arguments =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "conduitID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNode",
			Type = "Function",

			Arguments =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "node", Type = "SoulbindNode", Nilable = false },
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
			Name = "GetSpecsAssignedToSoulbind",
			Type = "Function",

			Arguments =
			{
				{ Name = "soulbindID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "specIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetTotalConduitChargesPending",
			Type = "Function",

			Returns =
			{
				{ Name = "count", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTotalConduitChargesPendingInSoulbind",
			Type = "Function",

			Arguments =
			{
				{ Name = "soulbindID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "count", Type = "number", Nilable = false },
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
			Name = "HasAnyInstalledConduitInSoulbind",
			Type = "Function",

			Arguments =
			{
				{ Name = "soulbindID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasAnyPendingConduits",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasPendingConduitsInSoulbind",
			Type = "Function",

			Arguments =
			{
				{ Name = "soulbindID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsConduitInstalled",
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
			Name = "IsConduitInstalledInSoulbind",
			Type = "Function",

			Arguments =
			{
				{ Name = "soulbindID", Type = "number", Nilable = false },
				{ Name = "conduitID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
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
			Name = "IsNodePendingModify",
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
			Name = "IsUnselectedConduitPendingInSoulbind",
			Type = "Function",

			Arguments =
			{
				{ Name = "soulbindID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ModifyNode",
			Type = "Function",

			Arguments =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
				{ Name = "conduitID", Type = "number", Nilable = false },
				{ Name = "type", Type = "SoulbindConduitTransactionType", Nilable = false },
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
			Name = "UnmodifyNode",
			Type = "Function",

			Arguments =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
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
			Name = "SoulbindConduitChargesUpdated",
			Type = "Event",
			LiteralName = "SOULBIND_CONDUIT_CHARGES_UPDATED",
			Payload =
			{
				{ Name = "charges", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SoulbindConduitCollectionCleared",
			Type = "Event",
			LiteralName = "SOULBIND_CONDUIT_COLLECTION_CLEARED",
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
				{ Name = "data", Type = "SoulbindConduitData", Nilable = false },
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
		{
			Name = "SoulbindPendingConduitChanged",
			Type = "Event",
			LiteralName = "SOULBIND_PENDING_CONDUIT_CHANGED",
			Payload =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
				{ Name = "conduitID", Type = "number", Nilable = false },
			},
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
				{ Name = "conduitItemLevel", Type = "number", Nilable = false },
				{ Name = "conduitType", Type = "SoulbindConduitType", Nilable = false },
				{ Name = "conduitSpecSetID", Type = "number", Nilable = false },
				{ Name = "conduitSpecIDs", Type = "table", InnerType = "number", Nilable = false },
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
				{ Name = "activationSoundKitID", Type = "number", Nilable = false },
				{ Name = "playerConditionReason", Type = "string", Nilable = true },
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
				{ Name = "failureRenownRequirement", Type = "number", Nilable = true },
				{ Name = "socketEnhanced", Type = "bool", Nilable = true },
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