local BattleNetShared =
{
	Tables =
	{
		{
			Name = "BattleNetFriendLevel",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 1,
			MaxValue = 3,
			Fields =
			{
				{ Name = "BattleTag", Type = "BattleNetFriendLevel", EnumValue = 1 },
				{ Name = "RealID", Type = "BattleNetFriendLevel", EnumValue = 2 },
				{ Name = "Title", Type = "BattleNetFriendLevel", EnumValue = 3 },
			},
		},
		{
			Name = "BattleNetFriendTag",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 0,
			MaxValue = 9,
			Fields =
			{
				{ Name = "Professions", Type = "BattleNetFriendTag", EnumValue = 0 },
				{ Name = "PvP", Type = "BattleNetFriendTag", EnumValue = 1 },
				{ Name = "Raiding", Type = "BattleNetFriendTag", EnumValue = 2 },
				{ Name = "Dungeons", Type = "BattleNetFriendTag", EnumValue = 3 },
				{ Name = "Delves", Type = "BattleNetFriendTag", EnumValue = 4 },
				{ Name = "Questing", Type = "BattleNetFriendTag", EnumValue = 5 },
				{ Name = "Roleplaying", Type = "BattleNetFriendTag", EnumValue = 6 },
				{ Name = "DamagerRole", Type = "BattleNetFriendTag", EnumValue = 7 },
				{ Name = "HealerRole", Type = "BattleNetFriendTag", EnumValue = 8 },
				{ Name = "TankRole", Type = "BattleNetFriendTag", EnumValue = 9 },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(BattleNetShared);