-- Points are cleared first to avoid some complications related to drag and drop.
local function SetHorizontalPoint(frame, offset, scrollTarget)
	frame:ClearAllPoints();
	frame:SetPoint("TOPLEFT", scrollTarget, "TOPLEFT", offset, 0);
	frame:SetPoint("BOTTOMLEFT", scrollTarget, "BOTTOMLEFT", offset, 0);
	return frame:GetWidth();
end

local function SetVerticalPoint(frame, offset, scrollTarget)
	frame:ClearAllPoints();
	frame:SetPoint("TOPLEFT", scrollTarget, "TOPLEFT", 0, -offset);
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

function ScrollBoxLinearBaseViewMixin:Layout()
	local frames = self:GetFrames();
	local frameCount = frames and #frames or 0;
	if frameCount == 0 then
		return 0;
	end

	local spacing = self:GetSpacing();
	local scrollTarget = self:GetScrollTarget();
	local setPoint = self:IsHorizontal() and SetHorizontalPoint or SetVerticalPoint;
	local frameLevelCounter = ScrollBoxViewUtil.CreateFrameLevelCounter(self:GetFrameLevelPolicy(), scrollTarget:GetFrameLevel(), frameCount);
	
	local total = 0;
	local offset = 0;
	for index, frame in ipairs(frames) do
		local extent = setPoint(frame, offset, scrollTarget);
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

ScrollBoxListLinearViewMixin = CreateFromMixins(ScrollBoxListViewMixin, ScrollBoxLinearBaseViewMixin);

function ScrollBoxListLinearViewMixin:Init(top, bottom, left, right, spacing)
	ScrollBoxListViewMixin.Init(self);
	self:SetPadding(top, bottom, left, right, spacing);
end

function ScrollBoxListLinearViewMixin:CalculateDataIndices(scrollBox)
	return ScrollBoxListViewMixin.CalculateDataIndices(self, scrollBox, self:GetStride(), self:GetSpacing());
end

function ScrollBoxListLinearViewMixin:GetExtent(recalculate, scrollBox)
	return ScrollBoxListViewMixin.GetExtent(self, recalculate, scrollBox, self:GetStride(), self:GetSpacing());
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
		local firstFrame = self:GetFrames()[1];
		if firstFrame then
			self.panExtent = self:GetFrameExtent(firstFrame) + self:GetSpacing();
		end
	end

	return self.panExtent or 0;
end

function ScrollBoxLinearViewMixin:GetExtent(recalculate, scrollBox)
	if recalculate or not self.extent then
		local extent = 0;
		
		local frames = self:GetFrames();
		for index, frame in ipairs(frames) do
			extent = extent + self:GetFrameExtent(frame);
		end

		local space = ScrollBoxViewUtil.CalculateSpacingUntil(#frames, self:GetStride(), self:GetSpacing());
		self.extent = extent + space + scrollBox:GetUpperPadding() + scrollBox:GetLowerPadding();
	end
	
	return self.extent;
end

function CreateScrollBoxLinearView(top, bottom, left, right, spacing)
	return CreateAndInitFromMixin(ScrollBoxLinearViewMixin, top or 0, bottom or 0, left or 0, right or 0, spacing or 0);
end
