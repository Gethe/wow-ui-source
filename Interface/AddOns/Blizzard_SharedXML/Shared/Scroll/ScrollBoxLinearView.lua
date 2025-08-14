ScrollBoxLinearBaseViewMixin = CreateFromMixins(ScrollBoxViewMixin);

function ScrollBoxLinearBaseViewMixin:SetPadding(top, bottom, left, right, spacing)
	local padding = CreateScrollBoxPadding(top, bottom, left, right, spacing);
	ScrollBoxListViewMixin.SetPadding(self, padding);
end

function ScrollBoxLinearBaseViewMixin:GetSpacing()
	return self.padding:GetSpacing();
end

function ScrollBoxLinearBaseViewMixin:LayoutInternal(layoutFunction)
	local frames = self:GetFrames();
	local frameCount = frames and #frames or 0;
	if frameCount == 0 then
		return 0;
	end

	local spacing = self:GetSpacing();
	local scrollTarget = self:GetScrollTarget();
	local frameLevelCounter = ScrollBoxViewUtil.CreateFrameLevelCounter(self:GetFrameLevelPolicy(), 
		scrollTarget:GetFrameLevel(), frameCount);
	
	local offset = 0;
	for index, frame in ipairs(frames) do
		local extent = layoutFunction(index, frame, offset, scrollTarget);
		offset = offset + extent + spacing;

		if frameLevelCounter then
			frame:SetFrameLevel(frameLevelCounter());
		end
	end
end

function ScrollBoxLinearBaseViewMixin:SetElementIndentCalculator(elementIndentCalculator)
	self.elementIndentCalculator = elementIndentCalculator;
end

function ScrollBoxLinearBaseViewMixin:GetElementIndent(frame)
	return self.elementIndentCalculator and self.elementIndentCalculator(frame:GetElementData()) or 0;
end

function ScrollBoxLinearBaseViewMixin:GetLayoutFunction()
	local elementStretchDisabled = self:IsElementStretchDisabled();
	local setPoint = self:IsHorizontal() and ScrollBoxViewUtil.SetHorizontalPoint or ScrollBoxViewUtil.SetVerticalPoint;
	local scrollTarget = self:GetScrollTarget();
	local function Layout(index, frame, offset)
		local indent = self:GetElementIndent(frame);
		return setPoint(frame, offset, indent, elementStretchDisabled, scrollTarget);
	end
	return Layout;
end

function ScrollBoxLinearBaseViewMixin:Layout(scrollBox)
	self:LayoutInternal(self:GetLayoutFunction());
end

function ScrollBoxLinearBaseViewMixin:HasBiaxalLayout()
	return false;
end

ScrollBoxListLinearViewMixin = CreateFromMixins(ScrollBoxListViewMixin, ScrollBoxListStrideMixin, ScrollBoxLinearBaseViewMixin);

function ScrollBoxListLinearViewMixin:Init(top, bottom, left, right, spacing)
	ScrollBoxListViewMixin.Init(self);
	self:SetPadding(top, bottom, left, right, spacing);
end

function ScrollBoxListLinearViewMixin:GetStride()
	return 1;
end

function ScrollBoxListLinearViewMixin:HasIdenticalStrideExtent()
	return self:HasIdenticalElementExtent();
end

function ScrollBoxListLinearViewMixin:GetIdenticalStrideExtent()
	return self:GetIdenticalElementExtent();
end

function ScrollBoxListLinearViewMixin:SetScrollBox(scrollBox)
	ScrollBoxListViewMixin.SetScrollBox(self, scrollBox);

	if scrollBox.enableDefaultDrag then
		self:InitDefaultDrag(scrollBox);
	end
end

function ScrollBoxListLinearViewMixin:GetExtentSpacing()
	return self:GetSpacing();
end

function ScrollBoxListLinearViewMixin:ResizeFrame(scrollBox, frame, dataIndex, elementData)
	local extent = self:CalculateFrameExtent(dataIndex, elementData);
	scrollBox:SetFrameExtent(frame, extent);
end

function ScrollBoxListLinearViewMixin:InitDefaultDrag(scrollBox)
	return ScrollUtil.InitDefaultLinearDragBehavior(scrollBox);
end

function ScrollBoxListLinearViewMixin:SetElementExtent(extent)
	self:ClearCachedData();
	ScrollBoxListViewMixin.SetElementExtent(self, extent);
end

function ScrollBoxListLinearViewMixin:SetElementExtentCalculator(elementExtentCalculator)
	self:ClearElementExtentData();
	self.elementExtentCalculator = elementExtentCalculator;
end

function ScrollBoxListLinearViewMixin:GetElementExtentCalculator()
	return self.elementExtentCalculator;
end

function ScrollBoxListLinearViewMixin:ClearElementExtentData()
	self:ClearCachedData();
	ScrollBoxListViewMixin.ClearElementExtentData(self);
end

function ScrollBoxListLinearViewMixin:ClearCachedData()
	self.calculatedElementExtents = nil;
	self.templateExtents = nil;
end

do
	local function HasEqualTemplateInfoExtents(view, infos)
		local templateInfo = infos[next(infos)];
		if not templateInfo then
			return false;
		end

		local templateInfoExtent = view:GetExtentFromInfo(templateInfo);
		if templateInfoExtent <= 0 then
			return false;
		end
	
		for frameTemplate, info in pairs(infos) do
			local extent = view:GetExtentFromInfo(info);
			if not ApproximatelyEqual(templateInfoExtent, extent) then
				return false;
			end
		end
	
		return true;
	end
	
	function ScrollBoxListLinearViewMixin:HasIdenticalElementExtent()
		if self.elementExtent then
			return true;
		end

		if self.elementExtentCalculator then
			return false;
		end

		if self.templateInfoDirty then
			self.templateInfoDirty = nil;
	
			local infos = self.templateInfoCache:GetTemplateInfos();
			self.hasEqualTemplateInfoExtents = HasEqualTemplateInfoExtents(self, infos);
		end
		
		return self.hasEqualTemplateInfoExtents;
	end
end

function ScrollBoxListLinearViewMixin:GetIdenticalElementExtent()
	assert(self:HasIdenticalElementExtent());
	if self.elementExtent then
		return self.elementExtent;
	end

	local infos = self.templateInfoCache:GetTemplateInfos();
	local info = infos[next(infos)];
	return self:GetExtentFromInfo(info);
end

function ScrollBoxListLinearViewMixin:CalculateFrameExtent(dataIndex, elementData)
	if self.elementExtent then
		return self.elementExtent;
	end

	if self.elementExtentCalculator then
		return self.elementExtentCalculator(dataIndex, elementData);
	end

	return self:GetTemplateExtentFromElementData(elementData);
end

function ScrollBoxListLinearViewMixin:HasAnyExtentOrSizeCalculator()
	return self.elementExtentCalculator ~= nil;
end

function ScrollBoxListLinearViewMixin:RecalculateExtent(scrollBox)
	local function CalculateExtents(tbl, size)
		for dataIndex, elementData in self:EnumerateDataProvider() do
			local extent = self:CalculateFrameExtent(dataIndex, elementData);
			table.insert(tbl, extent);
		end

		return self:GetExtentTo(scrollBox, size);
	end

	local extent = 0;
	if self:HasDataProvider() then
		local function CalculateTemplateExtents(size)
			self.templateExtents = {};
			return CalculateExtents(self.templateExtents, size);
		end


		--[[
		CalculateTemplateExtents is ordered first here is because self.templateExtents will only 
		be assigned after all other options were checked. Once set, it is assumed that it is the 
		priority option, until explicitly cleared.
		]]--
		local size = self:GetDataProviderSize();
		local isTblSizeDifferent = self.templateExtents and #self.templateExtents ~= size;
		if isTblSizeDifferent then
			extent = CalculateTemplateExtents(size);
		elseif self:HasIdenticalElementExtent() then
			extent = self:GetExtentTo(scrollBox, size);
		elseif self.elementExtentCalculator then
			self.calculatedElementExtents = {};
			extent = CalculateExtents(self.calculatedElementExtents, size);
		else
			extent = CalculateTemplateExtents(size);
		end
	end
	
	local padding = scrollBox:GetUpperPadding() + scrollBox:GetLowerPadding();
	self:SetExtent(extent + padding);
end

function ScrollBoxListLinearViewMixin:GetElementExtent(dataIndex)
	local size = self:GetDataProviderSize();
	if dataIndex > size then
		return 0;
	end

	if self:HasIdenticalElementExtent() then 
		return self:GetIdenticalElementExtent();
	end

	if self.calculatedElementExtents then
		return self.calculatedElementExtents[dataIndex];
	elseif self.templateExtents then
		return self.templateExtents[dataIndex];
	end
	return 0;
end

function CreateScrollBoxListLinearView(top, bottom, left, right, spacing)
	return CreateAndInitFromMixin(ScrollBoxListLinearViewMixin, top or 0, bottom or 0, left or 0, right or 0, spacing or 0);
end

-- Simple option for scrolling regions without a data provider.
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

-- FIXME - Investigate this being necessary here. If actually required, add another
-- accessor and update ScrollBoxBaseMixin accordingly.
function ScrollBoxLinearViewMixin:HasBiaxalLayout()
	return true;
end

function ScrollBoxLinearViewMixin:GetDataScrollOffset(scrollBox)
	return scrollBox:GetUpperPadding();
end

function ScrollBoxLinearViewMixin:RecalculateExtent(scrollBox)
	local extent = 0;
	
	local frames = self:GetFrames();
	for index, frame in ipairs(frames) do
		extent = extent + self:GetFrameExtent(frame);
	end
	local space = math.max(#frames - 1, 0) * self:GetSpacing();
	local padding = scrollBox:GetUpperPadding() + scrollBox:GetLowerPadding();
	self:SetExtent(extent + space + padding);
end

function CreateScrollBoxLinearView(top, bottom, left, right, spacing)
	return CreateAndInitFromMixin(ScrollBoxLinearViewMixin, top or 0, bottom or 0, left or 0, right or 0, spacing or 0);
end
