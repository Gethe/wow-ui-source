local WoWHackAppearance =
{
	Name = "WoWHackAppearance",
	Type = "System",
	Namespace = "C_WoWHackAppearance",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetPlayerAuraSpellVisualKitIDs",
			Type = "Function",

			Returns =
			{
				{ Name = "spellVisualKitIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(WoWHackAppearance);