local PerksVendorConstants =
{
	Tables =
	{
		{
			Name = "PerksVendorCategoryType",
			Type = "Enumeration",
			NumValues = 12,
			MinValue = 1,
			MaxValue = 24,
			Fields =
			{
				{ Name = "Transmog", Type = "PerksVendorCategoryType", EnumValue = 1 },
				{ Name = "Mount", Type = "PerksVendorCategoryType", EnumValue = 2 },
				{ Name = "Pet", Type = "PerksVendorCategoryType", EnumValue = 3 },
				{ Name = "Toy", Type = "PerksVendorCategoryType", EnumValue = 5 },
				{ Name = "Illusion", Type = "PerksVendorCategoryType", EnumValue = 7 },
				{ Name = "Transmogset", Type = "PerksVendorCategoryType", EnumValue = 8 },
				{ Name = "WarbandScene", Type = "PerksVendorCategoryType", EnumValue = 9 },
				{ Name = "Stipend", Type = "PerksVendorCategoryType", EnumValue = 20 },
				{ Name = "Activity", Type = "PerksVendorCategoryType", EnumValue = 21 },
				{ Name = "GmAdjustment", Type = "PerksVendorCategoryType", EnumValue = 22 },
				{ Name = "Achievement", Type = "PerksVendorCategoryType", EnumValue = 23 },
				{ Name = "RefundUnused", Type = "PerksVendorCategoryType", EnumValue = 24 },
			},
		},
		{
			Name = "CriteriaRequiredValue",
			Type = "Structure",
			Fields =
			{
				{ Name = "criteriaID", Type = "number", Nilable = false },
				{ Name = "requiredValue", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CriteriaRequirement",
			Type = "Structure",
			Fields =
			{
				{ Name = "completed", Type = "bool", Nilable = false },
				{ Name = "requirementText", Type = "string", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PerksVendorConstants);