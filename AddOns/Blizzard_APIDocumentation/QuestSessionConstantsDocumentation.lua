local QuestSessionConstants =
{
	Tables =
	{
		{
			Name = "QuestSessionResult",
			Type = "Enumeration",
			NumValues = 26,
			MinValue = 0,
			MaxValue = 25,
			Fields =
			{
				{ Name = "Ok", Type = "QuestSessionResult", EnumValue = 0 },
				{ Name = "NotInParty", Type = "QuestSessionResult", EnumValue = 1 },
				{ Name = "InvalidOwner", Type = "QuestSessionResult", EnumValue = 2 },
				{ Name = "AlreadyActive", Type = "QuestSessionResult", EnumValue = 3 },
				{ Name = "NotActive", Type = "QuestSessionResult", EnumValue = 4 },
				{ Name = "InRaid", Type = "QuestSessionResult", EnumValue = 5 },
				{ Name = "OwnerRefused", Type = "QuestSessionResult", EnumValue = 6 },
				{ Name = "Timeout", Type = "QuestSessionResult", EnumValue = 7 },
				{ Name = "Disabled", Type = "QuestSessionResult", EnumValue = 8 },
				{ Name = "Started", Type = "QuestSessionResult", EnumValue = 9 },
				{ Name = "Stopped", Type = "QuestSessionResult", EnumValue = 10 },
				{ Name = "Joined", Type = "QuestSessionResult", EnumValue = 11 },
				{ Name = "Left", Type = "QuestSessionResult", EnumValue = 12 },
				{ Name = "OwnerLeft", Type = "QuestSessionResult", EnumValue = 13 },
				{ Name = "ReadyCheckFailed", Type = "QuestSessionResult", EnumValue = 14 },
				{ Name = "PartyDestroyed", Type = "QuestSessionResult", EnumValue = 15 },
				{ Name = "MemberTimeout", Type = "QuestSessionResult", EnumValue = 16 },
				{ Name = "AlreadyMember", Type = "QuestSessionResult", EnumValue = 17 },
				{ Name = "NotOwner", Type = "QuestSessionResult", EnumValue = 18 },
				{ Name = "AlreadyOwner", Type = "QuestSessionResult", EnumValue = 19 },
				{ Name = "AlreadyJoined", Type = "QuestSessionResult", EnumValue = 20 },
				{ Name = "NotMember", Type = "QuestSessionResult", EnumValue = 21 },
				{ Name = "Busy", Type = "QuestSessionResult", EnumValue = 22 },
				{ Name = "JoinRejected", Type = "QuestSessionResult", EnumValue = 23 },
				{ Name = "Logout", Type = "QuestSessionResult", EnumValue = 24 },
				{ Name = "Unknown", Type = "QuestSessionResult", EnumValue = 25 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(QuestSessionConstants);