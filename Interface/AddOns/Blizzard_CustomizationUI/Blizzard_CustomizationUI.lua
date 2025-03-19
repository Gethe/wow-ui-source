----------------- Parent Frame -----------------

CustomizationParentFrameBaseMixin = {};

function CustomizationParentFrameBaseMixin:SetCustomizationChoice(optionID, choiceID)
	-- Required Override
	assert(false);
end

function CustomizationParentFrameBaseMixin:PreviewCustomizationChoice(optionID, choiceID)
	-- Required Override
	assert(false);
end

function CustomizationParentFrameBaseMixin:ResetCustomizationPreview(clearSavedChoices)
	-- Required Override
	assert(false);
end

function CustomizationParentFrameBaseMixin:MarkCustomizationChoiceAsSeen(choiceID)
	-- Required Override
	assert(false);
end

function CustomizationParentFrameBaseMixin:MarkCustomizationOptionAsSeen(optionID)
	-- Required Override
	assert(false);
end

function CustomizationParentFrameBaseMixin:GetCurrentCameraZoom()
	-- Required Override
	assert(false);
end

function CustomizationParentFrameBaseMixin:SetCameraZoomLevel(zoomLevel, keepCustomZoom)
	-- Required Override
	assert(false);
end

function CustomizationParentFrameBaseMixin:ZoomCamera(zoomAmount)
	-- Required Override
	assert(false);
end

function CustomizationParentFrameBaseMixin:RotateSubject(rotationAmount)
	-- Required Override
	assert(false);
end

function CustomizationParentFrameBaseMixin:ResetSubjectRotation()
	-- Required Override
	assert(false);
end

function CustomizationParentFrameBaseMixin:RandomizeAppearance()
	-- Required Override
	assert(false);
end

function CustomizationParentFrameBaseMixin:SetCameraDistanceOffset(offset)
	-- Optional Override
end

function CustomizationParentFrameBaseMixin:OnButtonClick()
	-- Optional Override
	-- Called every time a button within the customization frame is clicked, useful for things like
	-- server timeout/last interaction time handling
end

----------------- Randomize Appearance Button -----------------

-- Expects to inherit CustomizationSmallButtonMixin
CustomizationRandomizeAppearanceButtonMixin = {};

function CustomizationRandomizeAppearanceButtonMixin:OnClick()
	CustomizationSmallButtonMixin.OnClick(self);
	self:GetCustomizationFrame():RandomizeAppearance();
end

----------------- Reset Camera Button -----------------

-- Expects to inherit CustomizationSmallButtonMixin
CustomizationResetCameraButtonMixin = {};

function CustomizationResetCameraButtonMixin:OnClick()
	CustomizationSmallButtonMixin.OnClick(self);
	local customizationFrame = self:GetCustomizationFrame();
	customizationFrame:ResetSubjectRotation();
	customizationFrame:UpdateCameraMode();
end

----------------- Zoom Button -----------------

CustomizationZoomButtonMixin = CreateFromMixins(CustomizationClickOrHoldButtonMixin);

function CustomizationZoomButtonMixin:DoClickAction()
	self:GetCustomizationFrame():ZoomCamera(self.clickAmount);
end

function CustomizationZoomButtonMixin:DoHoldAction(elapsed)
	self:GetCustomizationFrame():ZoomCamera(self.holdAmountPerSecond * elapsed);
end

----------------- Rotate Button -----------------

CustomizationRotateButtonMixin = CreateFromMixins(CustomizationClickOrHoldButtonMixin);

function CustomizationRotateButtonMixin:DoClickAction()
	self:GetCustomizationFrame():RotateSubject(self.clickAmount);
end

function CustomizationRotateButtonMixin:DoHoldAction(elapsed)
	self:GetCustomizationFrame():RotateSubject(self.holdAmountPerSecond * elapsed);
end

----------------- Category Button -----------------

CustomizationCategoryButtonMixin = CreateFromMixins(CustomizationMaskedButtonMixin, CustomizationContentFrameMixin);

function CustomizationCategoryButtonMixin:SetCategory(categoryData, selectedCategoryID)
	self.categoryData = categoryData;
	self.categoryID = categoryData.id;
	self.layoutIndex = categoryData.orderIndex;

	self:ClearTooltipLines();

	if CustomizationUtil.ShouldShowDebugTooltipInfo() then
		self:AddTooltipLine("Category ID: "..categoryData.id, HIGHLIGHT_FONT_COLOR);
	end

	self.New:SetShown(categoryData.hasNewChoices);
	local selected = self:IsSelected(categoryData, selectedCategoryID);

	if selected then
		self:SetChecked(true);
		self:SetIconAtlas(categoryData.selectedIcon);
	else
		self:SetChecked(false);
		self:SetIconAtlas(categoryData.icon);
	end

	self:UpdateHighlightTexture();
end

function CustomizationCategoryButtonMixin:IsSelected(categoryData, selectedCategoryID)
	return selectedCategoryID == categoryData.id;
end

function CustomizationCategoryButtonMixin:OnClick()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);

	local hadCategoryChange = false;

	local customizationFrame = self:GetCustomizationFrame();

	if self.categoryData.subcategory then
		hadCategoryChange = not customizationFrame:IsSelectedSubcategory(self.categoryData);
		if hadCategoryChange then 
			customizationFrame:SetSelectedSubcategory(self.categoryData);
		end
	else
		-- If selecting a new main Category, we need to clear the Subcategory and 
		-- force it to pick a new best valid one in SetCategory().
		hadCategoryChange = not customizationFrame:IsSelectedCategory(self.categoryData);
		if hadCategoryChange then 
			customizationFrame:SetSelectedCategory(self.categoryData);
			customizationFrame:SetSelectedSubcategory(nil);
		end
	end

	-- If we didn't change category with this click, then we won't run SetCustomizations(), 
	-- which would have updated our button's state. So, update it here.
	if not hadCategoryChange then
		self:SetChecked(true);
		self:SetIconAtlas(self.categoryData.selectedIcon);
	end
end

function CustomizationCategoryButtonMixin:GetDebugName()
	return self.categoryData and self.categoryData.name or nil;
end

----------------- Customization Frame -----------------

CustomizationFrameBaseMixin = {};

function CustomizationFrameBaseMixin:CustomizationFrameBase_OnLoad()
	self:RegisterEvent("CVAR_UPDATE");

	self.pools = CreateFramePoolCollection();
	self.pools:CreatePool("CHECKBUTTON", self.Categories, self.categoryButtonTemplate);
	self.pools:CreatePool("FRAME", self.Options, "CustomizationOptionCheckButtonTemplate");
	self.pools:CreatePool("FRAME", self, "CustomizationAudioInterface", function(pool, audioInterface)
		Pool_HideAndClearAnchors(pool, audioInterface);
		audioInterface:StopAudio();
	end);

	-- Keep the dropdowns and sliders in different pools because we need to be careful not to release the option the player is interacting with
	self.dropdownPool = CreateFramePool("BUTTON", self.Options, "CustomizationDropdownWithSteppersAndLabelTemplate");
	self.sliderPool = CreateFramePool("FRAME", self.Options, "CustomizationOptionSliderTemplate");

	self.RandomizeAppearanceButton:SetCustomizationFrame(self);

	for _, button in ipairs(self.SmallButtons.ControlButtons) do
		button:SetCustomizationFrame(self);
	end
end

function CustomizationFrameBaseMixin:OnEvent(event, ...)
	if event == "CVAR_UPDATE" then
		local cvarName, cvarValue = ...;
		if cvarName == "debugTargetInfo" then
			CustomizationUtil.UpdateShowDebugTooltipInfo();
			if self:IsShown() then
				self:RefreshCustomizations();
			end
		end
	end
end

function CustomizationFrameBaseMixin:OnHide()
	local clearSavedChoices = true;
	self:ResetCustomizationPreview(clearSavedChoices);
	self:SaveSeenChoices();
end

function CustomizationFrameBaseMixin:AttachToParentFrame(parentFrame)
	self.parentFrame = parentFrame;
	self:SetParent(parentFrame);
end

-- Used to set up spacing adjustments when resolution and UI scale don't leave enough room.
function CustomizationFrameBaseMixin:SetOptionsSpacingConfiguration(topFrame, bottomFrame)
	self.Options:SetTopFrame(topFrame);
	self.Options:SetBottomFrame(bottomFrame, POPOUT_CLEARANCE);
end

function CustomizationFrameBaseMixin:OnButtonClick()
	self.parentFrame:OnButtonClick();
end

function CustomizationFrameBaseMixin:SetCustomizationChoice(optionID, choiceID)
	self.parentFrame:SetCustomizationChoice(optionID, choiceID);
end

function CustomizationFrameBaseMixin:PreviewCustomizationChoice(optionID, choiceID)
	self.parentFrame:PreviewCustomizationChoice(optionID, choiceID);
end

function CustomizationFrameBaseMixin:ResetCustomizationPreview(clearSavedChoices)
	self.parentFrame:ResetCustomizationPreview(clearSavedChoices);
end

function CustomizationFrameBaseMixin:MarkCustomizationChoiceAsSeen(choiceID)
	self.parentFrame:MarkCustomizationChoiceAsSeen(choiceID);
end

function CustomizationFrameBaseMixin:MarkCustomizationOptionAsSeen(optionID)
	self.parentFrame:MarkCustomizationOptionAsSeen(optionID);
end

function CustomizationFrameBaseMixin:SaveSeenChoices()
	self.parentFrame:SaveSeenChoices();
end

function CustomizationFrameBaseMixin:Reset()
	self.selectedCategoryData = nil;
	self.selectedSubcategoryData = nil;
end

function CustomizationFrameBaseMixin:NeedsCategorySelected()
	if not self:HasSelectedCategory() then
		return true;
	end

	for _, categoryData in ipairs(self:GetCategories()) do
		if self.selectedCategoryData.id == categoryData.id then
			return false;
		end
	end

	return true;
end

function CustomizationFrameBaseMixin:NeedsSubcategorySelected()
	if not self:HasSelectedSubcategory() then
		return true;
	end

	for _, categoryData in ipairs(self:GetCategories()) do
		if self.selectedSubcategoryData.id == categoryData.id then
			return false;
		end
	end

	return true;
end

function CustomizationFrameBaseMixin:RefreshCustomizations()
	local categories = self:GetCategories();
	if categories then
		self:SetCustomizations(categories);
	end
end

function CustomizationFrameBaseMixin:GetFirstValidSubcategory()
	local categories = self:GetCategories();

	for i, category in ipairs(categories) do
		if category.subcategory then
			return category;
		end
	end

	return self:GetFirstValidCategory();
end

function CustomizationFrameBaseMixin:GetFirstValidCategory()
	local categories = self:GetCategories();
	local firstCategory = categories[1];

	return firstCategory;
end

function CustomizationFrameBaseMixin:GetCategory(categoryIndex)
	return self:GetCategories()[categoryIndex];
end

function CustomizationFrameBaseMixin:GetCategories()
	return self.categories;
end

function CustomizationFrameBaseMixin:SetCustomizations(categories)
	self.categories = categories;

	local keepState = self:HasSelectedCategory();

	-- Select required Category if needed.
	local needsCategorySelected = self:NeedsCategorySelected();
	if needsCategorySelected then
		self:SetSelectedCategory(self:GetFirstValidCategory(), keepState);
	else
		self:SetSelectedCategory(self.selectedCategoryData, keepState);
	end

	-- Select required Subcategory if needed.
	keepState = self:HasSelectedSubcategory();
	if needsCategorySelected or self:NeedsSubcategorySelected() then
		self:SetSelectedSubcategory(self:GetFirstValidSubcategory(), keepState);
	else 
		self:SetSelectedSubcategory(self.selectedSubcategoryData, keepState);
	end

	self:AddMissingOptions();

	EventRegistry:TriggerEvent("Customization.OnSetCustomizations");
end

function CustomizationFrameBaseMixin:GetOptionPool(optionType)
	if optionType == Enum.ChrCustomizationOptionType.Dropdown then
		return self.dropdownPool;
	elseif optionType == Enum.ChrCustomizationOptionType.Checkbox then
		return self.pools:GetPool("CustomizationOptionCheckButtonTemplate");
	elseif optionType == Enum.ChrCustomizationOptionType.Slider then
		return self.sliderPool;
	end
end

function CustomizationFrameBaseMixin:GetCategoryPool(categoryData)
	return self.pools:GetPool(self.categoryButtonTemplate);
end

-- Releases all sliders EXCEPT the one the player is currently dragging (if they are dragging one).
-- Returns the currently dragging slider if there was one
function CustomizationFrameBaseMixin:ReleaseNonDraggingSliders()
	local draggingSlider;
	local releaseSliders = {};

	for optionSlider in self.sliderPool:EnumerateActive() do
		if optionSlider.Slider:IsDraggingThumb() then
			draggingSlider = optionSlider;
		else
			table.insert(releaseSliders, optionSlider);
		end
	end

	for _, releaseSlider in ipairs(releaseSliders) do
		self.sliderPool:Release(releaseSlider);
	end

	return draggingSlider;
end

-- Releases all popouts EXCEPT the one the player currently has open (if they have one open)
-- Returns the currently open popout if there was one
function CustomizationFrameBaseMixin:ReleaseClosedDropdowns()
	local openOptionFrame;
	local optionFrames = {};

	for optionFrame in self.dropdownPool:EnumerateActive() do
		if optionFrame.Dropdown:IsMenuOpen() then
			openOptionFrame = optionFrame;
		else
			table.insert(optionFrames, optionFrame);
		end
	end

	for _, optionFrame in ipairs(optionFrames) do
		self.dropdownPool:Release(optionFrame);
	end

	return openOptionFrame;
end

function CustomizationFrameBaseMixin:ProcessCategory(categoryData, interactingOption, optionsToSetup)
	local categoryPool = self:GetCategoryPool(categoryData);
	local button = categoryPool:Acquire();
	button:SetCustomizationFrame(self);

	local selectedSubcategoryDataID = 0;
	if self.selectedSubcategoryData then
		selectedSubcategoryDataID = self.selectedSubcategoryData.id;
	end

	if categoryData.subcategory then
		self.numSubcategories = self.numSubcategories + 1;
		button:SetCategory(categoryData, selectedSubcategoryDataID);
	else
		button:SetCategory(categoryData, self.selectedCategoryData.id);
	end

	button:Show();

	local fallbackToCategory = not selectedSubcategoryDataID;
	local categoryMatches = self.selectedCategoryData.id == categoryData.id;
	local subcategoryMatches = selectedSubcategoryDataID == categoryData.id;
	local interactingOptionReused = false;

	if (fallbackToCategory and categoryMatches) or subcategoryMatches then
		for _, optionData in ipairs(categoryData.options) do
			local optionPool = self:GetOptionPool(optionData.optionType);
			if optionPool then
				local optionFrame;

				if interactingOption and interactingOption.optionData.id == optionData.id then
					-- This option is being interacted with and so was not released.
					optionFrame = interactingOption;
					interactingOptionReused = true;
				else
					optionFrame = optionPool:Acquire();
					optionFrame:SetCustomizationFrame(self);
				end
				-- This is only to guarantee that the frame has a resolvable rect prior to layout. Intended to disappear
				-- in a future version of LayoutFrame.
				optionFrame:SetPoint("TOPLEFT");

				-- Just set layoutIndex on the option and add it to optionsToSetup for now.
				-- Setup will be called on each one, but it needs to happen after self.Options:Layout() is called
				optionFrame.layoutIndex = optionData.orderIndex;
				optionsToSetup[optionFrame] = optionData;
				optionFrame:Show();
			end
		end
	end

	return interactingOptionReused;
end

function CustomizationFrameBaseMixin:UpdateOptionButtons(forceReset)
	self.pools:ReleaseAll();

	local interactingOption;

	if forceReset then
		self.sliderPool:ReleaseAll();
		self.dropdownPool:ReleaseAll();
	else
		local draggingSlider = self:ReleaseNonDraggingSliders();
		local openOptionFrame = self:ReleaseClosedDropdowns();
		interactingOption = draggingSlider or openOptionFrame;
	end

	self.numSubcategories = 0;

	local optionsToSetup = {};
	for _, categoryData in ipairs(self:GetCategories()) do
		local interactingOptionUsed = self:ProcessCategory(categoryData, interactingOption, optionsToSetup);
		if interactingOptionUsed then
			-- If the interacting option got used, clear it so it doesn't get re-reused or released
			interactingOption = nil;
		end
	end

	-- If the interacting option wasn't reused, ensure it gets released
	if interactingOption then
		local owningPool = self:GetOptionPool(interactingOption:GetOptionData().optionType);
		owningPool:Release(interactingOption);
	end

	-- Update options container before setup so it's the proper size/layout first
	self:UpdateOptionsContainer();

	for optionFrame, optionData in pairs(optionsToSetup) do
		optionFrame:SetupOption(optionData);

		if optionFrame:HasSound() then
			optionFrame:SetupAudio(self.pools:Acquire("CustomizationAudioInterface"));
		end
	end

	self:UpdateCategoriesContainer();
end

function CustomizationFrameBaseMixin:UpdateOptionsContainer()
	self.Options:Layout();
end

function CustomizationFrameBaseMixin:UpdateCategoriesContainer()
	self.Categories:SetShown(self.numSubcategories > 1);
end


function CustomizationFrameBaseMixin:GetBestCategoryData()
	-- Prefer Subcategory if we have one.
	if self.selectedSubcategoryData then
		return self.selectedSubcategoryData;
	else
		return self.selectedCategoryData;
	end
end

function CustomizationFrameBaseMixin:UpdateCameraDistanceOffset()
	local categoryData = self:GetBestCategoryData();
	self.parentFrame:SetCameraDistanceOffset(categoryData.cameraDistanceOffset);
end

function CustomizationFrameBaseMixin:UpdateZoomButtonStates()
	local currentZoom = self.parentFrame:GetCurrentCameraZoom();

	if not currentZoom then
		self.SmallButtons:Hide();
		return;
	else
		self.SmallButtons:Show();
	end

	local zoomOutEnabled = (currentZoom > 0);
	self.SmallButtons.ZoomOutButton:SetEnabled(zoomOutEnabled);
	self.SmallButtons.ZoomOutButton.Icon:SetAtlas(zoomOutEnabled and "common-icon-zoomout" or "common-icon-zoomout-disable");

	local zoomInEnabled = (currentZoom < 100);
	self.SmallButtons.ZoomInButton:SetEnabled(zoomInEnabled);
	self.SmallButtons.ZoomInButton.Icon:SetAtlas(zoomInEnabled and "common-icon-zoomin" or "common-icon-zoomin-disable");
end

function CustomizationFrameBaseMixin:UpdateCameraMode(keepCustomZoom)
	local categoryData = self:GetBestCategoryData();
	self.parentFrame:SetCameraZoomLevel(categoryData.cameraZoomLevel, keepCustomZoom);
	self:UpdateZoomButtonStates();
end

function CustomizationFrameBaseMixin:SetSelectedCategory(categoryData, keepState)
	local hadCategoryChange = not self:IsSelectedCategory(categoryData);

	self.selectedCategoryData = categoryData;
	if not self.selectedSubcategoryData then
		self:UpdateOptionButtons(not keepState);
		self:UpdateCameraDistanceOffset();
		self:UpdateCameraMode(keepState);
	end

	EventRegistry:TriggerEvent("Customization.OnCategorySelected", self, hadCategoryChange);
end

function CustomizationFrameBaseMixin:SetSelectedSubcategory(categoryData, keepState)
	if not categoryData then
		self.selectedSubcategoryData = nil;
		return;
	end

	local hadCategoryChange = not self:IsSelectedSubcategory(categoryData);

	self.selectedSubcategoryData = categoryData;
	self:UpdateOptionButtons(not keepState);
	self:UpdateCameraDistanceOffset();
	self:UpdateCameraMode(keepState);

	EventRegistry:TriggerEvent("Customization.OnCategorySelected", self, hadCategoryChange);
end

function CustomizationFrameBaseMixin:HasSelectedSubcategory()
	return self.selectedSubcategoryData ~= nil;
end

function CustomizationFrameBaseMixin:GetSelectedSubcategory()
	return self.selectedSubcategoryData;
end

function CustomizationFrameBaseMixin:IsSelectedSubcategory(subcategoryData)
	if self:HasSelectedSubcategory() then
		return self:GetSelectedSubcategory().id == subcategoryData.id;
	end

	return false;
end

function CustomizationFrameBaseMixin:HasSelectedCategory()
	return self.selectedCategoryData ~= nil;
end

function CustomizationFrameBaseMixin:GetSelectedCategory()
	return self.selectedCategoryData;
end

function CustomizationFrameBaseMixin:IsSelectedCategory(categoryData)
	if self:HasSelectedCategory() then
		local selectedCategoryData = self:GetSelectedCategory();
		return selectedCategoryData.id == categoryData.id;
	end

	return false;
end

function CustomizationFrameBaseMixin:ResetSubjectRotation()
	self.parentFrame:ResetSubjectRotation();
end

function CustomizationFrameBaseMixin:OnMouseWheel(delta)
	self:ZoomCamera((delta > 0) and 20 or -20);
end

function CustomizationFrameBaseMixin:ZoomCamera(zoomAmount)
	self.parentFrame:ZoomCamera(zoomAmount);
	self:UpdateZoomButtonStates();
end

function CustomizationFrameBaseMixin:RotateSubject(rotationAmount)
	self.parentFrame:RotateSubject(rotationAmount);
end

function CustomizationFrameBaseMixin:RandomizeAppearance()
	self.parentFrame:RandomizeAppearance();
end

function CustomizationFrameBaseMixin:ResetPreviewIfDirty()
	if self.previewIsDirty then
		self.previewIsDirty = false;
		self:ResetCustomizationPreview();
	end
end

function CustomizationFrameBaseMixin:PreviewChoice(optionData, choiceData)
	local selected = optionData.currentChoiceIndex == choiceData.choiceIndex;
	if not selected then
		self.previewIsDirty = false;
		self:PreviewCustomizationChoice(optionData.id, choiceData.id);
	end

	if choiceData.isNew then
		self:MarkCustomizationChoiceAsSeen(choiceData.id);
	end
end

function CustomizationFrameBaseMixin:OnUpdate()
	self:ResetPreviewIfDirty();
end

function CustomizationFrameBaseMixin:AddMissingOptions()
	self.missingOptions = nil;

	for categoryIndex, category in ipairs(self:GetCategories()) do
		for optionIndex, option in ipairs(category.options) do
			if not option.currentChoiceIndex then
				self:AddMissingOption(categoryIndex, optionIndex);
			end
		end
	end
end

function CustomizationFrameBaseMixin:AddMissingOption(categoryIndex, optionIndex)
	if not self.missingOptions then
		self.missingOptions = {};
	end

	table.insert(self.missingOptions, { categoryIndex = categoryIndex, optionIndex = optionIndex });
end

function CustomizationFrameBaseMixin:GetMissingOptions()
	return self.missingOptions;
end

function CustomizationFrameBaseMixin:HasMissingOptions()
	return self:GetMissingOptions() ~= nil;
end

function CustomizationFrameBaseMixin:GetNextMissingOption()
	local missingOptions = self:GetMissingOptions();
	if missingOptions and #missingOptions > 0 then
		local missingOption = missingOptions[1];
		return missingOption.categoryIndex, missingOption.optionIndex;
	end
end

function CustomizationFrameBaseMixin:HighlightNextMissingOption()
	local categoryIndex, optionIndex = self:GetNextMissingOption();
	if categoryIndex then
		local keepState = true;
		local categoryData = self:GetCategory(categoryIndex);
		if categoryData.subcategory then
			self:SetSelectedSubcategory(categoryData, keepState);
		else
			self:SetSelectedCategory(categoryData, keepState);
		end

		self:SetMissingOptionWarningEnabled(true);
	end
end

function CustomizationFrameBaseMixin:DisableMissingOptionWarnings()
	self:SetMissingOptionWarningEnabled(false);
end

function CustomizationFrameBaseMixin:SetMissingOptionWarningEnabled(enabled)
	EventRegistry:TriggerEvent("Customization.SetMissingOptionWarningEnabled", enabled);
end

function CustomizationFrameBaseMixin:ToggleTooltipsExpanded()
	self.tooltipsExpanded = not self.tooltipsExpanded;
end

function CustomizationFrameBaseMixin:GetTooltipsExpanded()
	return self.tooltipsExpanded;
end