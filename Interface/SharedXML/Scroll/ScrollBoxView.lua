local ScrollBoxListFrameMixin = {};

-- Verbose argument names here to avoid collisions. Expect
-- add on authors to use SetElementData().
function ScrollBoxListFrameMixin:GetElementData()
	return self.scrollBoxElementData;
end

function ScrollBoxListFrameMixin:SetElementData(elementData)
	self.scrollBoxElementData = elementData;
end

function ScrollBoxListFrameMixin:ElementDataMatches(elementData)
	return self:GetElementData() == elementData;
end

function ScrollBoxListFrameMixin:GetOrderIndex()
	return self.scrollBoxOrderIndex;
end

function ScrollBoxListFrameMixin:SetOrderIndex(orderIndex)
	self.scrollBoxOrderIndex = orderIndex;
end

ScrollBoxPaddingMixin = {};

function ScrollBoxPaddingMixin:Init(top, bottom, left, right)
	self:SetTop(top or 0);
	self:SetBottom(bottom or 0);
	self:SetLeft(left or 0);
	self:SetRight(right or 0);
end

function ScrollBoxPaddingMixin:GetTop()
	return self.top;
end

function ScrollBoxPaddingMixin:SetTop(top)
	self.top = top;
end

function ScrollBoxPaddingMixin:GetBottom()
	return self.bottom;
end

function ScrollBoxPaddingMixin:SetBottom(bottom)
	self.bottom = bottom;
end

function ScrollBoxPaddingMixin:GetLeft()
	return self.left;
end

function ScrollBoxPaddingMixin:SetLeft(left)
	self.left = left;
end

function ScrollBoxPaddingMixin:GetRight()
	return self.right;
end

function ScrollBoxPaddingMixin:SetRight(right)
	self.right = right;
end

function CreateScrollBoxPadding(top, bottom, left, right, spacing)
	return CreateAndInitFromMixin(ScrollBoxPaddingMixin, top, bottom, left, right, spacing);
end

ScrollBoxViewUtil = {};

function ScrollBoxViewUtil.CalculateSpacingUntil(index, stride, spacing)
	return math.max(0, math.ceil(index/stride) - 1) * spacing;
end

function ScrollBoxViewUtil.CreateFrameLevelCounter(frameLevelPolicy, referenceFrameLevel, range)
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

local InvalidationReason =
{
	DataProviderAssigned = 1,
	DataProviderContentsChanged = 2,
};

ScrollBoxViewMixin = CreateFromMixins(ScrollDirectionMixin);

ScrollBoxViewMixin.FrameLevelPolicy =
{
	Ascending = 1,
	Descending = 2,
};

function ScrollBoxViewMixin:Init()
	self.frames = {};
end

function ScrollBoxViewMixin:SetPadding(padding)
	self.padding = padding;
end

function ScrollBoxViewMixin:GetPadding()
	return self.padding;
end

function ScrollBoxViewMixin:SetPanExtent(panExtent)
	self.panExtent = panExtent;
end

function ScrollBoxViewMixin:GetFrameLevelPolicy()
	return self.frameLevelPolicy or ScrollBoxViewMixin.FrameLevelPolicy.Ascending;
end

function ScrollBoxViewMixin:SetFrameLevelPolicy(frameLevelPolicy)
	self.frameLevelPolicy = frameLevelPolicy;
end

function ScrollBoxViewMixin:SetScrollTarget(scrollTarget)
	self.scrollTarget = scrollTarget;
	scrollTarget:ClearAllPoints();
	scrollTarget:SetPoint("TOPLEFT");
	scrollTarget:SetPoint(self:IsHorizontal() and "BOTTOMLEFT" or "TOPRIGHT");
end

function ScrollBoxViewMixin:GetScrollTarget()
	return self.scrollTarget;
end

local NoFrames = {};
function ScrollBoxViewMixin:GetFrames()
	return self.frames or NoFrames;
end

function ScrollBoxViewMixin:FindFrame(elementData)
	return self:FindFrameByPredicate(function(frame)
		return frame:GetElementData() == elementData;
	end);
end

function ScrollBoxViewMixin:FindFrameByPredicate(predicate)
	for index, frame in ipairs(self:GetFrames()) do
		if predicate(frame) then
			return frame;
		end
	end
	return nil;
end

ScrollBoxListViewMixin = CreateFromMixins(ScrollBoxViewMixin, CallbackRegistryMixin);
ScrollBoxListViewMixin:GenerateCallbackEvents(
	{
		"OnDataChanged",
		"OnAcquiredFrame",
		"OnReleasedFrame",
	}
);

function ScrollBoxListViewMixin:Init()
	CallbackRegistryMixin.OnLoad(self);
	ScrollBoxViewMixin.Init(self);

	self.poolCollection = CreateFramePoolCollection();

	-- This function is being returned to the consumer of ScrollBox, so
	-- any values produced here that we want to use in the Acquire() function
	-- are assigned to self. Will probably need to investigate the taint
	-- implications here.
	self.factory = function(frameType, frameTemplate, elementReset)
		if frameTemplate == nil then
			frameTemplate = "";
		end
	
		local pool = self.poolCollection:GetOrCreatePool(frameType, self:GetScrollTarget(), frameTemplate);
		local frame, new = pool:Acquire();
		if not frame then
			error(string.format("ScrollBoxListViewMixin: Failed to create a frame with frameType '%s' and frameTemplate '%s'", frameType, frameTemplate));
		end

		-- For many conveniences, the elementData is assigned to the frame, and done so prior to returning
		-- a reference to the consumer.
		Mixin(frame, ScrollBoxListFrameMixin);
		frame:SetElementData(self.factoryFrameElementData);

		self.factoryFrame = frame;
		self.factoryFrameNew = new;
		return frame, new;
	end
end

function ScrollBoxListViewMixin:Flush()
	for index, frame in ipairs_reverse(self:GetFrames()) do
		self:Release(frame);
	end
	self.frames = {};

	self.dataIndexBegin = nil;
	self.dataIndexEnd = nil;
	self.dataIndicesInvalidated = nil;
	self.poolCollection:ReleaseAll();

	if self:GetDataProvider() then
		self:SetDataProvider(nil);
	end
end

function ScrollBoxListViewMixin:ForEachFrame(func)
	for index, frame in ipairs(self:GetFrames()) do
		func(frame, frame:GetElementData());
	end
end

function ScrollBoxListViewMixin:EnumerateFrames()
	return ipairs(self:GetFrames());
end

function ScrollBoxListViewMixin:FindElementDataByPredicate(predicate)
	return self:GetDataProvider():FindElementDataByPredicate(predicate);
end

function ScrollBoxListViewMixin:FindElementDataIndexByPredicate(predicate)
	return self:GetDataProvider():FindIndexByPredicate(predicate);
end

function ScrollBoxListViewMixin:FindByPredicate(predicate)
	return self:GetDataProvider():FindByPredicate(predicate);
end

function ScrollBoxListViewMixin:Find(index)
	return self:GetDataProvider():Find(index);
end

function ScrollBoxListViewMixin:FindIndex(elementData)
	return self:GetDataProvider():FindIndex(elementData);
end

function ScrollBoxListViewMixin:InsertElementData(...)
	self:GetDataProvider():Insert(...);
end

function ScrollBoxListViewMixin:InsertElementDataTable(tbl)
	self:GetDataProvider():InsertTable(tbl);
end

function ScrollBoxListViewMixin:InsertElementDataTableRange(tbl, indexBegin, indexEnd)
	self:GetDataProvider():InsertTableRange(tbl, indexBegin, indexEnd);
end

function ScrollBoxListViewMixin:ContainsElementDataByPredicate(predicate)
	return self:GetDataProvider():ContainsByPredicate(predicate);
end

function ScrollBoxListViewMixin:GetDataProvider()
	return self.dataProvider;
end

function ScrollBoxListViewMixin:HasDataProvider()
	return self.dataProvider ~= nil;
end

function ScrollBoxListViewMixin:ClearDataProvider()
	self:SetDataProvider(nil);
end

function ScrollBoxListViewMixin:GetDataProviderSize()
	local dataProvider = self:GetDataProvider();
	if dataProvider then
		return dataProvider:GetSize();
	end
	return 0;
end

function ScrollBoxListViewMixin:SetDataProvider(dataProvider, retainScrollPosition)
	local oldDataProvider = self:GetDataProvider();
	if oldDataProvider then
		oldDataProvider:RemoveListener(self);
	end

	self.dataProvider = dataProvider;
	if dataProvider then
		dataProvider:AddListener(self);
	end
	
	self:SignalDataChangeEvent(InvalidationReason.DataProviderAssigned);
end

function ScrollBoxListViewMixin:OnDataProviderSizeChanged(pendingSort)
	-- Defer if we're about to be sorted since we have a handler for that.
	if not pendingSort then
		self:SignalDataChangeEvent(InvalidationReason.DataProviderContentsChanged);
	end
end

function ScrollBoxListViewMixin:OnDataProviderSort()
	self:SignalDataChangeEvent(InvalidationReason.DataProviderContentsChanged);
end

function ScrollBoxListViewMixin:SignalDataChangeEvent(invalidationReason)
	self:SetInvalidationReason(invalidationReason);
	self:TriggerEvent(ScrollBoxListViewMixin.Event.OnDataChanged);
end

function ScrollBoxListViewMixin:IsAcquireLocked()
	return self.acquireLock;
end

function ScrollBoxListViewMixin:SetAcquireLocked(locked)
	self.acquireLock = locked;
end

function ScrollBoxListViewMixin:Acquire(dataIndex)
	if self:IsAcquireLocked() then
		-- Report an error if an Acquire() call causes the ScrollBox to Acquire() again. This most likely means 
		-- the data provider was changed in the Acquire() call, which is a no-no. This shouldn't occur due to a 
		-- frame size change because our size change event handlers are deferred until the next UpdateImmediately call.
		error("ScrollBoxListViewMixin:Acquire was reentrant.");
	end
	self:SetAcquireLocked(true);

	local elementData = self:GetDataProvider():Find(dataIndex);
	self.factoryFrameElementData = elementData;
	self.frameFactory(self.factory, elementData);

	local frame = self.factoryFrame;
	local new = self.factoryFrameNew;
	self.factoryFrame = nil;
	self.factoryFrameNew = nil;
	self.factoryFrameElementData = nil;

	table.insert(self:GetFrames(), frame);

	frame:SetOrderIndex(dataIndex);
	frame:Show();

	self:TriggerEvent(ScrollBoxListViewMixin.Event.OnAcquiredFrame, frame, elementData, new);

	self:SetAcquireLocked(false);
end

function ScrollBoxListViewMixin:Release(frame)
	local oldElementData = frame:GetElementData();

	tDeleteItem(self:GetFrames(), frame);
	self.poolCollection:Release(frame);

	if self.frameResetter then
		self.frameResetter(frame);
	end

	frame:SetElementData(nil);
	frame:SetOrderIndex(nil);

	self:TriggerEvent(ScrollBoxListViewMixin.Event.OnReleasedFrame, frame, oldElementData);
end

function ScrollBoxListViewMixin:GetFrameCount()
	return #self.frames;
end

function ScrollBoxListViewMixin:SetElementExtentCalculator(elementExtentCalculator)
	self.elementExtentCalculator = elementExtentCalculator;
end

--[[]
	Use SetElementInitializer if using a single template type.
	SetElementInitializer("Button", "TemplateOne", function(button, elementData, new)
		button:Init(elementData); 
	end);
]]
function ScrollBoxListViewMixin:SetElementInitializer(frameType, frameTemplate, initializer)
	 local function Factory(factory, elementData)
        local frame, new = factory(frameType, frameTemplate);
		initializer(frame, elementData, new);
    end;
	self:SetElementFactory(Factory);
end

--[[
	Use SetElementFactory if using different template types:
	SetElementFactory(function(factory, elementData)
		local button, new = factory("Button", elementData.templateType);
		button:Init(elementData);
	end);
]]
function ScrollBoxListViewMixin:SetElementFactory(frameFactory)
	self.frameFactory = frameFactory;
end

function ScrollBoxListViewMixin:SetElementResetter(resetter)
	self.frameResetter = resetter;
end

function ScrollBoxListViewMixin:SetNonVirtualized()
	self.nonVirtualized = true;
end

function ScrollBoxListViewMixin:CalculateFrameExtent(dataIndex, elementData)
	if self.elementExtent then
		return self.elementExtent;
	end

	if self.elementExtentCalculator then
		return math.max(1, self.elementExtentCalculator(dataIndex, elementData));
	end

	local frame = self:GetFrames()[dataIndex];
	if frame then
		return self:GetFrameExtent(frame);
	end
	return 0;
end

function ScrollBoxListViewMixin:GetPanExtent(spacing)
	if not self.panExtent then
		local dataProvider = self:GetDataProvider();
		local dataIndex = 1;
		local elementData = dataProvider and dataProvider:Find(dataIndex);
		if elementData then
			self.panExtent = self:CalculateFrameExtent(dataIndex, elementData) + spacing;
		end
	end

	return self.panExtent or 0;
end

function ScrollBoxListViewMixin:IsVirtualized()
	return not self.nonVirtualized and (self.elementExtent or self.elementExtentCalculator);
end

local function CheckDataIndicesReturn(dataIndexBegin, dataIndexEnd)
	-- Erroring here to prevent the client from lockup if 100000 frames are requested. This can happen
	-- if a frame doesn't correct frame extents (1 height/width), causing a much larger range to be displayed than expected.
	local size = dataIndexEnd - dataIndexBegin;
	local capacity = 500;
	if size >= capacity then
		error(string.format("ScrollBoxListViewMixin:CalculateDataIndices encountered an unsupported size. %d/%d", size, capacity));
	end

	return dataIndexBegin, dataIndexEnd;
end

function ScrollBoxListViewMixin:CalculateDataIndices(scrollBox, stride, spacing)
	local dataProvider = self:GetDataProvider();
	if not dataProvider then
		return 0, 0;
	end

	local size = dataProvider:GetSize();
	if size == 0 then
		return 0, 0;
	end

	if not self:IsVirtualized() then
		CheckDataIndicesReturn(1, size);
	end

	local dataIndexBegin;
	local dataIndexEnd;
	local scrollOffset = scrollBox:GetDerivedScrollOffset();
	local extentBegin = scrollBox:GetUpperPadding();
	-- For large element ranges (i.e. 10,000+), we're required to use fixed element extents 
	-- to avoid performance issues. We're calculating the number of elements that occupy the
	-- existing scroll offset to obtain our reference position.
	if self:HasFixedElementExtent() then
		local extentWithSpacing = self:GetFixedElementExtent() + spacing;
		local intervals = math.max(math.floor(scrollOffset / extentWithSpacing), 1) - 1;
		dataIndexBegin = 1 + (stride * intervals);
		extentBegin = extentBegin + extentWithSpacing + (extentWithSpacing * intervals);
	else
		do
			dataIndexBegin = 1 - stride;
			repeat
				dataIndexBegin = dataIndexBegin + stride;
				extentBegin = extentBegin + self:GetElementExtent(dataIndexBegin) + spacing;
			until (extentBegin >= scrollOffset);
		end
	end

	-- Optimization above for fixed element extents above not necessary here, because we
	-- we only interested in avoiding large iteration ranges. Obtaining the end extents here
	-- is at worse the number of elements that fit in the displayable area.
	local extentEnd = scrollBox:GetVisibleExtent() + scrollOffset;
	dataIndexEnd = dataIndexBegin;
	while (dataIndexEnd < size) and (extentBegin < extentEnd) do
		local nextDataIndex = dataIndexEnd + stride;
		extentBegin = extentBegin + self:GetElementExtent(nextDataIndex) + spacing;
		dataIndexEnd = nextDataIndex;
	end

	if stride > 1 then
		dataIndexEnd = math.min(dataIndexEnd - (dataIndexEnd % stride) + stride, size);
	else
		dataIndexEnd = math.min(dataIndexEnd, size);
	end

	return CheckDataIndicesReturn(dataIndexBegin, dataIndexEnd);
end

function ScrollBoxListViewMixin:GetExtent(recalculate, scrollBox, stride, spacing)
	if recalculate or (not self.virtualExtent) or (self.virtualExtent == 0) then
		local virtualExtent = 0;
		local size = 0;

		local dataProvider = self:GetDataProvider();
		if dataProvider then
			size = dataProvider:GetSize();

			if self:HasFixedElementExtent() then
				virtualExtent = math.ceil(size/stride) * self:GetFixedElementExtent();
			else
				self.calculatedElementExtents = {};

				for dataIndex = 1, size do
					local elementData = dataProvider:Find(dataIndex);
					local extent = self:CalculateFrameExtent(dataIndex, elementData);
					table.insert(self.calculatedElementExtents, extent);
				end

				for dataIndex = 1, size, stride do
					virtualExtent = virtualExtent + self.calculatedElementExtents[dataIndex];
				end
			end
		end;
		
		local space = ScrollBoxViewUtil.CalculateSpacingUntil(size, stride, spacing);
		self.virtualExtent = virtualExtent + space + scrollBox:GetUpperPadding() + scrollBox:GetLowerPadding();
	end
	
	return self.virtualExtent;
end

function ScrollBoxListViewMixin:HasFixedElementExtent()
	return self.elementExtent ~= nil;
end

function ScrollBoxListViewMixin:GetFixedElementExtent()
	return self.elementExtent;	
end

function ScrollBoxListViewMixin:GetElementExtent(dataIndex)
	return self.elementExtent or (self.calculatedElementExtents and self.calculatedElementExtents[dataIndex] or 0);
end

function ScrollBoxListViewMixin:SetElementExtent(extent)
	self.elementExtent = math.max(extent, 1);
end

function ScrollBoxListViewMixin:GetExtentUntil(scrollBox, dataIndex, stride, spacing)
	if dataIndex == 0 then
		return 0;
	end

	local index = dataIndex - stride;
	local extent = 0;
	if self:HasFixedElementExtent() then
		extent = math.max(0, math.ceil(index / stride)) * self:GetFixedElementExtent();
	else
		do
			while index > 0 do
				extent = extent + self:GetElementExtent(index);
				index = index - stride;
			end
		end
	end
	
	
	local space = ScrollBoxViewUtil.CalculateSpacingUntil(dataIndex, stride, spacing);
	return extent + space + scrollBox:GetUpperPadding();
end


function ScrollBoxListViewMixin:GetDataScrollOffset(scrollBox)
	local dataIndexBegin, dataIndexEnd = self:CalculateDataIndices(scrollBox);
	local dataScrollOffset = self:GetExtentUntil(scrollBox, dataIndexBegin);
	return dataScrollOffset;
end

function ScrollBoxListViewMixin:Rebuild()
	for index, frame in ipairs_reverse(self:GetFrames()) do
		self:Release(frame);
	end

	local dataIndexBegin, dataIndexEnd = self:GetDataRange();
	if dataIndexEnd > 0 then
		for dataIndex = dataIndexBegin, dataIndexEnd do
			self:Acquire(dataIndex);
		end
	end
end

function ScrollBoxListViewMixin:ValidateDataRange(scrollBox)
	-- Calculate the range of indices to display.
	local oldDataIndexBegin, oldDataIndexEnd = self:GetDataRange();
	local dataIndexBegin, dataIndexEnd = self:CalculateDataIndices(scrollBox);

	-- Invalidation occurs whenever the data provider is sorted, the size changes, or the data provider is replaced.
	local invalidated = self:IsInvalidated();
	local rangeChanged = invalidated or oldDataIndexBegin ~= dataIndexBegin or oldDataIndexEnd ~= dataIndexEnd;
	if rangeChanged then
		local dataProvider = self:GetDataProvider();
		--[[
			local size = dataProvider and dataProvider:GetSize() or 0;
			print(string.format("%d - %d of %d, invalidated =", dataIndexBegin, dataIndexEnd, 
				size), invalidated, GetTime());
		--]]

		self:SetDataRange(dataIndexBegin, dataIndexEnd);

		-- Frames are generally recyclable when the element data is a table because we can uniquely identify it.
		-- Note that if an invalidation occurred due to the data provider being exchanged, we never try and recycle.
		local canRecycle = not invalidated or self:GetInvalidationReason() ~= InvalidationReason.DataProviderAssigned;
		if canRecycle then
			for index, frame in ipairs(self:GetFrames()) do
				if type(frame:GetElementData()) ~= "table" then
					canRecycle = false;
					break;
				end
			end
		end

		if canRecycle then
			local acquireList = {};
			local releaseList = {};
			for index, frame in ipairs(self:GetFrames()) do
				releaseList[frame:GetElementData()] = frame;
			end

			if dataIndexBegin > 0 then
				for dataIndex = dataIndexBegin, dataIndexEnd do
					local currentElementData = dataProvider:Find(dataIndex);
					if releaseList[currentElementData] then
						local frame = releaseList[currentElementData];
						frame:SetOrderIndex(dataIndex);
						releaseList[currentElementData] = nil;
					else
						tinsert(acquireList, dataIndex);
					end
				end
			end

			for elementData, frame in pairs(releaseList) do
				self:Release(frame);
			end

			for index, dataIndex in ipairs(acquireList) do
				self:Acquire(dataIndex);
			end
		else
			self:Rebuild();
		end
		
		self:ClearInvalidation();

		self:SortFrames();

		return true;
	end
	return false;
end

function ScrollBoxListViewMixin:SortFrames()
	table.sort(self:GetFrames(), function(lhs, rhs)
		return lhs:GetOrderIndex() < rhs:GetOrderIndex();
	end);
end

function ScrollBoxListViewMixin:SetInvalidationReason(invalidationReason)
	self.invalidationReason = invalidationReason;
end

function ScrollBoxListViewMixin:GetInvalidationReason()
	return self.invalidationReason;
end

function ScrollBoxListViewMixin:ClearInvalidation()
	self.invalidationReason = nil;
end

function ScrollBoxListViewMixin:IsInvalidated()
	return self.invalidationReason ~= nil;
end

function ScrollBoxListViewMixin:GetDataIndexBegin()
	return self.dataIndexBegin or 0;
end

function ScrollBoxListViewMixin:GetDataIndexEnd()
	return self.dataIndexEnd or 0;
end

function ScrollBoxListViewMixin:GetDataRange()
	return self.dataIndexBegin, self.dataIndexEnd;
end

function ScrollBoxListViewMixin:SetDataRange(dataIndexBegin, dataIndexEnd)
	self.dataIndexBegin = dataIndexBegin;
	self.dataIndexEnd = dataIndexEnd;
end

function ScrollBoxListViewMixin:IsDataIndexWithinRange(dataIndex)
	local dataIndexBegin, dataIndexEnd = self:GetDataRange();
	return WithinRange(dataIndex, dataIndexBegin, dataIndexEnd);
end