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
				{ Name = "showCooldownFrame", Type = "bool", Nilable = false, Default = false },
				{ Name = "showCooldownEdge", Type = "bool", Nilable = false, Default = false },
				{ Name = "showCountdownNumbers", Type = "bool", Nilable = false, Default = false },
				{ Name = "showDispelIcon", Type = "bool", Nilable = false, Default = false },
				{ Name = "isContainer", Type = "bool", Nilable = false, Default = false },
				{ Name = "iconInfo", Type = "PrivateAuraIconInfo", Nilable = true },
				{ Name = "durationAnchor", Type = "AnchorBinding", Nilable = true },
			},
		},
		{
			Name = "GroupBuffVisualAlertInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "visualValue", Type = "VisualAlertType", Nilable = false },
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
				{ Name = "borderScale", Type = "uiUnit", Nilable = true },
			},
		},
		{
			Name = "UnitAuraSoundInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "soundFileName", Type = "string", Nilable = true, Documentation = { "Sound file to play. Playback stops after five seconds." } },
				{ Name = "soundFileID", Type = "number", Nilable = true, Documentation = { "Sound file to play. Playback stops after five seconds." } },
				{ Name = "outputChannel", Type = "string", Nilable = true },
				{ Name = "throttleSeconds", Type = "number", Nilable = true, Documentation = { "Minimum time in seconds between plays. Must be between 0 and 5 seconds, inclusive. Invalid values reject registration." } },
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
				{ Name = "showCooldownFrame", Type = "bool", Nilable = false, Default = false },
				{ Name = "showCooldownEdge", Type = "bool", Nilable = false, Default = false },
				{ Name = "showCountdownNumbers", Type = "bool", Nilable = false, Default = false },
				{ Name = "showDispelIcon", Type = "bool", Nilable = false, Default = false },
				{ Name = "iconWidth", Type = "uiUnit", Nilable = true },
				{ Name = "iconHeight", Type = "uiUnit", Nilable = true },
				{ Name = "borderScale", Type = "uiUnit", Nilable = true },
				{ Name = "isContainer", Type = "bool", Nilable = true },
				{ Name = "parent", Type = "SimpleFrame", Nilable = false },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(UnitConstants);