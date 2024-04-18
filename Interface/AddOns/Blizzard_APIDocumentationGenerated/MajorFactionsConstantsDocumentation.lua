local MajorFactionsConstants =
{
	Tables =
	{
		{
			Name = "MajorFactionFeatureAbility",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Generic", Type = "MajorFactionFeatureAbility", EnumValue = 0 },
				{ Name = "Fishing", Type = "MajorFactionFeatureAbility", EnumValue = 1 },
				{ Name = "Hunts", Type = "MajorFactionFeatureAbility", EnumValue = 2 },
			},
		},
		{
			Name = "MajorFactionType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "MajorFactionType", EnumValue = 0 },
				{ Name = "DragonscaleExpedition", Type = "MajorFactionType", EnumValue = 1 },
				{ Name = "MaruukCentaur", Type = "MajorFactionType", EnumValue = 2 },
				{ Name = "IskaaraTuskarr", Type = "MajorFactionType", EnumValue = 3 },
				{ Name = "ValdrakkenAccord", Type = "MajorFactionType", EnumValue = 4 },
			},
		},
		{
			Name = "MajorFactionsConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "WORLD_STATE_RENOWN_CAP_10_0", Type = "number", Value = 19735 },
				{ Name = "WORLD_STATE_RAPID_RENOWN_CAP_10_0", Type = "number", Value = 20851 },
				{ Name = "PLUNDERSTORM_MAJOR_FACTION_ID", Type = "number", Value = 2593 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(MajorFactionsConstants);