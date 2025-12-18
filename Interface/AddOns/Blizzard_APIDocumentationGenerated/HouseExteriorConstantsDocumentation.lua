local HouseExteriorConstants =
{
	Tables =
	{
		{
			Name = "HouseExteriorSizeOption",
			Type = "Structure",
			Fields =
			{
				{ Name = "size", Type = "HousingFixtureSize", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "isLocked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HouseExteriorSizeOptionsInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "selectedSize", Type = "HousingFixtureSize", Nilable = false },
				{ Name = "options", Type = "table", InnerType = "HouseExteriorSizeOption", Nilable = false },
			},
		},
		{
			Name = "HouseExteriorTypeOption",
			Type = "Structure",
			Fields =
			{
				{ Name = "houseExteriorTypeID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "isLocked", Type = "bool", Nilable = false },
				{ Name = "lockReasonString", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "HouseExteriorTypeOptionsInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "selectedExteriorType", Type = "number", Nilable = false },
				{ Name = "options", Type = "table", InnerType = "HouseExteriorTypeOption", Nilable = false },
			},
		},
		{
			Name = "HousingCoreFixtureInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "selectedVariantFixtureID", Type = "number", Nilable = false, Documentation = { "For fixtures that are variants, the id of specific selected variant; If fixture has no variants, will be the same id as selectedStyleFixtureID" } },
				{ Name = "selectedStyleFixtureID", Type = "number", Nilable = false, Documentation = { "For fixtures that are variants, the id of their specific base style fixture; If fixture has no variants, will be the same id as selectedVariantFixtureID" } },
				{ Name = "currentStyleVariantOptions", Type = "table", InnerType = "HousingFixtureOption", Nilable = false, Documentation = { "Fixtures that are variants of the same style as the selected (meaning they all share the same hooks); Includes the currently selected fixture" } },
				{ Name = "styleOptions", Type = "table", InnerType = "HousingFixtureOption", Nilable = false, Documentation = { "Fixtures that are different styles for this type and size of fixture (swapping will clear all hooks); Includes the currently selected fixture" } },
			},
		},
		{
			Name = "HousingFixtureOption",
			Type = "Structure",
			Fields =
			{
				{ Name = "fixtureID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "typeID", Type = "number", Nilable = false },
				{ Name = "typeName", Type = "cstring", Nilable = false },
				{ Name = "isLocked", Type = "bool", Nilable = false },
				{ Name = "lockReasonString", Type = "cstring", Nilable = false },
				{ Name = "colorID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HousingFixturePointInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "ownerHash", Type = "number", Nilable = false },
				{ Name = "selectedFixtureID", Type = "number", Nilable = true },
				{ Name = "fixtureOptions", Type = "table", InnerType = "HousingFixtureOption", Nilable = false },
				{ Name = "canSelectionBeRemoved", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(HouseExteriorConstants);