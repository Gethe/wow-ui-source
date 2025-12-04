local HousingCatalogSearcherAPI =
{
	Name = "HousingCatalogSearcherAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "GetAllSearchItems",
			Type = "Function",
			Documentation = { "Returns all catalog entries being searched (note these are NOT search results, this is the source collection of what's being searched)" },

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
			Documentation = { "Returns the most recent search result entries" },

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
			SecretArguments = "AllowedWhenUntainted",

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
			Documentation = { "Returns the total number of entries being searched through" },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "numSearchItems", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSearchCount",
			Type = "Function",
			Documentation = { "Returns the total number of owned instances across all most recent search result entries" },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "searchCount", Type = "number", Nilable = false },
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
			Name = "IsSearchInProgress",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isSearchInProgress", Type = "bool", Nilable = false },
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
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Set the toggle state of all filter tags within a specific group; If active, only entries that match Any of the tags in the group will be included in search results" },

			Arguments =
			{
				{ Name = "groupID", Type = "number", Nilable = false },
				{ Name = "active", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetAllowedIndoors",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Search parameter; If true, entries that can be placed in house interiors will be included in the search; Note many decor objects can be placed both indoors and outdoors, so having only this toggled on may still include decor that can also be placed outdoors" },

			Arguments =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetAllowedOutdoors",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Search parameter; If true, entries that can be placed outside in plots will be included in the search; Note many decor objects can be placed both indoors and outdoors, so having only this toggled on may still include decor that can also be placed indoors" },

			Arguments =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetAutoUpdateOnParamChanges",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "If true, searcher automatically updates results whenever search param values are changed" },

			Arguments =
			{
				{ Name = "autoUpdateActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCollected",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Search parameter; If true, includes all owned entries, including those that are in storage OR placed in an owned house or plot; See IsOwnedOnlyActive for a more exclusive toggle" },

			Arguments =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCustomizableOnly",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Search parameter; If true, catalog entries that cannot be customized (ie dyed) will be excluded from the search" },

			Arguments =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetEditorModeContext",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Search parameter; If set, limits search results to only entries that are used/valid in the specified editor mode" },

			Arguments =
			{
				{ Name = "editorModeContext", Type = "HouseEditorMode", Nilable = true },
			},
		},
		{
			Name = "SetFilterTagStatus",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Set the toggle state of a single filter tag within a specific group" },

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
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Search parameter; If set, limits search results to only those within the specified category" },

			Arguments =
			{
				{ Name = "categoryID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "SetFilteredSubcategoryID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Search parameter; If set, limits search results to only those within the specified subcategory" },

			Arguments =
			{
				{ Name = "subcategoryID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "SetFirstAcquisitionBonusOnly",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Search parameter; If true, excludes any entries that do not reward house xp when acquired for the first time" },

			Arguments =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetOwnedOnly",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Search parameter; If true, only entries that you own, and have instances of available in storage, will be included; This does not include entries that you own but have all been placed in a house; See IsCollectedActive for param that includes placed entries" },

			Arguments =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetResultsUpdatedCallback",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "callback", Type = "HousingCatalogSearchResultsUpdatedCallback", Nilable = false },
			},
		},
		{
			Name = "SetSearchText",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Search parameter; If set, multiple text fields are checked for instances of the text, including name, category, subcategory, and data tags" },

			Arguments =
			{
				{ Name = "searchText", Type = "string", Nilable = true, Documentation = { "Supports advanced search tokens ('\"' '-' and '|'), case and accent insensitive; Set nil to clear out the search text" } },
			},
		},
		{
			Name = "SetSortType",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "sortType", Type = "HousingCatalogSortType", Nilable = false },
			},
		},
		{
			Name = "SetUncollected",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Search parameter; If true, includes entries that are not owned, meaning not available in storage nor placed in any owned houses or plots" },

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
			SecretArguments = "AllowedWhenUntainted",

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