local SocialConstants =
{
	Tables =
	{
		{
			Name = "SocialWhoOrigin",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Unknown", Type = "SocialWhoOrigin", EnumValue = 0 },
				{ Name = "Social", Type = "SocialWhoOrigin", EnumValue = 1 },
				{ Name = "Chat", Type = "SocialWhoOrigin", EnumValue = 2 },
				{ Name = "Item", Type = "SocialWhoOrigin", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SocialConstants);