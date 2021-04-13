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

ScrollBoxViewMixin = CreateFromMixins(ScrollDirectionMixin);

ScrollBoxViewMixin.FrameLevelPolicy =
{
	Ascending,
	Descending,
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
		return frame.elementData == elementData;
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

	self.factory = function(frameType, frameTemplate, elementReset)
		local reset = function(pool, frame)
			-- elementReset handler not expected to be concerned about the implementation details
			-- of ScrollBox's frame pool management.
			FramePool_HideAndClearAnchors(pool, frame);
			if elementReset then
				elementReset(frame);
			end
		end

		local pool = self.poolCollection:GetOrCreatePool(frameType, self:GetScrollTarget(), frameTemplate, reset);
		local frame, new = pool:Acquire();
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
		func(frame, frame.elementData);
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

	if not self:IsVirtualized() then
		for index, frame in ipairs_reverse(self:GetFrames()) do
			self:Release(frame);
		end

		for dataIndex = 1, self:GetDataProviderSize() do
			self:Acquire(dataIndex);
		end
	end
	
	self:Invalidate();

	self:TriggerEvent(ScrollBoxListViewMixin.Event.OnDataChanged);
end

function ScrollBoxListViewMixin:OnDataProviderSizeChanged(pendingSort)
	-- Defer if we're about to be sorted since we have a handler for that.
	if not pendingSort then
		self:TriggerEvent(ScrollBoxListViewMixin.Event.OnDataChanged);
	end
end

function ScrollBoxListViewMixin:OnDataProviderSort()
	self:TriggerEvent(ScrollBoxListViewMixin.Event.OnDataChanged);
end

function ScrollBoxListViewMixin:CanAddFrameToElementData(elementData)
	return type(elementData) == "table";
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
	self.frameFactory(self.factory, elementData);

	-- See self.factory for the factory output caching explanation.
	local frame, new = self.factoryFrame, self.factoryFrameNew;
	self.factoryFrameNew, self.factoryFrame = nil, nil;

	table.insert(self:GetFrames(), frame);

	if self:CanAddFrameToElementData(elementData) then
		elementData.scrollBoxChild = frame;
	end

	frame.elementData = elementData;
	frame.orderIndex = dataIndex;
	frame:Show();

	self:TriggerEvent(ScrollBoxListViewMixin.Event.OnAcquiredFrame, frame, elementData, new);

	self:SetAcquireLocked(false);
end

function ScrollBoxListViewMixin:Release(frame)
	if self:CanAddFrameToElementData() then
		frame.elementData.scrollBoxChild = nil;
	end

	tDeleteItem(self:GetFrames(), frame);
	self.poolCollection:Release(frame);

	local oldElementData = frame.elementData;
	frame.elementData = nil;
	frame.orderIndex = nil;

	self:TriggerEvent(ScrollBoxListViewMixin.Event.OnReleasedFrame, frame, oldElementData);
end

function ScrollBoxListViewMixin:GetFrameCount()
	return #self.frames;
end

function ScrollBoxListViewMixin:SetElementExtentCalculator(elementExtentCalculator)
	self.elementExtentCalculator = elementExtentCalculator;
end

function ScrollBoxListViewMixin:SetFactory(frameFactory)
	self.frameFactory = frameFactory;
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
		return 1, size;
	end

	local dataIndexBegin = 0;
	local dataIndexEnd = 0;
	local scrollOffset = scrollBox:GetDerivedScrollOffset();

	local extentBegin = scrollBox:GetUpperPadding();
	if self:HasStaticElementExtent() then
		local extentWithSpacing = self.elementExtent + spacing;
		local intervals = math.floor(scrollOffset / extentWithSpacing);
		dataIndexBegin = 1 + (stride * intervals);
		extentBegin = extentBegin + (extentWithSpacing * intervals)
	else
		do
			dataIndexBegin = 1 - stride;
			repeat
				dataIndexBegin = dataIndexBegin + stride;
				extentBegin = extentBegin + self:GetElementExtent(dataIndexBegin) + spacing;
			until (extentBegin >= scrollOffset);
		end
	end

	local extentEnd = scrollBox:GetVisibleExtent() + scrollOffset;
	dataIndexEnd = dataIndexBegin;
	while (dataIndexEnd < size) and (extentBegin < extentEnd) do
		local nextDataIndex = dataIndexEnd + stride;
		extentBegin = extentBegin + self:GetElementExtent(nextDataIndex) + spacing;
		dataIndexEnd = nextDataIndex;
	end

	if stride > 1 then
		return dataIndexBegin, math.min(dataIndexEnd - (dataIndexEnd % stride) + stride, size);
	end
	return dataIndexBegin, math.min(dataIndexEnd, size);
end

function ScrollBoxListViewMixin:GetExtent(recalculate, scrollBox, stride, spacing)
	if recalculate or not self.virtualExtent then
		local virtualExtent = 0;
		local size = 0;

		local dataProvider = self:GetDataProvider();
		if dataProvider then
			size = dataProvider:GetSize();

			if self:HasStaticElementExtent() then
				virtualExtent = math.ceil(size/stride) * self.elementExtent;
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

function ScrollBoxListViewMixin:HasStaticElementExtent()
	return self.elementExtent ~= nil;
end

function ScrollBoxListViewMixin:GetElementExtent(dataIndex)
	return self.elementExtent or self:GetCalculatedElementExtent(dataIndex);
end

function ScrollBoxListViewMixin:GetCalculatedElementExtent(dataIndex)
	return self.calculatedElementExtents and self.calculatedElementExtents[dataIndex] or 0;
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
	if self:HasStaticElementExtent() then
		extent = math.max(0, math.ceil(index / stride)) * self.elementExtent;
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

	if self.dataIndexEnd > 0 then
		for dataIndex = self.dataIndexBegin, self.dataIndexEnd do
			self:Acquire(dataIndex);
		end
	end
end

function ScrollBoxListViewMixin:ValidateDataRange(scrollBox)
	-- Calculate the range of indices to display.
	local dataIndexBegin, dataIndexEnd = self:CalculateDataIndices(scrollBox);
	local rangeChanged = self.dataIndicesInvalidated or self.dataIndexBegin ~= dataIndexBegin or self.dataIndexEnd ~= dataIndexEnd;
	if rangeChanged then
		local dataProvider = self:GetDataProvider();
		--[[
			print(string.format("%d - %d of %d, invalidated = %s", dataIndexBegin, dataIndexEnd, 
				dataProvider and dataProvider:GetSize() or 0, tostring(self.dataIndicesInvalidated)));
		]]

		self.dataIndexBegin = dataIndexBegin;
		self.dataIndexEnd = dataIndexEnd;
	
		-- Frames cannot be recycled unless the element data is uniquely identifiable. This is naturally
		-- possible by comparison when using a table. If the element data is an index, the comparison cannot
		-- account for the actual data referred to by the index having shifted into a new position.
		local canRecycle = true;
		for index, frame in ipairs(self:GetFrames()) do
			if type(frame.elementData) ~= "table" then
				canRecycle = false;
				break;
			end
		end

		if canRecycle then
			local acquireList = {};
			local releaseList = {};
			for index, frame in ipairs(self:GetFrames()) do
				releaseList[frame.elementData] = frame;
			end

			if dataIndexBegin > 0 then
				for dataIndex = dataIndexBegin, dataIndexEnd do
					local currentElementData = dataProvider:Find(dataIndex);
					if releaseList[currentElementData] then
						local frame = releaseList[currentElementData];
						frame.orderIndex = dataIndex;
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
		
		self.dataIndicesInvalidated = false;

		self:SortFrames();

		return true;
	end
	return false;
end

function ScrollBoxListViewMixin:SortFrames()
	table.sort(self:GetFrames(), function(lhs, rhs)
		return lhs.orderIndex < rhs.orderIndex;
	end);
end

function ScrollBoxListViewMixin:Invalidate()
	self.dataIndicesInvalidated = true;
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

function ScrollBoxListViewMixin:IsDataIndexWithinRange(dataIndex)
	local dataIndexBegin, dataIndexEnd = self:GetDataRange();
	return WithinRange(dataIndex, dataIndexBegin, dataIndexEnd);
end