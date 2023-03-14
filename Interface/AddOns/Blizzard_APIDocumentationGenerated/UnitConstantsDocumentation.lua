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
				{ Name = "addedAuras", Type = "table", InnerType = "AuraData", Nilable = true },
				{ Name = "updatedAuraInstanceIDs", Type = "table", InnerType = "number", Nilable = true },
			},
		},
		{
			Name = "UnitPrivateAuraAnchor",
			Type = "Structure",
			Fields =
			{
				{ Name = "anchorID", Type = "number", Nilable = false },
				{ Name = "unitToken", Type = "cstring", Nilable = false },
				{ Name = "globalXOfsFromCenter", Type = "uiUnit", Nilable = false },
				{ Name = "globalYOfsFromCenter", Type = "uiUnit", Nilable = false },
				{ Name = "useCompactAura", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UnitConstants);