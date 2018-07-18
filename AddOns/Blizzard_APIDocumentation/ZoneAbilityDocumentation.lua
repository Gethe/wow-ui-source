local ZoneAbility =
{
	Name = "ZoneAbility",
	Type = "System",

	Functions =
	{
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "ZoneAbilityType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Garrison", Type = "ZoneAbilityType", EnumValue = 0 },
				{ Name = "OrderHall", Type = "ZoneAbilityType", EnumValue = 1 },
				{ Name = "Argus", Type = "ZoneAbilityType", EnumValue = 2 },
				{ Name = "WarEffort", Type = "ZoneAbilityType", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ZoneAbility);