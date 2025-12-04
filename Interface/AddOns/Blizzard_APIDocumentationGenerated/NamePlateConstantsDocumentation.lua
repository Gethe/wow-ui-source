local NamePlateConstants =
{
	Tables =
	{
		{
			Name = "NamePlateCastBarDisplay",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "None", Type = "NamePlateCastBarDisplay", EnumValue = 0 },
				{ Name = "SpellName", Type = "NamePlateCastBarDisplay", EnumValue = 1 },
				{ Name = "SpellIcon", Type = "NamePlateCastBarDisplay", EnumValue = 2 },
				{ Name = "SpellTarget", Type = "NamePlateCastBarDisplay", EnumValue = 3 },
				{ Name = "HighlightImportantCasts", Type = "NamePlateCastBarDisplay", EnumValue = 4 },
				{ Name = "HighlightWhenCastTarget", Type = "NamePlateCastBarDisplay", EnumValue = 5 },
			},
		},
		{
			Name = "NamePlateEnemyNpcAuraDisplay",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "NamePlateEnemyNpcAuraDisplay", EnumValue = 0 },
				{ Name = "Buffs", Type = "NamePlateEnemyNpcAuraDisplay", EnumValue = 1 },
				{ Name = "Debuffs", Type = "NamePlateEnemyNpcAuraDisplay", EnumValue = 2 },
				{ Name = "CrowdControl", Type = "NamePlateEnemyNpcAuraDisplay", EnumValue = 3 },
			},
		},
		{
			Name = "NamePlateEnemyPlayerAuraDisplay",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "NamePlateEnemyPlayerAuraDisplay", EnumValue = 0 },
				{ Name = "Buffs", Type = "NamePlateEnemyPlayerAuraDisplay", EnumValue = 1 },
				{ Name = "Debuffs", Type = "NamePlateEnemyPlayerAuraDisplay", EnumValue = 2 },
				{ Name = "LossOfControl", Type = "NamePlateEnemyPlayerAuraDisplay", EnumValue = 3 },
			},
		},
		{
			Name = "NamePlateFriendlyPlayerAuraDisplay",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "NamePlateFriendlyPlayerAuraDisplay", EnumValue = 0 },
				{ Name = "Buffs", Type = "NamePlateFriendlyPlayerAuraDisplay", EnumValue = 1 },
				{ Name = "Debuffs", Type = "NamePlateFriendlyPlayerAuraDisplay", EnumValue = 2 },
				{ Name = "LossOfControl", Type = "NamePlateFriendlyPlayerAuraDisplay", EnumValue = 3 },
			},
		},
		{
			Name = "NamePlateInfoDisplay",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "NamePlateInfoDisplay", EnumValue = 0 },
				{ Name = "CurrentHealthPercent", Type = "NamePlateInfoDisplay", EnumValue = 1 },
				{ Name = "CurrentHealthValue", Type = "NamePlateInfoDisplay", EnumValue = 2 },
				{ Name = "RarityIcon", Type = "NamePlateInfoDisplay", EnumValue = 3 },
			},
		},
		{
			Name = "NamePlateSimplifiedType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "NamePlateSimplifiedType", EnumValue = 0 },
				{ Name = "Minion", Type = "NamePlateSimplifiedType", EnumValue = 1 },
				{ Name = "MinusMob", Type = "NamePlateSimplifiedType", EnumValue = 2 },
				{ Name = "FriendlyPlayer", Type = "NamePlateSimplifiedType", EnumValue = 3 },
				{ Name = "FriendlyNpc", Type = "NamePlateSimplifiedType", EnumValue = 4 },
			},
		},
		{
			Name = "NamePlateSize",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 1,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Small", Type = "NamePlateSize", EnumValue = 1 },
				{ Name = "Medium", Type = "NamePlateSize", EnumValue = 2 },
				{ Name = "Large", Type = "NamePlateSize", EnumValue = 3 },
				{ Name = "ExtraLarge", Type = "NamePlateSize", EnumValue = 4 },
				{ Name = "Huge", Type = "NamePlateSize", EnumValue = 5 },
			},
		},
		{
			Name = "NamePlateStackType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "NamePlateStackType", EnumValue = 0 },
				{ Name = "Enemy", Type = "NamePlateStackType", EnumValue = 1 },
				{ Name = "Friendly", Type = "NamePlateStackType", EnumValue = 2 },
			},
		},
		{
			Name = "NamePlateStyle",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Modern", Type = "NamePlateStyle", EnumValue = 0 },
				{ Name = "Thin", Type = "NamePlateStyle", EnumValue = 1 },
				{ Name = "Block", Type = "NamePlateStyle", EnumValue = 2 },
				{ Name = "HealthFocus", Type = "NamePlateStyle", EnumValue = 3 },
				{ Name = "CastFocus", Type = "NamePlateStyle", EnumValue = 4 },
				{ Name = "Legacy", Type = "NamePlateStyle", EnumValue = 5 },
			},
		},
		{
			Name = "NamePlateThreatDisplay",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "NamePlateThreatDisplay", EnumValue = 0 },
				{ Name = "Progressive", Type = "NamePlateThreatDisplay", EnumValue = 1 },
				{ Name = "Flash", Type = "NamePlateThreatDisplay", EnumValue = 2 },
				{ Name = "HealthBarColor", Type = "NamePlateThreatDisplay", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(NamePlateConstants);