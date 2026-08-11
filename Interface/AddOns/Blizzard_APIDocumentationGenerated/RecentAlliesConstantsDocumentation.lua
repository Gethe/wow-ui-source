local RecentAlliesConstants =
{
	Tables =
	{
		{
			Name = "RecentAlliesFriendTag",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Professions", Type = "RecentAlliesFriendTag", EnumValue = 0 },
				{ Name = "PvP", Type = "RecentAlliesFriendTag", EnumValue = 1 },
				{ Name = "Raiding", Type = "RecentAlliesFriendTag", EnumValue = 2 },
				{ Name = "Dungeons", Type = "RecentAlliesFriendTag", EnumValue = 3 },
				{ Name = "Delves", Type = "RecentAlliesFriendTag", EnumValue = 4 },
				{ Name = "Questing", Type = "RecentAlliesFriendTag", EnumValue = 5 },
			},
		},
		{
			Name = "RecentAllyPinResult",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Success", Type = "RecentAllyPinResult", EnumValue = 0 },
				{ Name = "ServerError", Type = "RecentAllyPinResult", EnumValue = 1 },
			},
		},
		{
			Name = "RecentAlliesConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "PIN_EXPIRATION_WARNING_DAYS", Type = "number", Value = 5 },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(RecentAlliesConstants);