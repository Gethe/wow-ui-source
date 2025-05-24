local ValidateNameConstants =
{
	Tables =
	{
		{
			Name = "ScrubStringFlags",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "ScrubStringFlags", EnumValue = 0 },
				{ Name = "TruncateNewLines", Type = "ScrubStringFlags", EnumValue = 1 },
				{ Name = "AllowBarCodes", Type = "ScrubStringFlags", EnumValue = 2 },
				{ Name = "StripControlCodes", Type = "ScrubStringFlags", EnumValue = 4 },
			},
		},
		{
			Name = "ValidateNameResult",
			Type = "Enumeration",
			NumValues = 18,
			MinValue = 0,
			MaxValue = 17,
			Fields =
			{
				{ Name = "Success", Type = "ValidateNameResult", EnumValue = 0 },
				{ Name = "Failure", Type = "ValidateNameResult", EnumValue = 1 },
				{ Name = "NoName", Type = "ValidateNameResult", EnumValue = 2 },
				{ Name = "TooShort", Type = "ValidateNameResult", EnumValue = 3 },
				{ Name = "TooLong", Type = "ValidateNameResult", EnumValue = 4 },
				{ Name = "InvalidCharacter", Type = "ValidateNameResult", EnumValue = 5 },
				{ Name = "MixedLanguages", Type = "ValidateNameResult", EnumValue = 6 },
				{ Name = "Profane", Type = "ValidateNameResult", EnumValue = 7 },
				{ Name = "Reserved", Type = "ValidateNameResult", EnumValue = 8 },
				{ Name = "InvalidApostrophe", Type = "ValidateNameResult", EnumValue = 9 },
				{ Name = "MultipleApostrophes", Type = "ValidateNameResult", EnumValue = 10 },
				{ Name = "ThreeConsecutive", Type = "ValidateNameResult", EnumValue = 11 },
				{ Name = "InvalidSpace", Type = "ValidateNameResult", EnumValue = 12 },
				{ Name = "ConsecutiveSpaces", Type = "ValidateNameResult", EnumValue = 13 },
				{ Name = "RussianConsecutiveSilentCharacters", Type = "ValidateNameResult", EnumValue = 14 },
				{ Name = "RussianSilentCharacterAtBeginningOrEnd", Type = "ValidateNameResult", EnumValue = 15 },
				{ Name = "DeclensionDoesntMatchBaseName", Type = "ValidateNameResult", EnumValue = 16 },
				{ Name = "SpacesDisallowed", Type = "ValidateNameResult", EnumValue = 17 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ValidateNameConstants);