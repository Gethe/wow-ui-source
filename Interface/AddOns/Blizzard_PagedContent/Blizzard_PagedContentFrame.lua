--[[
	Frame for displaying paginated elements. Supports spaced groups of elements, variable layouts, and multiple views.

	A View here is a container of elements. One or more may visible on a single page depending on your design (most cases only need 1).
	Element data is split into views based on how many elements can fit within a single view, as calculated by layout-specific derived mixins.
	Splitting into view buckets is done ahead of time, rather than recalculated every time current page changes.
	For simplicity, it is assumed that all ViewFrames are the same size and use the same layout settings.

	Example of 1 view per page:
	 ________page1______    ________page2______    ________page3______
	|  ______view1____  |  |  ______view2____  |  |  ______view3____  |
	| |element element| |  | |element element| |  | |element element| |
	| |element element| |  | |element element| |  | |element        | |
	| |_______________| |  | |_______________| |  | |_______________| |
	|___________________|  |___________________|  |___________________|

	Example of 2 views per page:
     ________________page1________________   ________________page2________________
	|  ______view1____   ______view2____  | |  ______view3____   ______view4____  |
	| |element element| |element element| | | |element element| |               | |
	| |element element| |element element| | | |element        | |               | |
	| |_______________| |_______________| | | |_______________| |_______________| |
	|_____________________________________| |_____________________________________|
]]

PagedContentFrameBaseMixin = CreateFromMixins(CallbackRegistryMixin);

PagedContentFrameBaseMixin:GenerateCallbackEvents(
	{
		"OnUpdate",
	}
);

function PagedContentFrameBaseMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self.cachedTemplateInfos = {};
	self.viewsPerPage = self.viewsPerPage or #self.ViewFrames;
	self.framePoolCollection = CreateFramePoolCollection();
	-- Extra table used to cache instantiated non-spacer frames so they can be retrieved/enumerated in order of instantiation
	-- Since enumerating via framePoolCollection doesn't guarantee any reliable order
	self.frames = {};
end

--[[
	Set the template data used to determine how to display content elements.
	Expects pairs of templateKeys to templateData:
	{	
	--	[templateKey] = templateData
		["Header"] = { template = "MyHeaderTemplate", initFunc = MyHeader.Init, resetFunc = MyHeader.Reset },
		["RoundButton"] = { template = "MyRoundButtonTemplate", ...}
	}
	templateKey: [string] key for associating elementData with the template it should use
	templateData:
		template: [string] Name of template frame used for elements with matching templateKey
		initFunc: [function(elementFrame, elementData)] Optional function for initializing elements after acquiring from pool
		resetFunc: [function(framePool, elementFrame)] Optional function for resetting elements on releasing to pool
]]
function PagedContentFrameBaseMixin:SetElementTemplateData(templateData)
	self.elementTemplateData = templateData;
	self.cachedTemplateInfos = {};
end

--[[
	Set the data provider containing the element data to be displayed.
	Expected provider collection is list of one or more data groups, each with an optional header + elements list:
	{
	--	{ header = elementData, elements = {elementData, elementData, ... }}
		{ header = { templateKey = "Header", text = "Header One" }, elements = { { templateKey = "RoundButton", id = 1 }, { templateKey = "SquareButton", id = 3 }, ... } },
		{ elements = { { templateKey = "RoundButton", id = 11 }, ... }	},
	}
	header: [elementData] Optional, header data for the group; layout logic prevents headers from displaying alone at the end of a view
	elements: [elementData list] List of elements that make up the group
	elementData:
		templateKey: [string] key for identifying which template data to use to display the element
		(+ whatever additional properties expected by mixins)
]]
function PagedContentFrameBaseMixin:SetDataProvider(dataProvider, retainCurrentPage)
	if not self.elementTemplateData then
		error("SetElementTemplateData must be called before any SetDataProvider calls");
	end

	local skipPageReset = true;
	self:InternalRemoveDataProvider(skipPageReset);

	self.dataProvider = dataProvider;

	self:UpdateElementViewDistribution();

	if not retainCurrentPage and self.PagingControls:GetCurrentPage() ~= 1 then
		-- Reset to page 1, which will trigger DisplayViewsForCurrentPage
		self.PagingControls:SetCurrentPage(1);
	else
		-- Otherwise, page isn't changing, just trigger manually
		self:DisplayViewsForCurrentPage();
	end
end

function PagedContentFrameBaseMixin:RemoveDataProvider()
	local skipPageReset = false;
	self:InternalRemoveDataProvider(skipPageReset);
end

function PagedContentFrameBaseMixin:SetViewsPerPage(viewsPerPage, retainCurrentPage)
	if viewsPerPage == self.viewsPerPage then
		return;
	end
	if not self.viewDataList then
		self.viewsPerPage = viewsPerPage;
		return;
	end

	local newCurrentPage = 1;
	local currentPage = self.PagingControls:GetCurrentPage();
	-- Cache the current leftmost view data index being displayed 
	-- That's what we'll try to focus if retaining across view count change
	local currentFirstViewIndex = self:GetViewDataIndexForPage(currentPage);

	self.viewsPerPage = viewsPerPage;

	if retainCurrentPage then
		newCurrentPage = self:GetPageForViewDataIndex(currentFirstViewIndex);
	end
	
	local maxPages = math.max(1, math.ceil(#self.viewDataList / self.viewsPerPage));
	self.PagingControls:SetMaxPages(maxPages);

	if self.PagingControls:GetCurrentPage() ~= newCurrentPage then
		-- Reset to page, which will trigger DisplayViewsForCurrentPage
		self.PagingControls:SetCurrentPage(newCurrentPage);
	else
		-- Otherwise, page isn't changing, just trigger manually
		self:DisplayViewsForCurrentPage();
	end
end

function PagedContentFrameBaseMixin:InternalRemoveDataProvider(skipPageReset)
	if self.dataProvider then
		self.dataProvider:UnregisterCallback(DataProviderMixin.Event.OnSizeChanged, self);
		self.dataProvider:UnregisterCallback(DataProviderMixin.Event.OnSort, self);
	end
	self.dataProvider = nil;

	self.viewDataList = nil;
	self.framePoolCollection:ReleaseAll();
	self.frames = {};

	if not skipPageReset then
		self.PagingControls:SetMaxPages(1);
	end
end

function PagedContentFrameBaseMixin:UpdateElementViewDistribution()
	self.viewDataList = self:SplitElementsIntoViewData();
	local maxPages = math.max(1, math.ceil(#self.viewDataList / self.viewsPerPage));
	self.PagingControls:SetMaxPages(maxPages);
end

-- Calculates what view data index would show on the specified page, in the specified view frame
-- Ex: If displaying page 3, which view data would display in view frame 2
function PagedContentFrameBaseMixin:GetViewDataIndexForPage(pageNumber, viewFrameIndex)
	viewFrameIndex = viewFrameIndex or 1;
	return ((pageNumber - 1) * self.viewsPerPage) + viewFrameIndex;
end

-- Calculates what page number would display the specified view index
function PagedContentFrameBaseMixin:GetPageForViewDataIndex(viewIndex)
	return math.ceil(viewIndex / self.viewsPerPage);
end

function PagedContentFrameBaseMixin:GetFrames()
	return self.frames or {};
end

function PagedContentFrameBaseMixin:EnumerateFrames()
	return ipairs(self:GetFrames());
end

function PagedContentFrameBaseMixin:ForEachFrame(func)
	for i, frame in self:EnumerateFrames() do
		if frame.GetElementData and func(frame, frame:GetElementData()) then
			return;
		end
	end
end

-- Switches to the page containing the element matching the provided predicateFunc(elementData) and returns the frame for that element
function PagedContentFrameBaseMixin:GoToElementByPredicate(predicateFunc)
	if not self.viewDataList then
		return nil;
	end

	for viewDataIndex, viewData in ipairs(self.viewDataList) do
		for elementIndex, elementData in ipairs(viewData) do
			if not elementData.isSpacer and predicateFunc(elementData) then
				local pageForView = self:GetPageForViewDataIndex(viewDataIndex);
				self.PagingControls:SetCurrentPage(pageForView);
				local templateInfo = self:InternalGetTemplateInfo(elementData.templateKey);
				return self:GetElementFrameByPredicateAndTemplate(predicateFunc, templateInfo.template, elementData.templateKey);
			end
		end
	end

	return nil;
end

-- Returns the element frame that matches the specified predicateFunc(elementData)
-- Will only find frame for elements active on the current page (see GoToElementByPredicate for switching pages to a specific element)
-- Less efficient than GetElementFrameByPredicateAndTemplate
function PagedContentFrameBaseMixin:GetElementFrameByPredicate(predicateFunc)
	for i, elementFrame in self:EnumerateFrames() do
		if elementFrame.GetElementData and predicateFunc(elementFrame:GetElementData()) then
			return elementFrame;
		end
	end
	return nil;
end

-- Returns the element frame that matches the specified predicateFunc(elementData) and uses the specified template
-- Will only find frame for elements active on the current page (see GoToElementByPredicate for switching pages to a specific element)
-- More efficient than GetElementFrameByPredicate
function PagedContentFrameBaseMixin:GetElementFrameByPredicateAndTemplate(predicateFunc, template, templateKey)
	for elementFrame in self.framePoolCollection:EnumerateActiveByTemplate(template, templateKey) do
		if elementFrame.GetElementData and predicateFunc(elementFrame:GetElementData()) then
			return elementFrame;
		end
	end
	return nil;
end

function PagedContentFrameBaseMixin:OnMouseWheel(delta)
	self.PagingControls:OnMouseWheel(delta);
end

function PagedContentFrameBaseMixin:OnDataProviderSizeChanged(pendingSort)
	-- Defer if we're about to be sorted since we have a handler for that.
	if not pendingSort then
		self:OnDataProviderContentsChanged();
	end
end

function PagedContentFrameBaseMixin:OnDataProviderSort()
	self:OnDataProviderContentsChanged();
end

function PagedContentFrameBaseMixin:OnDataProviderContentsChanged()
	self:UpdateElementViewDistribution();
	self:DisplayViewsForCurrentPage();
end

function PagedContentFrameBaseMixin:OnPageChanged()
	self:DisplayViewsForCurrentPage();
end

function PagedContentFrameBaseMixin:InternalGetTemplateInfo(templateKey)
	if not templateKey or templateKey == "" then
		return nil;
	end

	local templateInfo = self.cachedTemplateInfos[templateKey];

	if templateInfo then
		return templateInfo;
	end

	if templateKey == self.spacerTemplate then
		templateInfo = C_XMLUtil.GetTemplateInfo(self.spacerTemplate);
		templateInfo.template = self.spacerTemplate;
	else
		local templateData = self.elementTemplateData[templateKey];

		if not templateData then
			error(string.format("PagedContentFrameBaseMixin: Failed to find template data for template key '%s'", templateKey));
		end
	
		-- Cache extra information about this element's template
		templateInfo = C_XMLUtil.GetTemplateInfo(templateData.template);
		templateInfo.template = templateData.template;
		templateInfo.initFunc = templateData.initFunc;
		templateInfo.resetFunc = templateData.resetFunc;
	end
		
	self:ProcessTemplateInfo(templateInfo);
	
	self.cachedTemplateInfos[templateKey] = templateInfo;

	return templateInfo;
end

-- Split element data into buckets based on how many can fit per-view
function PagedContentFrameBaseMixin:SplitElementsIntoViewData()
	if not self.dataProvider then
		return;
	end

	local splitData = {
		viewDataList = {},
		currentViewData = {},
		totalViewSpace = 0,
		viewSpaceRemaining = 0,
		totalSpacerSize = 0,
	}

	-- We currently assume all ViewFrames are sized and layed out the same
	-- If that ever changes, this logic will get more complicated and changing viewsPerFrame at runtime will get more expensive
	local viewFrame = self.ViewFrames[1];

	-- Initialize any layout-specific state-tracking data
	self:InitializeElementSplit(splitData, viewFrame);

	splitData.totalViewSpace = self:GetTotalViewSpace(viewFrame);
	splitData.viewSpaceRemaining = splitData.totalViewSpace;
	local groupSpacerInfo = self.spacerTemplate and self:InternalGetTemplateInfo(self.spacerTemplate) or nil;
	splitData.totalSpacerSize = groupSpacerInfo and self:GetViewSpaceNeededForSpacer(splitData, groupSpacerInfo) or 0;

	self:OnNewViewStarted(splitData);
	for groupIndex, dataGroup in self.dataProvider:Enumerate() do
		self:OnDataGroupStarted(splitData, dataGroup);

		if dataGroup.header then
			local isHeader = true;
			self:ProcessElement(splitData, dataGroup.header, -1, isHeader, dataGroup);
		end

		for elementIndex, elementData in ipairs(dataGroup.elements) do
			local isHeader = false;
			self:ProcessElement(splitData, elementData, elementIndex, isHeader, dataGroup);
		end
	end
	table.insert(splitData.viewDataList, splitData.currentViewData);

	return splitData.viewDataList;
end

function PagedContentFrameBaseMixin:ProcessElement(splitData, elementData, elementIndex, isHeader, dataGroup)
	elementData.isHeader = isHeader;
	local elementTemplateInfo = self:InternalGetTemplateInfo(elementData.templateKey);

	local isFirstElementInGroup = isHeader or (not dataGroup.header and elementIndex == 1);
	-- If this is the first elementData in a new group, on a view with other content, a spacer is needed to break up the groups
	local needsGroupSpacer = splitData.totalSpacerSize > 0 and isFirstElementInGroup and #splitData.currentViewData > 0;

	-- Some layouts can conditionally skip checking an element for space fit, for example if there's still room in an existing grid row to fit the element
	if self:WillElementUseTrackedViewSpace(splitData, elementData, elementTemplateInfo, needsGroupSpacer) then
		local sizeForElement = self:GetViewSpaceNeededForElement(splitData, elementData, elementTemplateInfo);
		local totalSizeNeededForElement = sizeForElement;
		local sizeForNextElement = 0;

		if needsGroupSpacer then
			totalSizeNeededForElement = totalSizeNeededForElement + splitData.totalSpacerSize;
		end

		if dataGroup.elements and ((isHeader and #dataGroup.elements > 0) or (not isHeader and #dataGroup.elements > elementIndex)) then
			-- Cache next element's size, either for Header checks or just approximate next element placement calculations
			local nextElementIndex = isHeader and 1 or elementIndex + 1;
			local nextElementData = dataGroup.elements[nextElementIndex];
			local nextTemplateInfo = self:InternalGetTemplateInfo(nextElementData.templateKey);
			sizeForNextElement = self:GetViewSpaceNeededForElement(splitData, nextElementData, nextTemplateInfo);
		end

		-- If elementData is a header, ensure there's room to include at least one of the group's elements after it
		-- This avoids a header awkwardly displaying by itself at the end of a view
		if isHeader and dataGroup.elements and #dataGroup.elements > 0 then
			totalSizeNeededForElement = totalSizeNeededForElement + sizeForNextElement;
		end

		-- Not enough space, Start a new view
		if self:ShouldStartNewView(splitData.viewSpaceRemaining, totalSizeNeededForElement, splitData) then
			table.insert(splitData.viewDataList, splitData.currentViewData);
			splitData.viewSpaceRemaining = splitData.totalViewSpace;
			splitData.currentViewData = {};
			needsGroupSpacer = false; -- No longer need a group spacer if we're moving to a new view
			self:OnNewViewStarted(splitData);
		end

		-- Spacer definitely needed, add it
		if needsGroupSpacer then
			local spacerData = { isSpacer = true };
			table.insert(splitData.currentViewData, spacerData)
			splitData.viewSpaceRemaining = splitData.viewSpaceRemaining - splitData.totalSpacerSize;
			self:OnSpacerAddedToView(splitData, spacerData);
		end

		splitData.viewSpaceRemaining = splitData.viewSpaceRemaining - sizeForElement;
		-- Let layout code know element space was removed from remaining view space so it can do any other state changes
		self:OnElementSpaceTakenFromView(splitData, elementData, elementTemplateInfo, sizeForElement, sizeForNextElement);
	end

	table.insert(splitData.currentViewData, elementData);
	self:OnElementAddedToView(splitData, elementData, elementTemplateInfo);
end

-- Display elements for current page based on pre-determined view buckets
function PagedContentFrameBaseMixin:DisplayViewsForCurrentPage()
	self.framePoolCollection:ReleaseAll();
	self.frames = {};

	if self.viewDataList == nil or #self.viewDataList == 0 then
		return;
	end

	local currentPage = self.PagingControls:GetCurrentPage();
	local spacerTemplateInfo = self.spacerTemplate and self:InternalGetTemplateInfo(self.spacerTemplate) or nil;

	for viewFrameIndex = 1, self.viewsPerPage do
		local viewDataIndex = self:GetViewDataIndexForPage(currentPage, viewFrameIndex);
		local viewData = self.viewDataList[viewDataIndex];

		if viewData then
			local viewFrame = self.ViewFrames[viewFrameIndex];

			local layoutFrames = {};
			for elementIndex, elementData in ipairs(viewData) do
				-- Instantiate spacer frame
				if elementData.isSpacer then
					if spacerTemplateInfo then
						local spacerPool = self.framePoolCollection:GetOrCreatePool(spacerTemplateInfo.type, nil, self.spacerTemplate);
						local spacerFrame = spacerPool:Acquire();
						spacerFrame.isSpacer = true;
						self:ProcessSpacerFrame(spacerFrame, elementData, elementIndex);

						spacerFrame:SetParent(viewFrame);
						table.insert(layoutFrames, spacerFrame);
					end

				-- Instantiate a regular element frame
				else
					local elementTemplateInfo = self:InternalGetTemplateInfo(elementData.templateKey);
					local elementPool = self.framePoolCollection:GetOrCreatePool(elementTemplateInfo.type, nil, elementTemplateInfo.template, elementTemplateInfo.resetFunc, nil, elementData.templateKey);
					local elementFrame = elementPool:Acquire();
					table.insert(self:GetFrames(), elementFrame);
					
					self:ProcessElementFrame(elementFrame, elementData, elementIndex);

					elementFrame:SetParent(viewFrame);
					table.insert(layoutFrames, elementFrame);

					elementFrame.GetElementData = function()
						return elementData;
					end;
				end
			end

			self:ApplyLayout(layoutFrames, viewFrame);

			-- Initialize and show frames AFTER layout applied so that they're working with their actual anchoring/dimensions
			for index, elementFrame in ipairs(layoutFrames) do
				if elementFrame.GetElementData then
					local elementData = elementFrame.GetElementData();
					local elementTemplateInfo = self:InternalGetTemplateInfo(elementData.templateKey);
					if elementTemplateInfo.initFunc then
						elementTemplateInfo.initFunc(elementFrame, elementData);
					end
				end

				elementFrame:Show();
			end
		end
	end

	self:TriggerEvent(PagedContentFrameBaseMixin.Event.OnUpdate);
end


--------- Layout-specific derived mixin functions ---------

function PagedContentFrameBaseMixin:ProcessTemplateInfo(templateInfo)
	-- Optional 
	-- Cache additional layout-specific info in templateInfo
end

function PagedContentFrameBaseMixin:InitializeElementSplit(splitData, viewFrame)
	-- Optional 
	-- Add initial layout-specific state info to splitData as needed for other split functions
end

function PagedContentFrameBaseMixin:GetTotalViewSpace(viewFrame)
	-- Required 
	-- Return total amount of space available within a view before population
	assert(false);
end

function PagedContentFrameBaseMixin:OnDataGroupStarted(splitData, dataGroup)
	-- Optional
	-- Do any layout-specific data caching/clearing in preparation for the start of a new group of elements
	-- This function should NOT process/position any of the elements or headers in this group
end

function PagedContentFrameBaseMixin:GetViewSpaceNeededForElement(splitData, elementData, elementTemplateInfo)
	-- Required
	-- Return total amount of space an element takes up within a view
	-- This should consider both dimmensional size and any between-element padding
	-- This should NOT consider group spacer size, or "first element after header" size
	assert(false);
end

function PagedContentFrameBaseMixin:GetViewSpaceNeededForSpacer(splitData, spacerTemplateInfo)
	-- Required
	-- Return total amount of space the group spacer takes up within a view
	-- This should consider both self.spacerSize and any between-element padding
	assert(false);
end

function PagedContentFrameBaseMixin:WillElementUseTrackedViewSpace(splitData, elementData, elementTemplateInfo, needsGroupSpacer)
	-- Required
	-- Return false if adding this next element to the view will not result in the view taking up additional tracked space within the view.
	-- For example, if using a grid layout and the tracked view space is height, you may return false if the next element can fit within an
	-- already-in-progress row, since that row height will have already been accounted for.
	assert(false);
end

function PagedContentFrameBaseMixin:ShouldStartNewView(viewSpaceRemaining, totalSizeNeededForElement, splitData)
	-- Optional Override
	-- Override if layout-specific logic requires more complicated checks around space taken vs remaining available.
	return viewSpaceRemaining < totalSizeNeededForElement;
end

function PagedContentFrameBaseMixin:OnNewViewStarted(splitData)
	-- Optional
	-- Called when a new View starts being filled, either because it's the first one or because the previous one was full
	-- Do any layout-specific data caching/clearing in preparation for the start of the new View
end

function PagedContentFrameBaseMixin:OnElementSpaceTakenFromView(splitData, elementData, elementTemplateInfo, spaceTaken, sizeOfNextElement)
	-- Optional
	-- Called when an element has taken up some available view space
	-- Separate from OnElementAddedToView as not all added elements take up tracked space (see WillElementUseTrackedViewSpace)
end

function PagedContentFrameBaseMixin:OnElementAddedToView(splitData, elementData, elementTemplateInfo)
	-- Optional
	-- Called when an element has been added to view data
	-- Separate from OnElementSpaceTakenFromView as not all added elements take up tracked space (see WillElementUseTrackedViewSpace)
end

function PagedContentFrameBaseMixin:OnSpacerAddedToView(splitData, elementData)
	-- Optional
	-- Called when a spacer has been added to view data
end

function PagedContentFrameBaseMixin:ProcessSpacerFrame(spacerFrame, elementData, elementIndex)
	-- Optional
	-- Do any layout-specific operations on instantiated spacerFrame
end

function PagedContentFrameBaseMixin:ProcessElementFrame(elementFrame, elementData, elementIndex)
	-- Optional
	-- Do any layout-specific operations on instantiated element frame
end

function PagedContentFrameBaseMixin:ApplyLayout(layoutFrames, viewFrame)
	-- Required
	-- Apply layout settings/commands to populated View Frame
	assert(false);
end