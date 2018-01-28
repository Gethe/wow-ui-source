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
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Garrison", Type = "ZoneAbilityType", EnumValue = 0 },
				{ Name = "OrderHall", Type = "ZoneAbilityType", EnumValue = 1 },
				{ Name = "Argus", Type = "ZoneAbilityType", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ZoneAbility);