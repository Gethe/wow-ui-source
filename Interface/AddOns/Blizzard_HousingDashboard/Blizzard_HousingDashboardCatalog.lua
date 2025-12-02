local CatalogLifetimeEvents = {
	"HOUSING_CATALOG_SEARCHER_RELEASED",
	"PLAYER_LEAVING_WORLD",
};

local CatalogWhileVisibleEvents = {
	"HOUSING_STORAGE_UPDATED",
	"HOUSING_STORAGE_ENTRY_UPDATED",
};

HousingCatalogFrameMixin = {};

function HousingCatalogFrameMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, CatalogLifetimeEvents);
end

function HousingCatalogFrameMixin:OneTimeInit()
	if self.didOneTimeInitialize then
		return;
	end

	-- Delaying the first time we initialize all this so that we don't load up all catalog data in CPP if it's never needed or shown
	self.didOneTimeInitialize = true;

	-- TODO: A better way to filter out rooms category
	local displayContext = Enum.HouseEditorMode.BasicDecor;

	self.catalogSearcher = C_HousingCatalog.CreateCatalogSearcher();
	self.catalogSearcher:SetResultsUpdatedCallback(function() self:OnEntryResultsUpdated(); end);
	self.catalogSearcher:SetAutoUpdateOnParamChanges(false);
	self.catalogSearcher:SetOwnedOnly(false);
	self.catalogSearcher:SetIncludeMarketEntries(false);
	self.catalogSearcher:SetEditorModeContext(displayContext);

	self.Filters:Initialize(self.catalogSearcher);
	self.Filters:SetCollectionFiltersAvailable(true);
	self.Categories:Initialize(GenerateClosure(self.OnCategoryFocusChanged, self), { withOwnedEntriesOnly = false, editorModeContext = displayContext });
	self.SearchBox:Initialize(GenerateClosure(self.OnSearchTextUpdated, self));
end

function HousingCatalogFrameMixin:OnEvent(event, ...)
	if event == "HOUSING_STORAGE_UPDATED" and self.catalogSearcher then
		self.catalogSearcher:RunSearch();
	elseif event == "HOUSING_STORAGE_ENTRY_UPDATED" then
		local entryID = ...;
		self:OnCatalogEntryUpdated(entryID);
	elseif event == "HOUSING_CATALOG_SEARCHER_RELEASED" then
		local releasedSearcher = ...;
		if self.catalogSearcher and self.catalogSearcher == releasedSearcher then
			-- This should only get called as part of ReloadUI
			-- Unfortunately can't just clear it by listening to LEAVING_WORLD because that'll happen after the searcher has already been released
			-- and after other receiving while-shown cleanup events that will lead this UI to attempt to reference it
			self.catalogSearcher = nil;
			self.Filters:ClearSearcherReference();
			self.OptionsContainer:ClearCatalogData();
		end
	end
end

function HousingCatalogFrameMixin:OnShow()
	self:OneTimeInit();

	FrameUtil.RegisterFrameForEvents(self, CatalogWhileVisibleEvents);
	EventRegistry:RegisterCallback("HousingCatalogEntry.OnInteract", function(owner, catalogEntry, button, isDrag)
		if button == "LeftButton" and not isDrag then
			if ContentTrackingUtil.IsTrackingModifierDown() then
				if C_ContentTracking.IsTracking(Enum.ContentTrackingType.Decor, catalogEntry.entryInfo.entryID.recordID) then
					C_ContentTracking.StopTracking(Enum.ContentTrackingType.Decor, catalogEntry.entryInfo.entryID.recordID, Enum.ContentTrackingStopType.Manual);
					PlaySound(SOUNDKIT.CONTENT_TRACKING_STOP_TRACKING);
				else
					local error = C_ContentTracking.StartTracking(Enum.ContentTrackingType.Decor, catalogEntry.entryInfo.entryID.recordID);
					if error then
						ContentTrackingUtil.DisplayTrackingError(error);
					else 
						PlaySound(SOUNDKIT.CONTENT_TRACKING_START_TRACKING);
						PlaySound(SOUNDKIT.CONTENT_TRACKING_OBJECTIVE_TRACKING_START);
					end
				end
			else
				PlaySound(SOUNDKIT.HOUSING_CATALOG_ENTRY_SELECT);
				self.PreviewFrame:PreviewCatalogEntryInfo(catalogEntry.entryInfo);
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
		self.PreviewFrame:PreviewCatalogEntryInfo(firstEntryInfo);
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

function HousingCatalogFrameMixin:OnCatalogEntryUpdated(entryID)
	local entryInfo = C_HousingCatalog.GetCatalogEntryInfo(entryID);
	local shouldShowOption = entryInfo and entryInfo.quantity > 0 or false;

	local elementData, optionFrame = self.OptionsContainer:TryGetElementAndFrame(entryID);
	
	-- If option was added or removed entirely, reset our options list
	if self.catalogSearcher and ((shouldShowOption and not elementData) or (not shouldShowOption and elementData)) then
		self.catalogSearcher:RunSearch();
		return;
	end

	-- Otherwise, if the frame for this option is currently showing, update its data
	if shouldShowOption and optionFrame then
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
