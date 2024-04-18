local ClubShared =
{
	Tables =
	{
		{
			Name = "ClubRoleIdentifier",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 1,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Owner", Type = "ClubRoleIdentifier", EnumValue = 1 },
				{ Name = "Leader", Type = "ClubRoleIdentifier", EnumValue = 2 },
				{ Name = "Moderator", Type = "ClubRoleIdentifier", EnumValue = 3 },
				{ Name = "Member", Type = "ClubRoleIdentifier", EnumValue = 4 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ClubShared);