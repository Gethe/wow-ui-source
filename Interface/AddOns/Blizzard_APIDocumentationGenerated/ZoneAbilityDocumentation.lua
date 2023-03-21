local ZoneAbility =
{
	Name = "ZoneAbility",
	Type = "System",
	Namespace = "C_ZoneAbility",

	Functions =
	{
		{
			Name = "GetActiveAbilities",
			Type = "Function",

			Returns =
			{
				{ Name = "zoneAbilities", Type = "table", InnerType = "ZoneAbilityInfo", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "ZoneAbilityInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "zoneAbilityID", Type = "number", Nilable = false },
				{ Name = "uiPriority", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "tutorialText", Type = "cstring", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ZoneAbility);