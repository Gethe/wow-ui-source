local CooldownViewer =
{
	Name = "CooldownViewer",
	Type = "System",
	Namespace = "C_CooldownViewer",

	Functions =
	{
		{
			Name = "GetCooldownViewerCategorySet",
			Type = "Function",

			Arguments =
			{
				{ Name = "category", Type = "CooldownViewerCategory", Nilable = false },
				{ Name = "allowUnlearned", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "cooldownIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetCooldownViewerCooldownInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "cooldownID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "cooldownInfo", Type = "CooldownViewerCooldown", Nilable = false },
			},
		},
		{
			Name = "IsCooldownViewerAvailable",
			Type = "Function",

			Returns =
			{
				{ Name = "isAvailable", Type = "bool", Nilable = false },
				{ Name = "failureReason", Type = "string", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "CooldownViewerSpellOverrideUpdated",
			Type = "Event",
			LiteralName = "COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED",
			Payload =
			{
				{ Name = "baseSpellID", Type = "number", Nilable = false, Documentation = { "The base spell that is either being overridden or losing its override spell." } },
				{ Name = "overrideSpellID", Type = "number", Nilable = true, Documentation = { "The spell overriding the base spell. A nil value indicates that the override spell is being removed from the base spell." } },
			},
		},
		{
			Name = "CooldownViewerTableHotfixed",
			Type = "Event",
			LiteralName = "COOLDOWN_VIEWER_TABLE_HOTFIXED",
		},
	},

	Tables =
	{
		{
			Name = "CooldownViewerCooldown",
			Type = "Structure",
			Fields =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "overrideSpellID", Type = "number", Nilable = true },
				{ Name = "linkedSpellIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "selfAura", Type = "bool", Nilable = false },
				{ Name = "hasAura", Type = "bool", Nilable = false },
				{ Name = "charges", Type = "bool", Nilable = false },
				{ Name = "isKnown", Type = "bool", Nilable = false },
				{ Name = "flags", Type = "CooldownSetSpellFlags", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CooldownViewer);