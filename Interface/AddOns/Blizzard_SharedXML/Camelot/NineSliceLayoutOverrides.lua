-- Adjustments are added to whatever the existing offset value is, while overrides completely replace it.
local NINE_SLICE_OFFSET_OVERRIDES =
{
	{
		pieceName = "TopRightCorner",
		atlas = "UI-Frame-Metal-CornerTopRight",
		xAdjustment = -2,
	},
	{
		pieceName = "TopRightCorner",
		atlas = "UI-Frame-Metal-CornerTopRightDouble",
		xAdjustment = -2,
	},
	{
		pieceName = "BottomLeftCorner",
		atlas = "UI-Frame-Metal-CornerBottomLeft",
		yOverride = -8,
	},
	{
		pieceName = "BottomRightCorner",
		atlas = "UI-Frame-Metal-CornerBottomRight",
		xAdjustment = -2,
		yOverride = -8,
	},
};

local function ApplyXOffsetAdjustment(piece, xAdjustment)
	if xAdjustment then
		piece.x = (piece.x or 0) + xAdjustment;
	end
end

local function ApplyYOffsetOverride(piece, yOverride)
	if yOverride then
		piece.y = yOverride;
	end
end

local function ApplyOffsetOverrides(layout)
	for _, offsetOverride in ipairs(NINE_SLICE_OFFSET_OVERRIDES) do
		local piece = layout[offsetOverride.pieceName];
		if piece and piece.atlas == offsetOverride.atlas then
			ApplyXOffsetAdjustment(piece, offsetOverride.xAdjustment);
			ApplyYOffsetOverride(piece, offsetOverride.yOverride);
		end
	end
end

-- In some places the art made for Camelot doesn't match the exact size of the Mainline Standard
-- art and needs to be offset differently.
for _layoutName, layout in pairs(NineSliceLayouts) do
	ApplyOffsetOverrides(layout);
end
