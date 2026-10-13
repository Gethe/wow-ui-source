local UITextureConstants =
{
	Tables =
	{
		{
			Name = "UITextureSliceMode",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Stretched", Type = "UITextureSliceMode", EnumValue = 0 },
				{ Name = "Tiled", Type = "UITextureSliceMode", EnumValue = 1 },
			},
		},
		{
			Name = "UITextureSliceData",
			Type = "Structure",
			Fields =
			{
				{ Name = "marginLeft", Type = "number", Nilable = false },
				{ Name = "marginTop", Type = "number", Nilable = false },
				{ Name = "marginRight", Type = "number", Nilable = false },
				{ Name = "marginBottom", Type = "number", Nilable = false },
				{ Name = "sliceMode", Type = "UITextureSliceMode", Nilable = false },
			},
		},
		{
			Name = "UITextureSliceMargins",
			Type = "Structure",
			Fields =
			{
				{ Name = "left", Type = "number", Nilable = false },
				{ Name = "top", Type = "number", Nilable = false },
				{ Name = "right", Type = "number", Nilable = false },
				{ Name = "bottom", Type = "number", Nilable = false },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(UITextureConstants);