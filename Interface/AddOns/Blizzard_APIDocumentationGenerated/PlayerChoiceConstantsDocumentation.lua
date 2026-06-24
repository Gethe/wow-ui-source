local PlayerChoiceConstants =
{
	Tables =
	{
		{
			Name = "PlayerChoiceFlags",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 1,
			MaxValue = 256,
			Fields =
			{
				{ Name = "InfiniteRange", Type = "PlayerChoiceFlags", EnumValue = 1 },
				{ Name = "HideWarboardHeader", Type = "PlayerChoiceFlags", EnumValue = 2 },
				{ Name = "KeepOpenAfterChoice", Type = "PlayerChoiceFlags", EnumValue = 4 },
				{ Name = "DoNotRefresh", Type = "PlayerChoiceFlags", EnumValue = 8 },
				{ Name = "ShowChoicesAsList", Type = "PlayerChoiceFlags", EnumValue = 16 },
				{ Name = "RequiresSelection", Type = "PlayerChoiceFlags", EnumValue = 32 },
				{ Name = "ShowChoicesAsGrid", Type = "PlayerChoiceFlags", EnumValue = 64 },
				{ Name = "HideAnswerArt", Type = "PlayerChoiceFlags", EnumValue = 128 },
				{ Name = "ShowChoicesAsColumns", Type = "PlayerChoiceFlags", EnumValue = 256 },
			},
		},
		{
			Name = "PlayerChoiceLayout",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Default", Type = "PlayerChoiceLayout", EnumValue = 0 },
				{ Name = "Grid", Type = "PlayerChoiceLayout", EnumValue = 1 },
				{ Name = "List", Type = "PlayerChoiceLayout", EnumValue = 2 },
				{ Name = "Columns", Type = "PlayerChoiceLayout", EnumValue = 3 },
			},
		},
		{
			Name = "PlayerChoiceResponseFlags",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 0,
			MaxValue = 256,
			Fields =
			{
				{ Name = "None", Type = "PlayerChoiceResponseFlags", EnumValue = 0 },
				{ Name = "ShowAnswerDisabled", Type = "PlayerChoiceResponseFlags", EnumValue = 1 },
				{ Name = "ShowArtDesaturated", Type = "PlayerChoiceResponseFlags", EnumValue = 2 },
				{ Name = "ShowOptionDisabled", Type = "PlayerChoiceResponseFlags", EnumValue = 4 },
				{ Name = "InvertCondition", Type = "PlayerChoiceResponseFlags", EnumValue = 8 },
				{ Name = "ShowAnswerDisabledWhenConditionFails", Type = "PlayerChoiceResponseFlags", EnumValue = 16 },
				{ Name = "ConsolidateWidgets", Type = "PlayerChoiceResponseFlags", EnumValue = 32 },
				{ Name = "CheckmarkOnlyButton", Type = "PlayerChoiceResponseFlags", EnumValue = 64 },
				{ Name = "HideButton", Type = "PlayerChoiceResponseFlags", EnumValue = 128 },
				{ Name = "ShowAnswerSelected", Type = "PlayerChoiceResponseFlags", EnumValue = 256 },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(PlayerChoiceConstants);