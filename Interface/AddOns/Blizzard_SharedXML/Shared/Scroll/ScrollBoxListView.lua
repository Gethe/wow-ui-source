local InvalidationReason = EnumUtil.MakeEnum("DataProviderReassigned", "DataProviderContentsChanged");

ScrollBoxListViewMixin = CreateFromMixins(ScrollBoxViewMixin, CallbackRegistryMixin);
ScrollBoxListViewMixin:GenerateCallbackEvents(
	{
		"OnDataChanged",
		"OnDataProviderReassigned",
		"OnAcquiredFrame",
		"OnInitializedFrame",
		"OnReleasedFrame",
	}
);

function ScrollBoxListViewMixin:Init()
	CallbackRegistryMixin.OnLoad(self);
	ScrollBoxViewMixin.Init(self);

	self.canSignalWithoutInitializer = true;
	self.initializers = {};

	self.frameFactory = CreateFrameFactory();
	self.templateInfoCache = self.frameFactory:GetTemplateInfoCache();

	self.factory = function(frameTemplateOrFrameType, initializer)
		local frame, new = self.frameFactory:Create(self:GetScrollTarget(), frameTemplateOrFrameType, self.frameFactoryResetter);
		self.initializers[frame] = initializer;

		if not frame then
			error(string.format("ScrollBoxListViewMixin: Failed to create a frame from pool for frame template or frame type '%s'", frameTemplateOrFrameType));
		end
		
		-- The frame and new values are captured here instead of being returned to prevent the callee from having
		-- access to the frame prior to it being properly anchored or arranged. The frame's initializer will be called
		-- once all frames have been arranged in the layout step.
		self.factoryFrame = frame;
		self.factoryFrameIsNew = new;
	end

	-- For convenience of not having to call SetElementExtent during view setup, automatically set the element extent, 
	-- as long as it hasn't already been set, and the view isn't configured to calculate it instead.
	if self.frameTemplateOrFrameType ~= nil then
		if not self:HasElementExtent() and not self:HasAnyExtentOrSizeCalculator() then
			if C_XMLUtil.GetTemplateInfo(frameTemplate) == nil then
				error("Failed to assign an explicit element extent or set an extent calculator.");
			end

			local extent = self:GetTemplateExtent(self.frameTemplateOrFrameType);
			if extent > 0 then
				self:SetElementExtent(extent);
			end
		end
		self.frameTemplateOrFrameType = nil;
	end
end

function ScrollBoxListViewMixin:GetExtentFromInfo(info)
	return self:IsHorizontal() and info.width or info.height;
end

function ScrollBoxListViewMixin:GetTemplateInfo(frameTemplate)
	return self.templateInfoCache:GetTemplateInfo(frameTemplate);
end

function ScrollBoxListViewMixin:GetFirstTemplateInfo()
	local infos = self.templateInfoCache:GetTemplateInfos();
	return infos[next(infos)];
end

function ScrollBoxListViewMixin:AssignAccessors(frame, elementData)
	--[[ 
	Provides an accessor to the underlying data. If the elements in your data provider 
	wrap this data in any way (as is done in TreeDataProvider), ensure that the data
	can be retrieved via your view's TranslateElementDataToUnderlyingData function. Note
	that this function was provided after all of the conversions occured in 10.0, so many
	calls to GetElementData() would be correct to be replaced with GetData() below. However,
	since nearly all of these cases pertain to linear view, the return result is the same.
	]]--

	local view = self;

	frame.GetData = function(self)
		return view:TranslateElementDataToUnderlyingData(elementData);
	end
	
	--[[ 
	Should always return the data stored in the data provider. Views require this function
	to relate data provider elements with their frame counterpart. This elementData could be
	the same as the underlying data, or it could be a tree node.
	]]--
	frame.GetElementData = function(self)
		return elementData;
	end;
	
	frame.GetElementDataIndex = function(self)
		return view:FindElementDataIndex(elementData);
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
	frame.GetElementDataIndex = nil;
	frame.GetData = nil;
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
	self.frameFactory:ReleaseAll();

	self:RemoveDataProvider();
end

function ScrollBoxListViewMixin:ForEachFrame(func)
	for index, frame in ipairs(self:GetFrames()) do
		local result = func(frame, frame:GetElementData());
		if result then
			return result;
		end
	end

	return nil;
end

function ScrollBoxListViewMixin:ReverseForEachFrame(func)
	for index, frame in ipairs_reverse(self:GetFrames()) do
		if func(frame, frame:GetElementData()) then
			return;
		end
	end
end

function ScrollBoxListViewMixin:EnumerateFrames()
	return ipairs(self:GetFrames());
end

function ScrollBoxListViewMixin:FindFrame(elementData)
	for index, frame in ipairs(self:GetFrames()) do
		if frame:ElementDataMatches(elementData) then
			return frame;
		end
	end
end
 
function ScrollBoxListViewMixin:FindFrameElementDataIndex(findFrame)
	local dataIndexBegin = self:GetDataIndexBegin();
	for index, frame in ipairs(self:GetFrames()) do
		if frame == findFrame then
			return dataIndexBegin + (index - 1);
		end
	end
end

--[[ Accessor warnings
DataProvider method overrides may be required if the view expects non-contiguous
element ranges to be displayed. See TreeListDataProvider as an example.
--]]
function ScrollBoxListViewMixin:ForEachElementData(func)
	self:GetDataProvider():ForEach(func);
end

function ScrollBoxListViewMixin:ReverseForEachElementData(func)
	self:GetDataProvider():ReverseForEach(func);
end

function ScrollBoxListViewMixin:FindElementData(index)
	return self:GetDataProvider():Find(index);
end

function ScrollBoxListViewMixin:FindElementDataIndex(elementData)
	return self:GetDataProvider():FindIndex(elementData);
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

function ScrollBoxListViewMixin:ContainsElementDataByPredicate(predicate)
	return self:GetDataProvider():ContainsByPredicate(predicate);
end

function ScrollBoxListViewMixin:EnumerateDataProviderEntireRange()
	return self:GetDataProvider():EnumerateEntireRange();
end

function ScrollBoxListViewMixin:EnumerateDataProvider(indexBegin, indexEnd)
	return self:GetDataProvider():Enumerate(indexBegin, indexEnd);
end

function ScrollBoxListViewMixin:ReverseEnumerateDataProviderEntireRange()
	return self:GetDataProvider():ReverseEnumerateEntireRange();
end

function ScrollBoxListViewMixin:ReverseEnumerateDataProvider(indexBegin, indexEnd)
	return self:GetDataProvider():ReverseEnumerate(indexBegin, indexEnd);
end

function ScrollBoxListViewMixin:GetDataProviderSize()
	local dataProvider = self:GetDataProvider();
	if dataProvider then
		return dataProvider:GetSize();
	end
	return 0;
end

function ScrollBoxListViewMixin:TranslateElementDataToUnderlyingData(elementData)
	return elementData;
end

function ScrollBoxListViewMixin:IsScrollToDataIndexSafe()
	return true;
end

function ScrollBoxListViewMixin:PrepareScrollToElementDataByPredicate(predicate)
	-- Optionally derived to ensure the view can locate the required element. See ScrollBoxTreeView as an example.
end

function ScrollBoxListViewMixin:PrepareScrollToElementData(elementData)
	-- Optionally derived to ensure the view can locate the required element. See ScrollBoxTreeView as an example.
end
-- End of accessor warning section

function ScrollBoxListViewMixin:GetDataProvider()
	return self.dataProvider;
end

function ScrollBoxListViewMixin:HasDataProvider()
	return self.dataProvider ~= nil;
end

function ScrollBoxListViewMixin:RemoveDataProviderInternal()
	local dataProvider = self:GetDataProvider();
	if dataProvider then
		dataProvider:UnregisterCallback(DataProviderMixin.Event.OnSizeChanged, self);
		dataProvider:UnregisterCallback(DataProviderMixin.Event.OnSort, self);
	end

	self.dataProvider = nil;

	-- Anytime the data provider is discarded we also want to discard any cached extent and size data.
	self:ClearCachedData();
end

function ScrollBoxListViewMixin:RemoveDataProvider()
	self:RemoveDataProviderInternal();
	self:SignalDataChangeEvent(InvalidationReason.DataProviderReassigned);
end

function ScrollBoxListViewMixin:FlushDataProvider()
	local dataProvider = self:GetDataProvider();
	if dataProvider then
		dataProvider:Flush();
	end
end

function ScrollBoxListViewMixin:SetDataProvider(dataProvider, retainScrollPosition)
	if dataProvider == nil then
		error("SetDataProvider() dataProvider was nil. Call RemoveDataProvider() if this was your intent.");
	end

	if self.elementFactory == nil then
		error("SetDataProvider() elementFactory was nil. Call SetElementFactory() before setting the data provider.");
	end

	self:RemoveDataProviderInternal();

	self.dataProvider = dataProvider;
	if dataProvider then
		dataProvider:RegisterCallback(DataProviderMixin.Event.OnSizeChanged, self.OnDataProviderSizeChanged, self);
		dataProvider:RegisterCallback(DataProviderMixin.Event.OnSort, self.OnDataProviderSort, self);
	end
	
	self:TriggerEvent(ScrollBoxListViewMixin.Event.OnDataProviderReassigned);
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

	-- Resize the frame.
	self:ResizeFrame(self:GetScrollBox(), frame, dataIndex, elementData);

	-- Assign any accessors required by ScrollBox or this view on the frame.
	self:AssignAccessors(frame, elementData);

	-- Order index required for frame level sorting.
	frame:SetOrderIndex(dataIndex);
	frame:Show();

	self:TriggerEvent(ScrollBoxListViewMixin.Event.OnAcquiredFrame, frame, elementData, new);

	self:SetAcquireLocked(false);
end

function ScrollBoxListViewMixin:InvokeInitializer(frame, initializer)
	local elementData = frame:GetElementData();
	if initializer then
		initializer(frame, elementData);
	end

	-- OnInitializedFrame is still called even if there isn't an initializer because an addon
	-- may still want this event. The cases where elements are used without an initializer (dividers, etc.)
	-- imply they would be using a factory initializer instead of an element initializer, and 
	-- since they are able to check the element data type there, they can also check it in the event callback. 
	-- To be safe, this is behavior will be configurable, but on by default.
	if initializer or self.canSignalWithoutInitializer then
		self:TriggerEvent(ScrollBoxListViewMixin.Event.OnInitializedFrame, frame, elementData);
	end
end

-- Frame initialization is no longer supported during the factory step. The initializer passed to the
-- factory object is called once layout has completed, ensuring that the frame can access it's effective
-- dimensions inside it's own initializer.
function ScrollBoxListViewMixin:InvokeInitializers()
	local function SecureInvokeInitializer(frame, initializer)
		self:InvokeInitializer(frame, initializer);
	end

	secureexecuterange(self.initializers, SecureInvokeInitializer);
	wipe(self.initializers);
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

function ScrollBoxListViewMixin:ReinitializeFrames()
	for index, frame in self:EnumerateFrames() do
		local elementData = frame:GetElementData();
		local template, initializer = self:GetFactoryDataFromElementData(elementData);
		self:InvokeInitializer(frame, initializer);
	end
end

function ScrollBoxListViewMixin:Release(frame)
	local elementData = frame:GetElementData();

	if self.frameResetter then
		self.frameResetter(frame, elementData);
	end

	self:TriggerEvent(ScrollBoxListViewMixin.Event.OnReleasedFrame, frame, elementData);
	
	tDeleteItem(self:GetFrames(), frame);
	self.frameFactory:Release(frame);

	self:UnassignAccessors(frame);

	self.initializers[frame] = nil;
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
	self:SetElementFactory(function(factory, elementData)
		factory(frameTemplateOrFrameType, initializer);
	end);

	-- Store this frame type so that we can try to set the element extent in Init(), if appropriate.
	-- We want to defer that so the order of initialization related function calls is unimportant.
	-- (ex. Calling SetElementExtent before SetElementInitializer, and vice-versa). We cannot do 
	-- this for multiple element factories because element data is required to determine the template
	-- type used.
	self.frameTemplateOrFrameType = frameTemplateOrFrameType;
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

function ScrollBoxListViewMixin:SetFrameFactoryResetter(resetter)
	self.frameFactoryResetter = resetter;
end

function ScrollBoxListViewMixin:SetElementResetter(resetter)
	self.frameResetter = resetter;
end

function ScrollBoxListViewMixin:SetVirtualized(virtualized)
	self.virtualized = virtualized;
end

	-- This local factory function allows us to ask for the template and initializer
	-- without actually creating a frame. This is useful in these cases:
	-- 1) Asking for the template extents before a frame is created
	-- 2) Asking for the template and initializer for creating a drag and drop cursor attachment
	-- 3) Asking for the initializers again to reinitialize every visible frame
do
	local template;
	local initializer;
	local factory = function(frameTemplate, frameInitializer)
		template = frameTemplate;
		initializer = frameInitializer;
	end;
	
	function ScrollBoxListViewMixin:GetFactoryDataFromElementData(elementData)
		self.elementFactory(factory, elementData);
		return template, initializer;
	end
end

-- An optimization to avoid unnecessarily fetching the template and template info
-- is planned in a future version. In the meantime, this must occur before calculating
-- the extent.
function ScrollBoxListViewMixin:PrepareRecalculateExtent()
	local dataProvider = self:GetDataProvider();
	if not dataProvider then
		return;
	end

	local size = self:GetDataProviderSize();
	if size == 0 then
		return;
	end

	-- IndexRangeDataProvider is virtual and can represent thousands
	-- of elements whom are only ever represented by a single template.
	local enumerateSize = dataProvider:IsVirtual() and 1 or size;
	for dataIndex, elementData in self:EnumerateDataProvider(1, enumerateSize) do
		self:CacheTemplateInfoFromElementData(elementData);
	end
end

function ScrollBoxListViewMixin:CacheTemplateInfoFromElementData(elementData)
	local frameTemplate, initializer = self:GetFactoryDataFromElementData(elementData);
	self:GetTemplateInfo(frameTemplate);
end

function ScrollBoxListViewMixin:GetTemplateExtent(frameTemplate)
	local info = self:GetTemplateInfo(frameTemplate);
	if not info then
		error(string.format("GetTemplateExtent: Failed to obtain template info for frame template '%s'", frameTemplate));
	end
	return self:GetExtentFromInfo(info);
end

function ScrollBoxListViewMixin:IsVirtualized()
	return self.virtualized ~= false;
end

function ScrollBoxListViewMixin:GetExtentUntil(scrollBox, dataIndexEnd)
	error("GetExtentUntil implementation required")
end

function ScrollBoxListViewMixin:GetExtentTo(scrollBox, dataIndexEnd)
	error("GetExtentTo implementation required")
end

function ScrollBoxListViewMixin:CalculateDataIndices(scrollBox)
	error("CalculateDataIndices implementation required")
end

function ScrollBoxListViewMixin:RecalculateExtent(scrollBox)
	error("RecalculateExtent implementation required")
end

function ScrollBoxListViewMixin:GetExtentSpacing(scrollBox)
	error("GetExtentSpacing implementation required")
end

function ScrollBoxListViewMixin:GetElementExtent(dataIndex)
	error("GetElementExtent implementation required")
end

function ScrollBoxListViewMixin:HasAnyExtentOrSizeCalculator()
	error("HasAnyExtentOrSizeCalculator implementation required")
end

function ScrollBoxListViewMixin:CalculateFrameExtent()
	error("CalculateFrameExtent implementation required")
end

function ScrollBoxListViewMixin:GetPanExtent(scrollBox)
	if not self.panExtent and self:HasDataProvider() then
		for dataIndex, elementData in self:EnumerateDataProvider() do -- luacheck: ignore 512 (loop is executed at most once)
			local panExtent = self:CalculateFrameExtent(dataIndex, elementData);
			if panExtent > 0 then
				self.panExtent = panExtent;
			end
			break;
		end
	end

	if not self.panExtent then
		return 0;
	end
	
	local panExtent = self.panExtent + self:GetExtentSpacing();
	if self.maxPanExtent and (panExtent > self.maxPanExtent) then
		return self.maxPanExtent;
	end

	return panExtent;
end

function ScrollBoxListViewMixin:ClearElementExtentData()
	self.elementExtent = nil;
end

function ScrollBoxListViewMixin:SetElementExtent(extent)
	self:ClearElementExtentData();
	self.elementExtent = math.max(extent, 1);
end

function ScrollBoxListViewMixin:HasElementExtent()
	return self.elementExtent ~= nil;
end

function ScrollBoxListViewMixin:GetDataScrollOffset(scrollBox)
	local dataIndexBegin, dataIndexEnd = self:CalculateDataIndices(scrollBox);
	local extent = self:GetExtentUntil(scrollBox, dataIndexBegin);
	return extent + scrollBox:GetUpperPadding();
end

function ScrollBoxListViewMixin:ValidateDataRange(scrollBox)
	-- Calculate the range of indices to display.
	local oldDataIndexBegin, oldDataIndexEnd = self:GetDataRange();
	local dataIndexBegin, dataIndexEnd = self:CalculateDataIndices(scrollBox);

	-- Invalidation occurs whenever the data provider is sorted, the size changes, or the data provider is replaced.
	local invalidated = self:IsInvalidated();
	local rangeChanged = invalidated or oldDataIndexBegin ~= dataIndexBegin or oldDataIndexEnd ~= dataIndexEnd;
	if rangeChanged then
		--[[
			local size = self:GetDataProviderSize();
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
			for index, frame in ipairs_reverse(self:GetFrames()) do
				self:Release(frame);
			end

			dataIndexBegin, dataIndexEnd = self:GetDataRange();
			if dataIndexEnd > 0 then
				local range = {};
				for dataIndex = dataIndexBegin, dataIndexEnd do
					table.insert(range, dataIndex);
				end
				self:AcquireRange(range);
			end
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
