local HousingBlueprintConstants =
{
	Tables =
	{
		{
			Name = "HousingBlueprintContentType",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "None", Type = "HousingBlueprintContentType", EnumValue = 0 },
				{ Name = "HouseType", Type = "HousingBlueprintContentType", EnumValue = 1 },
				{ Name = "Room", Type = "HousingBlueprintContentType", EnumValue = 2 },
				{ Name = "Decor", Type = "HousingBlueprintContentType", EnumValue = 3 },
				{ Name = "Dye", Type = "HousingBlueprintContentType", EnumValue = 4 },
				{ Name = "Fixture", Type = "HousingBlueprintContentType", EnumValue = 5 },
				{ Name = "Other", Type = "HousingBlueprintContentType", EnumValue = 6 },
			},
		},
		{
			Name = "HousingBlueprintUnmetRequirementFlags",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 1,
			MaxValue = 128,
			Fields =
			{
				{ Name = "InsufficientBudget", Type = "HousingBlueprintUnmetRequirementFlags", EnumValue = 1 },
				{ Name = "MissingRoom", Type = "HousingBlueprintUnmetRequirementFlags", EnumValue = 2 },
				{ Name = "MissingFixture", Type = "HousingBlueprintUnmetRequirementFlags", EnumValue = 4 },
				{ Name = "MissingDecor", Type = "HousingBlueprintUnmetRequirementFlags", EnumValue = 8 },
				{ Name = "MissingDye", Type = "HousingBlueprintUnmetRequirementFlags", EnumValue = 16 },
				{ Name = "MismatchedExteriorFaction", Type = "HousingBlueprintUnmetRequirementFlags", EnumValue = 32 },
				{ Name = "HouseTypeLocked", Type = "HousingBlueprintUnmetRequirementFlags", EnumValue = 64 },
				{ Name = "HouseSizeLocked", Type = "HousingBlueprintUnmetRequirementFlags", EnumValue = 128 },
			},
		},
		{
			Name = "HousingBlueprintBudgetEntry",
			Type = "Structure",
			Fields =
			{
				{ Name = "budgetType", Type = "HousingBudgetType", Nilable = false },
				{ Name = "cost", Type = "number", Nilable = false },
				{ Name = "max", Type = "number", Nilable = true, Documentation = { "Will be nil if there is no target house or information for it is unavailable" } },
				{ Name = "current", Type = "number", Nilable = true, Documentation = { "Will be nil if there is no target house or information for it is unavailable" } },
			},
		},
		{
			Name = "HousingBlueprintBudgetInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "exteriorBudgets", Type = "table", InnerType = "HousingBlueprintBudgetEntry", KeyType = "HousingBudgetType", Nilable = false, Documentation = { "Map of budget type to budget entry" } },
				{ Name = "interiorBudgets", Type = "table", InnerType = "HousingBlueprintBudgetEntry", KeyType = "HousingBudgetType", Nilable = false, Documentation = { "Map of budget type to budget entry" } },
			},
		},
		{
			Name = "HousingBlueprintCollection",
			Type = "Structure",
			Documentation = { "List of Blueprints, separated into like groups" },
			Fields =
			{
				{ Name = "groups", Type = "table", InnerType = "HousingBlueprintGroup", Nilable = false },
			},
		},
		{
			Name = "HousingBlueprintContentEntry",
			Type = "Structure",
			Documentation = { "A single specific object that makes up a Blueprint's contents" },
			Fields =
			{
				{ Name = "contentType", Type = "HousingBlueprintContentType", Nilable = false },
				{ Name = "recordID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "total", Type = "number", Nilable = false, Default = 0, Documentation = { "Total instances of the object contained within or required by the Blueprint" } },
				{ Name = "numMissing", Type = "number", Nilable = false, Default = 0, Documentation = { "The number of instances of this item that the player doesn't own, or have unlocked, or have available for use (depending on the type of content)" } },
				{ Name = "invalid", Type = "bool", Nilable = false, Default = false, Documentation = { "True for content that isn't valid for use whether it's owned or not, for example exterior types of the opposite faction than the house's neighborhood" } },
				{ Name = "tooltip", Type = "string", Nilable = true },
			},
		},
		{
			Name = "HousingBlueprintContentGroup",
			Type = "Structure",
			Documentation = { "Group of entries of one specific type of object within a Blueprint" },
			Fields =
			{
				{ Name = "contentType", Type = "HousingBlueprintContentType", Nilable = false },
				{ Name = "entries", Type = "table", InnerType = "HousingBlueprintContentEntry", Nilable = false },
			},
		},
		{
			Name = "HousingBlueprintContentInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "shareCode", Type = "string", Nilable = false },
				{ Name = "targetHouseGUID", Type = "WOWGUID", Nilable = true },
				{ Name = "budgetInfo", Type = "HousingBlueprintBudgetInfo", Nilable = false },
				{ Name = "contentGroups", Type = "table", InnerType = "HousingBlueprintContentGroup", Nilable = false },
				{ Name = "unmetRequirementFlags", Type = "HousingBlueprintUnmetRequirementFlags", Nilable = false },
				{ Name = "blockingRequirementFlags", Type = "HousingBlueprintUnmetRequirementFlags", Nilable = false },
			},
		},
		{
			Name = "HousingBlueprintGroup",
			Type = "Structure",
			Documentation = { "Group of Blueprints of the same or similar types" },
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "entries", Type = "table", InnerType = "HousingBlueprintInfo", Nilable = false },
			},
		},
		{
			Name = "HousingBlueprintInfo",
			Type = "Structure",
			Documentation = { "List of entries of one specific type of object within a Blueprint" },
			Fields =
			{
				{ Name = "blueprintID", Type = "BigUInteger", Nilable = false },
				{ Name = "shareCode", Type = "string", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "blueprintType", Type = "HousingBlueprintType", Nilable = false },
				{ Name = "creationTime", Type = "time_t", Nilable = false },
				{ Name = "isAutoSave", Type = "bool", Nilable = false, Documentation = { "True if this blueprint is an automatically saved backup, rather than a manually player-saved blueprint" } },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(HousingBlueprintConstants);