local GARRISON_FOLLOWER_TYPEConstants =
{
	Tables =
	{
		{
			Name = "GarrisonFollowerType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 1,
			MaxValue = 123,
			Fields =
			{
				{ Name = "FollowerType_6_0_GarrisonFollower", Type = "GarrisonFollowerType", EnumValue = 1 },
				{ Name = "FollowerType_6_0_Boat", Type = "GarrisonFollowerType", EnumValue = 2 },
				{ Name = "FollowerType_7_0_GarrisonFollower", Type = "GarrisonFollowerType", EnumValue = 4 },
				{ Name = "FollowerType_8_0_GarrisonFollower", Type = "GarrisonFollowerType", EnumValue = 22 },
				{ Name = "FollowerType_9_0_GarrisonFollower", Type = "GarrisonFollowerType", EnumValue = 123 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(GARRISON_FOLLOWER_TYPEConstants);