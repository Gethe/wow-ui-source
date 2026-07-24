local AuraContainerShared =
{
	Tables =
	{
		{
			Name = "CustomAuraButtonDispelTypeTextureStyle",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Border", Type = "CustomAuraButtonDispelTypeTextureStyle", EnumValue = 0, Documentation = { "Uses a built-in border based on the aura's dispel type." } },
				{ Name = "BorderWithIcon", Type = "CustomAuraButtonDispelTypeTextureStyle", EnumValue = 1, Documentation = { "Uses a built-in border with a corner icon based on the aura's dispel type." } },
				{ Name = "Icon", Type = "CustomAuraButtonDispelTypeTextureStyle", EnumValue = 2, Documentation = { "Uses a built-in icon based on the aura's dispel type." } },
				{ Name = "PreserveAsset", Type = "CustomAuraButtonDispelTypeTextureStyle", EnumValue = 3, Documentation = { "Preserves the texture's existing asset." } },
				{ Name = "CustomAsset", Type = "CustomAuraButtonDispelTypeTextureStyle", EnumValue = 4, Documentation = { "Uses a custom texture asset selected from the configured dispel type asset map." } },
			},
		},
		{
			Name = "CustomAuraButtonUpdateMode",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Assignment", Type = "CustomAuraButtonUpdateMode", EnumValue = 0, Documentation = { "Applies a newly assigned aura, resetting presentation state rather than transitioning from the previous aura." } },
				{ Name = "Update", Type = "CustomAuraButtonUpdateMode", EnumValue = 1, Documentation = { "Refreshes the current aura assignment, allowing presentation state to retain continuity." } },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(AuraContainerShared);