local BountyShared =
{
	Tables =
	{
		{
			Name = "BountyInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "factionID", Type = "number", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "numObjectives", Type = "number", Nilable = false },
				{ Name = "turninRequirementText", Type = "cstring", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(BountyShared);