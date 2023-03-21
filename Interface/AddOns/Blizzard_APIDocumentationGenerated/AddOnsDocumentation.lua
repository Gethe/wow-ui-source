local AddOns =
{
	Name = "AddOns",
	Type = "System",
	Namespace = "C_AddOns",

	Functions =
	{
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