local DistrictConstants =
{
	Tables =
	{
		{
			Name = "EvictionType",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "Outsider", Type = "EvictionType", EnumValue = 0 },
				{ Name = "OutsiderParty", Type = "EvictionType", EnumValue = 1 },
				{ Name = "JoinParty", Type = "EvictionType", EnumValue = 2 },
				{ Name = "LeaveParty", Type = "EvictionType", EnumValue = 3 },
				{ Name = "ServerExpiryNormal", Type = "EvictionType", EnumValue = 4 },
				{ Name = "ServerExpiryAggressive", Type = "EvictionType", EnumValue = 5 },
				{ Name = "ServerExpiryParty", Type = "EvictionType", EnumValue = 6 },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(DistrictConstants);