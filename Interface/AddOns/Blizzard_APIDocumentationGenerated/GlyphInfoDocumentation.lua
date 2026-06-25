local GlyphInfo =
{
	Name = "GlyphInfo",
	Type = "System",
	Namespace = "C_GlyphInfo",
	Environment = "All",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "ActivateGlyph",
			Type = "Event",
			LiteralName = "ACTIVATE_GLYPH",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CancelGlyphCast",
			Type = "Event",
			LiteralName = "CANCEL_GLYPH_CAST",
			SynchronousEvent = true,
		},
		{
			Name = "GlyphAdded",
			Type = "Event",
			LiteralName = "GLYPH_ADDED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "glyphSlot", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GlyphRemoved",
			Type = "Event",
			LiteralName = "GLYPH_REMOVED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "glyphSlot", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GlyphUpdated",
			Type = "Event",
			LiteralName = "GLYPH_UPDATED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "glyphSlot", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UseGlyph",
			Type = "Event",
			LiteralName = "USE_GLYPH",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(GlyphInfo);