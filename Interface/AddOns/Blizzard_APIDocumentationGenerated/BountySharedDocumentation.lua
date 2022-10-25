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
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "numObjectives", Type = "number", Nilable = false },
				{ Name = "turninRequirementText", Type = "string", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(BountyShared);