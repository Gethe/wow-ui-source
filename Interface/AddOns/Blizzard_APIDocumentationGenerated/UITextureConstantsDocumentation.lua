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
	},
};

APIDocumentation:AddDocumentationTable(UITextureConstants);