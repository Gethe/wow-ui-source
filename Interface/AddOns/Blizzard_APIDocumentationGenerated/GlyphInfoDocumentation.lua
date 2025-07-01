local GlyphInfo =
{
	Name = "GlyphInfo",
	Type = "System",
	Namespace = "C_GlyphInfo",

	Functions =
	{
		{
			Name = "GetGlyphInfoByID",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "glyphID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "glyphType", Type = "number", Nilable = false },
				{ Name = "isKnown", Type = "bool", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "link", Type = "string", Nilable = false },
			},
		},
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
			Name = "GlyphAdded",
			Type = "Event",
			LiteralName = "GLYPH_ADDED",
			Payload =
			{
				{ Name = "glyphSlot", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GlyphRemoved",
			Type = "Event",
			LiteralName = "GLYPH_REMOVED",
			Payload =
			{
				{ Name = "glyphSlot", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GlyphUpdated",
			Type = "Event",
			LiteralName = "GLYPH_UPDATED",
			Payload =
			{
				{ Name = "glyphSlot", Type = "number", Nilable = false },
			},
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