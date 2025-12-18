local UnitAuraShared =
{
	Tables =
	{
		{
			Name = "UnitAuraSortDirection",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Normal", Type = "UnitAuraSortDirection", EnumValue = 0 },
				{ Name = "Reverse", Type = "UnitAuraSortDirection", EnumValue = 1 },
			},
		},
		{
			Name = "UnitAuraSortRule",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "Unsorted", Type = "UnitAuraSortRule", EnumValue = 0, Documentation = { "Applies no sorting to auras." } },
				{ Name = "Default", Type = "UnitAuraSortRule", EnumValue = 1, Documentation = { "Sorts auras according first by whether or not the aura was applied by the player, else whether or not the player can apply the aura, and finally by aura instance ID." } },
				{ Name = "BigDefensive", Type = "UnitAuraSortRule", EnumValue = 2, Documentation = { "Sorts auras according first by whether or not the aura was applied by another player, else by expiration time (longest to shortest), and finally by aura instance ID." } },
				{ Name = "Expiration", Type = "UnitAuraSortRule", EnumValue = 3, Documentation = { "Sorts auras according first by whether or not the aura was applied by the player, else whether or not the player can apply the aura, then by expiration time (soonest to longest, followed by permanent auras), and finally by aura instance ID." } },
				{ Name = "ExpirationOnly", Type = "UnitAuraSortRule", EnumValue = 4, Documentation = { "Sorts auras according only to expiration time." } },
				{ Name = "Name", Type = "UnitAuraSortRule", EnumValue = 5, Documentation = { "Sorts auras according first by whether or not the aura was applied by the player, else whether or not the player can apply the aura, then by spell name, and finally by aura instance ID." } },
				{ Name = "NameOnly", Type = "UnitAuraSortRule", EnumValue = 6, Documentation = { "Sorts auras according only their spell name." } },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UnitAuraShared);