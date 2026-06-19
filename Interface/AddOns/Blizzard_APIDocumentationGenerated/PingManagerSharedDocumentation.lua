local PingManagerShared =
{
	Tables =
	{
		{
			Name = "PingCooldownInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "startTimeMs", Type = "number", Nilable = false },
				{ Name = "endTimeMs", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PingMacroInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "type", Type = "PingSubjectType", Nilable = true },
				{ Name = "targetToken", Type = "cstring", Nilable = true },
				{ Name = "spellID", Type = "number", Nilable = true },
				{ Name = "itemID", Type = "number", Nilable = true },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(PingManagerShared);