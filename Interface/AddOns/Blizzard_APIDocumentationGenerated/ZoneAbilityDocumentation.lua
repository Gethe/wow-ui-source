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
		{
			Name = "GetZoneAbilityIcon",
			Type = "Function",

			Arguments =
			{
				{ Name = "zoneAbilitySpellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "zoneAbilityIconID", Type = "number", Nilable = true },
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