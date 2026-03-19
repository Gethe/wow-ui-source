local CatalogLifetimeEvents = {
	"PLAYER_LEAVING_WORLD",
};

local CatalogWhileVisibleEvents = {
	"HOUSING_STORAGE_UPDATED",
	"HOUSING_STORAGE_ENTRY_UPDATED",
};

HousingCatalogFrameMixin = {};

function HousingCatalogFrameMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, CatalogLifetimeEvents);

	EventRegistry:RegisterCallback("HousingCatalogFrame.OpenToDecorID", self.OnOpenToDecorID, self);
end

function HousingCatalogFrameMixin:OneTimeInit()
	if self.didOneTimeInitialize then
		return;
	end

	-- Delaying the first time we initialize all this so that we don't load up all catalog data in CPP if it's never needed or shown
	self.didOneTimeInitialize = true;

	-- TODO: A better way to filter out rooms category
	local displayContext = Enum.HouseEditorMode.BasicDecor;

	self.OptionsContainer:SetEntryDisplayContextGetter(function()
		return {
			showMarketInfo = false,
			showVariantStacks = false,
			showDestroyOptions = false,
			showTrackingOptions = true
		};
	end);

	self.catalogSearcher = C_HousingCatalog.CreateCatalogSearcher();
	self.catalogSearcher:SetResultsUpdatedCallback(function() self:OnEntryResultsUpdated(); end);
	self.catalogSearcher:SetAutoUpdateOnParamChanges(false);
	self.catalogSearcher:SetStoredOnly(false);
	self.catalogSearcher:SetBaseVariantOnly(true);
	self.catalogSearcher:SetEditorModeContext(displayContext);

	self.Filters:Initialize(self.catalogSearcher);
	self.Filters:SetCollectionFiltersAvailable(true);
	self.Categories:Initialize(GenerateClosure(self.OnCategoryFocusChanged, self), { withStoredEntriesOnly = false, editorModeContext = displayContext });
	self.SearchBox:Initialize(GenerateClosure(self.OnSearchTextUpdated, self));
end

function HousingCatalogFrameMixin:OnEvent(event, ...)
	if event == "HOUSING_STORAGE_UPDATED" and self.catalogSearcher then
		self.catalogSearcher:RunSearch();
	elseif event == "HOUSING_STORAGE_ENTRY_UPDATED" then
		local entryVariantID = ...;
		self:OnCatalogEntryUpdated(entryVariantID);
	end
end

function HousingCatalogFrameMixin:OnShow()
	self:OneTimeInit();

	FrameUtil.RegisterFrameForEvents(self, CatalogWhileVisibleEvents);
	EventRegistry:RegisterCallback("HousingCatalogEntry.OnInteract", function(owner, catalogEntry, button, isDrag)
		if button == "LeftButton" and not isDrag then
			if ContentTrackingUtil.IsTrackingModifierDown() then
				if C_ContentTracking.IsTracking(Enum.ContentTrackingType.Decor, catalogEntry.entryInfo.recordID) then
					C_ContentTracking.StopTracking(Enum.ContentTrackingType.Decor, catalogEntry.entryInfo.recordID, Enum.ContentTrackingStopType.Manual);
					PlaySound(SOUNDKIT.CONTENT_TRACKING_STOP_TRACKING);
				else
					local error = C_ContentTracking.StartTracking(Enum.ContentTrackingType.Decor, catalogEntry.entryInfo.recordID);
					if error then
						ContentTrackingUtil.DisplayTrackingError(error);
					else 
						PlaySound(SOUNDKIT.CONTENT_TRACKING_START_TRACKING);
						PlaySound(SOUNDKIT.CONTENT_TRACKING_OBJECTIVE_TRACKING_START);
					end
				end
			else
				PlaySound(SOUNDKIT.HOUSING_CATALOG_ENTRY_SELECT);
				self.PreviewFrame:PreviewCatalogEntryInfo(catalogEntry.entryInfo, catalogEntry.variantInfo);
				self.PreviewFrame:Show();
			end
		end
	end, self);

	if self.catalogSearcher then
		self.catalogSearcher:SetAutoUpdateOnParamChanges(true);
		self.catalogSearcher:RunSearch();
	end
end

function HousingCatalogFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CatalogWhileVisibleEvents);
	EventRegistry:UnregisterCallback("HousingCatalogEntry.OnInteract", self);

	self.PreviewFrame:Hide();
	self.PreviewFrame:ClearPreviewData();

	if self.catalogSearcher then
		self.catalogSearcher:SetAutoUpdateOnParamChanges(false);
	end
end

function HousingCatalogFrameMixin:OnEntryResultsUpdated()
	self:UpdateCatalogData();

	-- Once we get back catalog data, if we've deferred a link click, open to the deferred id
	if self.deferredTargetDecorID then

		local elementData, _frame = self.OptionsContainer:TryGetElementAndFrameByPredicate(function(elementData)
			if elementData.entryVariantID and elementData.entryVariantID.entryType == Enum.HousingCatalogEntryType.Decor then
				return elementData.entryVariantID.recordID == self.deferredTargetDecorID;
			end
		end);

		if elementData and self.OptionsContainer.ScrollBox then
				self.OptionsContainer.ScrollBox:ScrollToElementData(elementData);

				local element = self.OptionsContainer.ScrollBox:FindFrame(elementData);
				if element then
					local button = "LeftButton";
					local drag = false;
					EventRegistry:TriggerEvent("HousingCatalogEntry.OnInteract", element, button, drag);
				end
		end

		self.deferredTargetDecorID = nil;
	end
end

function HousingCatalogFrameMixin:UpdateCatalogData()
	if not self:IsShown() then
		return;
	end

	local entries = self.catalogSearcher:GetCatalogSearchResults();

	-- If not currently showing anything in the preview pane, show the first entry in the list
	if not self.PreviewFrame:IsShown() and entries and #entries > 0 then
		local firstEntry = entries[1];
		local firstEntryInfo = C_HousingCatalog.GetCatalogEntryInfo(firstEntry);
		local firstEntryVariantInfo = C_HousingCatalog.GetCatalogEntryVariantInfo(firstEntry);
		self.PreviewFrame:PreviewCatalogEntryInfo(firstEntryInfo, firstEntryVariantInfo);
		self.PreviewFrame:Show();
	end

	local retainCurrentPosition = true;
	self.OptionsContainer:SetCatalogData(entries, retainCurrentPosition);
end

function HousingCatalogFrameMixin:UpdateCategoryText()
	local categoryString = self.Categories:GetFocusedCategoryString();
	if not categoryString then
		self.OptionsContainer.CategoryText:SetText("");
		return;
	end

	self.OptionsContainer.CategoryText:SetText(categoryString);
	if self.catalogSearcher:GetFilteredCategoryID() == Constants.HousingCatalogConsts.HOUSING_CATALOG_ALL_CATEGORY_ID then
		self.OptionsContainer.CategoryText:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	else
		self.OptionsContainer.CategoryText:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	end
end

function HousingCatalogFrameMixin:OnOpenToDecorID(decorID)
	if not self.didOneTimeInitialize then
		self:OneTimeInit();
	end

	EventRegistry:TriggerEvent("HousingDashboard.OpenToCatalogFrame");

	self.Filters:ResetFiltersToDefault(); --always reset filters when opening to a particular decor.
	self.deferredTargetDecorID = decorID;
	self.catalogSearcher:RunSearch();
end

function HousingCatalogFrameMixin:OnCatalogEntryUpdated(entryVariantID)
	local entryInfo = C_HousingCatalog.GetCatalogEntryInfo(entryVariantID);

	local elementData, optionFrame = self.OptionsContainer:TryGetElementAndFrame(entryVariantID);
	
	-- If option was added or removed entirely, reset our options list
	if self.catalogSearcher and ((entryInfo and not elementData) or (not entryInfo and elementData)) then
		self.catalogSearcher:RunSearch();
		return;
	end

	-- Otherwise, if the frame for this option is currently showing, update its data
	if entryInfo and optionFrame then
		optionFrame:UpdateEntryData();
	end
end

function HousingCatalogFrameMixin:OnSearchTextUpdated(newSearchText)
	if not self.catalogSearcher then
		return;
	end

	if newSearchText ~= self.catalogSearcher:GetSearchText() then
		self.catalogSearcher:SetSearchText(newSearchText);

		-- On searching something new, clear out any active category focus so we're searching all categories
		if newSearchText and newSearchText ~= "" then
			self.catalogSearcher:SetFilteredCategoryID(nil);
			self.catalogSearcher:SetFilteredSubcategoryID(nil);
			self.Categories:SetFocus(Constants.HousingCatalogConsts.HOUSING_CATALOG_ALL_CATEGORY_ID);

			self:UpdateCategoryText();
		end
	end
end

function HousingCatalogFrameMixin:OnCategoryFocusChanged(focusedCategoryID, focusedSubcategoryID)
	if not self.catalogSearcher then
		return;
	end

	if self.catalogSearcher:GetFilteredCategoryID() == focusedCategoryID and self.catalogSearcher:GetFilteredSubcategoryID() == focusedSubcategoryID then
		self:UpdateCatalogData();
		return;
	end

	self.catalogSearcher:SetFilteredCategoryID(focusedCategoryID);
	self.catalogSearcher:SetFilteredSubcategoryID(focusedSubcategoryID);

	self:UpdateCategoryText();

	-- On focusing categories, clear out any previous search text
	if (focusedCategoryID or focusedSubcategoryID) and self.catalogSearcher:GetSearchText() then
		if focusedCategoryID ~= Constants.HousingCatalogConsts.HOUSING_CATALOG_ALL_CATEGORY_ID then
			self:ClearSearchText();
		end
	end
end

function HousingCatalogFrameMixin:ClearSearchText()
	if not self.catalogSearcher then
		return;
	end

	self.catalogSearcher:SetSearchText(nil);
	SearchBoxTemplate_ClearText(self.SearchBox);
end
