local UnitConstants =
{
	Tables =
	{
		{
			Name = "UnitAuraUpdateInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "isFullUpdate", Type = "bool", Nilable = false, Default = false },
				{ Name = "removedAuraInstanceIDs", Type = "table", InnerType = "number", Nilable = true },
				{ Name = "addedAuras", Type = "table", InnerType = "table", Nilable = true },
				{ Name = "updatedAuraInstanceIDs", Type = "table", InnerType = "number", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UnitConstants);