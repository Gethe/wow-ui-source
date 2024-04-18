local PerksVendorConstants =
{
	Tables =
	{
		{
			Name = "PerksVendorCategoryType",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 1,
			MaxValue = 8,
			Fields =
			{
				{ Name = "Transmog", Type = "PerksVendorCategoryType", EnumValue = 1 },
				{ Name = "Mount", Type = "PerksVendorCategoryType", EnumValue = 2 },
				{ Name = "Pet", Type = "PerksVendorCategoryType", EnumValue = 3 },
				{ Name = "Toy", Type = "PerksVendorCategoryType", EnumValue = 5 },
				{ Name = "Illusion", Type = "PerksVendorCategoryType", EnumValue = 7 },
				{ Name = "Transmogset", Type = "PerksVendorCategoryType", EnumValue = 8 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PerksVendorConstants);