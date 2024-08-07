
local DefaultMinBottomSpacing = 20;


-- Used when you want to dynamically adjust spacing to the actual space available. For example,
-- when things need to be adjusted based on UI scale and resolution.
SpaceToFitDirectionalLayoutMixin = {};

function SpaceToFitDirectionalLayoutMixin:SetFixedMaxSpace(maxSpace)
	self.maxSpace = maxSpace;
end

function SpaceToFitDirectionalLayoutMixin:GetAvailableSpace()
	-- Override in your derived Mixin.

	if self.maxSpace then
		return self.maxSpace / self:GetEffectiveScale();
	end
end

function SpaceToFitDirectionalLayoutMixin:GetChildSize(child)
	-- Override in your derived Mixin.

	local width, height = child:GetSize();
	return math.max(width, height);
end

function SpaceToFitDirectionalLayoutMixin:UpdateSpacing(children)
	children = children or self:GetLayoutChildren();

	local baseSpacing = self.baseSpacing;
	self.spacing = baseSpacing;

	local spaceAvailable = self:GetAvailableSpace();
	if spaceAvailable then
		local numChildren = #children;
		if numChildren >= 1 then
			local childSize = self:GetChildSize(children[1]);
			local spaceRequired = numChildren * childSize;
			local leftOverSpace = spaceAvailable - spaceRequired;

			if leftOverSpace < (baseSpacing * numChildren) then
				self.spacing = math.floor(leftOverSpace / numChildren);
			end

			local baseFrameLevel = self:GetFrameLevel();
			for i, child in ipairs(children) do
				child:SetFrameLevel(baseFrameLevel + (numChildren - i) + 1);
			end
		end
	end
end

function SpaceToFitDirectionalLayoutMixin:IsSpacingAdjusted()
	return not ApproximatelyEqual(self.spacing, self.baseSpacing);
end

function SpaceToFitDirectionalLayoutMixin:GetSpacing()
	return self.spacing;
end


SpaceToFitVerticalLayoutMixin = CreateFromMixins(SpaceToFitDirectionalLayoutMixin);

function SpaceToFitVerticalLayoutMixin:LayoutChildren(children, expandToWidth)
	self:UpdateSpacing(children);
	return VerticalLayoutMixin.LayoutChildren(self, children, expandToWidth);
end

function SpaceToFitVerticalLayoutMixin:GetAvailableSpace()
	local baseSpace = SpaceToFitDirectionalLayoutMixin.GetAvailableSpace(self);
	if baseSpace then
		return baseSpace;
	end

	local bottomMin = self.bottomFrame and self.bottomFrame:GetTop();
	if not bottomMin then
		return nil;
	end

	local topMax = self:GetTopMax();
	if not topMax then
		return nil;
	end

	return (topMax - bottomMin) - self.minBottomSpacing;
end

function SpaceToFitVerticalLayoutMixin:GetChildSize(child)
	-- Overrides SpaceToFitDirectionalLayoutMixin.

	return child:GetHeight();
end

-- Used to cap the height and adjust spacing as required by UI scale and resolution.
function SpaceToFitVerticalLayoutMixin:SetBottomFrame(bottomFrame, minBottomSpacing)
	self.bottomFrame = bottomFrame;
	self.minBottomSpacing = minBottomSpacing or DefaultMinBottomSpacing;
end

-- Used to cap the height and adjust spacing as required by UI scale and resolution.
function SpaceToFitVerticalLayoutMixin:SetTopFrame(topFrame)
	self.topFrame = topFrame;
end

function SpaceToFitVerticalLayoutMixin:GetTopMax()
	return (self.topFrame and self.topFrame:GetBottom()) or self:GetTop();
end


-- Less featured than the Vertical version simply because nothing else was required originally.
SpaceToFitHorizontalLayoutMixin = CreateFromMixins(SpaceToFitDirectionalLayoutMixin);

function SpaceToFitHorizontalLayoutMixin:LayoutChildren(children, expandToWidth)
	self:UpdateSpacing(children);
	return HorizontalLayoutMixin.LayoutChildren(self, children, expandToWidth);
end

function SpaceToFitHorizontalLayoutMixin:GetChildSize(child)
	-- Overrides SpaceToFitDirectionalLayoutMixin.

	return child:GetWidth();
end
