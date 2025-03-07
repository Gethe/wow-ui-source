local CooldownViewerConstants =
{
	Tables =
	{
		{
			Name = "CooldownSetSpellFlags",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "HideAura", Type = "CooldownSetSpellFlags", EnumValue = 1 },
			},
		},
		{
			Name = "CooldownViewerCategory",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Essential", Type = "CooldownViewerCategory", EnumValue = 0 },
				{ Name = "Utility", Type = "CooldownViewerCategory", EnumValue = 1 },
				{ Name = "TrackedBuff", Type = "CooldownViewerCategory", EnumValue = 2 },
				{ Name = "TrackedBar", Type = "CooldownViewerCategory", EnumValue = 3 },
			},
		},
		{
			Name = "CooldownViewerUIConstants",
			Type = "Constants",
			Values =
			{
				{ Name = "COOLDOWN_VIEWER_LINKED_SPELLS_SIZE", Type = "number", Value = 4 },
				{ Name = "COOLDOWN_VIEWER_CATEGORY_SET_SIZE", Type = "number", Value = 16 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CooldownViewerConstants);