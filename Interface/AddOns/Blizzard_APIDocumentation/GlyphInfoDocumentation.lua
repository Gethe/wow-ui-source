local GlyphInfo =
{
	Name = "GlyphInfo",
	Type = "System",
	Namespace = "C_GlyphInfo",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "ActivateGlyph",
			Type = "Event",
			LiteralName = "ACTIVATE_GLYPH",
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CancelGlyphCast",
			Type = "Event",
			LiteralName = "CANCEL_GLYPH_CAST",
		},
		{
			Name = "UseGlyph",
			Type = "Event",
			LiteralName = "USE_GLYPH",
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(GlyphInfo);