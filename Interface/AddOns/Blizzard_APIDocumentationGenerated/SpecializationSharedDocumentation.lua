local SpecializationShared =
{
	Name = "SpecializationShared",
	Type = "System",

	Functions =
	{
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "SpecializationInfoResult",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "role", Type = "cstring", Nilable = false },
				{ Name = "recommended", Type = "bool", Nilable = false },
				{ Name = "allowedForBoost", Type = "bool", Nilable = false },
				{ Name = "masterySpell1", Type = "number", Nilable = true },
				{ Name = "masterySpell2", Type = "number", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SpecializationShared);