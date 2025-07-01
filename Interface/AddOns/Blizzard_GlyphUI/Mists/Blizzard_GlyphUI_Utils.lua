NUM_GLYPH_SLOTS = 6;

GLYPH_ID_MINOR_1 = 1;
GLYPH_ID_MAJOR_1 = 2;
GLYPH_ID_MINOR_2 = 3;
GLYPH_ID_MAJOR_2 = 4;
GLYPH_ID_MINOR_3 = 5;
GLYPH_ID_MAJOR_3 = 6;

GLYPH_STRING = { MAJOR_GLYPH, MINOR_GLYPH}
GLYPH_STRING_PLURAL = { MAJOR_GLYPHS, MINOR_GLYPHS}

GLYPH_TYPE_INFO = {};
GLYPH_TYPE_INFO[GLYPH_TYPE_MAJOR] =  {
	ring = { size = 84, left = 0.00390625, right = 0.33203125, top = 0.27539063, bottom = 0.43945313 };
	highlight = { size = 98, left = 0.54296875, right = 0.92578125, top = 0.00195313, bottom = 0.19335938 };
}
GLYPH_TYPE_INFO[GLYPH_TYPE_MINOR] =  {
	ring = { size = 68, left = 0.33984375, right = 0.60546875, top = 0.27539063, bottom = 0.40820313 };
	highlight = { size = 82, left = 0.61328125, right = 0.93359375, top = 0.27539063, bottom = 0.43554688 };
}


BOTTOM_RIGHT_OFFSET = 26;

NUM_GLYPH_OFFSET = 2;
HEIGHT_OFFSET = 10;
GLYPH_SIZE_OFFSET = 6;

function ShouldDisplaySpecTextInGlyphSubtext()
	return true;
end

function ShouldDisplaySpecIconInBackground()
	return true;
end
