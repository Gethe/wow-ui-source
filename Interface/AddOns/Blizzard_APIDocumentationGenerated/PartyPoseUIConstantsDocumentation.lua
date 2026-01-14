local PartyPoseUIConstants =
{
	Tables =
	{
		{
			Name = "PartyPoseFlags",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "HideLeaveInstanceButton", Type = "PartyPoseFlags", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PartyPoseUIConstants);