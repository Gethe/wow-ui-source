local RecentAlliesConstants =
{
	Tables =
	{
		{
			Name = "RecentAlliesInteractionCategoryFilter",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Professions", Type = "RecentAlliesInteractionCategoryFilter", EnumValue = 0 },
				{ Name = "PvP", Type = "RecentAlliesInteractionCategoryFilter", EnumValue = 1 },
				{ Name = "Raiding", Type = "RecentAlliesInteractionCategoryFilter", EnumValue = 2 },
				{ Name = "Dungeons", Type = "RecentAlliesInteractionCategoryFilter", EnumValue = 3 },
				{ Name = "Delves", Type = "RecentAlliesInteractionCategoryFilter", EnumValue = 4 },
				{ Name = "Questing", Type = "RecentAlliesInteractionCategoryFilter", EnumValue = 5 },
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