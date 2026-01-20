WARDROBE_TAB_ITEMS = 1;
WARDROBE_TAB_SETS = 2;
WARDROBE_TABS_MAX_WIDTH = 185;

WardrobeCollectionFrameMixin = { };

function WardrobeCollectionFrameMixin:ClickTab(tab)
	self:SetTab(tab:GetID());
	PanelTemplates_ResizeTabsToFit(WardrobeCollectionFrame, WARDROBE_TABS_MAX_WIDTH);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

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
		self.ClassDropdown:ClearAllPoints();
		self.ClassDropdown:SetPoint("TOPRIGHT", self.ItemsCollectionFrame.SlotsFrame, "TOPLEFT", -12, -2);
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
		self.ClassDropdown:ClearAllPoints();
		self.ClassDropdown:SetPoint("BOTTOMRIGHT", self.SetsCollectionFrame, "TOPRIGHT", -9, 4);
		self.SetsCollectionFrame:Show();
	end
end

function WardrobeCollectionFrameMixin:InitItemsFilterButton()
	-- Source filters are in a submenu when unless we're at a transmogrifier.
	local function CreateSourceFilters(description)
		description:CreateButton(CHECK_ALL, function()
			C_TransmogCollection.SetAllSourceTypeFilters(true);
			return MenuResponse.Refresh;
		end);

		description:CreateButton(UNCHECK_ALL, function()
			C_TransmogCollection.SetAllSourceTypeFilters(false);
			return MenuResponse.Refresh;
		end);
		
		local function IsChecked(filter)
			return C_TransmogCollection.IsSourceTypeFilterChecked(filter);
		end

		local function SetChecked(filter)
			C_TransmogCollection.SetSourceTypeFilter(filter, not IsChecked(filter));
		end
		
		for filterIndex = 1, C_TransmogCollection.GetNumTransmogSources() do
			if (C_TransmogCollection.IsValidTransmogSource(filterIndex)) then
				description:CreateCheckbox(_G["TRANSMOG_SOURCE_"..filterIndex], IsChecked, SetChecked, filterIndex);
			end
		end
	end

	self.FilterButton:SetIsDefaultCallback(function()
		return C_TransmogCollection.IsUsingDefaultFilters();
	end);

	self.FilterButton:SetDefaultCallback(function()
		return C_TransmogCollection.SetDefaultFilters();
	end);

	self.FilterButton:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_WARDROBE_FILTER");

		rootDescription:CreateCheckbox(COLLECTED, C_TransmogCollection.GetCollectedShown, function()
			C_TransmogCollection.SetCollectedShown(not C_TransmogCollection.GetCollectedShown());
		end);

		rootDescription:CreateCheckbox(NOT_COLLECTED, C_TransmogCollection.GetUncollectedShown, function()
			C_TransmogCollection.SetUncollectedShown(not C_TransmogCollection.GetUncollectedShown());
		end);

		rootDescription:CreateCheckbox(TRANSMOG_SHOW_ALL_FACTIONS, C_TransmogCollection.GetAllFactionsShown, function()
			C_TransmogCollection.SetAllFactionsShown(not C_TransmogCollection.GetAllFactionsShown());
		end);

		rootDescription:CreateCheckbox(TRANSMOG_SHOW_ALL_RACES, C_TransmogCollection.GetAllRacesShown, function()
			C_TransmogCollection.SetAllRacesShown(not C_TransmogCollection.GetAllRacesShown());
		end);

		local submenu = rootDescription:CreateButton(SOURCES);
		CreateSourceFilters(submenu);
	end);
end

function WardrobeCollectionFrameMixin:InitBaseSetsFilterButton()
	self.FilterButton:SetIsDefaultCallback(function()
		return C_TransmogSets.IsUsingDefaultBaseSetsFilters();
	end);

	self.FilterButton:SetDefaultCallback(function()
		return C_TransmogSets.SetDefaultBaseSetsFilters();
	end);

	self.FilterButton:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_WARDROBE_BASE_SETS_FILTER");

		local function GetBaseSetsFilter(filter)
			C_TransmogSets.SetBaseSetsFilter(filter, not C_TransmogSets.GetBaseSetsFilter(filter));
		end

		rootDescription:CreateCheckbox(COLLECTED, C_TransmogSets.GetBaseSetsFilter, GetBaseSetsFilter, LE_TRANSMOG_SET_FILTER_COLLECTED);
		rootDescription:CreateCheckbox(NOT_COLLECTED, C_TransmogSets.GetBaseSetsFilter, GetBaseSetsFilter, LE_TRANSMOG_SET_FILTER_UNCOLLECTED);
		rootDescription:CreateDivider();
		rootDescription:CreateCheckbox(TRANSMOG_SET_PVE, C_TransmogSets.GetBaseSetsFilter, GetBaseSetsFilter, LE_TRANSMOG_SET_FILTER_PVE);
		rootDescription:CreateCheckbox(TRANSMOG_SET_PVP, C_TransmogSets.GetBaseSetsFilter, GetBaseSetsFilter, LE_TRANSMOG_SET_FILTER_PVP);
	end);
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

	CollectionsJournal:SetPortraitToAsset("Interface\\Icons\\inv_misc_enggizmos_19");

	self.FilterButton:SetWidth(90);

	-- TODO: Remove this at the next deprecation reset
	self.searchBox = self.SearchBox;
end

function WardrobeCollectionFrameMixin:OnEvent(event, ...)
	if ( event == "TRANSMOG_COLLECTION_ITEM_UPDATE" ) then
		if ( self.tooltipContentFrame ) then
			self.tooltipContentFrame:RefreshAppearanceTooltip();
		end
		if ( self.ItemsCollectionFrame:IsShown() ) then
			self.ItemsCollectionFrame:ValidateChosenVisualSources();
		end
	elseif ( event == "UNIT_FORM_CHANGED" ) then
		self:HandleFormChanged();
	elseif ( event == "PLAYER_LEVEL_UP" or event == "SKILL_LINES_CHANGED" or event == "UPDATE_FACTION" or event == "SPELLS_CHANGED" ) then
		self:UpdateUsableAppearances();
	elseif ( event == "TRANSMOG_SEARCH_UPDATED" ) then
		local searchType, arg1 = ...;
		if ( searchType == self:GetSearchType() ) then
			self.activeFrame:OnSearchUpdate(arg1);
		end
	elseif ( event == "SEARCH_DB_LOADED" ) then
		self:RestartSearchTracking();
	elseif ( event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" or event == "TRANSMOG_COLLECTION_CAMERA_UPDATE" ) then
		self:RefreshCameras();
	end
end

function WardrobeCollectionFrameMixin:HandleFormChanged()
	local hasAlternateForm, inAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
	self.needsFormChangedHandling = false;
	if ( self.inAlternateForm ~= inAlternateForm or self.updateOnModelChanged ) then
		if ( self.activeFrame:OnUnitModelChangedEvent() ) then
			self.inAlternateForm = inAlternateForm;
			self.updateOnModelChanged = nil;
		else
			self.needsFormChangedHandling = true;
		end
	end
end

function WardrobeCollectionFrameMixin:OnUpdate()
	if self.needsFormChangedHandling then
		self:HandleFormChanged();
	end
end

function WardrobeCollectionFrameMixin:OnShow()
	CollectionsJournal:SetPortraitToAsset("Interface\\Icons\\inv_chest_cloth_17");

	self:RegisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:RegisterUnitEvent("UNIT_FORM_CHANGED", "player");
	self:RegisterEvent("TRANSMOG_SEARCH_UPDATED");
	self:RegisterEvent("SEARCH_DB_LOADED");
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("SKILL_LINES_CHANGED");
	self:RegisterEvent("UPDATE_FACTION");
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("TRANSMOG_COLLECTION_CAMERA_UPDATE");

	local hasAlternateForm, inAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
	self.inAlternateForm = inAlternateForm;

	self:SetTab(self.selectedCollectionTab);
	self:UpdateTabButtons();
end

function WardrobeCollectionFrameMixin:OnHide()
	self:UnregisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:UnregisterEvent("UNIT_FORM_CHANGED");
	self:UnregisterEvent("TRANSMOG_SEARCH_UPDATED");
	self:UnregisterEvent("SEARCH_DB_LOADED");
	self:UnregisterEvent("PLAYER_LEVEL_UP");
	self:UnregisterEvent("SKILL_LINES_CHANGED");
	self:UnregisterEvent("UPDATE_FACTION");
	self:UnregisterEvent("SPELLS_CHANGED");
	self:UnregisterEvent("UI_SCALE_CHANGED");
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");
	self:UnregisterEvent("TRANSMOG_COLLECTION_CAMERA_UPDATE");
	C_TransmogCollection.EndSearch();
	self.jumpToVisualID = nil;
	for i, frame in ipairs(self.ContentFrames) do
		frame:Hide();
	end
end

function WardrobeCollectionFrameMixin:OnKeyDown(key)
	if self.tooltipCycle and key == WARDROBE_CYCLE_KEY then
		if IsShiftKeyDown() then
			self.tooltipSourceIndex = self.tooltipSourceIndex - 1;
		else
			self.tooltipSourceIndex = self.tooltipSourceIndex + 1;
		end
		self.tooltipContentFrame:RefreshAppearanceTooltip();
		return false;
	elseif (key == WARDROBE_UP_VISUAL_KEY or key == WARDROBE_DOWN_VISUAL_KEY) and self.activeFrame == self.SetsCollectionFrame then
		self.activeFrame:HandleKey(key);
		return false;
	end
	return true;
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
		if not appearanceSourceInfo then
			return;
		end

		local slot = CollectionWardrobeUtil.GetSlotFromCategoryID(appearanceSourceInfo.category);
		local isSecondary = false;
		local transmogLocation = TransmogUtil.GetTransmogLocation(slot, Enum.TransmogType.Appearance, isSecondary);
		self.ItemsCollectionFrame:GoToSourceID(sourceID, transmogLocation);
	elseif ( linkType == "transmogset") then
		local setID = tonumber(id);
		self:SetTab(WARDROBE_TAB_SETS);
		self.SetsCollectionFrame:SelectSet(setID);
		self.SetsCollectionFrame:ScrollToSet(self.SetsCollectionFrame:GetSelectedSetID(), ScrollBoxConstants.AlignCenter);
	end
end

function WardrobeCollectionFrameMixin:GoToItem(sourceID)
	self:SetTab(WARDROBE_TAB_ITEMS);

	local appearanceSourceInfo = C_TransmogCollection.GetAppearanceSourceInfo(sourceID);
	if not appearanceSourceInfo then
		return;
	end

	local slot = CollectionWardrobeUtil.GetSlotFromCategoryID(appearanceSourceInfo.category);
	if slot then
		local isSecondary = false;
		local transmogLocation = TransmogUtil.GetTransmogLocation(slot, Enum.TransmogType.Appearance, isSecondary);
		self.ItemsCollectionFrame:GoToSourceID(sourceID, transmogLocation);
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

function WardrobeCollectionFrameMixin:UpdateTabButtons()
	-- sets tab
	self.SetsTab.FlashFrame:SetShown(C_TransmogSets.GetLatestSource() ~= Constants.Transmog.NoTransmogID);
end

local function IsAnySourceCollected(sources)
	for i, source in ipairs(sources) do
		if source.isCollected then
			return true;
		end
	end

	return false;
end

function WardrobeCollectionFrameMixin:SetAppearanceTooltip(contentFrame, sources, primarySourceID, warningString, slot)
	self.tooltipContentFrame = contentFrame;
	local showTrackingInfo = not IsAnySourceCollected(sources);
	if WardrobeCollectionFrame.activeFrame == WardrobeCollectionFrame.SetsCollectionFrame then
		showTrackingInfo = false;
	end

	local appearanceData = {
		sources = sources,
		primarySourceID = primarySourceID,
		selectedIndex = self.tooltipSourceIndex,
		showUseError = true,
		inLegionArtifactCategory = TransmogUtil.IsCategoryLegionArtifact(self.ItemsCollectionFrame:GetActiveCategory()),
		subheaderString = nil,
		warningString = warningString,
		showTrackingInfo = showTrackingInfo,
		slotType = slot
	}

	self.tooltipSourceIndex, self.tooltipCycle = CollectionWardrobeUtil.SetAppearanceTooltip(GameTooltip, appearanceData);
end

function WardrobeCollectionFrameMixin:HideAppearanceTooltip()
	self.tooltipContentFrame = nil;
	self.tooltipCycle = nil;
	self.tooltipSourceIndex = nil;
	GameTooltip:Hide();
end

function WardrobeCollectionFrameMixin:UpdateUsableAppearances()
	if not self.updateUsableAppearances then
		self.updateUsableAppearances = true;
		C_Timer.After(0, function() self.updateUsableAppearances = nil; C_TransmogCollection.UpdateUsableAppearances(); end);
	end
end

function WardrobeCollectionFrameMixin:RefreshCameras()
	for i, frame in ipairs(self.ContentFrames) do
		frame:RefreshCameras();
	end
end

function WardrobeCollectionFrameMixin:GetAppearanceSourceTextAndColor(appearanceInfo)
	return CollectionWardrobeUtil.GetAppearanceSourceTextAndColor(appearanceInfo);
end

function WardrobeCollectionFrameMixin:UpdateProgressBar(value, max)
	self.progressBar:SetMinMaxValues(0, max);
	self.progressBar:SetValue(value);
	self.progressBar.text:SetFormattedText(HEIRLOOMS_PROGRESS_FORMAT, value, max);
end

function WardrobeCollectionFrameMixin:SwitchSearchCategory()
	if self.ItemsCollectionFrame.transmogLocation:IsIllusion() then
		self:ClearSearch();
		self.SearchBox:Disable();
		self.FilterButton:Disable();
		return;
	end

	self.SearchBox:Enable();
	self.FilterButton:Enable();
	if self.SearchBox:GetText() ~= "" then
		local finished = C_TransmogCollection.SetSearch(self:GetSearchType(), self.SearchBox:GetText());
		if not finished then
			self:RestartSearchTracking();
		end
	end
end

function WardrobeCollectionFrameMixin:RestartSearchTracking()
	if self.activeFrame.transmogLocation and self.activeFrame.transmogLocation:IsIllusion() then
		return;
	end

	self.SearchBox.ProgressFrame:Hide();
	self.SearchBox.updateDelay = 0;
	if not C_TransmogCollection.IsSearchInProgress(self:GetSearchType()) then
		self.activeFrame:OnSearchUpdate();
	else
		self.SearchBox:StartCheckingProgress();
	end
end

function WardrobeCollectionFrameMixin:SetSearch(text)
	if text == "" then
		C_TransmogCollection.ClearSearch(self:GetSearchType());
	else
		C_TransmogCollection.SetSearch(self:GetSearchType(), text);
	end
	self:RestartSearchTracking();
end

function WardrobeCollectionFrameMixin:ClearSearch(searchType)
	self.SearchBox:SetText("");
	self.SearchBox.ProgressFrame:Hide();
	C_TransmogCollection.ClearSearch(searchType or self:GetSearchType());
end

function WardrobeCollectionFrameMixin:GetSearchType()
	return self.activeFrame.searchType;
end

function WardrobeCollectionFrameMixin:ShowItemTrackingHelptipOnShow()
	if (not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_MODEL_CLICK)) then
		self.fromSuggestedContent = true;
	end
end

function WardrobeCollectionFrameMixin:GetTooltipSourceIndex()
	return self.tooltipSourceIndex;
end

WardrobeItemsCollectionSlotButtonMixin = { }

function WardrobeItemsCollectionSlotButtonMixin:OnClick()
	PlaySound(SOUNDKIT.UI_TRANSMOG_GEAR_SLOT_CLICK);
	WardrobeCollectionFrame.ItemsCollectionFrame:SetActiveSlot(self.transmogLocation);
end

function WardrobeItemsCollectionSlotButtonMixin:OnEnter()
	if self.transmogLocation:IsIllusion() then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(WEAPON_ENCHANTMENT);
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		local slotName = _G[self.slot];
		-- for shoulders check if equipped item has the secondary appearance toggled on
		if self.transmogLocation:GetSlotName() == "SHOULDERSLOT" then
			local itemLocation = TransmogUtil.GetItemLocationFromTransmogLocation(self.transmogLocation);
			if TransmogUtil.IsSecondaryTransmoggedForItemLocation(itemLocation) then
				if self.transmogLocation:IsSecondary() then
					slotName = LEFTSHOULDERSLOT;
				else
					slotName = RIGHTSHOULDERSLOT;
				end
			end
		end
		GameTooltip:SetText(slotName);
	end
end

WardrobeItemsCollectionMixin = { };

local spacingNoSmallButton = 2;
local spacingWithSmallButton = 12;
local defaultSectionSpacing = 24;
local shorterSectionSpacing = 19;

function WardrobeItemsCollectionMixin:CreateSlotButtons()
	local slots = { "head", "shoulder", "back", "chest", "shirt", "tabard", "wrist", defaultSectionSpacing, "hands", "waist", "legs", "feet", defaultSectionSpacing, "mainhand", spacingWithSmallButton, "secondaryhand" };
	local parentFrame = self.SlotsFrame;
	local lastButton;
	local xOffset = spacingNoSmallButton;
	for i = 1, #slots do
		local value = tonumber(slots[i]);
		if ( value ) then
			-- this is a spacer
			xOffset = value;
		else
			local slotString = slots[i];
			local button = CreateFrame("BUTTON", nil, parentFrame, "WardrobeSlotButtonTemplate");
			button.NormalTexture:SetAtlas("transmog-nav-slot-"..slotString, true);
			if ( lastButton ) then
				button:SetPoint("LEFT", lastButton, "RIGHT", xOffset, 0);
			else
				button:SetPoint("TOPLEFT");
			end
			button.slot = string.upper(slotString).."SLOT";
			xOffset = spacingNoSmallButton;
			lastButton = button;
			-- small buttons
			if ( slotString == "mainhand" or slotString == "secondaryhand" or slotString == "shoulder" ) then
				local smallButton = CreateFrame("BUTTON", nil, parentFrame, "WardrobeSmallSlotButtonTemplate");
				smallButton:SetPoint("BOTTOMRIGHT", button, "TOPRIGHT", 16, -15);
				smallButton.slot = button.slot;
				if ( slotString == "shoulder" ) then
					local isSecondary = true;
					smallButton.transmogLocation = TransmogUtil.GetTransmogLocation(smallButton.slot, Enum.TransmogType.Appearance, isSecondary);

					smallButton.NormalTexture:SetAtlas("transmog-nav-slot-shoulder", false);
					smallButton:Hide();
				else
					local isSecondary = false;
					smallButton.transmogLocation = TransmogUtil.GetTransmogLocation(smallButton.slot, Enum.TransmogType.Illusion, isSecondary);
				end
			end

			button.transmogLocation = TransmogUtil.GetTransmogLocation(button.slot, button.transmogType, button.isSecondary);
		end
	end
end

function WardrobeItemsCollectionMixin:OnEvent(event, ...)
	if ( event == "TRANSMOGRIFY_UPDATE" or event == "TRANSMOGRIFY_SUCCESS" or event == "PLAYER_EQUIPMENT_CHANGED" ) then
		local slotID = ...;
		if ( slotID and self.transmogLocation:IsAppearance() ) then
			if ( slotID == self.transmogLocation:GetSlotID() ) then
				self:UpdateItems();
			end
		else
			-- generic update
			self:UpdateItems();
		end
		if event == "PLAYER_EQUIPMENT_CHANGED" then
			if C_Transmog.CanHaveSecondaryAppearanceForSlotID(slotID) then
				self:UpdateSlotButtons();
			end
		end
	elseif ( event == "TRANSMOG_COLLECTION_UPDATED") then
		self:CheckLatestAppearance(true);
		self:ValidateChosenVisualSources();
		if ( self:IsVisible() ) then
			self:RefreshVisualsList();
			self:UpdateItems();
		end
		WardrobeCollectionFrame:UpdateTabButtons();
	elseif ( event == "TRANSMOG_COLLECTION_ITEM_UPDATE" ) then
		if ( self:IsVisible() ) then
			for i = 1, #self.Models do
				self.Models[i]:UpdateContentTracking();
				self.Models[i]:UpdateTrackingDisabledOverlay();
			end
		end
	end
end

function WardrobeItemsCollectionMixin:CheckLatestAppearance(changeTab)
	local latestAppearanceID, latestAppearanceCategoryID = C_TransmogCollection.GetLatestAppearance();
	if ( self.latestAppearanceID ~= latestAppearanceID ) then
		self.latestAppearanceID = latestAppearanceID;
		self.jumpToLatestAppearanceID = latestAppearanceID;
		self.jumpToLatestCategoryID = latestAppearanceCategoryID;

		if ( changeTab and not CollectionsJournal:IsShown() ) then
			CollectionsJournal_SetTab(CollectionsJournal, 5);
		end
	end
end

function WardrobeItemsCollectionMixin:OnLoad()
	self:CreateSlotButtons();
	self.BGCornerTopLeft:Hide();
	self.BGCornerTopRight:Hide();

	self.chosenVisualSources = { };

	self.NUM_ROWS = 3;
	self.NUM_COLS = 6;
	self.PAGE_SIZE = self.NUM_ROWS * self.NUM_COLS;

	self.WeaponDropdown:SetWidth(157);

	self:RegisterEvent("TRANSMOG_COLLECTION_UPDATED");

	self:CheckLatestAppearance();
end

function WardrobeItemsCollectionMixin:CheckHelpTip()
	if (GetCVarBitfield("closedInfoFramesAccountWide", Enum.FrameTutorialAccount.TransmogSetsTab)) then
		return;
	end

	local helpTipInfo = {
		text = TRANSMOG_SETS_TAB_TUTORIAL,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedInfoFramesAccountWide",
		bitfieldFlag = Enum.FrameTutorialAccount.TransmogSetsTab,
		targetPoint = HelpTip.Point.BottomEdgeCenter,
		checkCVars = true,
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
		if slot then
			-- The model got reset from OnShow, which restored all equipment.
			-- But ChangeModelsSlot tries to be smart and only change the difference from the previous slot to the current slot, so some equipment will remain left on.
			-- This is only set for new apperances, base transmogLocation is fine
			local isSecondary = false;
			local transmogLocation = TransmogUtil.GetTransmogLocation(slot, Enum.TransmogType.Appearance, isSecondary);
			local ignorePreviousSlot = true;
			self:SetActiveSlot(transmogLocation, self.jumpToLatestCategoryID, ignorePreviousSlot);
			self.jumpToLatestCategoryID = nil;
		else
			-- In some cases getting a slot will fail (Ex. You gain a new weapon appearance but the selected class in the filter dropdown can't use that weapon type)
			-- If we fail to get a slot then just default to the head slot as usual.
			local isSecondary = false;
			local transmogLocation = TransmogUtil.GetTransmogLocation("HEADSLOT", Enum.TransmogType.Appearance, isSecondary);
			self:SetActiveSlot(transmogLocation);
		end
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

	-- tab tutorial
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

function WardrobeItemsCollectionMixin:DressUpVisual(visualInfo)
	if self.transmogLocation:IsAppearance() then
		local sourceID = self:GetAnAppearanceSourceFromVisual(visualInfo.visualID, nil);
		DressUpCollectionAppearance(sourceID, self.transmogLocation, self:GetActiveCategory());
	elseif self.transmogLocation:IsIllusion() then
		local slot = self:GetActiveSlot();
		DressUpVisual(self.illusionWeaponAppearanceID, slot, visualInfo.sourceID);
	end
end

function WardrobeItemsCollectionMixin:OnMouseWheel(delta)
	self.PagingFrame:OnMouseWheel(delta);
end

function WardrobeItemsCollectionMixin:ChangeModelsSlot(newTransmogLocation, oldTransmogLocation)
	WardrobeCollectionFrame.updateOnModelChanged = nil;
	local oldSlot = oldTransmogLocation and oldTransmogLocation:GetSlotName();
	local newSlot = newTransmogLocation:GetSlotName();

	local undressSlot, reloadModel;
	local oldSlotIsArmor = oldTransmogLocation and oldTransmogLocation:GetArmorCategoryID();
	local newSlotIsArmor = newTransmogLocation and newTransmogLocation:GetArmorCategoryID();
	if ( oldSlotIsArmor and newSlotIsArmor ) then
		if ( TransmogUtil.GetUseTransmogSkin(oldSlot) ~= TransmogUtil.GetUseTransmogSkin(newSlot) or
				TransmogUtil.GetWardrobeModelSetupData(oldSlot).useTransmogChoices ~= TransmogUtil.GetWardrobeModelSetupData(newSlot).useTransmogChoices or
				TransmogUtil.GetWardrobeModelSetupData(oldSlot).obeyHideInTransmogFlag ~= TransmogUtil.GetWardrobeModelSetupData(newSlot).obeyHideInTransmogFlag ) then
			reloadModel = true;
		else
			undressSlot = true;
		end
	else
		reloadModel = true;
	end

	if ( reloadModel and not IsUnitModelReadyForUI("player") ) then
		WardrobeCollectionFrame.updateOnModelChanged = true;
		for i = 1, #self.Models do
			self.Models[i]:ClearModel();
		end
		return;
	end

	for i = 1, #self.Models do
		local model = self.Models[i];
		if ( undressSlot ) then
			local changedOldSlot = false;
			-- dress/undress setup gear
			local setupData = TransmogUtil.GetWardrobeModelSetupData(newSlot);
			for slot, equip in pairs(setupData.slots) do
				if ( equip ~= TransmogUtil.GetWardrobeModelSetupData(oldSlot).slots[slot] ) then
					if ( equip ) then
						model:TryOn(TransmogUtil.GetWardrobeModelSetupGearData(slot));
					else
						model:UndressSlot(GetInventorySlotInfo(slot));
					end
					if ( slot == oldSlot ) then
						changedOldSlot = true;
					end
				end
			end
			-- undress old slot
			if ( not changedOldSlot ) then
				local slotID = GetInventorySlotInfo(oldSlot);
				model:UndressSlot(slotID);
			end
		elseif ( reloadModel ) then
			model:Reload(newSlot);
		end
		model.visualInfo = nil;
	end
	self.illusionWeaponAppearanceID = nil;

	self:EvaluateSlotAllowed();
end

-- For dracthyr/mechagnome
function WardrobeItemsCollectionMixin:EvaluateSlotAllowed()
	local isArmor = self.transmogLocation:GetArmorCategoryID();
		-- Any model will do, using the 1st
	local model = self.Models[1];
	self.slotAllowed = not isArmor or model:IsSlotAllowed(self.transmogLocation:GetSlotID());	
	if not model:IsGeoReady() then
		self:MarkGeoDirty();
	end
end

function WardrobeItemsCollectionMixin:MarkGeoDirty()
	self.geoDirty = true;
end

function WardrobeItemsCollectionMixin:RefreshCameras()
	if ( self:IsShown() ) then
		for i, model in ipairs(self.Models) do
			model:RefreshCamera();
			if ( model.cameraID ) then
				Model_ApplyUICamera(model, model.cameraID);
			end
		end
	end
end

function WardrobeItemsCollectionMixin:OnUnitModelChangedEvent()
	if ( IsUnitModelReadyForUI("player") ) then
		self:ChangeModelsSlot(self.transmogLocation);
		self:UpdateItems();
		return true;
	else
		return false;
	end
end

function WardrobeItemsCollectionMixin:GetActiveSlot()
	return self.transmogLocation and self.transmogLocation:GetSlotName();
end

function WardrobeItemsCollectionMixin:GetActiveCategory()
	return self.activeCategory;
end

function WardrobeItemsCollectionMixin:IsValidWeaponCategoryForSlot(categoryID)
	local name, isWeapon, canEnchant, canMainHand, canOffHand = C_TransmogCollection.GetCategoryInfo(categoryID);
	if ( name and isWeapon ) then
		if ( (self.transmogLocation:IsMainHand() and canMainHand) or (self.transmogLocation:IsOffHand() and canOffHand) ) then
			return true;
		end
	end
	return false;
end

function WardrobeItemsCollectionMixin:SetActiveSlot(transmogLocation, category, ignorePreviousSlot)
	local previousTransmogLocation;
	if not ignorePreviousSlot then
		previousTransmogLocation = self.transmogLocation;
	end
	local slotChanged = not previousTransmogLocation or not previousTransmogLocation:IsEqual(transmogLocation);

	self.transmogLocation = transmogLocation;

	-- figure out a category
	if ( not category ) then
		if ( self.transmogLocation:IsIllusion() ) then
			category = nil;
		elseif ( self.transmogLocation:IsAppearance() ) then
			local useLastWeaponCategory = self.transmogLocation:IsEitherHand() and
											self.lastWeaponCategory and
											self:IsValidWeaponCategoryForSlot(self.lastWeaponCategory);
			if ( useLastWeaponCategory ) then
				category = self.lastWeaponCategory;
			else
				local activeSlotInfo = self:GetActiveSlotInfo();
				if ( activeSlotInfo.selectedSourceID ~= Constants.Transmog.NoTransmogID ) then
					local appearanceSourceInfo = C_TransmogCollection.GetAppearanceSourceInfo(activeSlotInfo.selectedSourceID);
					category = appearanceSourceInfo and appearanceSourceInfo.category;
					if category and not self:IsValidWeaponCategoryForSlot(category) then
						category = nil;
					end
				end
			end
			if ( not category ) then
				if ( self.transmogLocation:IsEitherHand() ) then
					-- find the first valid weapon category
					for categoryID = FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE, LAST_TRANSMOG_COLLECTION_WEAPON_TYPE do
						if ( self:IsValidWeaponCategoryForSlot(categoryID) ) then
							category = categoryID;
							break;
						end
					end
				else
					category = self.transmogLocation:GetArmorCategoryID();
				end
			end
		end
	end

	if ( slotChanged ) then
		self:ChangeModelsSlot(transmogLocation, previousTransmogLocation);
	end
	-- set only if category is different or slot is different
	if ( category ~= self.activeCategory or slotChanged ) then
		self:SetActiveCategory(category);
	end
end

function WardrobeItemsCollectionMixin:UpdateWeaponDropdown()
	local _name, isActiveCategoryWeapon;
	if self.transmogLocation:IsAppearance() then
		_name, isActiveCategoryWeapon = C_TransmogCollection.GetCategoryInfo(self:GetActiveCategory());
	end

	self.WeaponDropdown:SetShown(isActiveCategoryWeapon);

	if not isActiveCategoryWeapon then
		return;
	end

	local function IsSelected(categoryID)
		return categoryID == self:GetActiveCategory();
	end

	local function SetSelected(categoryID)
		if self:GetActiveCategory() ~= categoryID then
			self:SetActiveCategory(categoryID);
		end
	end

	local transmogLocation = self.transmogLocation;
	self.WeaponDropdown:SetupMenu(function(_dropdown, rootDescription)
		rootDescription:SetTag("MENU_WARDROBE_WEAPONS_FILTER");

		local isForMainHand = transmogLocation:IsMainHand();
		local isForOffHand = transmogLocation:IsOffHand();

		for categoryID = FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE, LAST_TRANSMOG_COLLECTION_WEAPON_TYPE do
			local name, isWeapon, _canEnchant, canMainHand, canOffHand = C_TransmogCollection.GetCategoryInfo(categoryID);
			if name and isWeapon and ((isForMainHand and canMainHand) or (isForOffHand and canOffHand)) then
				rootDescription:CreateRadio(name, IsSelected, SetSelected, categoryID);
			end
		end

		self.WeaponDropdown:SetEnabled(rootDescription:HasElements());
	end);
end

function WardrobeItemsCollectionMixin:SetActiveCategory(category)
	local previousCategory = self.activeCategory;
	self.activeCategory = category;
	if previousCategory ~= category and self.transmogLocation:IsAppearance() then
		C_TransmogCollection.SetSearchAndFilterCategory(category);
		local name, isWeapon = C_TransmogCollection.GetCategoryInfo(category);
		if ( isWeapon ) then
			self.lastWeaponCategory = category;
		end
		self:RefreshVisualsList();
	else
		self:RefreshVisualsList();
		self:UpdateItems();
	end
	self:UpdateWeaponDropdown();

	self:GetParent().progressBar:SetShown(not TransmogUtil.IsCategoryLegionArtifact(category));

	local slotButtons = self.SlotsFrame.Buttons;
	for i = 1, #slotButtons do
		local button = slotButtons[i];
		button.SelectedTexture:SetShown(button.transmogLocation:IsEqual(self.transmogLocation));
	end

	local resetPage = false;
	local switchSearchCategory = false;

	if previousCategory ~= category then
		resetPage = true;
		switchSearchCategory = true;
	end

	if resetPage then
		self:ResetPage();
	end
	if switchSearchCategory then
		self:GetParent():SwitchSearchCategory();
	end
end

function WardrobeItemsCollectionMixin:ResetPage()
	local page = 1;
	local selectedVisualID = NO_TRANSMOG_VISUAL_ID;
	if ( C_TransmogCollection.IsSearchInProgress(self:GetParent():GetSearchType()) ) then
		self.resetPageOnSearchUpdated = true;
	else
		if ( self.jumpToVisualID ) then
			selectedVisualID = self.jumpToVisualID;
			self.jumpToVisualID = nil;
		elseif ( self.jumpToLatestAppearanceID ) then
			selectedVisualID = self.jumpToLatestAppearanceID;
			self.jumpToLatestAppearanceID = nil;
		end
	end
	if ( selectedVisualID and selectedVisualID ~= NO_TRANSMOG_VISUAL_ID ) then
		local visualsList = self:GetFilteredVisualsList();
		for i = 1, #visualsList do
			if ( visualsList[i].visualID == selectedVisualID ) then
				page = CollectionWardrobeUtil.GetPage(i, self.PAGE_SIZE);
				break;
			end
		end
	end
	self.PagingFrame:SetCurrentPage(page);
	self:UpdateItems();
end

function WardrobeItemsCollectionMixin:FilterVisuals()
	local visualsList = self.visualsList;
	local filteredVisualsList = { };
	for i, visualInfo in ipairs(visualsList) do
		if not visualInfo.isHideVisual then
			table.insert(filteredVisualsList, visualInfo);
		end
	end
	self.filteredVisualsList = filteredVisualsList;
end

function WardrobeItemsCollectionMixin:SortVisuals()
	local comparison = function(source1, source2)
		if ( source1.isCollected ~= source2.isCollected ) then
			return source1.isCollected;
		end
		if ( source1.isUsable ~= source2.isUsable ) then
			return source1.isUsable;
		end
		if ( source1.isFavorite ~= source2.isFavorite ) then
			return source1.isFavorite;
		end
		if ( source1.canDisplayOnPlayer ~= source2.canDisplayOnPlayer ) then
			return source1.canDisplayOnPlayer;
		end
		if ( source1.isHideVisual ~= source2.isHideVisual ) then
			return source1.isHideVisual;
		end
		if ( source1.hasActiveRequiredHoliday ~= source2.hasActiveRequiredHoliday ) then
			return source1.hasActiveRequiredHoliday;
		end
		if ( source1.uiOrder and source2.uiOrder ) then
			return source1.uiOrder > source2.uiOrder;
		end
		return source1.sourceID > source2.sourceID;
	end

	table.sort(self.filteredVisualsList, comparison);
end

function WardrobeItemsCollectionMixin:GetActiveSlotInfo()
	return TransmogUtil.GetInfoForEquippedSlot(self.transmogLocation);
end

function WardrobeItemsCollectionMixin:GetWeaponInfoForEnchant()
	if ( DressUpFrame:IsShown() ) then
		local playerActor = DressUpFrame.ModelScene:GetPlayerActor();
		if playerActor then
			local itemTransmogInfo = playerActor:GetItemTransmogInfo(self.transmogLocation:GetSlotID());
			local appearanceID = itemTransmogInfo and itemTransmogInfo.appearanceID or Constants.Transmog.NoTransmogID;
			if ( TransmogUtil.CanEnchantSource(appearanceID) ) then
				local appearanceSourceInfo = C_TransmogCollection.GetAppearanceSourceInfo(appearanceID);
				if appearanceSourceInfo then
					return appearanceID, appearanceSourceInfo.itemAppearanceID, appearanceSourceInfo.itemSubclass;
				else
					return appearanceID, nil, nil;
				end
			end
		end
	end

	local correspondingTransmogLocation = TransmogUtil.GetCorrespondingHandTransmogLocation(self.transmogLocation);
	local equippedSlotInfo = TransmogUtil.GetInfoForEquippedSlot(correspondingTransmogLocation);
	if ( TransmogUtil.CanEnchantSource(equippedSlotInfo.selectedSourceID) ) then
		return equippedSlotInfo.selectedSourceID, equippedSlotInfo.selectedVisualID, equippedSlotInfo.itemSubclass;
	else
		local appearanceSourceID = C_TransmogCollection.GetFallbackWeaponAppearance();
		local appearanceSourceInfo = C_TransmogCollection.GetAppearanceSourceInfo(appearanceSourceID);
		if appearanceSourceInfo then
			return appearanceSourceID, appearanceSourceInfo.itemAppearanceID, appearanceSourceInfo.itemSubclass;
		else
			return appearanceSourceID, nil, nil;
		end
	end
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

	if (self.trackingModifierDown and not ContentTrackingUtil.IsTrackingModifierDown()) or (not self.trackingModifierDown and ContentTrackingUtil.IsTrackingModifierDown()) then
		for i, model in ipairs(self.Models) do
			model:UpdateTrackingDisabledOverlay();
		end
		self:RefreshAppearanceTooltip();
	end
	self.trackingModifierDown = ContentTrackingUtil.IsTrackingModifierDown();
end

function WardrobeItemsCollectionMixin:UpdateItems()
	local isArmor;
	local cameraID;
	local appearanceVisualID;	-- for weapon when looking at enchants
	local appearanceVisualSubclass;
	local changeModel = false;

	if ( self.transmogLocation:IsIllusion() ) then
		-- for enchants we need to get the visual of the item in that slot
		local appearanceSourceID;
		appearanceSourceID, appearanceVisualID, appearanceVisualSubclass = self:GetWeaponInfoForEnchant();
		cameraID = C_TransmogCollection.GetAppearanceCameraIDBySource(appearanceSourceID);
		if ( appearanceSourceID ~= self.illusionWeaponAppearanceID ) then
			self.illusionWeaponAppearanceID = appearanceSourceID;
			changeModel = true;
		end
	else
		local _, isWeapon = C_TransmogCollection.GetCategoryInfo(self.activeCategory);
		isArmor = not isWeapon;
	end

	local tutorialAnchorFrame;
	local checkTutorialFrame = self.transmogLocation:IsAppearance() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_MODEL_CLICK) and WardrobeCollectionFrame.fromSuggestedContent;

	local slotVisualInfo = C_Transmog.GetSlotVisualInfo(self.transmogLocation:GetData());
	local cameraVariation = TransmogUtil.GetCameraVariation(self.transmogLocation);

	local indexOffset = (self.PagingFrame:GetCurrentPage() - 1) * self.PAGE_SIZE;
	for i = 1, self.PAGE_SIZE do
		local model = self.Models[i];
		local index = i + indexOffset;
		local visualInfo = self.filteredVisualsList[index];
		if ( visualInfo ) then
			model:Show();

			-- camera
			if ( self.transmogLocation:IsAppearance() ) then
				cameraID = C_TransmogCollection.GetAppearanceCameraID(visualInfo.visualID, cameraVariation);
			end
			if ( model.cameraID ~= cameraID ) then
				Model_ApplyUICamera(model, cameraID);
				model.cameraID = cameraID;
			end

			local canDisplayVisuals = self.transmogLocation:IsIllusion() or visualInfo.canDisplayOnPlayer;
			if ( visualInfo ~= model.visualInfo or changeModel ) then
				if ( not canDisplayVisuals ) then
					if ( isArmor ) then
						model:UndressSlot(self.transmogLocation:GetSlotID());
					else
						model:ClearModel();
					end
				elseif ( isArmor ) then
					local sourceID = self:GetAnAppearanceSourceFromVisual(visualInfo.visualID, nil);
					model:TryOn(sourceID);
				elseif ( appearanceVisualID ) then
					-- appearanceVisualID is only set when looking at enchants
					model:SetItemAppearance(appearanceVisualID, visualInfo.visualID, appearanceVisualSubclass);
				else
					model:SetItemAppearance(visualInfo.visualID);
				end
			end
			model.visualInfo = visualInfo;
			model:UpdateContentTracking();
			model:UpdateTrackingDisabledOverlay();

			model.TransmogStateTexture:Hide();

			-- border
			if ( not visualInfo.isCollected ) then
				model.Border:SetAtlas("transmog-wardrobe-border-uncollected");
			elseif ( not visualInfo.isUsable ) then
				model.Border:SetAtlas("transmog-wardrobe-border-unusable");
			else
				model.Border:SetAtlas("transmog-wardrobe-border-collected");
			end

			if ( C_TransmogCollection.IsNewAppearance(visualInfo.visualID) ) then
				model.NewString:Show();
				model.NewGlow:Show();
			else
				model.NewString:Hide();
				model.NewGlow:Hide();
			end
			-- favorite
			model.Favorite.Icon:SetShown(visualInfo.isFavorite);
			-- hide visual option
			model.HideVisual.Icon:Hide();
			-- slots not allowed
			local showAsInvalid = not canDisplayVisuals or not self.slotAllowed;
			model.SlotInvalidTexture:SetShown(showAsInvalid);		
			model:SetDesaturated(showAsInvalid);

			if ( GameTooltip:GetOwner() == model ) then
				model:OnEnter();
			end

			-- find potential tutorial anchor for trackable item
			if ( checkTutorialFrame ) then
				if ( not WardrobeCollectionFrame.tutorialVisualID and not visualInfo.isCollected and not visualInfo.isHideVisual and model:HasTrackableSource()) then
					tutorialAnchorFrame = model;
				elseif ( WardrobeCollectionFrame.tutorialVisualID and WardrobeCollectionFrame.tutorialVisualID == visualInfo.visualID ) then
					tutorialAnchorFrame = model;
				end
			end
		else
			model:Hide();
			model.visualInfo = nil;
		end
	end

	-- progress bar
	self:UpdateProgressBar();
	-- tutorial
	if ( checkTutorialFrame ) then
		if ( tutorialAnchorFrame ) then
			if ( not WardrobeCollectionFrame.tutorialVisualID ) then
				WardrobeCollectionFrame.tutorialVisualID = tutorialAnchorFrame.visualInfo.visualID;
			end
			if ( WardrobeCollectionFrame.tutorialVisualID ~= tutorialAnchorFrame.visualInfo.visualID ) then
				tutorialAnchorFrame = nil;
			end
		end
	end
	if ( tutorialAnchorFrame ) then
		local helpTipInfo = {
			text = WARDROBE_TRACKING_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_TRANSMOG_MODEL_CLICK,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			onAcknowledgeCallback = function() WardrobeCollectionFrame.fromSuggestedContent = nil;
											   WardrobeCollectionFrame.ItemsCollectionFrame:CheckHelpTip(); end,
			acknowledgeOnHide = true,
		};
		HelpTip:Show(self, helpTipInfo, tutorialAnchorFrame);
	else
		HelpTip:Hide(self, WARDROBE_TRACKING_TUTORIAL);
	end
end

function WardrobeItemsCollectionMixin:UpdateProgressBar()
	local collected, total;
	if ( self.transmogLocation:IsIllusion() ) then
		total = #self.visualsList;
		collected = 0;
		for i, illusion in ipairs(self.visualsList) do
			if ( illusion.isCollected ) then
				collected = collected + 1;
			end
		end
	else
		collected = C_TransmogCollection.GetFilteredCategoryCollectedCount(self.activeCategory);
		total = C_TransmogCollection.GetFilteredCategoryTotal(self.activeCategory);
	end
	self:GetParent():UpdateProgressBar(collected, total);
end

function WardrobeItemsCollectionMixin:RefreshVisualsList()
	if self.transmogLocation:IsIllusion() then
		self.visualsList = C_TransmogCollection.GetIllusions();
	else
		self.visualsList = C_TransmogCollection.GetCategoryAppearances(self.activeCategory, self.transmogLocation:GetData());
	end
	self:FilterVisuals();
	self:SortVisuals();
	self.PagingFrame:SetMaxPages(ceil(#self.filteredVisualsList / self.PAGE_SIZE));
end

function WardrobeItemsCollectionMixin:GetFilteredVisualsList()
	return self.filteredVisualsList;
end

function WardrobeItemsCollectionMixin:GetAnAppearanceSourceFromVisual(visualID, mustBeUsable)
	local sourceID = self:GetChosenVisualSource(visualID);
	if ( sourceID == Constants.Transmog.NoTransmogID ) then
		local sources = CollectionWardrobeUtil.GetSortedAppearanceSources(visualID, self.activeCategory, self.transmogLocation);
		for i = 1, #sources do
			-- first 1 if it doesn't have to be usable
			if ( not mustBeUsable or self:IsAppearanceUsableForActiveCategory(sources[i]) ) then
				sourceID = sources[i].sourceID;
				break;
			end
		end
	end
	return sourceID;
end

function WardrobeItemsCollectionMixin:GoToSourceID(sourceID, transmogLocation, forceGo, forTransmog, overrideCategoryID)
	local categoryID, visualID;
	if ( transmogLocation:IsAppearance() ) then
		local appearanceSourceInfo = C_TransmogCollection.GetAppearanceSourceInfo(sourceID);
		if appearanceSourceInfo then
			categoryID = appearanceSourceInfo.category;
			visualID = appearanceSourceInfo.itemAppearanceID;
		end
	elseif ( transmogLocation:IsIllusion() ) then
		local illusionInfo = C_TransmogCollection.GetIllusionInfo(sourceID);
		visualID = illusionInfo and illusionInfo.visualID;
	end
	if overrideCategoryID then
		categoryID = overrideCategoryID;
	end
	if ( visualID or forceGo ) then
		self.jumpToVisualID = visualID;
		if ( self.activeCategory ~= categoryID or not self.transmogLocation:IsEqual(transmogLocation) ) then
			self:SetActiveSlot(transmogLocation, categoryID);
		else
			if not self.filteredVisualsList then
				self:RefreshVisualsList();
			end
			self:ResetPage();
		end
	end
end

function WardrobeItemsCollectionMixin:SetAppearanceTooltip(frame)
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
	self.tooltipModel = frame;
	self.tooltipVisualID = frame.visualInfo.visualID;
	self:RefreshAppearanceTooltip();
end

function WardrobeItemsCollectionMixin:RefreshAppearanceTooltip()
	if ( not self.tooltipVisualID ) then
		return;
	end
	local sources = CollectionWardrobeUtil.GetSortedAppearanceSourcesForClass(self.tooltipVisualID, C_TransmogCollection.GetClassFilter(), self.activeCategory, self.transmogLocation);
	
	-- When swapping Classes in the Collections panel,
	-- There is a quick period of time when moving the
	-- cursor to another element can produce a size 0
	-- sources list. This causes a nil error if not 
	-- guarded against
	if #sources == 0 then
		return;
	end

	local chosenSourceID = self:GetChosenVisualSource(self.tooltipVisualID);	
	local warningString = CollectionWardrobeUtil.GetBestVisibilityWarning(self.tooltipModel, self.transmogLocation, sources);
	self:GetParent():SetAppearanceTooltip(self, sources, chosenSourceID, warningString);
end

function WardrobeItemsCollectionMixin:ClearAppearanceTooltip()
	self.tooltipVisualID = nil;
	self:GetParent():HideAppearanceTooltip();
end

function WardrobeItemsCollectionMixin:UpdateSlotButtons()
	local shoulderSlotID = TransmogUtil.GetSlotID("SHOULDERSLOT");
	local itemLocation = ItemLocation:CreateFromEquipmentSlot(shoulderSlotID);
	local showSecondaryShoulder = TransmogUtil.IsSecondaryTransmoggedForItemLocation(itemLocation);

	local isSecondary = true;
	local secondaryShoulderTransmogLocation = TransmogUtil.GetTransmogLocation("SHOULDERSLOT", Enum.TransmogType.Appearance, isSecondary);
	local lastButton = nil;
	for i, button in ipairs(self.SlotsFrame.Buttons) do
		if not button.isSmallButton then
			local slotName =  button.transmogLocation:GetSlotName();
			if slotName == "BACKSLOT" then
				local xOffset = showSecondaryShoulder and spacingWithSmallButton or spacingNoSmallButton;
				button:SetPoint("LEFT", lastButton, "RIGHT", xOffset, 0);
			elseif slotName == "HANDSSLOT" or slotName == "MAINHANDSLOT" then
				local xOffset = showSecondaryShoulder and shorterSectionSpacing or defaultSectionSpacing;
				button:SetPoint("LEFT", lastButton, "RIGHT", xOffset, 0);
			end
			lastButton = button;
		elseif button.transmogLocation:IsEqual(secondaryShoulderTransmogLocation) then
			button:SetShown(showSecondaryShoulder);
		end
	end

	if self.transmogLocation then
		-- if it was selected and got hidden, reset to main shoulder
		-- otherwise if main selected, update cameras
		isSecondary = false;
		local mainShoulderTransmogLocation = TransmogUtil.GetTransmogLocation("SHOULDERSLOT", Enum.TransmogType.Appearance, isSecondary);
		if not showSecondaryShoulder and self.transmogLocation:IsEqual(secondaryShoulderTransmogLocation) then
			self:SetActiveSlot(mainShoulderTransmogLocation);
		elseif self.transmogLocation:IsEqual(mainShoulderTransmogLocation) then
			self:UpdateItems();
		end
	end
end

function WardrobeItemsCollectionMixin:OnPageChanged(userAction)
	PlaySound(SOUNDKIT.UI_TRANSMOG_PAGE_TURN);
	if ( userAction ) then
		self:UpdateItems();
	end
end

function WardrobeItemsCollectionMixin:OnSearchUpdate(category)
	if ( category ~= self.activeCategory ) then
		return;
	end

	self:RefreshVisualsList();
	if ( self.resetPageOnSearchUpdated ) then
		self.resetPageOnSearchUpdated = nil;
		self:ResetPage();
	else
		self:UpdateItems();
	end
end

function WardrobeItemsCollectionMixin:IsAppearanceUsableForActiveCategory(appearanceInfo)
	local inLegionArtifactCategory = TransmogUtil.IsCategoryLegionArtifact(self.activeCategory);
	return CollectionWardrobeUtil.IsAppearanceUsable(appearanceInfo, inLegionArtifactCategory);
end

function WardrobeItemsCollectionMixin:GetChosenVisualSource(visualID)
	return self.chosenVisualSources[visualID] or Constants.Transmog.NoTransmogID;
end

function WardrobeItemsCollectionMixin:SetChosenVisualSource(visualID, sourceID)
	self.chosenVisualSources[visualID] = sourceID;
end

function WardrobeItemsCollectionMixin:ValidateChosenVisualSources()
	for visualID, sourceID in pairs(self.chosenVisualSources) do
		if ( sourceID ~= Constants.Transmog.NoTransmogID ) then
			local keep = false;
			local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID);
			if sourceInfo then
				if sourceInfo.isCollected and not sourceInfo.useError then
					keep = true;
				end
			end
			if ( not keep ) then
				self.chosenVisualSources[visualID] = Constants.Transmog.NoTransmogID;
			end
		end
	end
end

function WardrobeItemsCollectionMixin:GetAppearanceNameTextAndColor(appearanceInfo)
	local inLegionArtifactCategory = TransmogUtil.IsCategoryLegionArtifact(self.activeCategory);
	return CollectionWardrobeUtil.GetAppearanceNameTextAndColor(appearanceInfo, inLegionArtifactCategory);
end

function WardrobeItemsCollectionMixin:GetTransmogLocation()
	return self.transmogLocation;
end

function WardrobeItemsCollectionMixin:GetTooltipSourceIndex()
	return self:GetTooltipSourceIndexCallback();
end

-- ***** MODELS

WardrobeItemModelMixin = CreateFromMixins(ItemModelBaseMixin);

-- Overridden.
function WardrobeItemModelMixin:OnMouseDown(button)
	ItemModelBaseMixin.OnMouseDown(self, button);

	local appearanceInfo = self:GetAppearanceInfo();
	local itemsCollectionFrame = self:GetCollectionFrame();
	if not appearanceInfo or not itemsCollectionFrame then
		return;
	end

	if not appearanceInfo.isCollected then
		local sourceInfo = self:GetSourceInfoForTracking();
		if sourceInfo then
			if not sourceInfo.playerCanCollect then
				ContentTrackingUtil.DisplayTrackingError(Enum.ContentTrackingError.Untrackable);
				return;
			end

			if self:CheckTrackableClick(button, Enum.ContentTrackingType.Appearance, sourceInfo.sourceID) then
				self:UpdateContentTracking();
				itemsCollectionFrame:RefreshAppearanceTooltip();
				return;
			end
		end
	end
end

-- Overridden.
function WardrobeItemModelMixin:OnEnter()
	ItemModelBaseMixin.OnEnter(self);

	local appearanceInfo = self:GetAppearanceInfo();
	local itemsCollectionFrame = self:GetCollectionFrame();
	if not appearanceInfo or not itemsCollectionFrame then
		return;
	end

	if C_TransmogCollection.IsNewAppearance(appearanceInfo.visualID) then
		C_TransmogCollection.ClearNewAppearance(appearanceInfo.visualID);
		if itemsCollectionFrame.jumpToLatestAppearanceID == appearanceInfo.visualID then
			itemsCollectionFrame.jumpToLatestAppearanceID = nil;
			itemsCollectionFrame.jumpToLatestCategoryID  = nil;
		end
		self.NewString:Hide();
		self.NewGlow:Hide();
	end
end

-- Overridden.
function WardrobeItemModelMixin:OnLeave()
	ItemModelBaseMixin.OnLeave(self);

	ResetCursor();
end

-- Overridden.
function WardrobeItemModelMixin:GetAppearanceInfo()
	return self.visualInfo;
end

-- Overridden.
function WardrobeItemModelMixin:GetCollectionFrame()
	return self:GetParent();
end

-- Overridden.
function WardrobeItemModelMixin:ToggleFavorite(visualID, isFavorite)
	ItemModelBaseMixin.ToggleFavorite(self, visualID, isFavorite);

	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_MODEL_CLICK, true);
end

-- Overridden.
function WardrobeItemModelMixin:GetAppearanceLink()
	local link = nil;
	local appearanceInfo = self:GetAppearanceInfo();
	local itemsCollectionFrame = self:GetCollectionFrame();
	if not appearanceInfo or not itemsCollectionFrame then
		return link;
	end

	local tooltipSourceIndex = itemsCollectionFrame:GetTooltipSourceIndex();
	local sources = CollectionWardrobeUtil.GetSortedAppearanceSourcesForClass(appearanceInfo.visualID, C_TransmogCollection.GetClassFilter(), itemsCollectionFrame:GetActiveCategory(), itemsCollectionFrame:GetTransmogLocation());
	if tooltipSourceIndex then
		local index = CollectionWardrobeUtil.GetValidIndexForNumSources(tooltipSourceIndex, #sources);
		local preferArtifact = itemsCollectionFrame:GetActiveCategory() == Enum.TransmogCollectionType.Paired;
		link = CollectionWardrobeUtil.GetAppearanceItemHyperlink(sources[index], preferArtifact);
	end

	return link;
end

function WardrobeItemModelMixin:UpdateContentTracking()
	local appearanceInfo = self:GetAppearanceInfo();
	local itemsCollectionFrame = self:GetCollectionFrame();
	if not appearanceInfo or not itemsCollectionFrame then
		return;
	end

	self:ClearTrackables();

	if not itemsCollectionFrame:GetTransmogLocation():IsIllusion() then
		local sources = CollectionWardrobeUtil.GetSortedAppearanceSourcesForClass(appearanceInfo.visualID, C_TransmogCollection.GetClassFilter(), itemsCollectionFrame:GetActiveCategory(), itemsCollectionFrame:GetTransmogLocation());
		for _index, sourceInfo in ipairs(sources) do
			if sourceInfo.playerCanCollect then
				self:AddTrackable(Enum.ContentTrackingType.Appearance, sourceInfo.sourceID);
			end
		end
	end

	self:UpdateTrackingCheckmark();
end

function WardrobeItemModelMixin:UpdateTrackingDisabledOverlay()
	local appearanceInfo = self:GetAppearanceInfo();
	if not appearanceInfo then
		return;
	end

	local contentTrackingDisabled = not ContentTrackingUtil.IsContentTrackingEnabled();
	if contentTrackingDisabled then
		self.DisabledOverlay:SetShown(false);
		return;
	end

	local showDisabled = ContentTrackingUtil.IsTrackingModifierDown() and (appearanceInfo.isCollected or not self:HasTrackableSource());
	self.DisabledOverlay:SetShown(showDisabled);
end

function WardrobeItemModelMixin:GetSourceInfoForTracking()
	local appearanceInfo = self:GetAppearanceInfo();
	local itemsCollectionFrame = self:GetCollectionFrame();
	if not appearanceInfo or not itemsCollectionFrame then
		return;
	end

	if itemsCollectionFrame:GetTransmogLocation():IsIllusion() then
		return nil;
	else
		local sourceIndex = itemsCollectionFrame.tooltipSourceIndex or 1;
		local sources = CollectionWardrobeUtil.GetSortedAppearanceSourcesForClass(appearanceInfo.visualID, C_TransmogCollection.GetClassFilter(), itemsCollectionFrame:GetActiveCategory(), itemsCollectionFrame:GetTransmogLocation());
		local index = CollectionWardrobeUtil.GetValidIndexForNumSources(sourceIndex, #sources);
		return sources[index];
	end
end

-- ***** TUTORIAL
WardrobeCollectionTutorialMixin = { };

function WardrobeCollectionTutorialMixin:OnLoad()

	self.helpTipInfo = {
		text = WARDROBE_SHORTCUTS_TUTORIAL_1,
		buttonStyle = HelpTip.ButtonStyle.None,
		targetPoint = HelpTip.Point.BottomEdgeLeft,
		alignment = HelpTip.Alignment.Left,
		offsetX = 32,
		offsetY = 16,
		appendFrame = TrackingInterfaceShortcutsFrame,
	};

end

function WardrobeCollectionTutorialMixin:OnEnter()
	HelpTip:Show(self, self.helpTipInfo);
end

function WardrobeCollectionTutorialMixin:OnLeave()
	HelpTip:Hide(self, WARDROBE_SHORTCUTS_TUTORIAL_1);
end

WardrobeCollectionClassDropdownMixin = {};

function WardrobeCollectionClassDropdownMixin:OnLoad()
	self:SetWidth(150);

	self:SetSelectionTranslator(function(selection)
		local classInfo = selection.data;
		local classColor = GetClassColorObj(classInfo.classFile) or HIGHLIGHT_FONT_COLOR;
		return classColor:WrapTextInColorCode(classInfo.className);
	end);
end

function WardrobeCollectionClassDropdownMixin:OnShow()
	self:Refresh();
end

function WardrobeCollectionClassDropdownMixin:GetClassFilter()
	local searchType = WardrobeCollectionFrame:GetSearchType();
	if searchType == Enum.TransmogSearchType.Items then
		return C_TransmogCollection.GetClassFilter();
	elseif searchType == Enum.TransmogSearchType.BaseSets then
		return C_TransmogSets.GetTransmogSetsClassFilter();
	end
end

function WardrobeCollectionClassDropdownMixin:SetClassFilter(classID)
	local searchType = WardrobeCollectionFrame:GetSearchType();
	if searchType == Enum.TransmogSearchType.Items then
		-- Let's reset to the helmet category if the class filter changes while a weapon category is active
		-- Not all classes can use the same weapons so the current category might not be valid
		local _name, isWeapon = C_TransmogCollection.GetCategoryInfo(WardrobeCollectionFrame.ItemsCollectionFrame:GetActiveCategory());
		if isWeapon then
			local isSecondary = false;
			WardrobeCollectionFrame.ItemsCollectionFrame:SetActiveSlot(TransmogUtil.GetTransmogLocation("HEADSLOT", Enum.TransmogType.Appearance, isSecondary));
		end

		C_TransmogCollection.SetClassFilter(classID);
	elseif searchType == Enum.TransmogSearchType.BaseSets then
		C_TransmogSets.SetTransmogSetsClassFilter(classID);
	end

	self:Refresh();
end

function WardrobeCollectionClassDropdownMixin:Refresh()
	local classFilter = self:GetClassFilter();
	if not classFilter then
		return;
	end

	local classInfo = C_CreatureInfo.GetClassInfo(classFilter);
	if not classInfo then
		return;
	end

	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_WARDROBE_CLASS");

		local function IsClassFilterSet(classInfo)
			return self:GetClassFilter() == classInfo.classID; 
		end;

		local function SetClassFilter(classInfo)
			self:SetClassFilter(classInfo.classID); 
		end;

		for classID = 1, GetNumClasses() do
			local classInfo = C_CreatureInfo.GetClassInfo(classID);
			rootDescription:CreateRadio(classInfo.className, IsClassFilterSet, SetClassFilter, classInfo);
		end
	end);
end

WardrobeCollectionFrameSearchBoxProgressMixin = { };

function WardrobeCollectionFrameSearchBoxProgressMixin:OnLoad()
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 15);

	self.ProgressBar:SetStatusBarColor(0, .6, 0, 1);
	self.ProgressBar:SetMinMaxValues(0, 1000);
	self.ProgressBar:SetValue(0);
	self.ProgressBar:GetStatusBarTexture():SetDrawLayer("BORDER");
end

function WardrobeCollectionFrameSearchBoxProgressMixin:OnHide()
	self.ProgressBar:SetValue(0);
end

function WardrobeCollectionFrameSearchBoxProgressMixin:OnUpdate(elapsed)
	if self.updateProgressBar then
		local searchType = WardrobeCollectionFrame:GetSearchType();
		if not C_TransmogCollection.IsSearchInProgress(searchType) then
			self:Hide();
		else
			local _, maxValue = self.ProgressBar:GetMinMaxValues();
			local searchSize = C_TransmogCollection.SearchSize(searchType);
			local searchProgress = C_TransmogCollection.SearchProgress(searchType);
			self.ProgressBar:SetValue((searchProgress * maxValue) / searchSize);
		end
	end
end

function WardrobeCollectionFrameSearchBoxProgressMixin:ShowLoadingFrame()
	self.LoadingFrame:Show();
	self.ProgressBar:Hide();
	self.updateProgressBar = false;
	self:Show();
end

function WardrobeCollectionFrameSearchBoxProgressMixin:ShowProgressBar()
	self.LoadingFrame:Hide();
	self.ProgressBar:Show();
	self.updateProgressBar = true;
	self:Show();
end

WardrobeCollectionFrameSearchBoxMixin = { }

function WardrobeCollectionFrameSearchBoxMixin:OnLoad()
	SearchBoxTemplate_OnLoad(self);
end

function WardrobeCollectionFrameSearchBoxMixin:OnHide()
	self.ProgressFrame:Hide();
end

function WardrobeCollectionFrameSearchBoxMixin:OnKeyDown(key, ...)
	if key == WARDROBE_CYCLE_KEY then
		WardrobeCollectionFrame:OnKeyDown(key, ...);
	end
end

function WardrobeCollectionFrameSearchBoxMixin:StartCheckingProgress()
	self.checkProgress = true;
	self.updateDelay = 0;
end

local WARDROBE_SEARCH_DELAY = 0.6;
function WardrobeCollectionFrameSearchBoxMixin:OnUpdate(elapsed)
	if not self.checkProgress then
		return;
	end

	self.updateDelay = self.updateDelay + elapsed;

	if not C_TransmogCollection.IsSearchInProgress(WardrobeCollectionFrame:GetSearchType()) then
		self.checkProgress = false;
	elseif self.updateDelay >= WARDROBE_SEARCH_DELAY then
		self.checkProgress = false;
		if not C_TransmogCollection.IsSearchDBLoading() then
			self.ProgressFrame:ShowProgressBar();
		else
			self.ProgressFrame:ShowLoadingFrame();
		end
	end
end

function WardrobeCollectionFrameSearchBoxMixin:OnTextChanged()
	SearchBoxTemplate_OnTextChanged(self);
	WardrobeCollectionFrame:SetSearch(self:GetText());
end

function WardrobeCollectionFrameSearchBoxMixin:OnEnter()
	if not self:IsEnabled() then
		GameTooltip:ClearAllPoints();
		GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 0);
		GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
		GameTooltip:SetText(WARDROBE_NO_SEARCH);
	end
end
