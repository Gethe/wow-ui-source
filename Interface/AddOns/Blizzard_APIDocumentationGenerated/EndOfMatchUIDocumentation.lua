local EndOfMatchUI =
{
	Name = "EndOfMatchUI",
	Type = "System",
	Namespace = "C_EndOfMatchUI",

	Functions =
	{
		{
			Name = "GetEndOfMatchDetails",
			Type = "Function",

			Returns =
			{
				{ Name = "matchDetails", Type = "MatchDetails", Nilable = true },
			},
		},
	},

	Events =
	{
		{
			Name = "ShowEndOfMatchUI",
			Type = "Event",
			LiteralName = "SHOW_END_OF_MATCH_UI",
		},
	},

	Tables =
	{
		{
			Name = "EndOfMatchType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "None", Type = "EndOfMatchType", EnumValue = 0 },
				{ Name = "Plunderstorm", Type = "EndOfMatchType", EnumValue = 1 },
			},
		},
		{
			Name = "MatchDetailType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Placement", Type = "MatchDetailType", EnumValue = 0 },
				{ Name = "Kills", Type = "MatchDetailType", EnumValue = 1 },
				{ Name = "PlunderAcquired", Type = "MatchDetailType", EnumValue = 2 },
			},
		},
		{
			Name = "MatchDetail",
			Type = "Structure",
			Fields =
			{
				{ Name = "type", Type = "MatchDetailType", Nilable = false },
				{ Name = "value", Type = "number", Nilable = false },
			},
		},
		{
			Name = "MatchDetails",
			Type = "Structure",
			Fields =
			{
				{ Name = "matchType", Type = "EndOfMatchType", Nilable = false },
				{ Name = "matchEnded", Type = "bool", Nilable = false },
				{ Name = "detailsList", Type = "table", InnerType = "MatchDetail", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(EndOfMatchUI);