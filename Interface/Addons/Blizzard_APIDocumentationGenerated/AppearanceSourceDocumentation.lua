local AppearanceSource =
{
	Tables =
	{
		{
			Name = "AppearanceSourceInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "visualID", Type = "number", Nilable = false },
				{ Name = "sourceID", Type = "number", Nilable = false },
				{ Name = "isCollected", Type = "bool", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "itemModID", Type = "number", Nilable = false },
				{ Name = "invType", Type = "luaIndex", Nilable = false, Default = 0 },
				{ Name = "categoryID", Type = "TransmogCollectionType", Nilable = false, Default = "None" },
				{ Name = "inventorySlot", Type = "number", Nilable = true },
				{ Name = "sourceType", Type = "luaIndex", Nilable = true },
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "quality", Type = "number", Nilable = true },
				{ Name = "useError", Type = "string", Nilable = true },
				{ Name = "useErrorType", Type = "TransmogUseErrorType", Nilable = true },
				{ Name = "meetsTransmogPlayerCondition", Type = "bool", Nilable = true },
				{ Name = "isHideVisual", Type = "bool", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AppearanceSource);