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
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "fileName", Type = "cstring", Nilable = false },
				{ Name = "createScreenIconAtlas", Type = "textureAtlas", Nilable = false },
			},
		},
		{
			Name = "PlayerInfoCharacterData",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "fileName", Type = "cstring", Nilable = false },
				{ Name = "alternateFormRaceData", Type = "CharacterAlternateFormData", Nilable = true },
				{ Name = "createScreenIconAtlas", Type = "textureAtlas", Nilable = false },
				{ Name = "sex", Type = "UnitSex", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PlayerInfoShared);