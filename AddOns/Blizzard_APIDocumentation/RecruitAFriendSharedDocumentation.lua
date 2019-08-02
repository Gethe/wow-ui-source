local RecruitAFriendShared =
{
	Tables =
	{
		{
			Name = "RafLinkType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "RafLinkType", EnumValue = 0 },
				{ Name = "Recruit", Type = "RafLinkType", EnumValue = 1 },
				{ Name = "Friend", Type = "RafLinkType", EnumValue = 2 },
				{ Name = "Both", Type = "RafLinkType", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(RecruitAFriendShared);