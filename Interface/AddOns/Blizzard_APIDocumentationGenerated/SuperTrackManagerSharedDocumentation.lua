local SuperTrackManagerShared =
{
	Tables =
	{
		{
			Name = "SuperTrackingType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Quest", Type = "SuperTrackingType", EnumValue = 0 },
				{ Name = "UserWaypoint", Type = "SuperTrackingType", EnumValue = 1 },
				{ Name = "Corpse", Type = "SuperTrackingType", EnumValue = 2 },
				{ Name = "Scenario", Type = "SuperTrackingType", EnumValue = 3 },
				{ Name = "Content", Type = "SuperTrackingType", EnumValue = 4 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SuperTrackManagerShared);