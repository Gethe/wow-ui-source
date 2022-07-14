local QuestSessionConstants =
{
	Tables =
	{
		{
			Name = "QuestSessionCommand",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "QuestSessionCommand", EnumValue = 0 },
				{ Name = "Start", Type = "QuestSessionCommand", EnumValue = 1 },
				{ Name = "Stop", Type = "QuestSessionCommand", EnumValue = 2 },
				{ Name = "SessionActiveNoCommand", Type = "QuestSessionCommand", EnumValue = 3 },
			},
		},
		{
			Name = "QuestSessionResult",
			Type = "Enumeration",
			NumValues = 35,
			MinValue = 0,
			MaxValue = 34,
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
				{ Name = "Empty", Type = "QuestSessionResult", EnumValue = 25 },
				{ Name = "QuestNotCompleted", Type = "QuestSessionResult", EnumValue = 26 },
				{ Name = "Resync", Type = "QuestSessionResult", EnumValue = 27 },
				{ Name = "Restricted", Type = "QuestSessionResult", EnumValue = 28 },
				{ Name = "InPetBattle", Type = "QuestSessionResult", EnumValue = 29 },
				{ Name = "InvalidPublicParty", Type = "QuestSessionResult", EnumValue = 30 },
				{ Name = "Unknown", Type = "QuestSessionResult", EnumValue = 31 },
				{ Name = "InCombat", Type = "QuestSessionResult", EnumValue = 32 },
				{ Name = "MemberInCombat", Type = "QuestSessionResult", EnumValue = 33 },
				{ Name = "RestrictedCrossFaction", Type = "QuestSessionResult", EnumValue = 34 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(QuestSessionConstants);