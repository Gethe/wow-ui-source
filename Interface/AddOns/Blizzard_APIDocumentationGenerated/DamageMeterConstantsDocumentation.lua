local DamageMeterConstants =
{
	Tables =
	{
		{
			Name = "DamageMeterSessionType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Overall", Type = "DamageMeterSessionType", EnumValue = 0 },
				{ Name = "Current", Type = "DamageMeterSessionType", EnumValue = 1 },
			},
		},
		{
			Name = "DamageMeterType",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "DamageDone", Type = "DamageMeterType", EnumValue = 0 },
				{ Name = "Dps", Type = "DamageMeterType", EnumValue = 1 },
				{ Name = "HealingDone", Type = "DamageMeterType", EnumValue = 2 },
				{ Name = "Hps", Type = "DamageMeterType", EnumValue = 3 },
				{ Name = "Interrupts", Type = "DamageMeterType", EnumValue = 4 },
				{ Name = "Dispels", Type = "DamageMeterType", EnumValue = 5 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(DamageMeterConstants);