
function WardrobeCollectionFrameMixin:SetTab(tabID)
	PanelTemplates_SetTab(self, tabID);
	local atTransmogrifier = C_Transmog.IsAtTransmogNPC();
	if atTransmogrifier then
		self.selectedTransmogTab = tabID;
	else
		self.selectedCollectionTab = tabID;
	end
	if tabID == WARDROBE_TAB_ITEMS then
		self.activeFrame = self.ItemsCollectionFrame;
		self.ItemsCollectionFrame:Show();
		self.SearchBox:ClearAllPoints();
		self.SearchBox:SetPoint("TOPRIGHT", -107, -35);
		self.SearchBox:SetWidth(115);
		local enableSearchAndFilter = self.ItemsCollectionFrame.transmogLocation and self.ItemsCollectionFrame.transmogLocation:IsAppearance()
		self.SearchBox:SetEnabled(enableSearchAndFilter);
		self.FilterButton:Show();
		self.FilterButton:SetEnabled(enableSearchAndFilter);
		self:InitItemsFilterButton();
	end
	WardrobeFrame:TriggerEvent(WardrobeFrameMixin.Event.OnCollectionTabChanged);
end

function WardrobeCollectionFrameMixin:OnLoad()
	PanelTemplates_SetNumTabs(self, 1);
	PanelTemplates_SetTab(self, WARDROBE_TAB_ITEMS);
	PanelTemplates_ResizeTabsToFit(self, WARDROBE_TABS_MAX_WIDTH);
	self.selectedCollectionTab = WARDROBE_TAB_ITEMS;
	self.selectedTransmogTab = WARDROBE_TAB_ITEMS;

	SetPortraitToTexture(self:GetParent().portrait, "Interface\\Icons\\inv_misc_enggizmos_19");

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
		local categoryID = C_TransmogCollection.GetAppearanceSourceInfo(sourceID);
		local slot = CollectionWardrobeUtil.GetSlotFromCategoryID(categoryID);
		local transmogLocation = TransmogUtil.GetTransmogLocation(slot, Enum.TransmogType.Appearance, Enum.TransmogModification.Main);
		self.ItemsCollectionFrame:GoToSourceID(sourceID, transmogLocation);
	end
end

function WardrobeCollectionFrameMixin:UpdateTabButtons()
end

function WardrobeCollectionFrameMixin:GoToSet(setID)
end

function WardrobeItemsCollectionMixin:CheckHelpTip()
	if (C_Transmog.IsAtTransmogNPC()) then
		local helpTipInfo = {
			text = TRANSMOG_SETS_VENDOR_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_TRANSMOG_SETS_VENDOR_TAB,
			targetPoint = HelpTip.Point.BottomEdgeCenter,
		};
		HelpTip:Show(WardrobeCollectionFrame, helpTipInfo, WardrobeCollectionFrame.SetsTab);
	else
		local helpTipInfo = {
			text = TRANSMOG_SETS_TAB_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFramesAccountWide",
			bitfieldFlag = LE_FRAME_TUTORIAL_ACCOUNT_TRANSMOG_SETS_TAB,
			targetPoint = HelpTip.Point.BottomEdgeCenter,
		};
		HelpTip:Show(WardrobeCollectionFrame, helpTipInfo, WardrobeCollectionFrame.SetsTab);
	end
end

function WardrobeItemsCollectionMixin:OnShow()
	self:RegisterEvent("TRANSMOGRIFY_UPDATE");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("TRANSMOGRIFY_SUCCESS");

	local needsUpdate = false;	-- we don't need to update if we call :SetActiveSlot as that will do an update
	if ( self.jumpToLatestCategoryID and self.jumpToLatestCategoryID ~= self.activeCategory and not C_Transmog.IsAtTransmogNPC() ) then
		local slot = CollectionWardrobeUtil.GetSlotFromCategoryID(self.jumpToLatestCategoryID);
		-- The model got reset from OnShow, which restored all equipment.
		-- But ChangeModelsSlot tries to be smart and only change the difference from the previous slot to the current slot, so some equipment will remain left on.
		-- This is only set for new apperances, base transmogLocation is fine
		local transmogLocation = TransmogUtil.GetTransmogLocation(slot, Enum.TransmogType.Appearance, Enum.TransmogModification.Main);
		local ignorePreviousSlot = true;
		self:SetActiveSlot(transmogLocation, self.jumpToLatestCategoryID, ignorePreviousSlot);
		self.jumpToLatestCategoryID = nil;
	elseif ( self.transmogLocation ) then
		-- redo the model for the active slot
		self:ChangeModelsSlot(self.transmogLocation);
		needsUpdate = true;
	else
		local transmogLocation = C_Transmog.IsAtTransmogNPC() and WardrobeTransmogFrame:GetSelectedTransmogLocation() or TransmogUtil.GetTransmogLocation("HEADSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main);
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
end