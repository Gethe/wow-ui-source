local SharedTraits =
{
	Name = "SharedTraits",
	Type = "System",
	Namespace = "C_Traits",

	Functions =
	{
		{
			Name = "CanPurchaseRank",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
				{ Name = "nodeID", Type = "number", Nilable = false },
				{ Name = "nodeEntryID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canPurchase", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanRefundRank",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
				{ Name = "nodeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canRefund", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CascadeRepurchaseRanks",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
				{ Name = "nodeID", Type = "number", Nilable = false },
				{ Name = "entryID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ClearCascadeRepurchaseHistory",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CloseTraitSystemInteraction",
			Type = "Function",
		},
		{
			Name = "CommitConfig",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ConfigHasStagedChanges",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasChanges", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GenerateImportString",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "importString", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GenerateInspectImportString",
			Type = "Function",

			Arguments =
			{
				{ Name = "target", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "importString", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetConditionInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
				{ Name = "condID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "condInfo", Type = "TraitCondInfo", Nilable = false },
			},
		},
		{
			Name = "GetConfigIDBySystemID",
			Type = "Function",

			Arguments =
			{
				{ Name = "systemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetConfigIDByTreeID",
			Type = "Function",

			Arguments =
			{
				{ Name = "treeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetConfigInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "configInfo", Type = "TraitConfigInfo", Nilable = false },
			},
		},
		{
			Name = "GetConfigsByType",
			Type = "Function",

			Arguments =
			{
				{ Name = "configType", Type = "TraitConfigType", Nilable = false },
			},

			Returns =
			{
				{ Name = "configIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetDefinitionInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "definitionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "definitionInfo", Type = "TraitDefinitionInfo", Nilable = false },
			},
		},
		{
			Name = "GetEntryInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
				{ Name = "entryID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "entryInfo", Type = "TraitEntryInfo", Nilable = false },
			},
		},
		{
			Name = "GetLoadoutSerializationVersion",
			Type = "Function",

			Returns =
			{
				{ Name = "serializationVersion", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNodeCost",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
				{ Name = "nodeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "costs", Type = "table", InnerType = "TraitCurrencyCost", Nilable = false },
			},
		},
		{
			Name = "GetNodeInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
				{ Name = "nodeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "nodeInfo", Type = "TraitNodeInfo", Nilable = false },
			},
		},
		{
			Name = "GetStagedChangesCost",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "costs", Type = "table", InnerType = "TraitCurrencyCost", Nilable = false },
			},
		},
		{
			Name = "GetStagedPurchases",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "nodeIDsWithPurchases", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetTraitCurrencyInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "traitCurrencyID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "flags", Type = "number", Nilable = false },
				{ Name = "type", Type = "number", Nilable = false },
				{ Name = "currencyTypesID", Type = "number", Nilable = true },
				{ Name = "icon", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetTraitDescription",
			Type = "Function",

			Arguments =
			{
				{ Name = "entryID", Type = "number", Nilable = false },
				{ Name = "rank", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "description", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetTraitSystemFlags",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "flags", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTraitSystemWidgetSetID",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "uiWidgetSetID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTreeCurrencyInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
				{ Name = "treeID", Type = "number", Nilable = false },
				{ Name = "excludeStagedChanges", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "treeCurrencyInfo", Type = "table", InnerType = "TreeCurrencyInfo", Nilable = false },
			},
		},
		{
			Name = "GetTreeHash",
			Type = "Function",

			Arguments =
			{
				{ Name = "treeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetTreeInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
				{ Name = "treeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "treeInfo", Type = "TraitTreeInfo", Nilable = false },
			},
		},
		{
			Name = "GetTreeNodes",
			Type = "Function",
			Documentation = { "Returns a list of nodeIDs, sorted ascending, for a given treeID. Contains nodes for all class specializations." },

			Arguments =
			{
				{ Name = "treeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "nodeIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "HasValidInspectData",
			Type = "Function",

			Returns =
			{
				{ Name = "hasValidInspectData", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsReadyForCommit",
			Type = "Function",

			Returns =
			{
				{ Name = "isReadyForCommit", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PurchaseRank",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
				{ Name = "nodeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RefundAllRanks",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
				{ Name = "nodeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RefundRank",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
				{ Name = "nodeID", Type = "number", Nilable = false },
				{ Name = "clearEdges", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ResetTree",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
				{ Name = "treeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ResetTreeByCurrency",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
				{ Name = "treeID", Type = "number", Nilable = false },
				{ Name = "traitCurrencyID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RollbackConfig",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetSelection",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
				{ Name = "nodeID", Type = "number", Nilable = false },
				{ Name = "nodeEntryID", Type = "number", Nilable = true },
				{ Name = "clearEdges", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "StageConfig",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TalentTestUnlearnSpells",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "ConfigCommitFailed",
			Type = "Event",
			LiteralName = "CONFIG_COMMIT_FAILED",
			Payload =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TraitCondInfoChanged",
			Type = "Event",
			LiteralName = "TRAIT_COND_INFO_CHANGED",
			Payload =
			{
				{ Name = "condID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TraitConfigCreated",
			Type = "Event",
			LiteralName = "TRAIT_CONFIG_CREATED",
			Payload =
			{
				{ Name = "configInfo", Type = "TraitConfigInfo", Nilable = false },
			},
		},
		{
			Name = "TraitConfigDeleted",
			Type = "Event",
			LiteralName = "TRAIT_CONFIG_DELETED",
			Payload =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TraitConfigListUpdated",
			Type = "Event",
			LiteralName = "TRAIT_CONFIG_LIST_UPDATED",
		},
		{
			Name = "TraitConfigUpdated",
			Type = "Event",
			LiteralName = "TRAIT_CONFIG_UPDATED",
			Payload =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TraitNodeChanged",
			Type = "Event",
			LiteralName = "TRAIT_NODE_CHANGED",
			Payload =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TraitNodeChangedPartial",
			Type = "Event",
			LiteralName = "TRAIT_NODE_CHANGED_PARTIAL",
			Payload =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "info", Type = "TraitNodeInfoPartial", Nilable = false },
			},
		},
		{
			Name = "TraitNodeEntryUpdated",
			Type = "Event",
			LiteralName = "TRAIT_NODE_ENTRY_UPDATED",
			Payload =
			{
				{ Name = "nodeEntryID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TraitSystemInteractionStarted",
			Type = "Event",
			LiteralName = "TRAIT_SYSTEM_INTERACTION_STARTED",
			Payload =
			{
				{ Name = "treeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TraitSystemNpcClosed",
			Type = "Event",
			LiteralName = "TRAIT_SYSTEM_NPC_CLOSED",
		},
		{
			Name = "TraitTreeChanged",
			Type = "Event",
			LiteralName = "TRAIT_TREE_CHANGED",
			Payload =
			{
				{ Name = "treeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TraitTreeCurrencyInfoUpdated",
			Type = "Event",
			LiteralName = "TRAIT_TREE_CURRENCY_INFO_UPDATED",
			Payload =
			{
				{ Name = "treeID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "TraitCondInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "condID", Type = "number", Nilable = false },
				{ Name = "ranksGranted", Type = "number", Nilable = true },
				{ Name = "isAlwaysMet", Type = "bool", Nilable = false },
				{ Name = "isMet", Type = "bool", Nilable = false },
				{ Name = "isGate", Type = "bool", Nilable = false },
				{ Name = "questID", Type = "number", Nilable = true },
				{ Name = "achievementID", Type = "number", Nilable = true },
				{ Name = "specSetID", Type = "number", Nilable = true },
				{ Name = "playerLevel", Type = "number", Nilable = true },
				{ Name = "traitCurrencyID", Type = "number", Nilable = true },
				{ Name = "spentAmountRequired", Type = "number", Nilable = true },
				{ Name = "tooltipFormat", Type = "string", Nilable = true },
			},
		},
		{
			Name = "TraitConfigInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "type", Type = "TraitConfigType", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "treeIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "usesSharedActionBars", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TraitCurrencyCost",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "amount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TraitDefinitionInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "spellID", Type = "number", Nilable = true },
				{ Name = "overrideName", Type = "string", Nilable = true },
				{ Name = "overrideSubtext", Type = "string", Nilable = true },
				{ Name = "overrideDescription", Type = "string", Nilable = true },
				{ Name = "overrideIcon", Type = "number", Nilable = true },
				{ Name = "overriddenSpellID", Type = "number", Nilable = true },
				{ Name = "subType", Type = "TraitDefinitionSubType", Nilable = true },
			},
		},
		{
			Name = "TraitEntryInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "definitionID", Type = "number", Nilable = false },
				{ Name = "type", Type = "TraitNodeEntryType", Nilable = false },
				{ Name = "maxRanks", Type = "number", Nilable = false },
				{ Name = "isAvailable", Type = "bool", Nilable = false },
				{ Name = "conditionIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "TraitEntryRankInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "entryID", Type = "number", Nilable = false },
				{ Name = "rank", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TraitGateInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "topLeftNodeID", Type = "number", Nilable = false },
				{ Name = "conditionID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TraitNodeInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "posX", Type = "number", Nilable = false },
				{ Name = "posY", Type = "number", Nilable = false },
				{ Name = "flags", Type = "number", Nilable = false },
				{ Name = "entryIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "entryIDsWithCommittedRanks", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "canPurchaseRank", Type = "bool", Nilable = false },
				{ Name = "canRefundRank", Type = "bool", Nilable = false },
				{ Name = "isAvailable", Type = "bool", Nilable = false },
				{ Name = "isVisible", Type = "bool", Nilable = false },
				{ Name = "ranksPurchased", Type = "number", Nilable = false },
				{ Name = "activeRank", Type = "number", Nilable = false },
				{ Name = "currentRank", Type = "number", Nilable = false },
				{ Name = "activeEntry", Type = "TraitEntryRankInfo", Nilable = true },
				{ Name = "nextEntry", Type = "TraitEntryRankInfo", Nilable = true },
				{ Name = "maxRanks", Type = "number", Nilable = false },
				{ Name = "type", Type = "TraitNodeType", Nilable = false },
				{ Name = "visibleEdges", Type = "table", InnerType = "TraitOutEdgeInfo", Nilable = false },
				{ Name = "meetsEdgeRequirements", Type = "bool", Nilable = false },
				{ Name = "groupIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "conditionIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "isCascadeRepurchasable", Type = "bool", Nilable = false },
				{ Name = "cascadeRepurchaseEntryID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "TraitNodeInfoPartial",
			Type = "Structure",
			Fields =
			{
				{ Name = "canPurchaseRank", Type = "bool", Nilable = true },
				{ Name = "canRefundRank", Type = "bool", Nilable = true },
				{ Name = "isAvailable", Type = "bool", Nilable = true },
				{ Name = "isVisible", Type = "bool", Nilable = true },
				{ Name = "ranksPurchased", Type = "number", Nilable = true },
				{ Name = "activeRank", Type = "number", Nilable = true },
				{ Name = "currentRank", Type = "number", Nilable = true },
				{ Name = "meetsEdgeRequirements", Type = "bool", Nilable = true },
				{ Name = "isCascadeRepurchasable", Type = "bool", Nilable = true },
				{ Name = "activeEntryID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "TraitOutEdgeInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "targetNode", Type = "number", Nilable = false },
				{ Name = "type", Type = "number", Nilable = false },
				{ Name = "visualStyle", Type = "number", Nilable = false },
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TraitTreeInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "gates", Type = "table", InnerType = "TraitGateInfo", Nilable = false },
				{ Name = "hideSingleRankNumbers", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TreeCurrencyInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "traitCurrencyID", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "maxQuantity", Type = "number", Nilable = true },
				{ Name = "spent", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SharedTraits);