local BattlePetConstants =
{
	Tables =
	{
		{
			Name = "BattlePetAction",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "BattlePetAction", EnumValue = 0 },
				{ Name = "Ability", Type = "BattlePetAction", EnumValue = 1 },
				{ Name = "SwitchPet", Type = "BattlePetAction", EnumValue = 2 },
				{ Name = "Trap", Type = "BattlePetAction", EnumValue = 3 },
				{ Name = "Skip", Type = "BattlePetAction", EnumValue = 4 },
			},
		},
		{
			Name = "BattlePetBreedQuality",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Poor", Type = "BattlePetBreedQuality", EnumValue = 0 },
				{ Name = "Common", Type = "BattlePetBreedQuality", EnumValue = 1 },
				{ Name = "Uncommon", Type = "BattlePetBreedQuality", EnumValue = 2 },
				{ Name = "Rare", Type = "BattlePetBreedQuality", EnumValue = 3 },
				{ Name = "Epic", Type = "BattlePetBreedQuality", EnumValue = 4 },
				{ Name = "Legendary", Type = "BattlePetBreedQuality", EnumValue = 5 },
			},
		},
		{
			Name = "BattlePetOwner",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Weather", Type = "BattlePetOwner", EnumValue = 0 },
				{ Name = "Ally", Type = "BattlePetOwner", EnumValue = 1 },
				{ Name = "Enemy", Type = "BattlePetOwner", EnumValue = 2 },
			},
		},
		{
			Name = "BattlePetSources",
			Type = "Enumeration",
			NumValues = 12,
			MinValue = 0,
			MaxValue = 11,
			Fields =
			{
				{ Name = "Drop", Type = "BattlePetSources", EnumValue = 0 },
				{ Name = "Quest", Type = "BattlePetSources", EnumValue = 1 },
				{ Name = "Vendor", Type = "BattlePetSources", EnumValue = 2 },
				{ Name = "Profession", Type = "BattlePetSources", EnumValue = 3 },
				{ Name = "WildPet", Type = "BattlePetSources", EnumValue = 4 },
				{ Name = "Achievement", Type = "BattlePetSources", EnumValue = 5 },
				{ Name = "WorldEvent", Type = "BattlePetSources", EnumValue = 6 },
				{ Name = "Promotion", Type = "BattlePetSources", EnumValue = 7 },
				{ Name = "Tcg", Type = "BattlePetSources", EnumValue = 8 },
				{ Name = "PetStore", Type = "BattlePetSources", EnumValue = 9 },
				{ Name = "Discovery", Type = "BattlePetSources", EnumValue = 10 },
				{ Name = "TradingPost", Type = "BattlePetSources", EnumValue = 11 },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(BattlePetConstants);