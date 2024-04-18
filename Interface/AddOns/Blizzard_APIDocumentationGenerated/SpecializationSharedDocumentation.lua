local SpecializationShared =
{
	Name = "SpecializationShared",
	Type = "System",

	Functions =
	{
		{
			Name = "GetNumSpecializationsForClassID",
			Type = "Function",

			Arguments =
			{
				{ Name = "specID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "specCount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpecializationInfoForClassID",
			Type = "Function",

			Arguments =
			{
				{ Name = "classID", Type = "number", Nilable = false },
				{ Name = "index", Type = "number", Nilable = false },
				{ Name = "gender", Type = "number", Nilable = true },
			},

			Returns =
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
		{
			Name = "GetSpecializationInfoForSpecID",
			Type = "Function",

			Arguments =
			{
				{ Name = "specID", Type = "number", Nilable = false },
				{ Name = "gender", Type = "number", Nilable = true },
			},

			Returns =
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
		{
			Name = "GetSpecializationNameForSpecID",
			Type = "Function",

			Arguments =
			{
				{ Name = "specID", Type = "number", Nilable = false },
				{ Name = "gender", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = true },
			},
		},
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