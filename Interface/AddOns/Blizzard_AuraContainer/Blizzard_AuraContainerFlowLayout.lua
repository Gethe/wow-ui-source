local AuraContainerFlowLayoutSharedMixin = {};

function AuraContainerFlowLayoutSharedMixin:GetFlowLayoutAxis()
	return self:GetFlowLayout():GetLayoutAxis();
end

function AuraContainerFlowLayoutSharedMixin:SetFlowLayoutAxis(layoutAxis)
	assert(EnumUtil.IsValid(AnchorUtil.FlowLayoutAxis, layoutAxis), "layoutAxis must be valid.");

	if self:GetFlowLayout():SetLayoutAxis(layoutAxis) then
		self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayout);
	end
end

function AuraContainerFlowLayoutSharedMixin:GetFlowLayoutAnchorPoint()
	return self:GetFlowLayout():GetAnchorPoint();
end

function AuraContainerFlowLayoutSharedMixin:SetFlowLayoutAnchorPoint(anchorPoint)
	assert(type(anchorPoint) == "string", "anchorPoint must be a string.");

	if self:GetFlowLayout():SetAnchorPoint(anchorPoint) then
		self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayout);
	end
end

function AuraContainerFlowLayoutSharedMixin:GetFlowLayoutGrowthDirection()
	return self:GetFlowLayout():GetGrowthDirection();
end

function AuraContainerFlowLayoutSharedMixin:SetFlowLayoutGrowthDirection(horizontalDirection, verticalDirection)
	assert(EnumUtil.IsValid(AnchorUtil.FlowDirection, horizontalDirection), "horizontalDirection must be valid.");
	assert(EnumUtil.IsValid(AnchorUtil.FlowDirection, verticalDirection), "verticalDirection must be valid.");

	if self:GetFlowLayout():SetGrowthDirection(horizontalDirection, verticalDirection) then
		self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayout);
	end
end

function AuraContainerFlowLayoutSharedMixin:GetFlowLayoutPadding()
	return self:GetFlowLayout():GetPadding();
end

function AuraContainerFlowLayoutSharedMixin:SetFlowLayoutPadding(left, right, top, bottom)
	assert(type(left) == "number", "left must be a number.");
	assert(type(right) == "number", "right must be a number.");
	assert(type(top) == "number", "top must be a number.");
	assert(type(bottom) == "number", "bottom must be a number.");

	if self:GetFlowLayout():SetPadding(left, right, top, bottom) then
		self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayout);
	end
end

function AuraContainerFlowLayoutSharedMixin:GetFlowLayoutMaximumLineSize()
	return self:GetFlowLayout():GetMaximumLineSize();
end

function AuraContainerFlowLayoutSharedMixin:SetFlowLayoutMaximumLineSize(maximumLineSize)
	assert(maximumLineSize == nil or type(maximumLineSize) == "number", "maximumLineSize must be a number or nil.");

	if self:GetFlowLayout():SetMaximumLineSize(maximumLineSize or math.huge) then
		self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayout);
	end
end

function AuraContainerFlowLayoutSharedMixin:ResetFlowLayoutOptions()
	self:GetFlowLayout():ResetOptions();
	self:ApplyFlowLayoutDefaults(self:GetFlowLayout());
	self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayout);
end

AuraContainerFlowLayoutInboundMixin = CreateFromMixins(AuraContainerFlowLayoutSharedMixin);
AuraContainerFlowLayoutPrivateMixin = CreateFromMixins(AuraContainerFlowLayoutSharedMixin);

function AuraContainerFlowLayoutPrivateMixin:ApplyFlowLayoutDefaults(_flowLayout)
	-- Override to apply any defaults after resetting flow layout options.
end

function AuraContainerFlowLayoutPrivateMixin:GetFlowLayout()
	-- Override to return the flow layout owned by the container.
	return self.flowLayout;
end

function AuraContainerFlowLayoutPrivateMixin:GetFlowLayoutGroups()
	-- Override to return the flow layout groups built by the container.
	return self.flowLayoutGroups;
end

function AuraContainerFlowLayoutPrivateMixin:ApplyFlowLayout()
	self:GetFlowLayout():Apply(self, self:GetFlowLayoutGroups());
end
