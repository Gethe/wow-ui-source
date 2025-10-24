local HousingCatalogSearcherAPI =
{
	Name = "HousingCatalogSearcherAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "GetAllSearchItems",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "matchingEntryIDs", Type = "table", InnerType = "HousingCatalogEntryID", Nilable = false },
			},
		},
		{
			Name = "GetCatalogSearchResults",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "matchingEntryIDs", Type = "table", InnerType = "HousingCatalogEntryID", Nilable = false },
			},
		},
		{
			Name = "GetEditorModeContext",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "editorModeContext", Type = "HouseEditorMode", Nilable = true },
			},
		},
		{
			Name = "GetFilterTagStatus",
			Type = "Function",

			Arguments =
			{
				{ Name = "groupID", Type = "number", Nilable = false },
				{ Name = "tagID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "active", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetFilteredCategoryID",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "categoryID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetFilteredSubcategoryID",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "subcategoryID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetNumSearchItems",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "numSearchItems", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSearchText",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "searchText", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetSortType",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "sortType", Type = "HousingCatalogSortType", Nilable = false },
			},
		},
		{
			Name = "IsAllowedIndoorsActive",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAllowedOutdoorsActive",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsCollectedActive",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsCustomizableOnlyActive",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsFirstAcquisitionBonusOnlyActive",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsIncludingMarketEntries",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isIncludingMarketEntries", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsOwnedOnlyActive",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsUncollectedActive",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RunSearch",
			Type = "Function",
			Documentation = { "Run search with all current param values" },

			Arguments =
			{
			},
		},
		{
			Name = "SetAllInFilterTagGroup",
			Type = "Function",

			Arguments =
			{
				{ Name = "groupID", Type = "number", Nilable = false },
				{ Name = "active", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetAllowedIndoors",
			Type = "Function",

			Arguments =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetAllowedOutdoors",
			Type = "Function",

			Arguments =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetAutoUpdateOnParamChanges",
			Type = "Function",
			Documentation = { "If true, searcher automatically updates results whenever search param values are changed" },

			Arguments =
			{
				{ Name = "autoUpdateActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCollected",
			Type = "Function",

			Arguments =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCustomizableOnly",
			Type = "Function",

			Arguments =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetEditorModeContext",
			Type = "Function",

			Arguments =
			{
				{ Name = "editorModeContext", Type = "HouseEditorMode", Nilable = true },
			},
		},
		{
			Name = "SetFilterTagStatus",
			Type = "Function",

			Arguments =
			{
				{ Name = "groupID", Type = "number", Nilable = false },
				{ Name = "tagID", Type = "number", Nilable = false },
				{ Name = "active", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetFilteredCategoryID",
			Type = "Function",

			Arguments =
			{
				{ Name = "categoryID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "SetFilteredSubcategoryID",
			Type = "Function",

			Arguments =
			{
				{ Name = "subcategoryID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "SetFirstAcquisitionBonusOnly",
			Type = "Function",

			Arguments =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetIncludeMarketEntries",
			Type = "Function",

			Arguments =
			{
				{ Name = "includeMarketEntries", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetOwnedOnly",
			Type = "Function",

			Arguments =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetResultsUpdatedCallback",
			Type = "Function",

			Arguments =
			{
				{ Name = "callback", Type = "HousingCatalogSearchResultsUpdatedCallback", Nilable = false },
			},
		},
		{
			Name = "SetSearchText",
			Type = "Function",
			Documentation = { "Supports advanced search tokens ('\"' '-' and '|')" },

			Arguments =
			{
				{ Name = "searchText", Type = "string", Nilable = true },
			},
		},
		{
			Name = "SetSortType",
			Type = "Function",

			Arguments =
			{
				{ Name = "sortType", Type = "HousingCatalogSortType", Nilable = false },
			},
		},
		{
			Name = "SetUncollected",
			Type = "Function",

			Arguments =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ToggleAllowedIndoors",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "ToggleAllowedOutdoors",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "ToggleCollected",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "ToggleCustomizableOnly",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "ToggleFilterTag",
			Type = "Function",

			Arguments =
			{
				{ Name = "groupID", Type = "number", Nilable = false },
				{ Name = "tagID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ToggleFirstAcquisitionBonusOnly",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "ToggleOwnedOnly",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "ToggleUncollected",
			Type = "Function",

			Arguments =
			{
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "HousingCatalogSearchResultsUpdatedCallback",
			Type = "CallbackType",
		},
	},
};

APIDocumentation:AddDocumentationTable(HousingCatalogSearcherAPI);