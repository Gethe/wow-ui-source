local SuperTrackManagerShared =
{
	Tables =
	{
		{
			Name = "SuperTrackingMapPinType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "AreaPOI", Type = "SuperTrackingMapPinType", EnumValue = 0 },
				{ Name = "QuestOffer", Type = "SuperTrackingMapPinType", EnumValue = 1 },
				{ Name = "TaxiNode", Type = "SuperTrackingMapPinType", EnumValue = 2 },
				{ Name = "DigSite", Type = "SuperTrackingMapPinType", EnumValue = 3 },
				{ Name = "HousingPlot", Type = "SuperTrackingMapPinType", EnumValue = 4 },
			},
		},
		{
			Name = "SuperTrackingType",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 0,
			MaxValue = 7,
			Fields =
			{
				{ Name = "Quest", Type = "SuperTrackingType", EnumValue = 0 },
				{ Name = "UserWaypoint", Type = "SuperTrackingType", EnumValue = 1 },
				{ Name = "Corpse", Type = "SuperTrackingType", EnumValue = 2 },
				{ Name = "Scenario", Type = "SuperTrackingType", EnumValue = 3 },
				{ Name = "Content", Type = "SuperTrackingType", EnumValue = 4 },
				{ Name = "PartyMember", Type = "SuperTrackingType", EnumValue = 5 },
				{ Name = "MapPin", Type = "SuperTrackingType", EnumValue = 6 },
				{ Name = "Vignette", Type = "SuperTrackingType", EnumValue = 7 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SuperTrackManagerShared);