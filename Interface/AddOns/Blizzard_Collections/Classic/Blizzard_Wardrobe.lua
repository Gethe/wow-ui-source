WARDROBE_TAB_ITEMS = 1;
WARDROBE_TAB_SETS = 2;
WARDROBE_TABS_MAX_WIDTH = 185;

WardrobeCollectionFrameMixin = { };

function WardrobeCollectionFrameMixin:ClickTab(tab)
	self:SetTab(tab:GetID());
	PanelTemplates_ResizeTabsToFit(WardrobeCollectionFrame, WARDROBE_TABS_MAX_WIDTH);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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
			description:CreateCheckbox(_G["TRANSMOG_SOURCE_"..filterIndex], IsChecked, SetChecked, filterIndex);
		end
	end

	self.FilterButton:SetIsDefaultCallback(function()
		return C_TransmogCollection.IsUsingDefaultFilters();
	end);

	self.FilterButton:SetDefaultCallback(function()
		return C_TransmogCollection.SetDefaultFilters();
	end);

	self.FilterButton:SetText(FILTER);

	self.FilterButton:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_WARDROBE_FILTER");
		rootDescription:CreateCheckbox(COLLECTED, C_TransmogCollection.GetCollectedShown, function()
			C_TransmogCollection.SetCollectedShown(not C_TransmogCollection.GetCollectedShown());
		end);

		rootDescription:CreateCheckbox(NOT_COLLECTED, C_TransmogCollection.GetUncollectedShown, function()
			C_TransmogCollection.SetUncollectedShown(not C_TransmogCollection.GetUncollectedShown());
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

function WardrobeCollectionFrameMixin:OnEvent(event, ...)
	if ( event == "TRANSMOG_COLLECTION_ITEM_UPDATE" ) then
		if ( self.tooltipContentFrame ) then
			self.tooltipContentFrame:RefreshAppearanceTooltip();
		end
		if ( self.ItemsCollectionFrame:IsShown() ) then
			self.ItemsCollectionFrame:ValidateChosenVisualSources();
		end
	elseif ( event == "UNIT_FORM_CHANGED" ) then
		local hasAlternateForm, inAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
		if ( (self.inAlternateForm ~= inAlternateForm or self.updateOnModelChanged) ) then
			if ( self.activeFrame:OnUnitModelChangedEvent() ) then
				self.inAlternateForm = inAlternateForm;
				self.updateOnModelChanged = nil;
			end
		end
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

function WardrobeCollectionFrameMixin:OnUpdate()
end

function WardrobeCollectionFrameMixin:OnShow()
	self:GetParent().portrait:SetTexture("Interface\\Icons\\inv_chest_cloth_17");

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

function WardrobeCollectionFrameMixin:SetAppearanceTooltip(contentFrame, sources, primarySourceID, warningString, slot)
	self.tooltipContentFrame = contentFrame;

	local appearanceData = {
		sources = sources,
		primarySourceID = primarySourceID,
		selectedIndex = self.tooltipSourceIndex,
		showUseError = true,
		inLegionArtifactCategory = TransmogUtil.IsCategoryLegionArtifact(self.ItemsCollectionFrame:GetActiveCategory()),
		subheaderString = nil,
		warningString = warningString,
		showTrackingInfo = false,
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
	if self.activeFrame.transmogLocation then
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

function WardrobeCollectionFrameMixin:GetTooltipSourceIndex()
	return self.tooltipSourceIndex;
end

WardrobeItemsCollectionSlotButtonMixin = { }

function WardrobeItemsCollectionSlotButtonMixin:OnClick()
	PlaySound(SOUNDKIT.UI_TRANSMOG_GEAR_SLOT_CLICK);
	WardrobeCollectionFrame.ItemsCollectionFrame:SetActiveSlot(self.transmogLocation);
end

function WardrobeItemsCollectionSlotButtonMixin:OnEnter()
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

WardrobeItemsCollectionMixin = { };

local spacingNoSmallButton = 2;
local spacingWithSmallButton = 12;
local defaultSectionSpacing = 24;
local shorterSectionSpacing = 19;

function WardrobeItemsCollectionMixin:CreateSlotButtons()
	local slots = { "head", "shoulder", "back", "chest", "shirt", "tabard", "wrist", defaultSectionSpacing, "hands", "waist", "legs", "feet", defaultSectionSpacing, "mainhand", "secondaryhand" }; --spacingWithSmallButton,
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
				button:SetPoint("TOPLEFT", 10, 0);
			end
			button.slot = string.upper(slotString).."SLOT";
			xOffset = spacingNoSmallButton;
			lastButton = button;
			-- small buttons
			if (slotString == "shoulder" ) then 
				local smallButton = CreateFrame("BUTTON", nil, parentFrame, "WardrobeSmallSlotButtonTemplate");
				smallButton:SetPoint("BOTTOMRIGHT", button, "TOPRIGHT", 16, -15);
				smallButton.slot = button.slot;
				if ( slotString == "shoulder" ) then
					local isSecondary = true;
					smallButton.transmogLocation = TransmogUtil.GetTransmogLocation(smallButton.slot, Enum.TransmogType.Appearance, isSecondary);

					smallButton.NormalTexture:SetAtlas("transmog-nav-slot-shoulder", false);
					smallButton:Hide();
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
	local name, isWeapon, canEnchant, canMainHand, canOffHand, canRanged = C_TransmogCollection.GetCategoryInfo(categoryID);
	if ( name and isWeapon ) then
		local isForMainHand = self.transmogLocation:IsMainHand();
		local isForOffHand = self.transmogLocation:IsOffHand();
		-- Ranged weapons appear in the mainhand dropdown for Appearances, but have their own slot at the transmogrifier
		local isForRanged = isForMainHand;
		if ( (isForMainHand and canMainHand) or (isForOffHand and canOffHand) or (isForRanged and canRanged) ) then
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
		if ( self.transmogLocation:IsAppearance() ) then
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

		-- Ranged weapons appear in the mainhand dropdown for Appearances, but have their own slot at the transmogrifier
		local isForRanged = isForMainHand;
		for categoryID = FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE, LAST_TRANSMOG_COLLECTION_WEAPON_TYPE do
			local name, isWeapon, _canEnchant, canMainHand, canOffHand, canRanged = C_TransmogCollection.GetCategoryInfo(categoryID);
			if name and isWeapon and ((isForMainHand and canMainHand) or (isForOffHand and canOffHand) or (isForRanged and canRanged)) then
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

function WardrobeItemsCollectionMixin:UpdateItems()
	local isArmor;
	local cameraID;
	local appearanceVisualID = nil;	-- for weapon when looking at enchants
	local appearanceVisualSubclass = nil;
	local changeModel = false;

	local _, isWeapon = C_TransmogCollection.GetCategoryInfo(self.activeCategory);
	isArmor = not isWeapon;

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

			if ( visualInfo ~= model.visualInfo or changeModel ) then
				if ( isArmor ) then
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

			if ( GameTooltip:GetOwner() == model ) then
				model:OnEnter();
			end
		else
			model:Hide();
			model.visualInfo = nil;
		end
	end

	-- progress bar
	self:UpdateProgressBar();
end

function WardrobeItemsCollectionMixin:UpdateProgressBar()
	local collected, total;
	collected = C_TransmogCollection.GetCategoryCollectedCount(self.activeCategory);
	total = C_TransmogCollection.GetCategoryTotal(self.activeCategory);

	self:GetParent():UpdateProgressBar(collected, total);
end

function WardrobeItemsCollectionMixin:RefreshVisualsList()
	self.visualsList = C_TransmogCollection.GetCategoryAppearances(self.activeCategory, self.transmogLocation:GetData());

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
	local sources = CollectionWardrobeUtil.GetSortedAppearanceSources(self.tooltipVisualID, self.activeCategory, self.transmogLocation);
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

function WardrobeItemsCollectionMixin:DressUpVisual(visualInfo)
	if self.transmogLocation:IsAppearance() then
		local sourceID = self:GetAnAppearanceSourceFromVisual(visualInfo.visualID, nil);
		DressUpVisual(sourceID);
	end
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
function WardrobeItemModelMixin:GetAppearanceLink()
	local link = nil;
	local appearanceInfo = self:GetAppearanceInfo();
	local itemsCollectionFrame = self:GetCollectionFrame();
	if not appearanceInfo or not itemsCollectionFrame then
		return link;
	end

	local tooltipSourceIndex = itemsCollectionFrame:GetTooltipSourceIndex();
	local sources = CollectionWardrobeUtil.GetSortedAppearanceSources(appearanceInfo.visualID, itemsCollectionFrame:GetActiveCategory(), itemsCollectionFrame:GetTransmogLocation());
	if tooltipSourceIndex then
		local index = CollectionWardrobeUtil.GetValidIndexForNumSources(tooltipSourceIndex, #sources);
		local preferArtifact = itemsCollectionFrame:GetActiveCategory() == Enum.TransmogCollectionType.Paired;
		link = CollectionWardrobeUtil.GetAppearanceItemHyperlink(sources[index], preferArtifact);
	end

	return link;
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
