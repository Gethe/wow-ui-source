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
				{ Name = "dyeColorCategoryID", Type = "number", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "channel", Type = "number", Nilable = false },
				{ Name = "dyeColorID", Type = "number", Nilable = true },
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
				{ Name = "canBeCustomized", Type = "bool", Nilable = false },
				{ Name = "canBeRemoved", Type = "bool", Nilable = false },
				{ Name = "isAllowedOutdoors", Type = "bool", Nilable = false },
				{ Name = "isAllowedIndoors", Type = "bool", Nilable = false },
				{ Name = "dyeSlots", Type = "table", InnerType = "HousingDecorDyeSlot", Nilable = false },
				{ Name = "dataTagsByID", Type = "LuaValueVariant", Nilable = false },
				{ Name = "size", Type = "HousingCatalogEntrySize", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(HousingDecorShared);