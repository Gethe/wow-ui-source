local RenownConstants =
{
	Tables =
	{
		{
			Name = "RenownRewardDisplayType",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 0,
			MaxValue = 9,
			Fields =
			{
				{ Name = "None", Type = "RenownRewardDisplayType", EnumValue = 0 },
				{ Name = "Item", Type = "RenownRewardDisplayType", EnumValue = 1 },
				{ Name = "Spell", Type = "RenownRewardDisplayType", EnumValue = 2 },
				{ Name = "Mount", Type = "RenownRewardDisplayType", EnumValue = 3 },
				{ Name = "Transmog", Type = "RenownRewardDisplayType", EnumValue = 4 },
				{ Name = "TransmogSet", Type = "RenownRewardDisplayType", EnumValue = 5 },
				{ Name = "TransmogIllusion", Type = "RenownRewardDisplayType", EnumValue = 6 },
				{ Name = "Title", Type = "RenownRewardDisplayType", EnumValue = 7 },
				{ Name = "GarrFollower", Type = "RenownRewardDisplayType", EnumValue = 8 },
				{ Name = "Currency", Type = "RenownRewardDisplayType", EnumValue = 9 },
			},
		},
		{
			Name = "RenownRewardsFlags",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 1,
			MaxValue = 8,
			Fields =
			{
				{ Name = "Milestone", Type = "RenownRewardsFlags", EnumValue = 1 },
				{ Name = "Capstone", Type = "RenownRewardsFlags", EnumValue = 2 },
				{ Name = "Hidden", Type = "RenownRewardsFlags", EnumValue = 4 },
				{ Name = "AccountUnlock", Type = "RenownRewardsFlags", EnumValue = 8 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(RenownConstants);