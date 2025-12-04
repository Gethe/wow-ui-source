local DamageMeterConstants =
{
	Tables =
	{
		{
			Name = "DamageMeterOverrideType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Ignore", Type = "DamageMeterOverrideType", EnumValue = 0 },
				{ Name = "RedirectSource", Type = "DamageMeterOverrideType", EnumValue = 1 },
				{ Name = "AllowFriendlyFire", Type = "DamageMeterOverrideType", EnumValue = 2 },
			},
		},
		{
			Name = "DamageMeterRedirectGuidType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "DamageMeterRedirectGuidType", EnumValue = 0 },
				{ Name = "Owner", Type = "DamageMeterRedirectGuidType", EnumValue = 1 },
				{ Name = "AuraCaster", Type = "DamageMeterRedirectGuidType", EnumValue = 2 },
			},
		},
		{
			Name = "DamageMeterSessionType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Overall", Type = "DamageMeterSessionType", EnumValue = 0 },
				{ Name = "Current", Type = "DamageMeterSessionType", EnumValue = 1 },
				{ Name = "Expired", Type = "DamageMeterSessionType", EnumValue = 2 },
			},
		},
		{
			Name = "DamageMeterStorageType",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "Damage", Type = "DamageMeterStorageType", EnumValue = 0 },
				{ Name = "HealingAndAbsorbs", Type = "DamageMeterStorageType", EnumValue = 1 },
				{ Name = "Absorbs", Type = "DamageMeterStorageType", EnumValue = 2 },
				{ Name = "Interrupts", Type = "DamageMeterStorageType", EnumValue = 3 },
				{ Name = "Dispels", Type = "DamageMeterStorageType", EnumValue = 4 },
				{ Name = "DamageTaken", Type = "DamageMeterStorageType", EnumValue = 5 },
				{ Name = "AvoidableDamageTaken", Type = "DamageMeterStorageType", EnumValue = 6 },
			},
		},
		{
			Name = "DamageMeterType",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 0,
			MaxValue = 8,
			Fields =
			{
				{ Name = "DamageDone", Type = "DamageMeterType", EnumValue = 0 },
				{ Name = "Dps", Type = "DamageMeterType", EnumValue = 1 },
				{ Name = "HealingDone", Type = "DamageMeterType", EnumValue = 2 },
				{ Name = "Hps", Type = "DamageMeterType", EnumValue = 3 },
				{ Name = "Absorbs", Type = "DamageMeterType", EnumValue = 4 },
				{ Name = "Interrupts", Type = "DamageMeterType", EnumValue = 5 },
				{ Name = "Dispels", Type = "DamageMeterType", EnumValue = 6 },
				{ Name = "DamageTaken", Type = "DamageMeterType", EnumValue = 7 },
				{ Name = "AvoidableDamageTaken", Type = "DamageMeterType", EnumValue = 8 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(DamageMeterConstants);