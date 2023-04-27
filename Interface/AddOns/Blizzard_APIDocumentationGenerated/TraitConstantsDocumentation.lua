local TraitConstants =
{
	Tables =
	{
		{
			Name = "NodeOpFailureReason",
			Type = "Enumeration",
			NumValues = 25,
			MinValue = 0,
			MaxValue = 24,
			Fields =
			{
				{ Name = "None", Type = "NodeOpFailureReason", EnumValue = 0 },
				{ Name = "MissingEdgeConnection", Type = "NodeOpFailureReason", EnumValue = 1 },
				{ Name = "RequiredForEdge", Type = "NodeOpFailureReason", EnumValue = 2 },
				{ Name = "MissingRequiredEdge", Type = "NodeOpFailureReason", EnumValue = 3 },
				{ Name = "HasMutuallyExclusiveEdge", Type = "NodeOpFailureReason", EnumValue = 4 },
				{ Name = "NotEnoughSourcedCurrencySpent", Type = "NodeOpFailureReason", EnumValue = 5 },
				{ Name = "NotEnoughCurrencySpent", Type = "NodeOpFailureReason", EnumValue = 6 },
				{ Name = "NotEnoughGoldSpent", Type = "NodeOpFailureReason", EnumValue = 7 },
				{ Name = "MissingAchievement", Type = "NodeOpFailureReason", EnumValue = 8 },
				{ Name = "MissingQuest", Type = "NodeOpFailureReason", EnumValue = 9 },
				{ Name = "WrongSpec", Type = "NodeOpFailureReason", EnumValue = 10 },
				{ Name = "WrongSelection", Type = "NodeOpFailureReason", EnumValue = 11 },
				{ Name = "MaxRank", Type = "NodeOpFailureReason", EnumValue = 12 },
				{ Name = "DataError", Type = "NodeOpFailureReason", EnumValue = 13 },
				{ Name = "NotEnoughSourcedCurrency", Type = "NodeOpFailureReason", EnumValue = 14 },
				{ Name = "NotEnoughCurrency", Type = "NodeOpFailureReason", EnumValue = 15 },
				{ Name = "NotEnoughGold", Type = "NodeOpFailureReason", EnumValue = 16 },
				{ Name = "SameSelection", Type = "NodeOpFailureReason", EnumValue = 17 },
				{ Name = "NodeNotFound", Type = "NodeOpFailureReason", EnumValue = 18 },
				{ Name = "EntryNotFound", Type = "NodeOpFailureReason", EnumValue = 19 },
				{ Name = "RequiredForCondition", Type = "NodeOpFailureReason", EnumValue = 20 },
				{ Name = "WrongTreeID", Type = "NodeOpFailureReason", EnumValue = 21 },
				{ Name = "LevelTooLow", Type = "NodeOpFailureReason", EnumValue = 22 },
				{ Name = "TreeFlaggedNoRefund", Type = "NodeOpFailureReason", EnumValue = 23 },
				{ Name = "NodeNeverPurchasable", Type = "NodeOpFailureReason", EnumValue = 24 },
			},
		},
		{
			Name = "SharedStringFlag",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "InternalOnly", Type = "SharedStringFlag", EnumValue = 1 },
			},
		},
		{
			Name = "TraitCombatConfigFlags",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 1,
			MaxValue = 4,
			Fields =
			{
				{ Name = "ActiveForSpec", Type = "TraitCombatConfigFlags", EnumValue = 1 },
				{ Name = "StarterBuild", Type = "TraitCombatConfigFlags", EnumValue = 2 },
				{ Name = "SharedActionBars", Type = "TraitCombatConfigFlags", EnumValue = 4 },
			},
		},
		{
			Name = "TraitCondFlag",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 1,
			MaxValue = 4,
			Fields =
			{
				{ Name = "IsGate", Type = "TraitCondFlag", EnumValue = 1 },
				{ Name = "IsAlwaysMet", Type = "TraitCondFlag", EnumValue = 2 },
				{ Name = "IsSufficient", Type = "TraitCondFlag", EnumValue = 4 },
			},
		},
		{
			Name = "TraitConditionType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Available", Type = "TraitConditionType", EnumValue = 0 },
				{ Name = "Visible", Type = "TraitConditionType", EnumValue = 1 },
				{ Name = "Granted", Type = "TraitConditionType", EnumValue = 2 },
				{ Name = "Increased", Type = "TraitConditionType", EnumValue = 3 },
			},
		},
		{
			Name = "TraitConfigDbState",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Ready", Type = "TraitConfigDbState", EnumValue = 0 },
				{ Name = "Created", Type = "TraitConfigDbState", EnumValue = 1 },
				{ Name = "Removed", Type = "TraitConfigDbState", EnumValue = 2 },
				{ Name = "Deleted", Type = "TraitConfigDbState", EnumValue = 3 },
			},
		},
		{
			Name = "TraitConfigType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Invalid", Type = "TraitConfigType", EnumValue = 0 },
				{ Name = "Combat", Type = "TraitConfigType", EnumValue = 1 },
				{ Name = "Profession", Type = "TraitConfigType", EnumValue = 2 },
				{ Name = "Generic", Type = "TraitConfigType", EnumValue = 3 },
			},
		},
		{
			Name = "TraitCurrencyFlag",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 1,
			MaxValue = 8,
			Fields =
			{
				{ Name = "ShowQuantityAsSpent", Type = "TraitCurrencyFlag", EnumValue = 1 },
				{ Name = "TraitSourcedShowMax", Type = "TraitCurrencyFlag", EnumValue = 2 },
				{ Name = "UseClassIcon", Type = "TraitCurrencyFlag", EnumValue = 4 },
				{ Name = "UseSpecIcon", Type = "TraitCurrencyFlag", EnumValue = 8 },
			},
		},
		{
			Name = "TraitCurrencyType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Gold", Type = "TraitCurrencyType", EnumValue = 0 },
				{ Name = "CurrencyTypesBased", Type = "TraitCurrencyType", EnumValue = 1 },
				{ Name = "TraitSourced", Type = "TraitCurrencyType", EnumValue = 2 },
			},
		},
		{
			Name = "TraitDefinitionSubType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "DragonflightRed", Type = "TraitDefinitionSubType", EnumValue = 0 },
				{ Name = "DragonflightBlue", Type = "TraitDefinitionSubType", EnumValue = 1 },
				{ Name = "DragonflightGreen", Type = "TraitDefinitionSubType", EnumValue = 2 },
				{ Name = "DragonflightBronze", Type = "TraitDefinitionSubType", EnumValue = 3 },
				{ Name = "DragonflightBlack", Type = "TraitDefinitionSubType", EnumValue = 4 },
			},
		},
		{
			Name = "TraitEdgeType",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "VisualOnly", Type = "TraitEdgeType", EnumValue = 0 },
				{ Name = "DeprecatedRankConnection", Type = "TraitEdgeType", EnumValue = 1 },
				{ Name = "SufficientForAvailability", Type = "TraitEdgeType", EnumValue = 2 },
				{ Name = "RequiredForAvailability", Type = "TraitEdgeType", EnumValue = 3 },
				{ Name = "MutuallyExclusive", Type = "TraitEdgeType", EnumValue = 4 },
				{ Name = "DeprecatedSelectionOption", Type = "TraitEdgeType", EnumValue = 5 },
			},
		},
		{
			Name = "TraitEdgeVisualStyle",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "None", Type = "TraitEdgeVisualStyle", EnumValue = 0 },
				{ Name = "Straight", Type = "TraitEdgeVisualStyle", EnumValue = 1 },
			},
		},
		{
			Name = "TraitNodeEntryType",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 0,
			MaxValue = 9,
			Fields =
			{
				{ Name = "SpendHex", Type = "TraitNodeEntryType", EnumValue = 0 },
				{ Name = "SpendSquare", Type = "TraitNodeEntryType", EnumValue = 1 },
				{ Name = "SpendCircle", Type = "TraitNodeEntryType", EnumValue = 2 },
				{ Name = "SpendSmallCircle", Type = "TraitNodeEntryType", EnumValue = 3 },
				{ Name = "DeprecatedSelect", Type = "TraitNodeEntryType", EnumValue = 4 },
				{ Name = "DragAndDrop", Type = "TraitNodeEntryType", EnumValue = 5 },
				{ Name = "SpendDiamond", Type = "TraitNodeEntryType", EnumValue = 6 },
				{ Name = "ProfPath", Type = "TraitNodeEntryType", EnumValue = 7 },
				{ Name = "ProfPerk", Type = "TraitNodeEntryType", EnumValue = 8 },
				{ Name = "ProfPathUnlock", Type = "TraitNodeEntryType", EnumValue = 9 },
			},
		},
		{
			Name = "TraitNodeFlag",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 1,
			MaxValue = 8,
			Fields =
			{
				{ Name = "ShowMultipleIcons", Type = "TraitNodeFlag", EnumValue = 1 },
				{ Name = "NeverPurchasable", Type = "TraitNodeFlag", EnumValue = 2 },
				{ Name = "TestPositionLocked", Type = "TraitNodeFlag", EnumValue = 4 },
				{ Name = "TestGridPositioned", Type = "TraitNodeFlag", EnumValue = 8 },
			},
		},
		{
			Name = "TraitNodeGroupFlag",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "AvailableByDefault", Type = "TraitNodeGroupFlag", EnumValue = 1 },
			},
		},
		{
			Name = "TraitNodeType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Single", Type = "TraitNodeType", EnumValue = 0 },
				{ Name = "Tiered", Type = "TraitNodeType", EnumValue = 1 },
				{ Name = "Selection", Type = "TraitNodeType", EnumValue = 2 },
			},
		},
		{
			Name = "TraitPointsOperationType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = -1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "None", Type = "TraitPointsOperationType", EnumValue = -1 },
				{ Name = "Set", Type = "TraitPointsOperationType", EnumValue = 0 },
				{ Name = "Multiply", Type = "TraitPointsOperationType", EnumValue = 1 },
			},
		},
		{
			Name = "TraitSystemFlag",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 1,
			MaxValue = 2,
			Fields =
			{
				{ Name = "AllowMultipleLoadoutsPerTree", Type = "TraitSystemFlag", EnumValue = 1 },
				{ Name = "ShowSpendConfirmation", Type = "TraitSystemFlag", EnumValue = 2 },
			},
		},
		{
			Name = "TraitTreeFlag",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 1,
			MaxValue = 2,
			Fields =
			{
				{ Name = "CannotRefund", Type = "TraitTreeFlag", EnumValue = 1 },
				{ Name = "HideSingleRankNumbers", Type = "TraitTreeFlag", EnumValue = 2 },
			},
		},
		{
			Name = "TraitConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "MAX_COMBAT_TRAIT_CONFIGS", Type = "number", Value = 10 },
				{ Name = "COMMIT_COMBAT_TRAIT_CONFIG_CHANGES_SPELL_ID", Type = "number", Value = 384255 },
				{ Name = "INSPECT_TRAIT_CONFIG_ID", Type = "number", Value = -1 },
				{ Name = "STARTER_BUILD_TRAIT_CONFIG_ID", Type = "number", Value = -2 },
				{ Name = "VIEW_TRAIT_CONFIG_ID", Type = "number", Value = -3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(TraitConstants);