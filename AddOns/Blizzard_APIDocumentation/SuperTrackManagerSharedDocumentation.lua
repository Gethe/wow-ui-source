local SuperTrackManagerShared =
{
	Tables =
	{
		{
			Name = "SuperTrackingType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Quest", Type = "SuperTrackingType", EnumValue = 0 },
				{ Name = "UserWaypoint", Type = "SuperTrackingType", EnumValue = 1 },
				{ Name = "Corpse", Type = "SuperTrackingType", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SuperTrackManagerShared);