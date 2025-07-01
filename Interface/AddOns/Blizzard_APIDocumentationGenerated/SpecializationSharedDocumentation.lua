local SpecializationShared =
{
	Name = "SpecializationShared",
	Type = "System",

	Functions =
	{
		{
			Name = "GetSpecializationNameForSpecID",
			Type = "Function",

			Arguments =
			{
				{ Name = "specID", Type = "number", Nilable = false },
				{ Name = "gender", Type = "UnitSex", Nilable = true },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "HasLootSpecializations",
			Type = "Function",

			Returns =
			{
				{ Name = "hasLootSpecializations", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "SpecializationSystem",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "TalentTab", Type = "SpecializationSystem", EnumValue = 0 },
				{ Name = "ChrSpecialization", Type = "SpecializationSystem", EnumValue = 1 },
			},
		},
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