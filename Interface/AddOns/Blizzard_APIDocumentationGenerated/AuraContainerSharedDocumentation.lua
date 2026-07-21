local AuraContainerShared =
{
	Tables =
	{
		{
			Name = "CustomAuraButtonBorderStyle",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Atlas", Type = "CustomAuraButtonBorderStyle", EnumValue = 0, Documentation = { "Uses built-in border atlases based on the aura's dispel type." } },
				{ Name = "Color", Type = "CustomAuraButtonBorderStyle", EnumValue = 1, Documentation = { "Uses vertex coloring based on the aura's dispel type." } },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(AuraContainerShared);