NUM_GLYPH_SLOTS = 9;

GLYPH_ID_MINOR_1 = 2;
GLYPH_ID_MAJOR_1 = 1;
GLYPH_ID_PRIME_1 = 7;
GLYPH_ID_MINOR_2 = 3;
GLYPH_ID_MAJOR_2 = 4;
GLYPH_ID_PRIME_2 = 8;
GLYPH_ID_MINOR_3 = 5;
GLYPH_ID_MAJOR_3 = 6;
GLYPH_ID_PRIME_3 = 9;
--[[
    7
  4 2 1
   3 5
8   6   9
]]--

GLYPH_STRING = { PRIME_GLYPH, MAJOR_GLYPH, MINOR_GLYPH}
GLYPH_STRING_PLURAL = { PRIME_GLYPHS, MAJOR_GLYPHS, MINOR_GLYPHS}

GLYPH_TYPE_INFO = {};
GLYPH_TYPE_INFO[GLYPH_TYPE_PRIME] =  {
	ring = { size = 82, left = 0.85839844, right = 0.93847656, top = 0.22265625, bottom = 0.30273438 };
	highlight = { size = 96, left = 0.85839844, right = 0.95214844, top = 0.30468750, bottom = 0.39843750 };
}
GLYPH_TYPE_INFO[GLYPH_TYPE_MAJOR] =  {
	ring = { size = 66, left = 0.85839844, right = 0.92285156, top = 0.00097656, bottom = 0.06542969 };
	highlight = { size = 80, left = 0.85839844, right = 0.93652344, top = 0.06738281, bottom = 0.14550781 };
}
GLYPH_TYPE_INFO[GLYPH_TYPE_MINOR] =  {
	ring = { size = 61, left = 0.92480469, right = 0.98437500, top = 0.00097656, bottom = 0.06054688 };
	highlight = { size = 75, left = 0.85839844, right = 0.93164063, top = 0.14746094, bottom = 0.22070313 };
}


BOTTOM_RIGHT_OFFSET = PANEL_INSET_BOTTOM_OFFSET;
NUM_GLYPH_OFFSET = 3;
HEIGHT_OFFSET = 5;
GLYPH_SIZE_OFFSET = 4;

function ShouldDisplaySpecTextInGlyphSubtext()
	return false;
end

function ShouldDisplaySpecIconInBackground()
	return false;
end
