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
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Garrison", Type = "ZoneAbilityType", EnumValue = 0 },
				{ Name = "OrderHall", Type = "ZoneAbilityType", EnumValue = 1 },
				{ Name = "Argus", Type = "ZoneAbilityType", EnumValue = 2 },
				{ Name = "WarEffort", Type = "ZoneAbilityType", EnumValue = 3 },
				{ Name = "Visions", Type = "ZoneAbilityType", EnumValue = 4 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ZoneAbility);