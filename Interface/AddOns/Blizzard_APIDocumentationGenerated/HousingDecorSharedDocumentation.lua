local HousingDecorShared =
{
	Tables =
	{
		{
			Name = "HousingDecorDyeSlot",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "dyeColorCategoryID", Type = "number", Nilable = false, Documentation = { "What category of dye colors this slot is for; This currently has no functional useage as slots accept colors of any category, but may be used for things like labeling in the future" } },
				{ Name = "orderIndex", Type = "number", Nilable = false, Documentation = { "Display sort order" } },
				{ Name = "channel", Type = "number", Nilable = false, Documentation = { "The specific shader channel that this slot affects when a dye color is applied" } },
				{ Name = "dyeColorID", Type = "number", Nilable = true, Documentation = { "What dye color (if any) is currently applied to this slot" } },
			},
		},
		{
			Name = "HousingDecorInstanceInfo",
			Type = "Structure",
			Documentation = { "Info for an instance of Housing Decor that has been/is being placed within a House or its exterior Plot" },
			Fields =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "decorID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "isLocked", Type = "bool", Nilable = false, Documentation = { "True if this decor is already being edited by someone else" } },
				{ Name = "canBeCustomized", Type = "bool", Nilable = false, Documentation = { "True if this decor can be customized, namely by applying Dyes" } },
				{ Name = "canBeRemoved", Type = "bool", Nilable = false, Documentation = { "False if this decor must remain placed in the house and cannot be placed back into house chest storage" } },
				{ Name = "isAllowedOutdoors", Type = "bool", Nilable = false },
				{ Name = "isAllowedIndoors", Type = "bool", Nilable = false },
				{ Name = "isRefundable", Type = "bool", Nilable = false },
				{ Name = "dyeSlots", Type = "table", InnerType = "HousingDecorDyeSlot", Nilable = false, Documentation = { "Empty for decor that can't be dyed (see canBeCustomized)" } },
				{ Name = "dataTagsByID", Type = "LuaValueVariant", Nilable = false, Documentation = { "Simple localized 'tag' strings that are primarily used for things like categorization and filtering" } },
				{ Name = "size", Type = "HousingCatalogEntrySize", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(HousingDecorShared);