local HousingCatalogSearcherAPI =
{
	Name = "HousingCatalogSearcherAPI",
	Type = "ScriptObject",

	Functions =
	{
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

			Arguments =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetAllowedOutdoors",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "SetCustomizableOnly",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetEditorModeContext",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "editorModeContext", Type = "HouseEditorMode", Nilable = true },
			},
		},
		{
			Name = "SetFilterTagStatus",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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

			Arguments =
			{
				{ Name = "categoryID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "SetFilteredSubcategoryID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "subcategoryID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "SetOwnedOnly",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			Documentation = { "Supports advanced search tokens ('\"' '-' and '|')" },

			Arguments =
			{
				{ Name = "searchText", Type = "string", Nilable = true },
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
			Name = "ToggleOwnedOnly",
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