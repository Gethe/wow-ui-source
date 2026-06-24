local FRAME_SLIDE_DURATION = 0.25;
local BUTTON_SLIDE_DURATION = 0.15;

CustomizeDecorPetFrameMixin = {};

function CustomizeDecorPetFrameMixin:OnLoad()
	local stride = 4;
	local view = CreateScrollBoxListGridView(stride, self.OptionsContainer.topPadding, self.OptionsContainer.bottomPadding, self.OptionsContainer.leftPadding, self.OptionsContainer.rightPadding, self.OptionsContainer.horizontalSpacing, self.OptionsContainer.verticalSpacing);
	view:SetElementInitializer("HousingPetEntryTemplate", function(button, elementData)
			button:Init(elementData);
		end);
	
	self.OptionsContainer.ScrollBox:SetEdgeFadeLength(75);
	local petEntryTemplate = C_XMLUtil.GetTemplateInfo("HousingPetEntryTemplate");
	view:SetElementSize(petEntryTemplate.width, petEntryTemplate.height);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.OptionsContainer.ScrollBox, self.OptionsContainer.ScrollBar, view);
	
	self:InitializeFilterDropdown();
	self:InitializeSearchBox();

	self.CollapseButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.HOUSING_CATALOG_COLLAPSE);
		self:SetCollapsed(true);
	end);
	self.CollapseButton:SetScript("OnEnter", function()
		self.CollapseButton.OverlayIcon:Show();
	end);
	self.CollapseButton:SetScript("OnLeave", function()
		self.CollapseButton.OverlayIcon:Hide();
	end);

	FrameUtil.InitFrameAnimTransition(self, {
		translationType = AnimTransitionMixinTransitionType.SlideLeft,
		duration = FRAME_SLIDE_DURATION,
		easingFunction = EasingUtil.OutExponential,
		hideOnAnimOut = true,
		onAnimOutFinish = function()
			FunctionUtil.CheckInvokeMethod(self.expandButton, "Show");
			FunctionUtil.CheckInvokeMethod(self.expandButton, "StartAnimIn");
		end,
	});
end

function CustomizeDecorPetFrameMixin:SetExpandButton(expandButton)
	self.expandButton = expandButton;
	FrameUtil.InitFrameAnimTransition(self.expandButton, {
		distanceX = self.expandButton:GetWidth() * 0.67,
		translationType = AnimTransitionMixinTransitionType.SlideLeft,
		duration = BUTTON_SLIDE_DURATION,
		easingFunction = EasingUtil.OutExponential,
		hideOnAnimOut = true,
		onAnimOutFinish = function()
			self:Show();
			self:StartAnimIn();
		end,
	});

	self.expandButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.HOUSING_CATALOG_EXPAND);
		self:SetCollapsed(false);
	end);
end

function CustomizeDecorPetFrameMixin:SetCollapsed(shouldCollapse)
	self.collapsed = shouldCollapse;
	self:UpdateCollapseState();
end

function CustomizeDecorPetFrameMixin:IsCollapsed()
	return self.collapsed;
end

function CustomizeDecorPetFrameMixin:UpdateCollapseState(immediate)
	if self.collapsed then
		-- No animation if we're not starting from a shown state.
		if immediate or not self:IsShown() then
			FunctionUtil.CheckInvokeMethod(self.expandButton, "Show");
			self:Hide();
		else
			self:StartAnimOut();
		end
	else
		-- No animation if we're not starting from a shown state.
		if immediate or not FunctionUtil.CheckInvokeMethod(self.expandButton, "IsShown") then
			FunctionUtil.CheckInvokeMethod(self.expandButton, "Hide");
			self:Show();
		else
			FunctionUtil.CheckInvokeMethod(self.expandButton, "StartAnimOut");
		end
	end
end

function CustomizeDecorPetFrameMixin:OnEvent(event)
	if event == "PET_JOURNAL_LIST_UPDATE" then
		self:UpdatePetList();
	end
end

function CustomizeDecorPetFrameMixin:InitializeSearchBox()
	self.SearchBox:SetScript("OnTextChanged", function(editBox)
		SearchBoxTemplate_OnTextChanged(editBox);
		C_PetJournal.SetSearchFilter(editBox:GetText());
	end);
end

function CustomizeDecorPetFrameMixin:InitializeFilterDropdown()
	self.Filters:SetDefaultCallback(function()
		self:SetHousingPetFilters();
	end);

	local function IsFamilyChecked(filterIndex) 
		return C_PetJournal.IsPetTypeChecked(filterIndex)
	end

	local function ToggleFamilyChecked(filterIndex) 
		C_PetJournal.SetPetTypeFilter(filterIndex, not IsFamilyChecked(filterIndex));
	end
	
	local function IsSourceChecked(filterIndex) 
		return C_PetJournal.IsPetSourceChecked(filterIndex)
	end

	local function ToggleSourceChecked(filterIndex) 
		C_PetJournal.SetPetSourceChecked(filterIndex, not IsSourceChecked(filterIndex));
	end
	
	local function IsSortByChecked(parameter) 
		return C_PetJournal.GetPetSortParameter() == parameter;
	end

	local function SetSortByChecked(parameter) 
		C_PetJournal.SetPetSortParameter(parameter);
		self:UpdatePetList();
	end
	
	local function SetAllPetTypesChecked(checked)
		C_PetJournal.SetAllPetTypesChecked(checked);
	end
	
	local function SetAllPetSourcesChecked(checked)
		C_PetJournal.SetAllPetSourcesChecked(checked);
	end

	self.Filters:SetIsDefaultCallback(function()
		for i = 1, C_PetJournal.GetNumPetTypes() do
			if not C_PetJournal.IsPetTypeChecked(i) then
				return false
			end
		end
		
		for i = 1, C_PetJournal.GetNumPetSources() do
			if not C_PetJournal.IsPetSourceChecked(i) then
				return false
			end
		end

		return IsSortByChecked(LE_SORT_BY_NAME);
	end);

	self.Filters:SetupMenu(function(dropdown, rootDescription)
		local familiesSubmenu = rootDescription:CreateButton(PET_FAMILIES);
		familiesSubmenu:CreateButton(CHECK_ALL, SetAllPetTypesChecked, true);
		familiesSubmenu:CreateButton(UNCHECK_ALL, SetAllPetTypesChecked, false);

		for filterIndex = 1, C_PetJournal.GetNumPetTypes() do
			familiesSubmenu:CreateCheckbox(_G["BATTLE_PET_NAME_"..filterIndex], IsFamilyChecked, ToggleFamilyChecked, filterIndex);
		end
		
		local sourceSubmenu = rootDescription:CreateButton(SOURCES);
		sourceSubmenu:CreateButton(CHECK_ALL, SetAllPetSourcesChecked, true);
		sourceSubmenu:CreateButton(UNCHECK_ALL, SetAllPetSourcesChecked, false);

		for filterIndex = 1, C_PetJournal.GetNumPetSources() do
			sourceSubmenu:CreateCheckbox(_G["BATTLE_PET_SOURCE_"..filterIndex], IsSourceChecked, ToggleSourceChecked, filterIndex);
		end
		
		local sortBySubmenu = rootDescription:CreateButton(RAID_FRAME_SORT_LABEL);
		sortBySubmenu:CreateRadio(NAME, IsSortByChecked, SetSortByChecked, LE_SORT_BY_NAME);
		sortBySubmenu:CreateRadio(LEVEL, IsSortByChecked, SetSortByChecked, LE_SORT_BY_LEVEL);
		sortBySubmenu:CreateRadio(RARITY, IsSortByChecked, SetSortByChecked, LE_SORT_BY_RARITY);
		sortBySubmenu:CreateRadio(TYPE, IsSortByChecked, SetSortByChecked, LE_SORT_BY_PETTYPE);
	end);
end

function CustomizeDecorPetFrameMixin:SetCustomizationPetPane(customizationPetPane)
	self.customizationPetPane = customizationPetPane;
end

function CustomizeDecorPetFrameMixin:CachePetJournalFilters()
	--Due to pet journal filters being hard coded to one cache of pets that gets filtered and sorted, if we want to re-use pet journal filters
	--we need to cache the currently saved filters and set them back on hide. This works since the pet journal UI can't be open in house edit mode.

	self.cachedFilters = {
		collected = C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED),
		notCollected = C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED),
		battlePets = C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_TYPE_BATTLE_PETS),
		nonCombatPets = C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_TYPE_NON_COMBAT_PETS),
		petTypes = {},
		petSources = {},
		sortParameter = C_PetJournal.GetPetSortParameter(),
		searchText = C_PetJournal.GetSearchFilter(),
	};
	
	for i = 1, C_PetJournal.GetNumPetTypes() do
		self.cachedFilters.petTypes[i] = C_PetJournal.IsPetTypeChecked(i);
	end
	
	for i = 1, C_PetJournal.GetNumPetSources() do
		self.cachedFilters.petSources[i] = C_PetJournal.IsPetSourceChecked(i);
	end
end

function CustomizeDecorPetFrameMixin:RestorePetJournalFilters()
	if not self.cachedFilters then
		return;
	end
	
	C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED, self.cachedFilters.collected);
	C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED, self.cachedFilters.notCollected);
	C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_TYPE_BATTLE_PETS, self.cachedFilters.battlePets);
	C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_TYPE_NON_COMBAT_PETS, self.cachedFilters.nonCombatPets);
	
	for i = 1, C_PetJournal.GetNumPetTypes() do
		C_PetJournal.SetPetTypeFilter(i, self.cachedFilters.petTypes[i]);
	end
	
	for i = 1, C_PetJournal.GetNumPetSources() do
		C_PetJournal.SetPetSourceChecked(i, self.cachedFilters.petSources[i]);
	end
	
	C_PetJournal.SetPetSortParameter(self.cachedFilters.sortParameter);
	C_PetJournal.SetSearchFilter(self.cachedFilters.searchText);
	
	self.cachedFilters = nil;
end

function CustomizeDecorPetFrameMixin:SetHousingPetFilters()
	C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED, true);
	C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED, false);
	C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_TYPE_BATTLE_PETS, true);
	C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_TYPE_NON_COMBAT_PETS, true);
	C_PetJournal.SetAllPetTypesChecked(true);
	C_PetJournal.SetAllPetSourcesChecked(true);
	C_PetJournal.SetPetSortParameter(LE_SORT_BY_NAME);
	C_PetJournal.SetSearchFilter("");
end

function CustomizeDecorPetFrameMixin:UpdatePetList()
	local newDataProvider = CreateDataProvider();
	newDataProvider:Insert({name = HOUSING_DECOR_CUSTOMIZATION_PET_NONE, customizationPetPane = self.customizationPetPane});
	
	for index = 1, C_PetJournal.GetNumPets() do
		local petID, speciesID = C_PetJournal.GetPetInfoByIndex(index);
		if petID then
			local petInfo = C_PetJournal.GetPetInfoTableByPetID(petID);
			if petInfo.canAttachToDecor then
				newDataProvider:Insert({
					petID = petID, 
					speciesID = petInfo.speciesID, 
					name = petInfo.name, 
					customName = petInfo.customName, 
					customizationPetPane = self.customizationPetPane
				});
			end
		end
	end
	
	self.OptionsContainer.ScrollBox:SetDataProvider(newDataProvider, ScrollBoxConstants.RetainScrollPosition);
end

local CustomizePetDecorShownEvents =
{
	"PET_JOURNAL_LIST_UPDATE",
}

function CustomizeDecorPetFrameMixin:OnShow()
	self:CachePetJournalFilters();
	self:SetHousingPetFilters();
	self.SearchBox:SetText("");
	self:UpdatePetList();

	FrameUtil.RegisterFrameForEvents(self, CustomizePetDecorShownEvents);
end

function CustomizeDecorPetFrameMixin:OnHide()
	self:RestorePetJournalFilters();
	
	FrameUtil.UnregisterFrameForEvents(self, CustomizePetDecorShownEvents);
end

DecorPetCustomizationMixin = {};

local PetBehaviorTypeStrings = {
	[Enum.HousingPetBehaviorType.Stationary] = HOUSING_DECOR_CUSTOMIZATION_PET_STATIONARY,
	[Enum.HousingPetBehaviorType.Wander] = HOUSING_DECOR_CUSTOMIZATION_PET_ROAMING,
};

function DecorPetCustomizationMixin:SetPetID(petID)
	self.petID = petID;
	if petID then
		local petInfo = C_PetJournal.GetPetInfoTableByPetID(petID);
		self.AssignPetContainer.PetIcon:SetTexture(petInfo.icon);
		self.AssignPetContainer.PetCustomName:SetText(petInfo.customName);
		self.AssignPetContainer.PetName:SetText(petInfo.name);
		self.AssignPetContainer.AssignPetText:Hide();
		self.AssignPetContainer.PetCustomName:Show();
		self.AssignPetContainer.PetName:Show();
		if petInfo.customName then
			self.AssignPetContainer.PetName:SetPoint("LEFT", self.AssignPetContainer.PetIconSlot, "RIGHT", 5, -6);
		else
			self.AssignPetContainer.PetName:SetPoint("LEFT", self.AssignPetContainer.PetIconSlot, "RIGHT", 5, 0);
		end
	else
		self.AssignPetContainer.AssignPetText:Show();
		self.AssignPetContainer.PetCustomName:Hide();
		self.AssignPetContainer.PetName:Hide();
		self.AssignPetContainer.PetIcon:SetAtlas("ItemUpgrade_GreenPlusIcon");
	end
end

function DecorPetCustomizationMixin:OnApply()
	if self:IsShown() then 
		C_HousingCustomizeMode.ApplyPetToSelectedDecor(self.petID, self.selectedBehaviorType);
	end
end

function DecorPetCustomizationMixin:OnShow()
	local petID, petBehavior = C_HousingCustomizeMode.GetSelectedDecorPetInfo();
	self.selectedBehaviorType = petBehavior;
	self:SetupDropdown();
	self:SetPetID(petID);
end

function DecorPetCustomizationMixin:SetupDropdown()
	local function OnBehaviorSelected(behaviorType)
		self.selectedBehaviorType = behaviorType;
	end

	self.BehaviorDropdown:SetupMenu(function(dropdown, rootDescription)
		local function IsSelected(behaviorType)
			return behaviorType == self.selectedBehaviorType;
		end;

		local function SetSelected(behaviorType)
			OnBehaviorSelected(behaviorType);
		end;

		for index, behaviorType in pairs(Enum.HousingPetBehaviorType) do
			local option = rootDescription:CreateHighlightRadio(PetBehaviorTypeStrings[behaviorType], IsSelected, SetSelected, behaviorType);

			--Wander behavior is not available outside
			if not C_Housing.IsInsideHouse() and behaviorType == Enum.HousingPetBehaviorType.Wander then
			option:SetEnabled(false);
				option:SetOnEnter(function(self)
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
					GameTooltip:SetText(HOUSING_DECOR_CUSTOMIZATION_PET_UNAVAILABLE_OUTSIDE, RED_FONT_COLOR:GetRGB());
					GameTooltip:Show();
				end);
				option:SetOnLeave(function(self)
					GameTooltip:Hide();
				end);
			end
		end
	end);
end

HousingPetEntryMixin = {};

function HousingPetEntryMixin:Init(elementData)
	if(elementData.speciesID) then
		local petInfo = C_PetJournal.GetPetInfoTableBySpeciesID(elementData.speciesID);
		local cardModelSceneID, loadoutModelSceneID = C_PetJournal.GetPetModelSceneInfoBySpeciesID(elementData.speciesID);
		local forceSceneChange = false;
		self.ModelScene:TransitionToModelSceneID(cardModelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN, forceSceneChange);

		local battlePetActor = self.ModelScene:GetActorByTag("unwrapped");
		if ( battlePetActor ) then
			battlePetActor:SetModelByCreatureDisplayID(petInfo.displayID, true);
		end

		self.NoPetIcon:Hide();
		self.ModelScene:Show();
	else
		self.ModelScene:Hide();
		self.NoPetIcon:Show();
	end

	self.name = elementData.name;
	self.customName = elementData.customName;
	self.petID = elementData.petID;
	self.customizationPetPane = elementData.customizationPetPane;
end

function HousingPetEntryMixin:OnEnter()
	self.HoverBackground:Show();
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if self.customName then
		GameTooltip_AddHighlightLine(GameTooltip, self.customName);
	end
	GameTooltip_AddNormalLine(GameTooltip, self.name);
	GameTooltip:Show();
end

function HousingPetEntryMixin:OnLeave()
	self.HoverBackground:Hide();
	GameTooltip:Hide();
end

function HousingPetEntryMixin:OnClick()
	self.customizationPetPane:SetPetID(self.petID);
end
