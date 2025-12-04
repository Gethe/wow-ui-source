function WardrobeCollectionFrameMixin:SetTab(tabID)
	PanelTemplates_SetTab(self, tabID);
	self.selectedCollectionTab = tabID;
	if tabID == WARDROBE_TAB_ITEMS then
		self.activeFrame = self.ItemsCollectionFrame;
		self.ItemsCollectionFrame:Show();
		self.SetsCollectionFrame:Hide();
		self.SearchBox:ClearAllPoints();
		self.SearchBox:SetPoint("TOPRIGHT", -107, -35);
		self.SearchBox:SetWidth(115);
		local enableSearchAndFilter = self.ItemsCollectionFrame.transmogLocation and self.ItemsCollectionFrame.transmogLocation:IsAppearance()
		self.SearchBox:SetEnabled(enableSearchAndFilter);
		self.FilterButton:Show();
		self.FilterButton:SetEnabled(enableSearchAndFilter);
		self:InitItemsFilterButton();
	elseif tabID == WARDROBE_TAB_SETS then
		self.ItemsCollectionFrame:Hide();
		self.SearchBox:ClearAllPoints();
		self.activeFrame = self.SetsCollectionFrame;
		self.SearchBox:SetPoint("TOPLEFT", 19, -69);
		self.SearchBox:SetWidth(145);
		self.FilterButton:Show();
		self.FilterButton:SetEnabled(true);
		self:InitBaseSetsFilterButton();
		self.SearchBox:SetEnabled(true);
		self.SetsCollectionFrame:Show();
	end
end

function WardrobeCollectionFrameMixin:OnLoad()
	PanelTemplates_SetNumTabs(self, 2);
	PanelTemplates_SetTab(self, WARDROBE_TAB_ITEMS);
	PanelTemplates_ResizeTabsToFit(self, WARDROBE_TABS_MAX_WIDTH);
	self.selectedCollectionTab = WARDROBE_TAB_ITEMS;
	self:SetTab(self.selectedCollectionTab);

	self.ItemsCollectionFrame.BGCornerTopLeft:Hide();
	self.ItemsCollectionFrame.BGCornerTopRight:Hide();

	self.ItemsCollectionFrame.GetTooltipSourceIndexCallback = GenerateClosure(self.GetTooltipSourceIndex, self);

	self:GetParent().portrait:SetPortraitToAsset("Interface\\Icons\\inv_misc_enggizmos_19");

	self.FilterButton:SetWidth(85);

	-- TODO: Remove this at the next deprecation reset
	self.searchBox = self.SearchBox;
end

function WardrobeCollectionFrameMixin:OpenTransmogLink(link)
	if ( not CollectionsJournal:IsVisible() or not self:IsVisible() ) then
		ToggleCollectionsJournal(5);
	end

	local linkType, id = strsplit(":", link);

	if ( linkType == "transmogappearance" ) then
		local sourceID = tonumber(id);
		self:SetTab(WARDROBE_TAB_ITEMS);
		-- For links a base appearance is fine
		local appearanceSourceInfo = C_TransmogCollection.GetAppearanceSourceInfo(sourceID);
		if appearanceSourceInfo then
			local slot = CollectionWardrobeUtil.GetSlotFromCategoryID(appearanceSourceInfo.category);
			local isSecondary = false;
			local transmogLocation = TransmogUtil.GetTransmogLocation(slot, Enum.TransmogType.Appearance, isSecondary);
			self.ItemsCollectionFrame:GoToSourceID(sourceID, transmogLocation);
		end
	elseif ( linkType == "transmogset") then
		local setID = tonumber(id);
		self:SetTab(WARDROBE_TAB_SETS);
		self.SetsCollectionFrame:SelectSet(setID);
		self.SetsCollectionFrame:ScrollToSet(self.SetsCollectionFrame:GetSelectedSetID(), ScrollBoxConstants.AlignCenter);
	end
end

function WardrobeCollectionFrameMixin:UpdateTabButtons()
	if(self.SetsCollectionFrame:HasSetsToShow()) then
		self.SetsTab:Show();
		self.SetsTab.FlashFrame:SetShown(C_TransmogSets.GetLatestSource() ~= Constants.Transmog.NoTransmogID);
	else
		-- if we have no sets to show, hide the tab and go back to items
		self.SetsTab:Hide();
		self:SetTab(WARDROBE_TAB_ITEMS);
	end
end

function WardrobeCollectionFrameMixin:GoToSet(setID)
	self:SetTab(WARDROBE_TAB_SETS);
	local classID = C_TransmogSets.GetValidClassForSet(setID);
	if classID then
		C_TransmogSets.SetTransmogSetsClassFilter(classID);
		self.ClassDropdown:Update();
	end
	self.SetsCollectionFrame:SelectSet(setID);
end

function WardrobeItemsCollectionMixin:CheckHelpTip()
	local helpTipInfo = {
		text = TRANSMOG_SETS_TAB_TUTORIAL,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedInfoFramesAccountWide",
		bitfieldFlag = Enum.FrameTutorialAccount.TransmogSetsTab,
		targetPoint = HelpTip.Point.BottomEdgeCenter,
	};
	HelpTip:Show(WardrobeCollectionFrame, helpTipInfo, WardrobeCollectionFrame.SetsTab);
end

function WardrobeItemsCollectionMixin:OnShow()
	self:RegisterEvent("TRANSMOGRIFY_UPDATE");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("TRANSMOGRIFY_SUCCESS");
	self:RegisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");

	local needsUpdate = false;	-- we don't need to update if we call :SetActiveSlot as that will do an update
	if ( self.jumpToLatestCategoryID and self.jumpToLatestCategoryID ~= self.activeCategory ) then
		local slot = CollectionWardrobeUtil.GetSlotFromCategoryID(self.jumpToLatestCategoryID);
		-- The model got reset from OnShow, which restored all equipment.
		-- But ChangeModelsSlot tries to be smart and only change the difference from the previous slot to the current slot, so some equipment will remain left on.
		-- This is only set for new apperances, base transmogLocation is fine
		local isSecondary = false;
		local transmogLocation = TransmogUtil.GetTransmogLocation(slot, Enum.TransmogType.Appearance, isSecondary);
		local ignorePreviousSlot = true;
		self:SetActiveSlot(transmogLocation, self.jumpToLatestCategoryID, ignorePreviousSlot);
		self.jumpToLatestCategoryID = nil;
	elseif ( self.transmogLocation ) then
		-- redo the model for the active slot
		self:ChangeModelsSlot(self.transmogLocation);
		needsUpdate = true;
	else
		local isSecondary = false;
		local transmogLocation = TransmogUtil.GetTransmogLocation("HEADSLOT", Enum.TransmogType.Appearance, isSecondary);
		self:SetActiveSlot(transmogLocation);
	end

	WardrobeCollectionFrame.progressBar:SetShown(not TransmogUtil.IsCategoryLegionArtifact(self:GetActiveCategory()));

	if ( needsUpdate ) then
		WardrobeCollectionFrame:UpdateUsableAppearances();
		self:RefreshVisualsList();
		self:UpdateItems();
		self:UpdateWeaponDropdown();
	end

	self:UpdateSlotButtons();

	self:CheckHelpTip();
end

function WardrobeItemsCollectionMixin:OnHide()
	self:UnregisterEvent("TRANSMOGRIFY_UPDATE");
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:UnregisterEvent("TRANSMOGRIFY_SUCCESS");
	self:UnregisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");

	StaticPopup_Hide("TRANSMOG_FAVORITE_WARNING");

	self:GetParent():ClearSearch(Enum.TransmogSearchType.Items);

	for i = 1, #self.Models do
		self.Models[i]:SetKeepModelOnHide(false);
	end

	self.visualsList = nil;
	self.filteredVisualsList = nil;
	self.activeCategory = nil;
	self.transmogLocation = nil;
end

function WardrobeItemsCollectionMixin:OnUpdate()
	if self.geoDirty then
		local model = self.Models[1];
		if model:IsGeoReady() then
			self.geoDirty = nil;

			self:EvaluateSlotAllowed();
			self:UpdateItems();
		end
	end
end
