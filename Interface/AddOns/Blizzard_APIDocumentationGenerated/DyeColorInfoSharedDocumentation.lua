local DyeColorInfoShared =
{
	Tables =
	{
		{
			Name = "DyeColorCategoryDisplayInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "DyeColorDisplayInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "dyeColorCategoryID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "sortOrder", Type = "number", Nilable = false },
				{ Name = "swatchColorStart", Type = "colorRGB", Mixin = "ColorMixin", Nilable = false },
				{ Name = "swatchColorEnd", Type = "colorRGB", Mixin = "ColorMixin", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = true, Documentation = { "The consumable item used to apply this Dye Color; May be nil if dye color does not have an associated item" } },
				{ Name = "numOwned", Type = "number", Nilable = false, Documentation = { "The number of this dye's consumable item owned by the player; Includes both held and banked items; Will be 0 if dye has no associated item" } },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(DyeColorInfoShared);