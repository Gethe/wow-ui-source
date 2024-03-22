local Time =
{
	Tables =
	{
		{
			Name = "CalendarTime",
			Type = "Structure",
			Fields =
			{
				{ Name = "day", Type = "number", Nilable = false },
				{ Name = "monthDay", Type = "luaIndex", Nilable = false },
				{ Name = "month", Type = "luaIndex", Nilable = false },
				{ Name = "weekday", Type = "luaIndex", Nilable = false },
				{ Name = "year", Type = "number", Nilable = false },
				{ Name = "hour", Type = "number", Nilable = false },
				{ Name = "minute", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Time);