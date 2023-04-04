local AddOns =
{
	Name = "AddOns",
	Type = "System",
	Namespace = "C_AddOns",

	Functions =
	{
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
	},
};

APIDocumentation:AddDocumentationTable(AddOns);