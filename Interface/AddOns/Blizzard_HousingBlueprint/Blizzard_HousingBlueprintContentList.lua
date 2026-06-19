----------------- Content List Container -----------------

HousingBlueprintContentListFrameMixin = {};

local ContentListWhileShownEvents = {
	"HOUSING_NUM_DECOR_PLACED_CHANGED",
	"HOUSING_STORAGE_UPDATED",
	"HOUSING_STORAGE_ENTRY_UPDATED",
	"HOUSING_LAYOUT_ROOM_RECEIVED",
	"HOUSING_LAYOUT_ROOM_REMOVED",
	"HOUSE_LEVEL_CHANGED",
	"HOUSING_BLUEPRINT_CONTENTS_RECEIVED",
	"HOUSING_BLUEPRINT_CONTENTS_FAILURE"
};

function HousingBlueprintContentListFrameMixin:OnLoad()
	self.CloseButton:SetScript("OnClick", function()
		self:HideSelf();
	end);
	self.BottomCloseButton:SetScript("OnClick", function()
		self:HideSelf();
	end);
		
	self.MissingOnlyCheckbox.Checkbox:SetScript("OnClick", function (button)
		-- Re-show contents, with the filter toggled
		if not self.isReadonly and self.blueprintContentInfo then
			local isFilterUpdate = true;
			self:ShowBlueprintContents(self.blueprintContentInfo, self.isReadonly, isFilterUpdate);
		end
	end);

	local childElementIndent, elementSpacing = 10, 3;
	local view = CreateScrollBoxListTreeListView(childElementIndent, self.topPadding, self.bottomPadding, self.leftPadding, self.rightPadding, elementSpacing);

	view:SetElementFactory(function(factory, node)
		local elementData = node:GetData();
		if elementData.entries then
			local function GroupInitializer(frame, node)
				frame:Init(node, self.isReadonly);
			end
			factory("HousingBlueprintContentGroupTemplate", GroupInitializer);
		elseif elementData.recordID then
			local function EntryInitializer(frame, node)
				frame:Init(node, self.isReadonly);
			end
			factory("HousingBlueprintContentEntryTemplate", EntryInitializer);
		end
	end);
	view:SetFrameFactoryResetter(function(pool, frame, new)
		if not new then
			frame.Reset(pool, frame);
		end
	end);
	view:SetElementExtentCalculator(function(dataIndex, node)
		local elementData = node:GetData();
		if elementData.entries then
			return 26;
		elseif elementData.recordID then
			return 20;
		end
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function HousingBlueprintContentListFrameMixin:GetNonPanelAnchor()
	-- Overrides HousingBlueprintBaseFrameMixin
	return "CENTER", nil, "CENTER", 400, 0;
end

function HousingBlueprintContentListFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ContentListWhileShownEvents);
end

function HousingBlueprintContentListFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ContentListWhileShownEvents);
	self:ClearData();
end

local function SortContentGroupsByType(nodeA, nodeB)
	local elementA = nodeA:GetData();
	local elementB = nodeB:GetData();
	return elementA.contentType < elementB.contentType;
end
local function SortEntriesByName(nodeA, nodeB)
	local elementA = nodeA:GetData();
	local elementB = nodeB:GetData();
	return strcmputf8i(elementA.name, elementB.name) < 0;
end

function HousingBlueprintContentListFrameMixin:IsShowingBlueprint(shareCode, houseGUID)
	if not self.blueprintContentInfo then
		return false;
	end

	return self.blueprintContentInfo.shareCode == shareCode and self.blueprintContentInfo.targetHouseGUID == houseGUID;
end

function HousingBlueprintContentListFrameMixin:IsOperationInProgress()
	return false;
end

function HousingBlueprintContentListFrameMixin:ShowBlueprintContents(blueprintContentInfo, isReadonly, isFilterUpdate)
	local isDataUpdate = not isFilterUpdate and blueprintContentInfo and self:IsShowingBlueprint(blueprintContentInfo.shareCode, blueprintContentInfo.targetHouseGUID);
	self:ClearData();

	if not blueprintContentInfo or not blueprintContentInfo.contentGroups then
		return;
	end

	self.blueprintContentInfo = blueprintContentInfo;
	self.isReadonly = isReadonly;
	
	local showMissingOnly = (not self.isReadonly) and self.MissingOnlyCheckbox.Checkbox:GetChecked();

	local dataProvider = CreateTreeDataProvider();
	local affectChildren = false;
	local skipSort = false;
	dataProvider:SetSortComparator(SortContentGroupsByType, affectChildren, skipSort);
	local numItems = 0;
	local numMissing = 0;
	for _, contentGroup in ipairs(self.blueprintContentInfo.contentGroups) do
		-- We're going to lazy-initialize the groupNode only once we know we're going to show one of its entries
		local groupNode = nil;
		for _, entry in ipairs(contentGroup.entries) do
			numItems = numItems + entry.total;
			if entry.invalid then
				numMissing = numMissing + entry.total;
			else
				numMissing = numMissing + entry.numMissing;
			end

			if (not showMissingOnly) or (entry.invalid or entry.numMissing > 0) then
				-- Now that we know this group will have at least one entry in it, add it to the data provider
				if not groupNode then
					groupNode = dataProvider:Insert(contentGroup);
					groupNode:SetSortComparator(SortEntriesByName, affectChildren, skipSort);
				end

				local entryNode = groupNode:Insert(entry);
			end
		end
	end

	if self.isReadonly then
		self.CountText:SetText(HOUSING_BLUEPRINT_CONTENT_COUNT_FMT:format(numItems));
	else
		local numAvailable = numItems - numMissing;
		self.CountText:SetText(HOUSING_BLUEPRINT_CONTENT_COUNT_COMPARE_FMT:format(numAvailable, numItems));
	end

	self.MissingOnlyCheckbox:SetShown(not self.isReadonly);

	self:ShowSelf();

	self.ScrollBox:SetDataProvider(dataProvider, isDataUpdate and ScrollBoxConstants.RetainScrollPosition or ScrollBoxConstants.DiscardScrollPosition);
end

function HousingBlueprintContentListFrameMixin:ClearData()
	self.ScrollBox:RemoveDataProvider();
	self.blueprintContentInfo = nil;
	self.isReadonly = nil;
end

function HousingBlueprintContentListFrameMixin:OnEvent(event, ...)
	if not self.blueprintContentInfo then
		return;
	end

	-- If the Import UI that opened this list is still open, then we can rely on it to respond to all of these events and update the list as needed
	if HousingBlueprintImportFrame:IsShown() and HousingBlueprintImportFrame.ValidationContent:IsShown() 
		and HousingBlueprintImportFrame.ValidationContent:IsShowingBlueprint(self.blueprintContentInfo.shareCode, self.blueprintContentInfo.targetHouseGUID) then
		return;
	end

	if event == "HOUSING_STORAGE_UPDATED"
		or event == "HOUSING_LAYOUT_ROOM_RECEIVED" 
		or event == "HOUSING_LAYOUT_ROOM_REMOVED"
		or event == "HOUSE_LEVEL_CHANGED" then
		self:UpdateBlueprintContentsData();
	elseif event == "HOUSING_STORAGE_ENTRY_UPDATED" then
		local entryVariantID = ...;
		if self:DoesBlueprintContainCatalogEntry(entryVariantID) then
			self:UpdateBlueprintContentsData();
		end
	elseif event == "HOUSING_BLUEPRINT_CONTENTS_FAILURE" then
		local sharecode, result = ...;
		self:OnContentRequestFailure(result);
	elseif event == "HOUSING_BLUEPRINT_CONTENTS_RECEIVED" then
		local contentInfo = ...;
		if contentInfo and self:IsShowingBlueprint(contentInfo.shareCode, contentInfo.targetHouseGUID) then
			self:ShowBlueprintContents(contentInfo, self.isReadonly);
		end
	end
end

function HousingBlueprintContentListFrameMixin:DoesBlueprintContainCatalogEntry(entryVariantID)
	if not self.blueprintContentInfo then
		return false;
	end

	local targetContentType = nil;
	if entryVariantID.entryType == Enum.HousingCatalogEntryType.Decor then
		targetContentType = Enum.HousingBlueprintContentType.Decor;
	elseif entryVariantID.entryType == Enum.HousingCatalogEntryType.Room then
		targetContentType = Enum.HousingBlueprintContentType.Room;
	else
		return false;
	end

	for _, contentGroup in ipairs(self.blueprintContentInfo.contentGroups) do
		if contentGroup.contentType == targetContentType then
			for _, entry in ipairs(contentGroup.entries) do
				if entry.recordID == entryVariantID.recordID then
					return true;
				end
			end
		end
	end

	return false;
end

function HousingBlueprintContentListFrameMixin:OnContentRequestFailure(result)
	local errorText = HousingResultToErrorText[result] or ERR_HOUSING_RESULT_BLUEPRINT_GENERIC_IMPORT_ERROR;
	UIErrorsFrame:AddExternalErrorMessage(HOUSING_BLUEPRINT_IMPORT_ERROR_FMT:format(errorText));
end

function HousingBlueprintContentListFrameMixin:UpdateBlueprintContentsData()
	if not self.blueprintContentInfo then
		return;
	end

	C_HousingBlueprint.RequestBlueprintContents(self.blueprintContentInfo.shareCode);
end

----------------- Content Group -----------------
HousingBlueprintContentGroupMixin = {};

function HousingBlueprintContentGroupMixin:OnLoad()
	self.Header:SetClickHandler(function(_header, button)
		if button == "LeftButton" then
			self:ToggleCollapsed();
		end
	end);

	self.Header:SetTitleColor(false, NORMAL_FONT_COLOR);
	self.Header:SetTitleColor(true, NORMAL_FONT_COLOR);
end

function HousingBlueprintContentGroupMixin:Init(node, isReadonly)
	local contentGroupData = node:GetData();
	self.node = node;
	self.contentGroupData = contentGroupData;
	self.isReadonly = isReadonly;

	local typeName = HousingBlueprintContentTypeStrings[contentGroupData.contentType];
	local numItems = 0;
	local numMissing = 0;
	for index, entry in ipairs(contentGroupData.entries) do
		numItems = numItems + entry.total;
		if entry.invalid then
			numMissing = numMissing + entry.total;
		else
			numMissing = numMissing + entry.numMissing;
		end
	end

	if self.isReadonly then
		self.Header:SetHeaderText(HOUSING_BLUEPRINT_CONTENT_TYPE_HEADER_FMT:format(typeName, numItems));
	else
		local numAvailable = numItems - numMissing;
		self.Header:SetHeaderText(HOUSING_BLUEPRINT_CONTENT_TYPE_HEADER_COMPARE_FMT:format(typeName, numAvailable, numItems))
	end

	self:SetCollapsed(node:IsCollapsed());
end

function HousingBlueprintContentGroupMixin.Reset(framePool, self)
	Pool_HideAndClearAnchors(framePool, self);
	self.contentGroupData = nil;
	self.isReadonly = nil;
	self.node = nil;
end

function HousingBlueprintContentGroupMixin:ToggleCollapsed()
	self:SetCollapsed(not self:IsCollapsed());
end

function HousingBlueprintContentGroupMixin:SetCollapsed(collapsed)
	if self.node then
		self.node:SetCollapsed(collapsed);
	end

	self.Header:UpdateCollapsedState(collapsed);
end

function HousingBlueprintContentGroupMixin:IsCollapsed()
	return self.node and self.node:IsCollapsed();
end

function HousingBlueprintContentGroupMixin:GetDebugName()
	if self.contentGroupData then
		local typeName = HousingBlueprintContentTypeStrings[self.contentGroupData.contentType];
		return typeName or "UNKNOWN GROUP";
	end
	return "Unused Group";
end

