local CovenantCallingsConstants =
{
	Tables =
	{
		{
			Name = "CallingStates",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "QuestOffer", Type = "CallingStates", EnumValue = 0 },
				{ Name = "QuestActive", Type = "CallingStates", EnumValue = 1 },
				{ Name = "QuestCompleted", Type = "CallingStates", EnumValue = 2 },
			},
		},
		{
			Name = "Callings",
			Type = "Constants",
			Values =
			{
				{ Name = "MaxCallings", Type = "number", Value = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CovenantCallingsConstants);