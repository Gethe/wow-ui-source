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
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "ClickBindingType", EnumValue = 0 },
				{ Name = "Spell", Type = "ClickBindingType", EnumValue = 1 },
				{ Name = "Macro", Type = "ClickBindingType", EnumValue = 2 },
				{ Name = "Interaction", Type = "ClickBindingType", EnumValue = 3 },
			},
		},
		{
			Name = "ClickBindingInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "type", Type = "ClickBindingType", Nilable = false },
				{ Name = "actionID", Type = "number", Nilable = false },
				{ Name = "button", Type = "cstring", Nilable = false },
				{ Name = "modifiers", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ClickBindingsConstants);