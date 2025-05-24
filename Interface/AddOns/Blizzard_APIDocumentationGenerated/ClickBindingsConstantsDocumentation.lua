local ClickBindingsConstants =
{
	Tables =
	{
		{
			Name = "ClickBindingInteraction",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 1,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Target", Type = "ClickBindingInteraction", EnumValue = 1 },
				{ Name = "OpenContextMenu", Type = "ClickBindingInteraction", EnumValue = 2 },
			},
		},
		{
			Name = "ClickBindingType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "ClickBindingType", EnumValue = 0 },
				{ Name = "Spell", Type = "ClickBindingType", EnumValue = 1 },
				{ Name = "Macro", Type = "ClickBindingType", EnumValue = 2 },
				{ Name = "Interaction", Type = "ClickBindingType", EnumValue = 3 },
				{ Name = "PetAction", Type = "ClickBindingType", EnumValue = 4 },
			},
		},
		{
			Name = "ClickBindingInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "type", Type = "ClickBindingType", Nilable = false },
				{ Name = "actionID", Type = "number", Nilable = false, Documentation = { "Base spellID for spell, macro index for macro, ClickBindingInteraction for interaction, spellID for PetAction" } },
				{ Name = "button", Type = "cstring", Nilable = false },
				{ Name = "modifiers", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ClickBindingsConstants);