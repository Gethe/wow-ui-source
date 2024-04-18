local SuperTrackManagerShared =
{
	Tables =
	{
		{
			Name = "SuperTrackingType",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Quest", Type = "SuperTrackingType", EnumValue = 0 },
				{ Name = "UserWaypoint", Type = "SuperTrackingType", EnumValue = 1 },
				{ Name = "Corpse", Type = "SuperTrackingType", EnumValue = 2 },
				{ Name = "Scenario", Type = "SuperTrackingType", EnumValue = 3 },
				{ Name = "Content", Type = "SuperTrackingType", EnumValue = 4 },
				{ Name = "PartyMember", Type = "SuperTrackingType", EnumValue = 5 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SuperTrackManagerShared);