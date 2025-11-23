local Deprecated_11_0_0 =
{
	Name = "Deprecated_11_0_0",
	Type = "System",
	Namespace = "C_Deprecated",
	Documentation = { "These are events and functions that were deprecated in 11.0.0 and will be removed before it ships." },

	Functions =
	{
	},

	Events =
	{
		{
			Name = "LearnedSpellInTab",
			Type = "Event",
			LiteralName = "LEARNED_SPELL_IN_TAB",
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "skillInfoIndex", Type = "number", Nilable = false },
				{ Name = "isGuildPerkSpell", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Deprecated_11_0_0);