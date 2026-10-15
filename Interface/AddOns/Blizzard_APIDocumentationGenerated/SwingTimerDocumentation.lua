local SwingTimer =
{

	Tables =
	{
		{
			Name = "PlayerSwingType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "MainHand", Type = "PlayerSwingType", EnumValue = 0 },
				{ Name = "OffHand", Type = "PlayerSwingType", EnumValue = 1 },
				{ Name = "Ranged", Type = "PlayerSwingType", EnumValue = 2 },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(SwingTimer);