
--------------------------------------------------------------------------------
-- BaseLayout Mixin
--------------------------------------------------------------------------------

local function IsLayoutFrame(frame)
	return frame.IsLayoutFrame and frame:IsLayoutFrame();
end

BaseLayoutMixin = {};

function BaseLayoutMixin:OnShow()
	if not self.skipLayoutOnShow then
		self:Layout();
	end
end

function BaseLayoutMixin:IsLayoutFrame()
	return true;
end

function BaseLayoutMixin:IgnoreLayoutIndex()
	return false;
end

function BaseLayoutMixin:MarkIgnoreInLayout(region, ...)
	if region then
		region.ignoreInLayout = true;
		self:MarkIgnoreInLayout(...);
	end
end

function BaseLayoutMixin:AddLayoutChildren(layoutChildren, ...)
	for i = 1, select("#", ...) do
		local region = select(i, ...);
		-- Individual regions can be ignored or every region can be ignored and require individual opt-in.
		local canInclude = (not region.ignoreInLayout) and (not self.ignoreAllChildren or region.includeInLayout);
		if region:IsShown() and canInclude and (self:IgnoreLayoutIndex() or region.layoutIndex) then
			layoutChildren[#layoutChildren + 1] = region;
		end
	end
end

function LayoutIndexComparator(left, right)
	if (left.layoutIndex == right.layoutIndex and left ~= right) then
		local leftName = (left.GetDebugName and left:GetDebugName()) or "unnamed";
		local rightName = (right.GetDebugName and right:GetDebugName()) or "unnamed";
		GMError(("Duplicate layoutIndex found: %d for %s and %s"):format(left.layoutIndex, leftName, rightName));
	end
	return left.layoutIndex < right.layoutIndex;
end

function BaseLayoutMixin:GetLayoutChildren()
	local children = {};
	self:AddLayoutChildren(children, self:GetChildren());
	self:AddLayoutChildren(children, self:GetRegions());
	self:AddLayoutChildren(children, self:GetAdditionalRegions());
	if not self:IgnoreLayoutIndex() then
		table.sort(children, LayoutIndexComparator);
	end

	return children;
end

function BaseLayoutMixin:GetAdditionalRegions()
	-- optional;
end

function BaseLayoutMixin:Layout()
	assert(false); -- Implement in derived class
end

function BaseLayoutMixin:OnUpdate()
	if self:IsDirty() then
		self:Layout();
	end
end

function BaseLayoutMixin:MarkDirty()
	self.dirty = true;

	-- To optimize performance, only set OnUpdate while marked dirty.
	self:SetScript("OnUpdate", self.OnUpdate);

	-- Tell any ancestors who may also be LayoutFrames that they should also become dirty
	local parent = self:GetParent();
	while parent do
		if IsLayoutFrame(parent) then
			parent:MarkDirty();
			return;
		end

		parent = parent:GetParent();
	end
end

function BaseLayoutMixin:MarkClean()
	self.dirty = false;
	self:OnCleaned();

	-- Clear OnUpdate once cleaned, unless it has been overridden in which case assume it needs to be called continuously.
	if self.OnUpdate == BaseLayoutMixin.OnUpdate then
		self:SetScript("OnUpdate", nil);
	end
end

function BaseLayoutMixin:IsDirty()
	return self.dirty;
end

function BaseLayoutMixin:OnCleaned()
	-- implement in derived if you want
end

function BaseLayoutMixin:SetFixedWidth(width)
	self.fixedWidth = width;
end

function BaseLayoutMixin:SetFixedHeight(height)
	self.fixedHeight = height;
end

function BaseLayoutMixin:SetFixedSize(width, height)
	self:SetFixedWidth(width);
	self:SetFixedHeight(height);
end

function BaseLayoutMixin:ClearFixedSize()
	self:SetFixedWidth(nil);
	self:SetFixedHeight(nil);
end

function BaseLayoutMixin:GetFixedWidth()
	return self.fixedWidth;
end

function BaseLayoutMixin:GetFixedHeight()
	return self.fixedHeight;
end

function BaseLayoutMixin:GetFixedSize()
	return self.fixedWidth, self.fixedHeight;
end

function BaseLayoutMixin:SetHeightPadding(padding)
	self.heightPadding = padding;
end

function BaseLayoutMixin:GetHeightPadding()
	return self.heightPadding or 0;
end

function BaseLayoutMixin:GetWidthPadding()
	return self.widthPadding or 0;
end

--------------------------------------------------------------------------------
-- Layout Mixin
--------------------------------------------------------------------------------

LayoutMixin = CreateFromMixins(BaseLayoutMixin);

function LayoutMixin:GetPadding()
	return (self.leftPadding or 0),
		   (self.rightPadding or 0),
		   (self.topPadding or 0),
		   (self.bottomPadding or 0);
end

-- If child is a layoutFrame that doesn't ignoreLayoutIndex (i.e. child is a vertical or horizontal layout frame) then we need to ignore the padding set on it
-- If we don't ignore padding here we will be applying that padding twice (once here when we lay out the child and then again when Layout is called on the child itself)
function LayoutMixin:GetChildPadding(child)
	if IsLayoutFrame(child) and not child:IgnoreLayoutIndex() then
		return 0, 0, 0, 0;
	else
		return (child.leftPadding or 0),
			   (child.rightPadding or 0),
			   (child.topPadding or 0),
			   (child.bottomPadding or 0);
	end
end

local function GetSize(desired, fixed, minimum, maximum)
	return fixed or Clamp(desired, minimum or desired, maximum or desired);
end

local function GetSizeHelper(expand, fixedSize, childSize)
	if expand and fixedSize and childSize > fixedSize then
		return childSize;
	else
		return fixedSize or childSize;
	end
end

function LayoutMixin:CalculateFrameSize(childrenWidth, childrenHeight)
	local leftPadding, rightPadding, topPadding, bottomPadding = self:GetPadding();

	childrenWidth = childrenWidth + leftPadding + rightPadding;
	childrenHeight = childrenHeight + topPadding + bottomPadding;

	-- Expand this frame if the "expand" keyvalue is set and children width or height is larger.
	-- Otherwise, set this frame size to the fixed size if set, or the size of the children
	local frameWidth = GetSizeHelper(self.expand, self:GetFixedWidth(), childrenWidth);
	local frameHeight = GetSizeHelper(self.expand, self:GetFixedHeight(), childrenHeight);
	return GetSize(frameWidth, nil, self.minimumWidth, self.maximumWidth), GetSize(frameHeight, nil, self.minimumHeight, self.maximumHeight);
end

function LayoutMixin:Layout()
	local children = self:GetLayoutChildren();
	local childrenWidth, childrenHeight, hasExpandableChild = self:LayoutChildren(children);

	local frameWidth, frameHeight = self:CalculateFrameSize(childrenWidth, childrenHeight);

	-- If at least one child had "expand" set and we did not already expand them, call LayoutChildren() again to expand them
	if (hasExpandableChild) then
		childrenWidth, childrenHeight = self:LayoutChildren(children, frameWidth, frameHeight);
		frameWidth, frameHeight = self:CalculateFrameSize(childrenWidth, childrenHeight);
	end

	self:SetSize(frameWidth, frameHeight);
	self:MarkClean();
end

--------------------------------------------------------------------------------
-- VerticalLayout Mixin
--------------------------------------------------------------------------------

VerticalLayoutMixin = {};

function VerticalLayoutMixin:LayoutChildren(children, expandToWidth)
	local frameLeftPadding, frameRightPadding, topOffset, bottomOffset = self:GetPadding();
	local spacing = self.spacing or 0;
	local childrenWidth, childrenHeight = 0, 0;
	local hasExpandableChild = false;

	-- Calculate width and height based on children
	for i, child in ipairs(children) do
		if IsLayoutFrame(child) then
			child:Layout();
		end

		local childScale = child:GetScale();

		local childWidth, childHeight = child:GetSize();
		if self.respectChildScale then
			childWidth = childWidth * childScale;
			childHeight = childHeight * childScale;
		end

		local leftPadding, rightPadding, topPadding, bottomPadding = self:GetChildPadding(child);

		-- Expand child width if it is set to expand and we also have an expandToWidth value.
		if child.expand then
			hasExpandableChild = true;

			if expandToWidth then
				childWidth = expandToWidth - leftPadding - rightPadding - frameLeftPadding - frameRightPadding;
				child:SetWidth(childWidth);
			end
		end

		childrenWidth = math.max(childrenWidth, childWidth + leftPadding + rightPadding);
		childrenHeight = childrenHeight + childHeight + topPadding + bottomPadding;
		if (i > 1) then
			childrenHeight = childrenHeight + spacing;
		end

		-- Set child position
		child:ClearAllPoints();
		if self.childLayoutDirection == "bottomToTop" then
			bottomOffset = bottomOffset + bottomPadding;
			bottomOffset = self.respectChildScale and bottomOffset / childScale or bottomOffset;
			if (child.align == "right") then
				local rightOffset = frameRightPadding + rightPadding;
				rightOffset = self.respectChildScale and rightOffset / childScale or rightOffset;
				child:SetPoint("BOTTOMRIGHT", -rightOffset, bottomOffset);
			elseif (child.align == "center") then
				local leftOffset = (frameLeftPadding - frameRightPadding + leftPadding - rightPadding) / 2;
				leftOffset = self.respectChildScale and leftOffset / childScale or leftOffset;
				child:SetPoint("BOTTOM", leftOffset, bottomOffset);
			else
				local leftOffset = frameLeftPadding + leftPadding;
				leftOffset = self.respectChildScale and leftOffset / childScale or leftOffset;
				child:SetPoint("BOTTOMLEFT", leftOffset, bottomOffset);
			end
			-- If you adjusted the offset due to respecting child scale then undo that adjustment since the next frame may have a different scale
			bottomOffset = self.respectChildScale and bottomOffset * childScale or bottomOffset;

			-- Determine bottomOffset for next frame
			bottomOffset = bottomOffset + childHeight + topPadding + spacing;
		else
			topOffset = topOffset + topPadding;
			topOffset = self.respectChildScale and topOffset / childScale or topOffset;
			if (child.align == "right") then
				local rightOffset = frameRightPadding + rightPadding;
				rightOffset = self.respectChildScale and rightOffset / childScale or rightOffset;
				child:SetPoint("TOPRIGHT", -rightOffset, -topOffset);
			elseif (child.align == "center") then
				local leftOffset = (frameLeftPadding - frameRightPadding + leftPadding - rightPadding) / 2;
				leftOffset = self.respectChildScale and leftOffset / childScale or leftOffset;
				child:SetPoint("TOP", leftOffset, -topOffset);
			else
				local leftOffset = frameLeftPadding + leftPadding;
				leftOffset = self.respectChildScale and leftOffset / childScale or leftOffset;
				child:SetPoint("TOPLEFT", leftOffset, -topOffset);
			end
			-- If you adjusted the offset due to respecting child scale then undo that adjustment since the next frame may have a different scale
			topOffset = self.respectChildScale and topOffset * childScale or topOffset;

			-- Determine topOffset for next frame
			topOffset = topOffset + childHeight + bottomPadding + spacing;
		end
	end

	return childrenWidth, childrenHeight, hasExpandableChild;
end

--------------------------------------------------------------------------------
-- HorizontalLayout Mixin
--------------------------------------------------------------------------------

HorizontalLayoutMixin = {};

function HorizontalLayoutMixin:LayoutChildren(children, ignored, expandToHeight)
	local leftOffset, rightOffset, frameTopPadding, frameBottomPadding = self:GetPadding();
	local spacing = self.spacing or 0;
	local childrenWidth, childrenHeight = 0, 0;
	local hasExpandableChild = false;

	-- Calculate width and height based on children
	for i, child in ipairs(children) do
		if IsLayoutFrame(child) then
			child:Layout();
		end

		local childWidth, childHeight = child:GetSize();
		local leftPadding, rightPadding, topPadding, bottomPadding = self:GetChildPadding(child);
		if (child.expand) then
			hasExpandableChild = true;
		end

		-- Expand child height if it is set to expand and we also have an expandToHeight value.
		if (child.expand and expandToHeight) then
			childHeight = expandToHeight - topPadding - bottomPadding - frameTopPadding - frameBottomPadding;
			child:SetHeight(childHeight);
			childWidth = child:GetWidth();
		end

		if self.respectChildScale then
			local childScale = child:GetScale();
			childWidth = childWidth * childScale;
			childHeight = childHeight * childScale;
		end

		childrenHeight = math.max(childrenHeight, childHeight + topPadding + bottomPadding);
		childrenWidth = childrenWidth + childWidth + leftPadding + rightPadding;
		if (i > 1) then
			childrenWidth = childrenWidth + spacing;
		end

		-- Set child position
		child:ClearAllPoints();

		if self.childLayoutDirection == "rightToLeft" then
			rightOffset = rightOffset + rightPadding;
			if (child.align == "bottom") then
				local bottomOffset = frameBottomPadding + bottomPadding;
				child:SetPoint("BOTTOMRIGH", -rightOffset, bottomOffset);
			elseif (child.align == "center") then
				local topOffset = (frameTopPadding - frameBottomPadding + topPadding - bottomPadding) / 2;
				child:SetPoint("RIGHT", -rightOffset, -topOffset);
			else
				local topOffset = frameTopPadding + topPadding;
				child:SetPoint("TOPRIGHT", -rightOffset, -topOffset);
			end
			rightOffset = rightOffset + childWidth + leftPadding + spacing;
		else
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
	end

	return childrenWidth, childrenHeight, hasExpandableChild;
end

--------------------------------------------------------------------------------
-- ResizeLayout Mixin
--------------------------------------------------------------------------------

ResizeLayoutMixin = CreateFromMixins(BaseLayoutMixin);

local function GetExtents(childFrame, left, right, top, bottom, layoutFrameScale)
	local frameLeft, frameBottom, frameWidth, frameHeight, defaulted = GetUnscaledFrameRect(childFrame, layoutFrameScale);
	local frameRight = frameLeft + frameWidth;
	local frameTop = frameBottom + frameHeight;

	left = left and math.min(frameLeft, left) or frameLeft;
	right = right and math.max(frameRight, right) or frameRight;
	top = top and math.max(frameTop, top) or frameTop;
	bottom = bottom and math.min(frameBottom, bottom) or frameBottom;

	return left, right, top, bottom, defaulted;
end

function ResizeLayoutMixin:IgnoreLayoutIndex()
	return true;
end

function ResizeLayoutMixin:SetWidthPadding(widthPadding)
	self.widthPadding = widthPadding;
end

function ResizeLayoutMixin:SetHeightPadding(heightPadding)
	self.heightPadding = heightPadding;
end

function ResizeLayoutMixin:SetMinimumWidth(minimumWidth)
	self.minimumWidth = minimumWidth;
end

function ResizeLayoutMixin:SetMaximumWidth(maximumWidth)
	self.maximumWidth = maximumWidth;
end

function ResizeLayoutMixin:Layout()
	-- GetExtents will fail if the LayoutFrame has 0 width or height, so set them to 1 to start
	self:SetSize(1, 1);

	-- GetExtents will also fail if the LayoutFrame has no anchors set, so if that is the case, set an anchor and then clear it after we are done
	local hadNoAnchors = (self:GetNumPoints() == 0);
	if hadNoAnchors then
		self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0);
	end

	local left, right, top, bottom, defaulted;
	local layoutFrameScale = self:GetEffectiveScale();
	for childIndex, child in ipairs(self:GetLayoutChildren()) do
		-- skipChildLayout is to prevent menus from calling Layout on children
		-- that have potentially had their extents overwritten by the menu. Their
		-- extents have already been accounted for.
		if not self.skipChildLayout and IsLayoutFrame(child) then
			child:Layout();
		end

		local l, r, t, b, d = GetExtents(child, left, right, top, bottom, layoutFrameScale);
		left, right, top, bottom = l, r, t, b;
		defaulted = defaulted or d;
	end

	local fw, fh = self:GetFixedSize();
	if fw and fh then
		self:SetSize(fw, fh);
	elseif left and right and top and bottom then
		local minw = self.minimumWidth;
		local maxw = self.maximumWidth;
		local width = GetSize((right - left) + self:GetWidthPadding(), fw, self.minimumWidth, self.maximumWidth);
		local height = GetSize((top - bottom) + self:GetHeightPadding(), fh, self.minimumHeight, self.maximumHeight);

		self:SetSize(width, height);
	end

	if hadNoAnchors then
		self:ClearAllPoints();
	end

	self:MarkClean();
end

--------------------------------------------------------------------------------
-- GridLayoutFrameMixin
--------------------------------------------------------------------------------

GridLayoutFrameMixin = {}

function GridLayoutFrameMixin:Layout()
	local layoutChildren = self:GetLayoutChildren();
	if not self:ShouldUpdateLayout(layoutChildren) then
		return;
	end

	-- Multipliers determine the direction the layout grows for grid layouts
	-- Positive means right/up
	-- Negative means left/down
	local xMultiplier = self.layoutFramesGoingRight and 1 or -1;
	local yMultiplier = self.layoutFramesGoingUp and 1 or -1;

	-- Create the grid layout according to whether we are horizontal or vertical
	local layout;
	if self.isHorizontal then
		layout = GridLayoutUtil.CreateStandardGridLayout(self.stride, self.childXPadding, self.childYPadding, xMultiplier, yMultiplier);
	else
		layout = GridLayoutUtil.CreateVerticalGridLayout(self.stride, self.childXPadding, self.childYPadding, xMultiplier, yMultiplier);
	end

	-- Need to change where the frames anchor based on how the layout grows
	local anchorPoint;
	if self.layoutFramesGoingUp then
		anchorPoint = self.layoutFramesGoingRight and "BOTTOMLEFT" or "BOTTOMRIGHT";
	else
		anchorPoint = self.layoutFramesGoingRight and "TOPLEFT" or "TOPRIGHT";
	end

	-- Apply the layout and then update our size
	GridLayoutUtil.ApplyGridLayout(layoutChildren, AnchorUtil.CreateAnchor(anchorPoint, self, anchorPoint), layout);
	ResizeLayoutMixin.Layout(self);
	self:CacheLayoutSettings(layoutChildren);
end

function GridLayoutFrameMixin:CacheLayoutSettings(layoutChildren)
    self.oldGridSettings = {
		layoutChildren = layoutChildren;
        childXPadding = self.childXPadding;
		childYPadding = self.childYPadding;
		isHorizontal = self.isHorizontal;
		stride = self.stride;
		layoutFramesGoingRight = self.layoutFramesGoingRight;
		layoutFramesGoingUp = self.layoutFramesGoingUp;
    };
end

function GridLayoutFrameMixin:ShouldUpdateLayout(layoutChildren)
    if not self:IsShown() then
        return false;
    end

	if self.alwaysUpdateLayout then
		return true;
	end

    if self.oldGridSettings == nil then
        return true;
    end

    if #self.oldGridSettings.layoutChildren ~= #layoutChildren
	or self.oldGridSettings.childXPadding ~= self.childXPadding
	or self.oldGridSettings.childYPadding ~= self.childYPadding
    or self.oldGridSettings.isHorizontal ~= self.isHorizontal
    or self.oldGridSettings.stride ~= self.stride
    or self.oldGridSettings.layoutFramesGoingRight ~= self.layoutFramesGoingRight
    or self.oldGridSettings.layoutFramesGoingUp ~= self.layoutFramesGoingUp then
        return true;
    end

    for index, child in ipairs(layoutChildren) do
        if self.oldGridSettings.layoutChildren[index] ~= child then
            return true;
        end
    end

    return false;
end

function GridLayoutFrameMixin:IgnoreLayoutIndex()
	return false;
end

--------------------------------------------------------------------------------
-- StaticGridLayoutFrameMixin
--------------------------------------------------------------------------------

-- Unlike GridLayoutFrame, which dynamically places child frames into grid columns and rows based on flow direction sand other settings,
-- StaticGridLayoutFrame expects all child frames to have their assigned grid column and row pre-calculated and simply positions them there,
-- calculating column and row sizes based on the sizes of the child frames.
StaticGridLayoutFrameMixin = CreateFromMixins(BaseLayoutMixin);

function StaticGridLayoutFrameMixin:Layout()
	local layoutChildren = self:GetLayoutChildren();

	local maxWidthByColumn, maxHeightByRow = {}, {};
	local maxColumn, maxRow = 0, 0;

	local childXPadding = self.childXPadding or 0;
	local childYPadding = self.childYPadding or 0;

	-- Iterate through frames and determine overall widths and heights to use for each column and row 
	-- based on the widest/tallest frame in each respective column and row
	for childIndex, childFrame in ipairs(layoutChildren) do
		if IsLayoutFrame(childFrame) then
			childFrame:Layout();
		end

		local column, row = childFrame.gridColumn, childFrame.gridRow;
		if column and row then
			local columnSize = childFrame.gridColumnSize or 1;
			local rowSize = childFrame.gridRowSize or 1;

			local endColumn = column + (columnSize - 1);
			local endRow = row + (rowSize - 1);

			maxColumn = math.max(maxColumn, endColumn);
			maxRow = math.max(maxRow, endRow);

			local widthPerColumn, heightPerRow = childFrame:GetSize();

			-- If a frame spans more than one column/row, consider its size as spread evenly across those cells
			if columnSize > 1 then
				-- Since columns/rows will already be separated by padding, ensure those are removed from the calculation so they aren't factored in twice
				-- Ex: If a frame spans 2 columns, then it also spans over the 1 set of x padding between them, which shouldn't also get factored into column A's or B's widths
				local encompassedXPadding = childXPadding * (columnSize - 1);
				widthPerColumn = (widthPerColumn / columnSize) - encompassedXPadding;
			end
			if rowSize > 1 then
				local encompassedYPadding = (childYPadding * (rowSize - 1));
				heightPerRow = (heightPerRow / rowSize) - encompassedYPadding;
			end

			-- For each column this frame spans, conditionally set that column's width to use the frame's calculated per-column width
			for i = column, endColumn do
				if not maxWidthByColumn[i] or widthPerColumn > maxWidthByColumn[i] then
					maxWidthByColumn[i] = widthPerColumn;
				end
			end

			-- For each row this frame spans, conditionally set that column's height to use the frame's calculated per-row height
			for i = row, endRow do
				if not maxHeightByRow[i] or heightPerRow > maxHeightByRow[i] then
					maxHeightByRow[i] = heightPerRow;
				end
			end
		end
	end

	-- Calculate what each column's anchor offset will need to be based on widths of columns before them
	local xOffsetByColumn = {};
	local totalXOffset = 0;
	for i = 1, maxColumn do
		local previousColumnWidth = maxWidthByColumn[i-1] or 0;
		totalXOffset = totalXOffset + previousColumnWidth;
		xOffsetByColumn[i] = totalXOffset;
	end

	-- Calculate what each row's anchor offset will need to be based on heights of columns above them
	local yOffsetByRow = {};
	local totalYOffset = 0;
	for i = 1, maxRow do
		local previousRowHeight = maxHeightByRow[i-1] or 0;
		totalYOffset = totalYOffset + previousRowHeight;
		yOffsetByRow[i] = totalYOffset;
	end

	-- Finally position all frames based on their assigned positions and calculated column/row offsets
	for childIndex, childFrame in ipairs(layoutChildren) do
		if childFrame.gridColumn and childFrame.gridRow then
			childFrame:ClearAllPoints();

			local x = xOffsetByColumn[childFrame.gridColumn];
			local y = -yOffsetByRow[childFrame.gridRow];
			if childFrame.gridColumn > 1 then
				x = x + (childXPadding * (childFrame.gridColumn - 1));
			end
			if childFrame.gridRow > 1 then
				y = y - (childYPadding * (childFrame.gridRow - 1));
			end
			childFrame:SetPoint("TOPLEFT", self, "TOPLEFT", x, y);
		end
	end

	self:MarkClean();
end

function StaticGridLayoutFrameMixin:IgnoreLayoutIndex()
	return true;
end