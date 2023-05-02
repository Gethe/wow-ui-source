local UnitConstants =
{
	Tables =
	{
		{
			Name = "AddPrivateAuraAnchorArgs",
			Type = "Structure",
			Fields =
			{
				{ Name = "unitToken", Type = "cstring", Nilable = false },
				{ Name = "auraIndex", Type = "number", Nilable = false },
				{ Name = "parent", Type = "SimpleFrame", Nilable = false },
				{ Name = "showCountdownFrame", Type = "bool", Nilable = false },
				{ Name = "showCountdownNumbers", Type = "bool", Nilable = false },
				{ Name = "iconInfo", Type = "PrivateAuraIconInfo", Nilable = true },
				{ Name = "durationAnchor", Type = "AnchorBinding", Nilable = true },
			},
		},
		{
			Name = "PrivateAuraIconInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "iconAnchor", Type = "AnchorBinding", Nilable = false },
				{ Name = "iconWidth", Type = "uiUnit", Nilable = false },
				{ Name = "iconHeight", Type = "uiUnit", Nilable = false },
			},
		},
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
			Name = "UnitPrivateAuraAnchorInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "anchorID", Type = "number", Nilable = false },
				{ Name = "unitToken", Type = "string", Nilable = false },
				{ Name = "auraIndex", Type = "number", Nilable = false },
				{ Name = "showCountdownFrame", Type = "bool", Nilable = false },
				{ Name = "showCountdownNumbers", Type = "bool", Nilable = false },
				{ Name = "iconWidth", Type = "uiUnit", Nilable = true },
				{ Name = "iconHeight", Type = "uiUnit", Nilable = true },
			},
		},
		{
			Name = "UnitPrivateAuraAppliedSoundInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "soundFileName", Type = "string", Nilable = true },
				{ Name = "soundFileID", Type = "number", Nilable = true },
				{ Name = "outputChannel", Type = "string", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UnitConstants);