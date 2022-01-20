-- Points are cleared first to avoid some complications related to drag and drop.
local function SetHorizontalPoint(frame, offset, indent, scrollTarget)
	frame:ClearAllPoints();
	frame:SetPoint("TOPLEFT", scrollTarget, "TOPLEFT", offset, indent);
	frame:SetPoint("BOTTOMLEFT", scrollTarget, "BOTTOMLEFT", offset, 0);
	return frame:GetWidth();
end

local function SetVerticalPoint(frame, offset, indent, scrollTarget)
	frame:ClearAllPoints();
	frame:SetPoint("TOPLEFT", scrollTarget, "TOPLEFT", indent, -offset);
	frame:SetPoint("TOPRIGHT", scrollTarget, "TOPRIGHT", 0, -offset);
	return frame:GetHeight();
end

ScrollBoxLinearPaddingMixin = CreateFromMixins(ScrollBoxPaddingMixin);

function ScrollBoxLinearPaddingMixin:Init(top, bottom, left, right, spacing)
	ScrollBoxPaddingMixin.Init(self, top, bottom, left, right);
	self:SetSpacing(spacing or 0);
end

function ScrollBoxLinearPaddingMixin:GetSpacing()
	return self.spacing;
end

function ScrollBoxLinearPaddingMixin:SetSpacing(spacing)
	self.spacing = spacing;
end

function CreateScrollBoxLinearPadding(top, bottom, left, right, spacing)
	return CreateAndInitFromMixin(ScrollBoxLinearPaddingMixin, top, bottom, left, right, spacing);
end

ScrollBoxLinearBaseViewMixin = CreateFromMixins(ScrollBoxViewMixin);

function ScrollBoxLinearBaseViewMixin:SetPadding(top, bottom, left, right, spacing)
	local padding = CreateScrollBoxLinearPadding(top, bottom, left, right, spacing);
	ScrollBoxViewMixin.SetPadding(self, padding);
end

function ScrollBoxLinearBaseViewMixin:GetSpacing()
	return self.padding:GetSpacing();
end

function ScrollBoxLinearBaseViewMixin:GetStride()
	return 1;
end

local function CreateFrameLevelCounter(frameLevelPolicy, referenceFrameLevel, range)
	if frameLevelPolicy == ScrollBoxViewMixin.FrameLevelPolicy.Ascending then
		local frameLevel = referenceFrameLevel + 1;
		return function()
			frameLevel = frameLevel + 1;
			return frameLevel;
		end
	elseif frameLevelPolicy == ScrollBoxViewMixin.FrameLevelPolicy.Descending then
		local frameLevel = referenceFrameLevel + 1 + range;
		return function()
			frameLevel = frameLevel - 1;
			return frameLevel;
		end
	end
	return nil;
end

function ScrollBoxLinearBaseViewMixin:LayoutInternal(anchorFunction)
	local frames = self:GetFrames();
	local frameCount = frames and #frames or 0;
	if frameCount == 0 then
		return 0;
	end

	local spacing = self:GetSpacing();
	local scrollTarget = self:GetScrollTarget();
	local frameLevelCounter = CreateFrameLevelCounter(self:GetFrameLevelPolicy(), scrollTarget:GetFrameLevel(), frameCount);
	
	local total = 0;
	local offset = 0;
	for index, frame in ipairs(frames) do
		local extent = anchorFunction(index, frame, offset, scrollTarget);
		offset = offset + extent + spacing;
		total = total + extent;

		if frameLevelCounter then
			frame:SetFrameLevel(frameLevelCounter());
		end
	end

	local spacingTotal = math.max(0, frameCount - 1) * spacing;
	local extentTotal = total + spacingTotal;
	return extentTotal;
end

function ScrollBoxLinearBaseViewMixin:Layout()
	local setPoint = self:IsHorizontal() and SetHorizontalPoint or SetVerticalPoint;
	local function AnchorFrame(index, frame, offset, scrollTarget)
		return setPoint(frame, offset, 0, scrollTarget);
	end
	return self:LayoutInternal(AnchorFrame);
end

ScrollBoxListLinearViewMixin = CreateFromMixins(ScrollBoxListViewMixin, ScrollBoxLinearBaseViewMixin);

function ScrollBoxListLinearViewMixin:Init(top, bottom, left, right, spacing)
	ScrollBoxListViewMixin.Init(self);
	self:SetPadding(top, bottom, left, right, spacing);
end

function ScrollBoxListLinearViewMixin:CalculateDataIndices(scrollBox)
	return ScrollBoxListViewMixin.CalculateDataIndices(self, scrollBox, self:GetStride(), self:GetSpacing());
end

function ScrollBoxListLinearViewMixin:GetExtent(scrollBox)
	return ScrollBoxListViewMixin.GetExtent(self, scrollBox, self:GetStride(), self:GetSpacing());
end

function ScrollBoxListLinearViewMixin:RecalculateExtent(scrollBox)
	return ScrollBoxListViewMixin.RecalculateExtent(self, scrollBox, self:GetStride(), self:GetSpacing());
end

function ScrollBoxListLinearViewMixin:GetExtentUntil(scrollBox, dataIndex)
	return ScrollBoxListViewMixin.GetExtentUntil(self, scrollBox, dataIndex, self:GetStride(), self:GetSpacing());
end

function ScrollBoxListLinearViewMixin:GetPanExtent()
	return ScrollBoxListViewMixin.GetPanExtent(self, self:GetSpacing());
end

function CreateScrollBoxListLinearView(top, bottom, left, right, spacing)
	return CreateAndInitFromMixin(ScrollBoxListLinearViewMixin, top or 0, bottom or 0, left or 0, right or 0, spacing or 0);
end

ScrollBoxListTreeListViewMixin = CreateFromMixins(ScrollBoxListLinearViewMixin);

function ScrollBoxListTreeListViewMixin:Init(indent, top, bottom, left, right, spacing)
	ScrollBoxListLinearViewMixin.Init(self, top, bottom, left, right, spacing);
	self:SetElementIndent(indent);
end

function ScrollBoxListTreeListViewMixin:EnumerateDataProvider(indexBegin, indexEnd)
	return self:GetDataProvider():EnumerateUncollapsed(indexBegin, indexEnd);
end

function ScrollBoxListTreeListViewMixin:SetElementIndent(indent)
	self.indent = indent;
end

function ScrollBoxListTreeListViewMixin:GetElementIndent()
	return self.indent;
end

function ScrollBoxListTreeListViewMixin:Layout()
	local setPoint = self:IsHorizontal() and SetHorizontalPoint or SetVerticalPoint;
	local elementIndent = self:GetElementIndent();
	local function AnchorFrame(index, frame, offset, scrollTarget)
		local elementData = frame:GetElementData();
		local indent = (elementData:GetDepth() - 1) * elementIndent;
		return setPoint(frame, offset, indent, scrollTarget);
	end
	return self:LayoutInternal(AnchorFrame);
end

function CreateScrollBoxListTreeListView(indent, top, bottom, left, right, spacing)
	return CreateAndInitFromMixin(ScrollBoxListTreeListViewMixin, indent or 10, top or 0, bottom or 0, left or 0, right or 0, spacing or 0);
end

ScrollBoxLinearViewMixin = CreateFromMixins(ScrollBoxLinearBaseViewMixin);

function ScrollBoxLinearViewMixin:Init(top, bottom, left, right, spacing)
	ScrollBoxViewMixin.Init(self);
	self:SetPadding(top, bottom, left, right, spacing);
end

function ScrollBoxLinearViewMixin:ReparentScrollChildren(...)
	local scrollTarget = self:GetScrollTarget();
	for index = 1, select("#", ...) do
		local child = select(index, ...);
		if child.scrollable then
			child:SetParent(scrollTarget);
			table.insert(self.frames, child);
		end
	end
end

function ScrollBoxLinearViewMixin:GetPanExtent()
	if not self.panExtent then
		local frames = self:GetFrames();
		local firstFrame = frames[1];
		if firstFrame then
			self.panExtent = self:GetFrameExtent(firstFrame) + self:GetSpacing();
		end
	end

	return self.panExtent or 0;
end

function ScrollBoxLinearViewMixin:RequiresFullUpdateOnScrollTargetSizeChange()
	return true;
end

function ScrollBoxLinearViewMixin:RecalculateExtent(scrollBox)
	local extent = 0;
	
	local frames = self:GetFrames();
	for index, frame in ipairs(frames) do
		extent = extent + self:GetFrameExtent(frame);
	end

	local space = ScrollBoxViewUtil.CalculateSpacingUntil(#frames, self:GetStride(), self:GetSpacing());
	self:SetExtent(extent + space + scrollBox:GetUpperPadding() + scrollBox:GetLowerPadding());
end

function ScrollBoxLinearViewMixin:GetExtent(scrollBox)
	if not self:IsExtentValid() then
		self:RecalculateExtent(scrollBox);
	end
	return self.extent;
end

function CreateScrollBoxLinearView(top, bottom, left, right, spacing)
	return CreateAndInitFromMixin(ScrollBoxLinearViewMixin, top or 0, bottom or 0, left or 0, right or 0, spacing or 0);
end
