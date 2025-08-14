local RolodexConstants =
{
	Tables =
	{
		{
			Name = "RolodexContextIDType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "RolodexContextIDType", EnumValue = 0 },
				{ Name = "ItemID", Type = "RolodexContextIDType", EnumValue = 1 },
				{ Name = "AreaID", Type = "RolodexContextIDType", EnumValue = 2 },
				{ Name = "MapID", Type = "RolodexContextIDType", EnumValue = 3 },
			},
		},
		{
			Name = "RolodexContextLevelType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "RolodexContextLevelType", EnumValue = 0 },
				{ Name = "Difficulty", Type = "RolodexContextLevelType", EnumValue = 1 },
				{ Name = "KeystoneLevel", Type = "RolodexContextLevelType", EnumValue = 2 },
				{ Name = "DelveTier", Type = "RolodexContextLevelType", EnumValue = 3 },
			},
		},
		{
			Name = "RolodexType",
			Type = "Enumeration",
			NumValues = 21,
			MinValue = 0,
			MaxValue = 20,
			Fields =
			{
				{ Name = "None", Type = "RolodexType", EnumValue = 0 },
				{ Name = "PartyMember", Type = "RolodexType", EnumValue = 1 },
				{ Name = "RaidMember", Type = "RolodexType", EnumValue = 2 },
				{ Name = "Trade", Type = "RolodexType", EnumValue = 3 },
				{ Name = "Whisper", Type = "RolodexType", EnumValue = 4 },
				{ Name = "PublicOrderFilledByOther", Type = "RolodexType", EnumValue = 5 },
				{ Name = "PublicOrderFilledByYou", Type = "RolodexType", EnumValue = 6 },
				{ Name = "PersonalOrderFilledByOther", Type = "RolodexType", EnumValue = 7 },
				{ Name = "PersonalOrderFilledByYou", Type = "RolodexType", EnumValue = 8 },
				{ Name = "GuildOrderFilledByOther", Type = "RolodexType", EnumValue = 9 },
				{ Name = "GuildOrderFilledByYou", Type = "RolodexType", EnumValue = 10 },
				{ Name = "CreatureKill", Type = "RolodexType", EnumValue = 11 },
				{ Name = "CompleteDungeon", Type = "RolodexType", EnumValue = 12 },
				{ Name = "KillRaidBoss", Type = "RolodexType", EnumValue = 13 },
				{ Name = "KillLfrBoss", Type = "RolodexType", EnumValue = 14 },
				{ Name = "CompleteDelve", Type = "RolodexType", EnumValue = 15 },
				{ Name = "CompleteArena", Type = "RolodexType", EnumValue = 16 },
				{ Name = "CompleteBg", Type = "RolodexType", EnumValue = 17 },
				{ Name = "Duel", Type = "RolodexType", EnumValue = 18 },
				{ Name = "PetBattle", Type = "RolodexType", EnumValue = 19 },
				{ Name = "PvPKill", Type = "RolodexType", EnumValue = 20 },
			},
		},
		{
			Name = "RolodexTypeFlags",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "None", Type = "RolodexTypeFlags", EnumValue = 0 },
				{ Name = "HiddenFromHistory", Type = "RolodexTypeFlags", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(RolodexConstants);