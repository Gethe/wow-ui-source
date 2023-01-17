local InvalidationReason = EnumUtil.MakeEnum("DataProviderReassigned", "DataProviderContentsChanged");

ScrollBoxListViewMixin = CreateFromMixins(ScrollBoxViewMixin, CallbackRegistryMixin);
ScrollBoxListViewMixin:GenerateCallbackEvents(
	{
		"OnDataChanged",
		"OnAcquiredFrame",
		"OnInitializedFrame",
		"OnReleasedFrame",
	}
);

function ScrollBoxListViewMixin:Init()
	CallbackRegistryMixin.OnLoad(self);
	ScrollBoxViewMixin.Init(self);

	self.poolCollection = CreateFramePoolCollection();
	self.initializerList = {};
	self.templateInfos = {};

	self.factory = function(frameTemplateOrFrameType, initializer)
		local frameTemplate = nil;
		local frameType = nil;
		local specialization = nil;

		local info = self:CreateTemplateInfoForTemplate(frameTemplateOrFrameType);
		if info then
			frameTemplate = frameTemplateOrFrameType;
			frameType = info.type;
		else
			-- Couldn't obtain template info, so the presumption is that this is a basic frame type.
			frameTemplate = "";
			frameType = frameTemplateOrFrameType;
			specialization = frameType;
		end

		-- The frame type is passed as a specialization argument if this is deduced to be a basic frame type (i.e. button, frame) to
		-- enable the pool collection to support multiple buckets for untemplated frame types. We're not leveraging it to provide any
		-- custom initialization of the frame, but only to define a distincy key for each frame bucket.
		local pool = self.poolCollection:GetOrCreatePool(frameType, self:GetScrollTarget(), frameTemplate, nil, nil, specialization);
		local frame, new = pool:Acquire();
		if not frame then
			error(string.format("ScrollBoxListViewMixin: Failed to create a frame from pool for frame template or frame type '%s'", frameTemplateOrFrameType));
		end
		
		-- The frame and new values are captured here instead of being returned to prevent the callee from having
		-- access to the frame prior to it being properly anchored or arranged. The frame's initializer will be called
		-- once all frames have been arranged in the layout step.
		self.factoryFrame = frame;
		self.factoryFrameIsNew = new;

		-- An initializer is not required, and we might expect this if the frame represents a line or divider.
		self.initializerList[frame] = initializer;
	end
end

function ScrollBoxListViewMixin:CreateTemplateInfoForTemplate(frameTemplate)
	local info = self.templateInfos[frameTemplate] or C_XMLUtil.GetTemplateInfo(frameTemplate);
	if info then
		info.extent = self:IsHorizontal() and info.width or info.height;
		self.templateInfos[frameTemplate] = info;
		self.templateInfoDirty = true;
	end
	return info;
end

function ScrollBoxListViewMixin:AssignAccessors(frame, elementData)
	frame.GetElementData = function(self)
		return elementData;
	end;

	frame.ElementDataMatches = function(self, elementData)
		return self:GetElementData() == elementData;
	end;

	local index = 1;
	frame.GetOrderIndex = function(self)
		return index;
	end;

	frame.SetOrderIndex = function(self, orderIndex)
		index = orderIndex;
	end;
end

function ScrollBoxListViewMixin:UnassignAccessors(frame)
	frame.GetElementData = nil;
	frame.ElementDataMatches = nil;
	frame.GetOrderIndex = nil;
	frame.SetOrderIndex = nil;
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

	self:ClearDataProvider();
end

function ScrollBoxListViewMixin:ForEachFrame(func)
	for index, frame in ipairs(self:GetFrames()) do
		func(frame, frame:GetElementData());
	end
end

function ScrollBoxListViewMixin:ForEachElementData(func)
	self:GetDataProvider():ForEach(func);
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

function ScrollBoxListViewMixin:EnumerateDataProvider(indexBegin, indexEnd)
	return self:GetDataProvider():Enumerate(indexBegin, indexEnd);
end

function ScrollBoxListViewMixin:ClearDataProviderInternal()
	local dataProvider = self:GetDataProvider();
	if dataProvider then
		dataProvider:UnregisterCallback(DataProviderMixin.Event.OnSizeChanged, self);
		dataProvider:UnregisterCallback(DataProviderMixin.Event.OnSort, self);
	end

	self.dataProvider = nil;

	-- Anytime the data provider is discarded we also want to discard any cached extents.
	self.templateExtents = nil;
	self.calculatedElementExtents = nil;
end

function ScrollBoxListViewMixin:ClearDataProvider()
	self:ClearDataProviderInternal();
	self:SignalDataChangeEvent(InvalidationReason.DataProviderReassigned);
end

function ScrollBoxListViewMixin:GetDataProviderSize()
	local dataProvider = self:GetDataProvider();
	if dataProvider then
		return dataProvider:GetSize();
	end
	return 0;
end

function ScrollBoxListViewMixin:SetDataProvider(dataProvider, retainScrollPosition)
	if dataProvider == nil then
		error("SetDataProvider() dataProvider was nil. Call ClearDataProvider() if this was your intent.");
	end
	
	self:ClearDataProviderInternal();

	self.dataProvider = dataProvider;
	if dataProvider then
		dataProvider:RegisterCallback(DataProviderMixin.Event.OnSizeChanged, self.OnDataProviderSizeChanged, self);
		dataProvider:RegisterCallback(DataProviderMixin.Event.OnSort, self.OnDataProviderSort, self);
	end
	
	self:SignalDataChangeEvent(InvalidationReason.DataProviderReassigned);
end

function ScrollBoxListViewMixin:OnDataProviderSizeChanged(pendingSort)
	-- Defer if we're about to be sorted since we have a handler for that.
	if not pendingSort then
		self:DataProviderContentsChanged();
	end
end

function ScrollBoxListViewMixin:OnDataProviderSort()
	self:DataProviderContentsChanged();
end

function ScrollBoxListViewMixin:DataProviderContentsChanged()
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

function ScrollBoxListViewMixin:AcquireInternal(dataIndex, elementData)
	if self:IsAcquireLocked() then
		-- Report an error if an Acquire() call causes the ScrollBox to Acquire() again. This most likely means 
		-- the data provider was changed in the Acquire() call, which is a no-no. This shouldn't occur due to a 
		-- frame size change because our size change event handlers are deferred until the next UpdateImmediately call.
		error("ScrollBoxListViewMixin:Acquire was reentrant.");
	end

	-- Since the factory functions no longer support frames being initialized before layout,
	-- these locks are generally unnecessary. However if a frame has some code in it's OnLoad() that
	-- causes the view to generate a new element, we'll want to error.
	self:SetAcquireLocked(true);

	-- Acquire a frame from the factory. The frame and it's 'new' state will be cached upon return. 
	-- We'll retrieve those and nil the cache fields to prevent misuse later.
	self.elementFactory(self.factory, elementData);
	local frame, new = self.factoryFrame, self.factoryFrameIsNew;
	assert(self.factoryFrame ~= nil, "ScrollBox: A frame was not returned from the element initializer or factory. Verify the factory object was called with a valid template.")
	self.factoryFrame, self.factoryFrameIsNew = nil, nil;
	table.insert(self:GetFrames(), frame);

	-- If either SetElementExtent or SetElementExtentCalculator is assigned we'll set the extent now. 
	-- Otherwise, the expectation is that the extent is defined in the XML.
	if self.elementExtent or self.elementExtentCalculator then
		local extent = self:CalculateFrameExtent(dataIndex, elementData);
		local scrollBox = self:GetScrollBox();
		scrollBox:SetFrameExtent(frame, extent);		
	end

	-- Assign any accessors required by ScrollBox or this view on the frame.
	self:AssignAccessors(frame, elementData);

	-- Order index required for frame level sorting.
	frame:SetOrderIndex(dataIndex);
	frame:Show();

	self:TriggerEvent(ScrollBoxListViewMixin.Event.OnAcquiredFrame, frame, elementData, new);

	self:SetAcquireLocked(false);
end

-- Frame initialization is no longer supported during the factory step. The initializer passed to the
-- factory object is called once layout has completed, ensuring that the frame can access it's effective
-- dimensions inside it's own initializer.
function ScrollBoxListViewMixin:InvokeInitializers()
	for frame, initializer in pairs(self.initializerList) do
		local elementData = frame:GetElementData();
		initializer(frame, elementData);
		self.initializerList[frame] = nil;
		self:TriggerEvent(ScrollBoxListViewMixin.Event.OnInitializedFrame, frame, elementData);
	end
end

function ScrollBoxListViewMixin:AcquireRange(dataIndices)
	if #dataIndices > 0 then
		local indexBegin = math.huge;
		local indexEnd = 0;
		for _, dataIndex in ipairs(dataIndices) do
			indexBegin = math.min(indexBegin, dataIndex);
			indexEnd = math.max(indexEnd, dataIndex);
		end

		for dataIndex, elementData in self:EnumerateDataProvider(indexBegin, indexEnd) do
			if tContains(dataIndices, dataIndex) then
				self:AcquireInternal(dataIndex, elementData);
			end
		end
	end
end

function ScrollBoxListViewMixin:Release(frame)
	local oldElementData = frame:GetElementData();

	tDeleteItem(self:GetFrames(), frame);
	self.poolCollection:Release(frame);

	if self.frameResetter then
		self.frameResetter(frame, oldElementData);
	end

	self:UnassignAccessors(frame);

	self:TriggerEvent(ScrollBoxListViewMixin.Event.OnReleasedFrame, frame, oldElementData);
end

function ScrollBoxListViewMixin:GetFrameCount()
	return #self.frames;
end

--[[]
	Use SetElementInitializer if using a single template type or basic frame type.
	local function Initializer(button, elementData)
		button:Init(elementData); 
	end
	SetElementInitializer("MyButtonTemplate", Initializer);

	local function Initializer(button, elementData)
		if not button.created then
			button.created = true;
			-- one-time operations on the button
		end
		-- regular initialization on the button
	end
	SetElementInitializer("Button", Initializer);
]]
function ScrollBoxListViewMixin:SetElementInitializer(frameTemplateOrFrameType, initializer)
	local function Factory(factory, elementData)
		factory(frameTemplateOrFrameType, initializer);
	end;
	self:SetElementFactory(Factory);

	-- For single type factories, we can default to setting the element extent.
	-- We cannot do this for multiple type factories because the template type can only be known
	-- after invoking the factory. See GetTemplateFromElementData for details on how this is
	-- happening.
	if not self.elementExtent and not self.elementExtentCalculator then
		local extent = self:CreateTemplateExtent(frameTemplateOrFrameType);
		if extent and extent > 0 then
			self:SetElementExtent(extent);
		end
	end
end

--[[
	Use SetElementFactory if using different template types:
	SetElementFactory(function(factory, elementData)
		if elementData.condition1 then
			factory("MyButtonTemplate", function(button, elementData)
				button:Init(elementData);
			end);
		elseif elementData.condition2 then
			factory("MyFrameTemplate", function(frame, elementData)
				frame:Init(elementData);
			end);
		elseif elementData.condition3 then
			local function Initializer(frame, elementData)
				if not frame.created then
					frame.created = true;
					-- one-time operations on the frame
				end
				-- regular initialization on the frame
			end
			factory("Frame", Initializer);
		end

		-- or if adding the template information to the element data is suitable:
		factory(elementData.template, elementData.initializer);
	end);
]]
function ScrollBoxListViewMixin:SetElementFactory(elementFactory)
	self.elementFactory = elementFactory;
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

	return self:CreateTemplateExtentFromElementData(elementData);
end

do
	-- Local outside GetTemplateFromElementData to avoid creating an unnecessary closure 
	-- every time we need to get the template.
	local template;
	local factory = function(frameTemplate, initializer)
		template = frameTemplate;
	end;
	
	function ScrollBoxListViewMixin:GetTemplateFromElementData(elementData)
		-- Asserting that we never attempted to call this function in any context where the element extent or calculator
		-- was set to expose any unintended execution.
		assert(self.elementExtent == nil and self.elementExtentCalculator == nil);

		-- When trying to obtain the extent in scenarios where multiple templates are in use, we have to 
		-- call the factory to obtain the correct template. We don't want to actually produce a frame, we
		-- only want to capture the template from the call, which we can accomplish with the shim above.
		self.elementFactory(factory, elementData);
		return template;
	end
end

function ScrollBoxListViewMixin:CreateTemplateExtentFromElementData(elementData)	
	return self:CreateTemplateExtent(self:GetTemplateFromElementData(elementData));
end

function ScrollBoxListViewMixin:CreateTemplateExtent(frameTemplate)
	local info = self:CreateTemplateInfoForTemplate(frameTemplate);
	if not info then
		error(string.format("ScrollBoxListViewMixin: Failed to obtain template info for frame template '%s'", frameTemplate));
	end
	return info.extent;
end

function ScrollBoxListViewMixin:GetPanExtent(spacing)
	if not self.panExtent and self:HasDataProvider() then
		for dataIndex, elementData in self:EnumerateDataProvider() do
			self.panExtent = self:CalculateFrameExtent(dataIndex, elementData) + spacing;
			break;
		end
	end

	return self.panExtent or 0;
end

function ScrollBoxListViewMixin:IsVirtualized()
	return not self.nonVirtualized;
end

local function CheckDataIndicesReturn(dataIndexBegin, dataIndexEnd)
	-- Erroring here to prevent the client from lockup if 100,000 frames are requested. This can happen
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
	local scrollOffset = scrollBox:GetDerivedScrollOffset();
	local upperPadding = scrollBox:GetUpperPadding();
	local extentBegin = upperPadding;
	-- For large element ranges (i.e. 10,000+), we're required to use identical element extents 
	-- to avoid performance issues. We're calculating the number of elements that partially or fully
	-- fit inside the extent of the scroll offset to obtain our reference position. If we happen to
	-- be using a traditional data provider, this optimization is still useful.
	if self:HasIdenticalElementExtents() then
		local extentWithSpacing = self:GetIdenticalElementExtents() + spacing;
		local intervals = math.floor(math.max(0, scrollOffset - upperPadding) / extentWithSpacing);
		dataIndexBegin = 1 + (intervals * stride);
		local extentTotal = (1 + intervals) * extentWithSpacing;
		extentBegin = extentBegin + extentTotal;
	else
		do
			dataIndexBegin = 1 - stride;
			repeat
				dataIndexBegin = dataIndexBegin + stride;
				local extentWithSpacing = self:GetElementExtent(dataIndexBegin) + spacing;
				extentBegin = extentBegin + extentWithSpacing;
			until (extentBegin >= scrollOffset);
		end
	end

	-- Optimization above for fixed element extents is not necessary here because we do
	-- not need to iterate over the entire data range. The iteration is limited to the
	-- number of elements that can fit in the displayable area.
	local extentEnd = scrollBox:GetVisibleExtent() + scrollOffset;
	local extentNext = extentBegin;
	local dataIndexEnd = dataIndexBegin;
	while (dataIndexEnd < size) and (extentNext < extentEnd) do
		local nextDataIndex = dataIndexEnd + stride;
		dataIndexEnd = nextDataIndex;

		-- We're oor, which is expected in the case of stride > 1. In this case we're done
		-- and the dataIndexEnd will be clamped into range of the data provider below.
		local extent = self:GetElementExtent(nextDataIndex);
		if extent == nil or extent == 0 then
			break;
		end

		extentNext = extentNext + extent + spacing;
	end

	if stride > 1 then
		dataIndexEnd = math.min(dataIndexEnd - (dataIndexEnd % stride) + stride, size);
	else
		dataIndexEnd = math.min(dataIndexEnd, size);
	end

	return CheckDataIndicesReturn(dataIndexBegin, dataIndexEnd);
end

function ScrollBoxListViewMixin:RecalculateExtent(scrollBox, stride, spacing)
	local function CalculateExtents(extentsTbl, size)
		local total = 0;

		for dataIndex, elementData in self:EnumerateDataProvider() do
			local extent = self:CalculateFrameExtent(dataIndex, elementData);
			table.insert(extentsTbl, extent);
		end

		for dataIndex = 1, size, stride do
			total = total + extentsTbl[dataIndex];
		end

		return total;
	end

	local extent = 0;
	local size = 0;
	local dataProvider = self:GetDataProvider();
	if dataProvider then
		size = dataProvider:GetSize();
		
		local function CalculateTemplateExtents()
			self.templateExtents = {};
			return CalculateExtents(self.templateExtents, size);
		end

		local templateExtentsMismatch = self.templateExtents and #self.templateExtents ~= size;
		if templateExtentsMismatch then
			extent = CalculateTemplateExtents();
		elseif self:HasIdenticalElementExtents() then
			extent = math.ceil(size/stride) * self:GetIdenticalElementExtents();
		elseif self.elementExtentCalculator then
			self.calculatedElementExtents = {};
			extent = CalculateExtents(self.calculatedElementExtents, size);
		else
			extent = CalculateTemplateExtents();
		end
	end
	
	local space = ScrollBoxViewUtil.CalculateSpacingUntil(size, stride, spacing);
	self:SetExtent(extent + space + scrollBox:GetUpperPadding() + scrollBox:GetLowerPadding());
end

function ScrollBoxListViewMixin:GetExtent(scrollBox, stride, spacing)
	if not self:IsExtentValid() then
		self:RecalculateExtent(scrollBox, stride, spacing);
	end
	return self.extent;
end

do
	local function HasEqualTemplateInfoExtents(view)
		local infos = view.templateInfos;
		local refInfo = infos[next(infos)];
		if not refInfo or refInfo.extent <= 0 then
			return false;
		end
	
		for frameTemplate, info in pairs(infos) do
			if not ApproximatelyEqual(refInfo.extent, info.extent) then
				return false;
			end
		end
	
		return true;
	end
	
	function ScrollBoxListViewMixin:HasEqualTemplateInfoExtents()
		if self.templateInfoDirty then
			self.templateInfoDirty = nil;
			self.hasEqualTemplateInfoExtents = HasEqualTemplateInfoExtents(self);
		end
	
		return self.hasEqualTemplateInfoExtents;
	end
end

function ScrollBoxListViewMixin:HasIdenticalElementExtents()
	if self.elementExtentCalculator then
		return false;
	end
	
	if self.elementExtent then
		return true;
	end

	return self:HasEqualTemplateInfoExtents();
end

function ScrollBoxListViewMixin:GetIdenticalElementExtents()
	assert(self:HasIdenticalElementExtents());
	if self.elementExtent then
		return self.elementExtent;
	end

	local info = self.templateInfos[next(self.templateInfos)];
	return info.extent;
end

local function ValidateExtent(extentsTbl, dataIndex)
	if not extentsTbl[dataIndex] then
		Dump(extentsTbl);
		error(string.format("dataIndex %d not found in extents table", dataIndex));
	end
end

function ScrollBoxListViewMixin:GetElementExtent(dataIndex)
	if self:HasIdenticalElementExtents() then 
		return self:GetIdenticalElementExtents();
	end

	local extent = 0;
	if self.calculatedElementExtents then
		extent = self.calculatedElementExtents[dataIndex];
		--ValidateExtent(self.calculatedElementExtents, dataIndex);
	elseif self.templateExtents then
		extent = self.templateExtents[dataIndex];
		--ValidateExtent(self.templateExtents, dataIndex);
	end
	return extent;
end

function ScrollBoxListViewMixin:SetElementExtent(extent)
	self.elementExtent = math.max(extent, 1);
	self.elementExtentCalculator = nil;
	self.templateExtents = nil;
	self.calculatedElementExtents = nil;
end

function ScrollBoxListViewMixin:SetElementExtentCalculator(elementExtentCalculator)
	self.elementExtentCalculator = elementExtentCalculator;
	self.elementExtent = nil;
	self.templateExtents = nil;
	self.calculatedElementExtents = nil;
end

function ScrollBoxListViewMixin:GetElementExtentCalculator()
	return self.elementExtentCalculator;
end

function ScrollBoxListViewMixin:GetExtentUntil(scrollBox, dataIndex, stride, spacing)
	if dataIndex == 0 then
		return 0;
	end

	local index = dataIndex - stride;
	local extent = 0;
	if self:HasIdenticalElementExtents() then
		extent = math.max(0, math.ceil(index / stride)) * self:GetIdenticalElementExtents();
	else
		while index > 0 do
			extent = extent + self:GetElementExtent(index);
			index = index - stride;
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
		local range = {};
		for dataIndex = dataIndexBegin, dataIndexEnd do
			table.insert(range, dataIndex);
		end
		self:AcquireRange(range);
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
		local canRecycle = not invalidated or self:GetInvalidationReason() ~= InvalidationReason.DataProviderReassigned;
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
				for dataIndex, currentElementData in self:EnumerateDataProvider(dataIndexBegin, dataIndexEnd) do
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

			self:AcquireRange(acquireList);

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