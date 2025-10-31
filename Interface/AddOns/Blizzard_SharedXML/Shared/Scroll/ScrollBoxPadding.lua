local ScrollBoxBasePaddingMixin = {};

function ScrollBoxBasePaddingMixin:Init(top, bottom, left, right)
	self:SetTop(top or 0);
	self:SetBottom(bottom or 0);
	self:SetLeft(left or 0);
	self:SetRight(right or 0);
end

function ScrollBoxBasePaddingMixin:GetTop()
	return self.top;
end

function ScrollBoxBasePaddingMixin:SetTop(top)
	self.top = top;
end

function ScrollBoxBasePaddingMixin:GetBottom()
	return self.bottom;
end

function ScrollBoxBasePaddingMixin:SetBottom(bottom)
	self.bottom = bottom;
end

function ScrollBoxBasePaddingMixin:GetLeft()
	return self.left;
end

function ScrollBoxBasePaddingMixin:SetLeft(left)
	self.left = left;
end

function ScrollBoxBasePaddingMixin:GetRight()
	return self.right;
end

function ScrollBoxBasePaddingMixin:SetRight(right)
	self.right = right;
end

local ScrollBoxPaddingMixin = CreateFromMixins(ScrollBoxBasePaddingMixin);

function ScrollBoxPaddingMixin:Init(top, bottom, left, right, spacing)
	ScrollBoxBasePaddingMixin.Init(self, top, bottom, left, right);
	self:SetSpacing(spacing or 0);
end

function ScrollBoxPaddingMixin:GetSpacing()
	return self.spacing;
end

function ScrollBoxPaddingMixin:SetSpacing(spacing)
	self.spacing = spacing;
end

function CreateScrollBoxPadding(top, bottom, left, right, spacing)
	return CreateAndInitFromMixin(ScrollBoxPaddingMixin, top, bottom, left, right, spacing);
end

local ScrollBoxBiaxalPaddingMixin = CreateFromMixins(ScrollBoxBasePaddingMixin);

function ScrollBoxBiaxalPaddingMixin:Init(top, bottom, left, right, horizontalSpacing, verticalSpacing)
	ScrollBoxBasePaddingMixin.Init(self, top, bottom, left, right);
	self:SetHorizontalSpacing(horizontalSpacing or 0);
	self:SetVerticalSpacing(verticalSpacing or 0);
end

function ScrollBoxBiaxalPaddingMixin:GetHorizontalSpacing()
	return self.horizontalSpacing;
end

function ScrollBoxBiaxalPaddingMixin:SetHorizontalSpacing(spacing)
	self.horizontalSpacing = spacing;
end

function ScrollBoxBiaxalPaddingMixin:GetVerticalSpacing()
	return self.verticalSpacing;
end

function ScrollBoxBiaxalPaddingMixin:SetVerticalSpacing(spacing)
	self.verticalSpacing = spacing;
end

function CreateScrollBoxBiaxalPadding(top, bottom, left, right, horizontalSpacing, verticalSpacing)
	return CreateAndInitFromMixin(ScrollBoxBiaxalPaddingMixin, top, bottom, left, right, horizontalSpacing, verticalSpacing);
end