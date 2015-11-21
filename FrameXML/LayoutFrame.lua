LayoutMixin = {};
VerticalLayoutMixin = {};
HorizontalLayoutMixin = {};

--------------------------------------------------------------------------------
-- Layout Mixin
--------------------------------------------------------------------------------

function LayoutMixin:GetPadding(frame)
	if (frame) then
		return (frame.leftPadding or 0),
			   (frame.rightPadding or 0),
			   (frame.topPadding or 0),
			   (frame.bottomPadding or 0);
	end
end

function LayoutMixin:GetSortedLayoutChildren(frames, regions)
	local layoutChildren = {};
	
	for i = 1, #frames do
		if (frames[i].layoutIndex and frames[i]:IsVisible()) then
			table.insert(layoutChildren, frames[i]);
		end
	end
	for i = 1, #regions do
		if (regions[i].layoutIndex and regions[i]:IsVisible()) then
			table.insert(layoutChildren, regions[i]);
		end
	end
	
	table.sort(layoutChildren, 
		function(left, right)
			if (left.layoutIndex == right.layoutIndex and left ~= right) then
				GMError("Duplicate layoutIndex found: " .. left.layoutIndex);
			end
			return left.layoutIndex < right.layoutIndex;
		end);
	
	return layoutChildren;
end

function LayoutMixin:CalculateFrameSize(childrenWidth, childrenHeight)
	local frameWidth, frameHeight;
	local leftPadding, rightPadding, topPadding, bottomPadding = self:GetPadding(self);
	
	childrenWidth = childrenWidth + leftPadding + rightPadding;
	childrenHeight = childrenHeight + topPadding + bottomPadding;
	
	-- Expand this frame if the "expand" keyvalue is set and children width or height is larger.
	-- Otherwise, set this frame size to the fixed size if set, or the size of the children
	if (self.expand and self.fixedWidth and childrenWidth > self.fixedWidth) then
		frameWidth = childrenWidth;
	else
		frameWidth = self.fixedWidth or childrenWidth;
	end
	if (self.expand and self.fixedHeight and childrenHeight > self.fixedHeight) then
		frameHeight = childrenHeight;
	else
		frameHeight = self.fixedHeight or childrenHeight;
	end
	return frameWidth, frameHeight;
end

function LayoutMixin:Layout()
	local leftPadding, rightPadding, topPadding, bottomPadding = self:GetPadding(self);
	
	local children = self:GetSortedLayoutChildren({self:GetChildren()}, {self:GetRegions()});
	local childrenWidth, childrenHeight, hasExpandableChild = self:LayoutChildren(children);
	
	local frameWidth, frameHeight = self:CalculateFrameSize(childrenWidth, childrenHeight);

	-- If at least one child had "expand" set and we did not already expand them, call LayoutChildren() again to expand them
	if (hasExpandableChild) then
		childrenWidth, childrenHeight = self:LayoutChildren(children, frameWidth, frameHeight);
		frameWidth, frameHeight = self:CalculateFrameSize(childrenWidth, childrenHeight);
	end
	
	self:SetSize(frameWidth, frameHeight);
end

--------------------------------------------------------------------------------
-- VerticalLayout Mixin
--------------------------------------------------------------------------------

function VerticalLayoutMixin:LayoutChildren(children, expandToWidth)
	local frameLeftPadding, frameRightPadding, topOffset = self:GetPadding(self);
	local spacing = self.spacing or 0;
	local childrenWidth, childrenHeight = 0, 0;
	local hasExpandableChild = false;
	
	-- Calculate width and height based on children
	for i = 1, #children do
		local child = children[i];
		local childWidth, childHeight = child:GetSize();
		local leftPadding, rightPadding, topPadding, bottomPadding = self:GetPadding(child);
		if (child.expand) then
			hasExpandableChild = true;
		end

		-- Expand child width if it is set to expand and we also have an expandToWidth value.
		if (child.expand and expandToWidth) then
			childWidth = expandToWidth - leftPadding - rightPadding - frameLeftPadding - frameRightPadding;
			child:SetWidth(childWidth);
			childHeight = child:GetHeight();
		end
		childrenWidth = math.max(childrenWidth, childWidth + leftPadding + rightPadding);
		childrenHeight = childrenHeight + childHeight + topPadding + bottomPadding;
		if (i > 1) then
			childrenHeight = childrenHeight + spacing;
		end
		
		-- Set child position
		child:ClearAllPoints();
		topOffset = topOffset + topPadding;
		if (child.align == "right") then
			local rightOffset = frameRightPadding + rightPadding;
			child:SetPoint("TOPRIGHT", -rightOffset, -topOffset);
		elseif (child.align == "center") then
			local leftOffset = (frameLeftPadding - frameRightPadding + leftPadding - rightPadding) / 2;
			child:SetPoint("TOP", leftOffset, -topOffset);
		else
			local leftOffset = frameLeftPadding + leftPadding;
			child:SetPoint("TOPLEFT", leftOffset, -topOffset);
		end
		topOffset = topOffset + childHeight + bottomPadding + spacing;
	end
	
	return childrenWidth, childrenHeight, hasExpandableChild;
end

--------------------------------------------------------------------------------
-- HorizontalLayout Mixin
--------------------------------------------------------------------------------

function HorizontalLayoutMixin:LayoutChildren(children, ignored, expandToHeight)
	local leftOffset, _, frameTopPadding, frameBottomPadding = self:GetPadding(self);
	local spacing = self.spacing or 0;
	local childrenWidth, childrenHeight = 0, 0;
	local hasExpandableChild = false;
	
	-- Calculate width and height based on children
	for i = 1, #children do
		local child = children[i];
		local childWidth, childHeight = child:GetSize();
		local leftPadding, rightPadding, topPadding, bottomPadding = self:GetPadding(child);
		if (child.expand) then
			hasExpandableChild = true;
		end
		
		-- Expand child height if it is set to expand and we also have an expandToHeight value.
		if (child.expand and expandToHeight) then
			childHeight = expandToHeight - topPadding - bottomPadding - frameTopPadding - frameBottomPadding;
			child:SetHeight(childHeight);
			childWidth = child:GetWidth();
		end
		childrenHeight = math.max(childrenHeight, childHeight + topPadding + bottomPadding);
		childrenWidth = childrenWidth + childWidth + leftPadding + rightPadding;
		if (i > 1) then
			childrenWidth = childrenWidth + spacing;
		end
		
		-- Set child position
		child:ClearAllPoints();
		leftOffset = leftOffset + leftPadding;
		if (child.align == "bottom") then
			local bottomOffset = frameBottomPadding + bottomPadding;
			child:SetPoint("BOTTOMLEFT", leftOffset, bottomOffset);
		elseif (child.align == "center") then
			local topOffset = (frameTopPadding - frameBottomPadding + topPadding - bottomPadding) / 2;
			child:SetPoint("LEFT", leftOffset, -topOffset);
		else
			local topOffset = frameTopPadding + topPadding;
			child:SetPoint("TOPLEFT", leftOffset, -topOffset);
		end
		leftOffset = leftOffset + childWidth + rightPadding + spacing;
	end
	
	return childrenWidth, childrenHeight, hasExpandableChild;
end
