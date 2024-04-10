local AddOns =
{
	Name = "AddOns",
	Type = "System",
	Namespace = "C_AddOns",

	Functions =
	{
		{
			Name = "DisableAddOn",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
				{ Name = "character", Type = "cstring", Nilable = false, Default = "0" },
			},
		},
		{
			Name = "DisableAllAddOns",
			Type = "Function",

			Arguments =
			{
				{ Name = "character", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "DoesAddOnExist",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
			},

			Returns =
			{
				{ Name = "exists", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "EnableAddOn",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
				{ Name = "character", Type = "cstring", Nilable = false, Default = "0" },
			},
		},
		{
			Name = "EnableAllAddOns",
			Type = "Function",

			Arguments =
			{
				{ Name = "character", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "GetAddOnDependencies",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
			},

			Returns =
			{
				{ Name = "unpackedPrimitiveType", Type = "string", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "GetAddOnEnableState",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
				{ Name = "character", Type = "cstring", Nilable = false, Default = "0" },
			},

			Returns =
			{
				{ Name = "state", Type = "AddOnEnableState", Nilable = false },
			},
		},
		{
			Name = "GetAddOnInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "title", Type = "cstring", Nilable = false },
				{ Name = "notes", Type = "cstring", Nilable = false },
				{ Name = "loadable", Type = "bool", Nilable = false },
				{ Name = "reason", Type = "cstring", Nilable = false },
				{ Name = "security", Type = "cstring", Nilable = false },
				{ Name = "updateAvailable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAddOnMetadata",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
				{ Name = "variable", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "value", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetAddOnOptionalDependencies",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
			},

			Returns =
			{
				{ Name = "unpackedPrimitiveType", Type = "string", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "GetNumAddOns",
			Type = "Function",

			Returns =
			{
				{ Name = "numAddOns", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetScriptsDisallowedForBeta",
			Type = "Function",

			Returns =
			{
				{ Name = "disallowed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAddOnLoadOnDemand",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
			},

			Returns =
			{
				{ Name = "loadOnDemand", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAddOnLoadable",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
				{ Name = "character", Type = "cstring", Nilable = false, Default = "0" },
				{ Name = "demandLoaded", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "loadable", Type = "bool", Nilable = false },
				{ Name = "reason", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "IsAddOnLoaded",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
			},

			Returns =
			{
				{ Name = "loadedOrLoading", Type = "bool", Nilable = false },
				{ Name = "loaded", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAddonVersionCheckEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LoadAddOn",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
			},

			Returns =
			{
				{ Name = "loaded", Type = "bool", Nilable = true },
				{ Name = "value", Type = "string", Nilable = true },
			},
		},
		{
			Name = "ResetAddOns",
			Type = "Function",
		},
		{
			Name = "ResetDisabledAddOns",
			Type = "Function",
		},
		{
			Name = "SaveAddOns",
			Type = "Function",
		},
		{
			Name = "SetAddonVersionCheck",
			Type = "Function",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AddonLoaded",
			Type = "Event",
			LiteralName = "ADDON_LOADED",
			Payload =
			{
				{ Name = "addOnName", Type = "cstring", Nilable = false },
				{ Name = "containsBindings", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "AddonsUnloading",
			Type = "Event",
			LiteralName = "ADDONS_UNLOADING",
			Payload =
			{
				{ Name = "closingClient", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SavedVariablesTooLarge",
			Type = "Event",
			LiteralName = "SAVED_VARIABLES_TOO_LARGE",
			Payload =
			{
				{ Name = "addOnName", Type = "cstring", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "AddOnEnableState",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "AddOnEnableState", EnumValue = 0 },
				{ Name = "Some", Type = "AddOnEnableState", EnumValue = 1 },
				{ Name = "All", Type = "AddOnEnableState", EnumValue = 2 },
			},
		},
		{
			Name = "AddOnInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "title", Type = "cstring", Nilable = false },
				{ Name = "notes", Type = "cstring", Nilable = false },
				{ Name = "loadable", Type = "bool", Nilable = false },
				{ Name = "reason", Type = "cstring", Nilable = false },
				{ Name = "security", Type = "cstring", Nilable = false },
				{ Name = "updateAvailable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "AddOnLoadableInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "loadable", Type = "bool", Nilable = false },
				{ Name = "reason", Type = "cstring", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AddOns);