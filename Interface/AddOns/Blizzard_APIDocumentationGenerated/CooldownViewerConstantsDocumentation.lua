local CooldownViewerConstants =
{
	Tables =
	{
		{
			Name = "CooldownSetLinkedSpellFlags",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "UseAsTooltip", Type = "CooldownSetLinkedSpellFlags", EnumValue = 1 },
			},
		},
		{
			Name = "CooldownSetSpellFlags",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 1,
			MaxValue = 2,
			Fields =
			{
				{ Name = "HideAura", Type = "CooldownSetSpellFlags", EnumValue = 1 },
				{ Name = "HideByDefault", Type = "CooldownSetSpellFlags", EnumValue = 2 },
			},
		},
		{
			Name = "CooldownViewerAddAlertStatus",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Success", Type = "CooldownViewerAddAlertStatus", EnumValue = 0 },
				{ Name = "InvalidAlertType", Type = "CooldownViewerAddAlertStatus", EnumValue = 1 },
				{ Name = "InvalidEventType", Type = "CooldownViewerAddAlertStatus", EnumValue = 2 },
				{ Name = "DuplicateAlert", Type = "CooldownViewerAddAlertStatus", EnumValue = 3 },
			},
		},
		{
			Name = "CooldownViewerAlertEventType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 1,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Available", Type = "CooldownViewerAlertEventType", EnumValue = 1 },
				{ Name = "PandemicTime", Type = "CooldownViewerAlertEventType", EnumValue = 2 },
				{ Name = "OnCooldown", Type = "CooldownViewerAlertEventType", EnumValue = 3 },
				{ Name = "ChargeGained", Type = "CooldownViewerAlertEventType", EnumValue = 4 },
			},
		},
		{
			Name = "CooldownViewerAlertType",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Sound", Type = "CooldownViewerAlertType", EnumValue = 1 },
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