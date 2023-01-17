local PlayerInfoShared =
{
	Tables =
	{
		{
			Name = "CharacterAlternateFormData",
			Type = "Structure",
			Fields =
			{
				{ Name = "raceID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "fileName", Type = "string", Nilable = false },
				{ Name = "createScreenIconAtlas", Type = "string", Nilable = false },
			},
		},
		{
			Name = "PlayerInfoCharacterData",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "fileName", Type = "string", Nilable = false },
				{ Name = "alternateFormRaceData", Type = "CharacterAlternateFormData", Nilable = true },
				{ Name = "createScreenIconAtlas", Type = "string", Nilable = false },
				{ Name = "sex", Type = "UnitSex", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PlayerInfoShared);