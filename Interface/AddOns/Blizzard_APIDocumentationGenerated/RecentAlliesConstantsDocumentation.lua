local RecentAlliesConstants =
{
	Tables =
	{
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
};

APIDocumentation:AddDocumentationTable(RecentAlliesConstants);