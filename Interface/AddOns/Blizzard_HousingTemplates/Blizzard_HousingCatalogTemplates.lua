
local function SetHeaderText(barDivider, elementData)
	barDivider:SetHeaderText(elementData.text, HOUSING_HEADER_COLOR);
	barDivider:SetMarginSpacing(4);
end

local function SetInstructionText(scrollBoxText, elementData)
	scrollBoxText:SetElementText(elementData.text, HOUSING_HEADER_COLOR);
end

local Templates = {
	["CATALOG_ENTRY_DECOR"] = { template = "HousingCatalogDecorEntryTemplate", initFunc = HousingCatalogEntryMixin.Init, resetFunc = HousingCatalogEntryMixin.Reset },
	["CATALOG_ENTRY_ROOM"] = { template = "HousingCatalogRoomEntryTemplate", initFunc = HousingCatalogEntryMixin.Init, resetFunc = HousingCatalogEntryMixin.Reset },
	["CATALOG_ENTRY_BUNDLE"] = { template = "HousingCatalogBundleDisplayTemplate", initFunc = HousingCatalogBundleDisplayMixin.Init, resetFunc = HousingCatalogBundleDisplayMixin.Reset },
	["CATALOG_ENTRY_BUNDLE_DIVIDER"] = { template = "BarDividerTemplate", initFunc = nop, resetFunc = Pool_HideAndClearAnchors },
	["CATALOG_ENTRY_HEADER"] = { template = "BarDividerTemplate", initFunc = SetHeaderText, resetFunc = Pool_HideAndClearAnchors },
	["CATALOG_ENTRY_INSTRUCTIONS"] = { template = "ScrollBoxTextContainerTemplate", initFunc = SetInstructionText, resetFunc = Pool_HideAndClearAnchors },
};

local FullWidthTemplateKeySet = {
	["CATALOG_ENTRY_BUNDLE_DIVIDER"] = true,
	["CATALOG_ENTRY_HEADER"] = true,
	["CATALOG_ENTRY_INSTRUCTIONS"] = true,
};

local TemplateHeightAdjust = {
	["CATALOG_ENTRY_BUNDLE"] = -8,
	["CATALOG_ENTRY_BUNDLE_DIVIDER"] = -24,
};

-- Base Mixin
BaseHousingCatalogMixin = {};

function BaseHousingCatalogMixin:SetCatalogData(catalogEntries, retainCurrentPosition, headerText, instructionText)
	if not catalogEntries or #catalogEntries == 0 then
		self:ClearCatalogData();
		return;
	end

	local lastTemplate = nil;
	local catalogElements = {};

	if headerText then
		table.insert(catalogElements, { templateKey = "CATALOG_ENTRY_HEADER", text = headerText });
	end

	for _, catalogEntry in ipairs(catalogEntries) do
		local elementData = catalogEntry;

		-- Bundle entries have a list of decor entries
		if catalogEntry.decorEntries then
			elementData.templateKey = "CATALOG_ENTRY_BUNDLE";
		else
			if lastTemplate == "CATALOG_ENTRY_BUNDLE" then
				-- Add a divider after all the bundles
				table.insert(catalogElements, { templateKey = "CATALOG_ENTRY_BUNDLE_DIVIDER" });
			end

			if catalogEntry.decorID then
				elementData = { bundleItemInfo = catalogEntry, };

				elementData.templateKey = "CATALOG_ENTRY_DECOR";
			else
				elementData = { entryID = catalogEntry, };

				local entryType = catalogEntry.entryType;
				if entryType == Enum.HousingCatalogEntryType.Decor then
					elementData.templateKey = "CATALOG_ENTRY_DECOR";
				elseif entryType == Enum.HousingCatalogEntryType.Room then
					elementData.templateKey = "CATALOG_ENTRY_ROOM";
				else
					assertsafe(false, ("Unexpected catalog entry type: %s"):format(entryType));
				end
			end
		end

		if elementData.templateKey then
			lastTemplate = elementData.templateKey;
			table.insert(catalogElements, elementData);
		end
	end

	if instructionText then
		table.insert(catalogElements, { templateKey = "CATALOG_ENTRY_INSTRUCTIONS", text = instructionText });
	end

	self:SetCatalogElements(catalogElements, retainCurrentPosition);
end

function BaseHousingCatalogMixin:ClearCatalogData()
	-- Required to implement
	assert(false);
end

function BaseHousingCatalogMixin:UpdateLayout()
	-- Optional, if any manual steps are required after parent sizing/layout changes
end

function BaseHousingCatalogMixin:TryGetElementAndFrame(entryID)
	-- Required to implement
	assert(false);
end

function BaseHousingCatalogMixin:SetCatalogElements(catalogElements, retainCurrentPosition)
	-- Required to implement
	assert(false);
end


-- Pagination-based Catalog Mixin
PagedHousingCatalogMixin = CreateFromMixins(BaseHousingCatalogMixin);

function PagedHousingCatalogMixin:OnLoad()
	self:SetElementTemplateData(Templates);
end

function PagedHousingCatalogMixin:SetCatalogElements(catalogElements, retainCurrentPosition)
	local catalogData = {{elements = catalogElements}};
	local dataProvider = CreateDataProvider(catalogData);
	self:SetDataProvider(dataProvider, retainCurrentPage);
end

function PagedHousingCatalogMixin:ClearCatalogData()
	self:RemoveDataProvider();
end

function PagedHousingCatalogMixin:TryGetElementAndFrame(entryID)
	return self:TryGetElementAndFrameByPredicate(function(elementData) return elementData.entryID == entryID; end);
end

function PagedHousingCatalogMixin:UpdateLayout()
	self:UpdateLayouts();
end


-- Scrolling Catalog Mixin
ScrollingHousingCatalogMixin = CreateFromMixins(BaseHousingCatalogMixin);

function ScrollingHousingCatalogMixin:OnLoad()
	local view = CreateScrollBoxListSequenceView(self.topPadding, self.bottomPadding, self.leftPadding, self.rightPadding, self.horizontalSpacing, self.verticalSpacing);
	view:SetElementFactory(function(factory, elementData)
		local templateEntry = Templates[elementData.templateKey];
		if templateEntry then
			factory(templateEntry.template, templateEntry.initFunc);
		end
	end);

	view:SetElementSizeCalculator(function(_dataIndex, elementData)
		local templateKey = elementData.templateKey;

		local heightAdjust = TemplateHeightAdjust[templateKey] or 0;

		-- The divider should fill the whole width of the scroll box.
		if FullWidthTemplateKeySet[templateKey] then
			local template = Templates[elementData.templateKey].template;
			local templateInfo = C_XMLUtil.GetTemplateInfo(template);
			return 0, templateInfo.height + heightAdjust;
		end

		local templateWidth, templateHeight = view:GetTemplateSizeFromElementData(elementData);
		return templateWidth, templateHeight + heightAdjust;
	end);


	view:SetFrameFactoryResetter(function(pool, frame, new)
		if not new then
			local elementData = frame:GetElementData();
			local templateEntry = Templates[elementData.templateKey];
			if templateEntry then
				templateEntry.resetFunc(pool, frame);
			end
		end
	end);
	
	self.ScrollBox:SetEdgeFadeLength(75);
	self:SetScrollBoxTopOffset(self.scrollBoxTopOffset);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function ScrollingHousingCatalogMixin:SetScrollBoxTopOffset(offset)
	self.ScrollBox:SetPoint("TOPLEFT", 0, offset);
end

function ScrollingHousingCatalogMixin:SetCatalogElements(catalogElements, retainCurrentPosition)
	local dataProvider = CreateDataProvider(catalogElements);
	self.ScrollBox:SetDataProvider(dataProvider, retainCurrentPosition);
end

function ScrollingHousingCatalogMixin:ClearCatalogData()
	self.ScrollBox:RemoveDataProvider();
end

function ScrollingHousingCatalogMixin:TryGetElementAndFrame(entryID)
	if not self.ScrollBox:HasDataProvider() then
		return nil, nil;
	end

	local frame = nil;
	local focusedElementData = self.ScrollBox:FindElementDataByPredicate(function(elementData) return elementData.entryID == entryID; end);
	if focusedElementData then
		frame = self.ScrollBox:FindFrame(focusedElementData);
	end
	return focusedElementData, frame;
end

function ScrollingHousingCatalogMixin:RefreshFrames()
	for _, frame in self.ScrollBox:EnumerateFrames() do
		if frame.UpdateVisuals then
			frame:UpdateVisuals();
		end
	end
end
