
-- Talent frame grids display talents in a fixed grid.

TalentFrameGridMixin = {};

function TalentFrameGridMixin:UpdateAllTalentButtonPositions()
	-- Overrides TalentFrameBaseMixin.

	local buttons = self.buttonsMethod(self);
	local stride = self.stride or 5;
	local paddingX = self.paddingX or 0;
	local paddingY = self.paddingY or 0;
	local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, stride, paddingX, paddingY);
	local anchor = CreateAnchor("TOPLEFT", self.ButtonsParent, "TOPLEFT");
	AnchorUtil.GridLayout(buttons, anchor, layout);
end
