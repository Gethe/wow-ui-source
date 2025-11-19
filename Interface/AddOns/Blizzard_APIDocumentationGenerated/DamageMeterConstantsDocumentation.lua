local DamageMeterConstants =
{
	Tables =
	{
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
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Damage", Type = "DamageMeterStorageType", EnumValue = 0 },
				{ Name = "HealingAndAbsorbs", Type = "DamageMeterStorageType", EnumValue = 1 },
				{ Name = "Absorbs", Type = "DamageMeterStorageType", EnumValue = 2 },
				{ Name = "Interrupts", Type = "DamageMeterStorageType", EnumValue = 3 },
				{ Name = "Dispels", Type = "DamageMeterStorageType", EnumValue = 4 },
				{ Name = "DamageTaken", Type = "DamageMeterStorageType", EnumValue = 5 },
			},
		},
		{
			Name = "DamageMeterType",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 0,
			MaxValue = 7,
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
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(DamageMeterConstants);