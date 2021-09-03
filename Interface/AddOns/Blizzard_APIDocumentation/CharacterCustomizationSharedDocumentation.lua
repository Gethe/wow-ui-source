local CharacterCustomizationShared =
{
	Tables =
	{
		{
			Name = "ChrCustomizationCategoryFlag",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "UndressModel", Type = "ChrCustomizationCategoryFlag", EnumValue = 1 },
			},
		},
		{
			Name = "ChrCustomizationOptionType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "SelectionPopout", Type = "ChrCustomizationOptionType", EnumValue = 0 },
				{ Name = "Checkbox", Type = "ChrCustomizationOptionType", EnumValue = 1 },
				{ Name = "Slider", Type = "ChrCustomizationOptionType", EnumValue = 2 },
			},
		},
		{
			Name = "Unitsex",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Male", Type = "Unitsex", EnumValue = 0 },
				{ Name = "Female", Type = "Unitsex", EnumValue = 1 },
				{ Name = "None", Type = "Unitsex", EnumValue = 2 },
			},
		},
		{
			Name = "CharCustomizationChoice",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "ineligibleChoice", Type = "bool", Nilable = false },
				{ Name = "isNew", Type = "bool", Nilable = false },
				{ Name = "swatchColor1", Type = "table", Mixin = "ColorMixin", Nilable = true },
				{ Name = "swatchColor2", Type = "table", Mixin = "ColorMixin", Nilable = true },
			},
		},
		{
			Name = "CharCustomizationOption",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "optionType", Type = "ChrCustomizationOptionType", Nilable = false },
				{ Name = "choices", Type = "table", InnerType = "CharCustomizationChoice", Nilable = false },
				{ Name = "currentChoiceIndex", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CharacterCustomizationShared);