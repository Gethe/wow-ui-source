-- Character-Customization-specific implementations of CustomizationUI mixins

CHAR_CUSTOMIZE_MAX_SCALE = 0.75;

local MAX_ALTERED_FORMS_DROPDOWN_HEIGHT = 625;

----------------- Char-Specific Base Parent Frame -----------------

CharCustomizeParentFrameBaseMixin = CreateFromMixins(CustomizationParentFrameBaseMixin);

function CharCustomizeParentFrameBaseMixin:SetViewingAlteredForm(viewingAlteredForm, resetCategory)
	-- Required Override
	assert(false);
end

function CharCustomizeParentFrameBaseMixin:SetViewingShapeshiftForm(formID)
	-- Required Override
	assert(false);
end

function CharCustomizeParentFrameBaseMixin:SetViewingChrModel(chrModelID)
	-- Required Override
	assert(false);
end

function CharCustomizeParentFrameBaseMixin:SetModelDressState(dressedState)
	-- Required Override
	assert(false);
end

function CharCustomizeParentFrameBaseMixin:SetCharacterSex(sexID)
	-- Required Override
	assert(false);
end

----------------- Char-Specific Category Button  -----------------

CharCustomizeCategoryButtonMixin = CreateFromMixins(CustomizationCategoryButtonMixin);

function CharCustomizeCategoryButtonMixin:IsSelected(categoryData, selectedCategoryID)
	-- Overrides CustomizationCategoryButtonMixin
	local customizationFrame = self:GetCustomizationFrame();
	local selected = selectedCategoryID == categoryData.id;
	if categoryData.chrModelID and not categoryData.subcategory and not customizationFrame.needsNativeFormCategory then
		if customizationFrame.viewingChrModelID then
			selected = categoryData.chrModelID == customizationFrame.viewingChrModelID;
		else
			selected = categoryData.chrModelID == customizationFrame.firstChrModelID;
		end
	end
	return selected;
end

----------------- Shapeshift Form Category Button -----------------

CharCustomizeShapeshiftFormButtonMixin = CreateFromMixins(CharCustomizeCategoryButtonMixin);

function CharCustomizeShapeshiftFormButtonMixin:SetupAnchors(tooltip)
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", self.tooltipXOffset, self.tooltipYOffset);
end

function CharCustomizeShapeshiftFormButtonMixin:SetCategory(categoryData, selectedCategoryID)
	CustomizationCategoryButtonMixin.SetCategory(self, categoryData, selectedCategoryID);

	self:ClearTooltipLines();
	self:AddTooltipLine(categoryData.name);

	if CustomizationUtil.ShouldShowDebugTooltipInfo() then
		self:AddBlankTooltipLine();
		self:AddTooltipLine("Category ID: "..categoryData.id, HIGHLIGHT_FONT_COLOR);
	end
end

----------------- Riding Drake Category Button -----------------

CharCustomizeRidingDrakeButtonMixin = CreateFromMixins(CharCustomizeCategoryButtonMixin);

function CharCustomizeRidingDrakeButtonMixin:SetupAnchors(tooltip)
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", self.tooltipXOffset, self.tooltipYOffset);
end

function CharCustomizeRidingDrakeButtonMixin:SetCategory(categoryData, selectedCategoryID)
	CustomizationCategoryButtonMixin.SetCategory(self, categoryData, selectedCategoryID);
	self:ClearTooltipLines();
	self:AddTooltipLine(categoryData.name);

	if CustomizationUtil.ShouldShowDebugTooltipInfo() then
		self:AddBlankTooltipLine();
		self:AddTooltipLine("Category ID: "..categoryData.id, HIGHLIGHT_FONT_COLOR);
	end
end

----------------- Altered Form Button -----------------

CharCustomizeAlteredFormButtonMixin = CreateFromMixins(CustomizationMaskedButtonMixin);

function CharCustomizeAlteredFormButtonMixin:SetupAlteredFormButton(raceData, isSelected, isAlteredForm, layoutIndex)
	self.layoutIndex = layoutIndex;
	self.isAlteredForm = isAlteredForm;
	self.raceData = raceData;

	self:SetIconAtlas(raceData.createScreenIconAtlas);

	self:ClearTooltipLines();
	self:AddTooltipLine(CHARACTER_FORM:format(raceData.name));

	self:SetChecked(isSelected);

	self:UpdateHighlightTexture();
end

function CharCustomizeAlteredFormButtonMixin:SetupAnchors(tooltip)
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", self.tooltipXOffset, self.tooltipYOffset);
end

function CharCustomizeAlteredFormButtonMixin:OnClick()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
	self:GetCustomizationFrame():SetViewingAlteredForm(self.isAlteredForm);
end

function CharCustomizeAlteredFormButtonMixin:GetDebugName()
	return self.raceData and self.raceData.name or nil;
end

----------------- Body Type Button -----------------

CharCustomizeBodyTypeButtonMixin = CreateFromMixins(CustomizationMaskedButtonMixin);

function CharCustomizeBodyTypeButtonMixin:SetBodyType(bodyTypeID, selecteBodyTypeID, layoutIndex)
	self.sexID = bodyTypeID;
	self.layoutIndex = layoutIndex;

	self:ClearTooltipLines();

	if bodyTypeID == Enum.UnitSex.Male then
		self:AddTooltipLine(BODY_1, HIGHLIGHT_FONT_COLOR);
	else
		self:AddTooltipLine(BODY_2, HIGHLIGHT_FONT_COLOR);
	end

	local isSelected = selecteBodyTypeID == bodyTypeID;
	local baseAtlas, selectedAtlas = GetBodyTypeAtlases(bodyTypeID);
	self:SetIconAtlas(isSelected and selectedAtlas or baseAtlas);

	self:SetChecked(isSelected);

	self:UpdateHighlightTexture();
end

function CharCustomizeBodyTypeButtonMixin:OnClick()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
	self:GetCustomizationFrame():SetCharacterSex(self.sexID);
end

----------------- Altered Form Icon -----------------
-- For use with CharCustomizeAlteredFormDropdownItemMixin/Template.

CharCustomizeAlteredFormDropdownItemIconMixin = {};

function CharCustomizeAlteredFormDropdownItemIconMixin:SetIconAtlas(atlasStr)
	self.Icon:SetAtlas(atlasStr);
end

function CharCustomizeAlteredFormDropdownItemIconMixin:SetSelected(isSelected)
	self.RingHighlight:SetShown(isSelected);
end

----------------- Altered Form Dropdown Item -----------------
-- For use with CharCustomizeAlteredFormsDropdownMixin/Template.

CharCustomizeAlteredFormDropdownItemMixin = {};

function CharCustomizeAlteredFormDropdownItemMixin:Init(categoryData, isSelected, isLastItem)
	self.Text:SetText(categoryData.name);
	self.IconFrame:SetIconAtlas(categoryData.icon);
	self.IconFrame:SetSelected(isSelected);
	self.Separator:SetShown(not isLastItem);
	self.isSelected = isSelected;
	self:SetBaseTextColor();
end

function CharCustomizeAlteredFormDropdownItemMixin:OnEnter()
	if not self.isSelected then
		self.Text:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	end

	if self.Text:IsTruncated() then
		CustomizationNoHeaderTooltip:SetOwner(self, "ANCHOR_LEFT");
		CustomizationNoHeaderTooltip:SetText(self.Text:GetText());
		CustomizationNoHeaderTooltip:Show();
	end
end

function CharCustomizeAlteredFormDropdownItemMixin:OnLeave()
	self:SetBaseTextColor();
	CustomizationNoHeaderTooltip:Hide();
end

function CharCustomizeAlteredFormDropdownItemMixin:SetBaseTextColor()
	local color = self.isSelected and NORMAL_FONT_COLOR or DISABLED_FONT_COLOR;
	self.Text:SetTextColor(color:GetRGB());
end

----------------- Altered Forms Dropdown -----------------

CharCustomizeAlteredFormsDropdownMixin = CreateFromMixins(ButtonStateBehaviorMixin, DropdownSelectionTextMixin);

function CharCustomizeAlteredFormsDropdownMixin:OnLoad()
	ButtonStateBehaviorMixin.OnLoad(self);
	DropdownSelectionTextMixin.OnLoad(self);

	self:SetSelectionTranslator(function(selection)
		local data = selection:GetData();
		return data and data.name;
	end);

	self:SetMenuAnchor(AnchorUtil.CreateAnchor("TOPRIGHT", self, "BOTTOMRIGHT", 13, -25));

	self.Text:SetScript("OnEnter", function(_text)
		self:OnEnter();
	end);

	self.Text:SetScript("OnLeave", function(_text)
		self:OnLeave();
	end);

	self.Text:SetScript("OnMouseDown", function(_text)
		self:SetMenuOpen(not self:IsMenuOpen());
	end);

	self.Text.HandlesGlobalMouseEvent = function(_text, ...)
		return self:HandlesGlobalMouseEvent(...);
	end;

	self:UpdateArrow();
end

function CharCustomizeAlteredFormsDropdownMixin:OnEnter()
	DropdownSelectionTextMixin.OnEnter(self);
	self.HighlightTexture:Show();
	self.ArrowHighlight:Show();
end

function CharCustomizeAlteredFormsDropdownMixin:OnLeave()
	DropdownSelectionTextMixin.OnLeave(self);
	self.HighlightTexture:Hide();
	self.ArrowHighlight:Hide();
end

function CharCustomizeAlteredFormsDropdownMixin:OnMenuOpened(menu)
	DropdownButtonMixin.OnMenuOpened(self, menu);
	self:UpdateArrow();
end

function CharCustomizeAlteredFormsDropdownMixin:OnMenuClosed(menu, closeReason)
	DropdownButtonMixin.OnMenuClosed(self, menu, closeReason);
	self:UpdateArrow();
end

function CharCustomizeAlteredFormsDropdownMixin:UpdateArrow()
	local rotation = self:IsMenuOpen() and (math.pi * 1.5) or (math.pi * 0.5);
	self.Arrow:SetRotation(rotation);
	self.ArrowHighlight:SetRotation(rotation);
end

function CharCustomizeAlteredFormsDropdownMixin:SetIconAtlas(atlasStr)
	self.Icon:SetAtlas(atlasStr);
end

function CharCustomizeAlteredFormsDropdownMixin:SetCount(count)
	self.Count:SetText(ALTERED_FORMS_COUNT_FORMAT:format(count));
end

----------------- Character Customize Frame -----------------

CharCustomizeMixin = CreateFromMixins(CustomizationFrameBaseMixin);

function CharCustomizeMixin:OnLoad()
	-- Expose container children as direct fields so CustomizationFrameBaseMixin methods can access them.
	self.Categories = self.CustomizeOptionsContainerFrame.Categories;
	self.Options = self.CustomizeOptionsContainerFrame.Options;
	self.RandomizeAppearanceButton = self.CustomizeOptionsContainerFrame.RandomizeAppearanceButton;

	self:CustomizationFrameBase_OnLoad();

	self.pools:CreatePool("CHECKBUTTON", self.AlteredForms, "CharCustomizeConditionalModelButtonTemplate");

	-- Keep the altered forms buttons in a different pool because we only want to release those when we enter this screen
	self.alteredFormsPools = CreateFramePoolCollection();
	self.alteredFormsPools:CreatePool("CHECKBUTTON", self.AlteredForms, "CharCustomizeAlteredFormButtonTemplate");
	self.alteredFormsPools:CreatePool("CHECKBUTTON", self.AlteredForms, "CharCustomizeAlteredFormSmallButtonTemplate");

	self.Categories:SetFixedMaxSpace(400);
	self.AlteredForms:SetRefreshCallback(GenerateClosure(self.UpdateAlteredFormsMaxWidth, self));
	self.alteredFormsUseDropdown = false;
end

function CharCustomizeMixin:OnShow()
	EventRegistry:TriggerEvent("CharCustomize.OnShow", self);
end

function CharCustomizeMixin:OnHide()
	CustomizationFrameBaseMixin.OnHide(self);
	EventRegistry:TriggerEvent("CharCustomize.OnHide", self);
end

function CharCustomizeMixin:GetAlteredFormsButtonPool()
	if self.hasShapeshiftForms then
		return self.alteredFormsPools:GetPool("CharCustomizeAlteredFormSmallButtonTemplate");
	else
		return self.alteredFormsPools:GetPool("CharCustomizeAlteredFormButtonTemplate");
	end
end

function CharCustomizeMixin:UpdateAlteredForms()
	if self.alteredFormsUseDropdown then
		self:UpdateAlteredFormsDropdown();
	else
		self:UpdateAlteredFormButtons();
	end
end

function CharCustomizeMixin:UpdateAlteredFormButtons()
	self.alteredFormsPools:ReleaseAll();

	local buttonPool = self:GetAlteredFormsButtonPool();

	local hasAlteredFormRaceData = (self.selectedRaceData.alternateFormRaceData and self.selectedRaceData.alternateFormRaceData.createScreenIconAtlas)
	if hasAlteredFormRaceData then
		local normalForm = buttonPool:Acquire();
		local notChrModel = not self.viewingShapeshiftForm and not self.viewingChrModelID;
		local normalFormSelected = notChrModel and not self.viewingAlteredForm;
		normalForm:SetCustomizationFrame(self);
		normalForm:SetupAlteredFormButton(self.selectedRaceData, normalFormSelected, false, -1);
		normalForm:Show();

		local alteredForm = buttonPool:Acquire();
		local alteredFormSelected = notChrModel and self.viewingAlteredForm;
		alteredForm:SetCustomizationFrame(self);
		alteredForm:SetupAlteredFormButton(self.selectedRaceData.alternateFormRaceData, alteredFormSelected, true, 0);
		alteredForm:Show();
	elseif self.needsNativeFormCategory then
		local normalForm = buttonPool:Acquire();
		local normalFormSelected = not self.viewingChrModelID and not self.viewingShapeshiftForm;
		normalForm:SetCustomizationFrame(self);
		normalForm:SetupAlteredFormButton(self.selectedRaceData, normalFormSelected, false, -1);
		normalForm:Show();
	end

	self.AlteredForms:Layout();
end

function CharCustomizeMixin:SetAlteredFormsUseDropdown(useDropdown)
	self.alteredFormsUseDropdown = useDropdown;
	self.AlteredForms:SetShown(not useDropdown);
	self.FormsDropdown:SetShown(useDropdown);
end

function CharCustomizeMixin:UpdateAlteredFormsDropdown()
	local chrModelCategories = {};
	for _, categoryData in ipairs(self:GetCategories()) do
		if categoryData.chrModelID and not categoryData.subcategory and not self.needsNativeFormCategory then
			table.insert(chrModelCategories, categoryData);
		end
	end

	table.sort(chrModelCategories, function(a, b) return a.orderIndex < b.orderIndex; end);

	local customizationFrame = self;

	local function IsSelected(categoryData)
		if customizationFrame.viewingChrModelID then
			return customizationFrame.viewingChrModelID == categoryData.chrModelID;
		else
			return categoryData.chrModelID == customizationFrame.firstChrModelID;
		end
	end

	local function SetSelected(categoryData)
		PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
		customizationFrame:SetSelectedCategory(categoryData);
		customizationFrame:SetSelectedSubcategory(nil);
	end

	self.FormsDropdown:SetupMenu(function(_dropdown, rootDescription)
		rootDescription:SetScrollMode(MAX_ALTERED_FORMS_DROPDOWN_HEIGHT);

		for index, categoryData in ipairs(chrModelCategories) do
			local isLastItem = (index == #chrModelCategories);

			local itemDescription = rootDescription:CreateTemplate("CharCustomizeAlteredFormDropdownItemTemplate");
			itemDescription:SetData(categoryData);
			itemDescription:SetOnEnter(CharCustomizeAlteredFormDropdownItemMixin.OnEnter);
			itemDescription:SetOnLeave(CharCustomizeAlteredFormDropdownItemMixin.OnLeave);
			itemDescription:SetIsSelected(IsSelected);
			itemDescription:SetResponder(SetSelected);
			itemDescription:SetRadio(true);
			itemDescription:AddInitializer(function(button, description, _menu)
				local isSelected = IsSelected(categoryData);
				button:Init(categoryData, isSelected, isLastItem);
				button:SetScript("OnClick", function(_button, buttonName)
					description:Pick(MenuInputContext.MouseButton, buttonName);
				end);
			end);
		end
	end);

	local selectedIcon = nil;
	if self.viewingChrModelID then
		for _, categoryData in ipairs(chrModelCategories) do
			if categoryData.chrModelID == self.viewingChrModelID then
				selectedIcon = categoryData.selectedIcon or categoryData.icon;
				break;
			end
		end
	else
		local firstCategory = chrModelCategories[1];
		if firstCategory then
			selectedIcon = firstCategory.selectedIcon or firstCategory.icon;
		end
	end

	if selectedIcon then
		self.FormsDropdown:SetIconAtlas(selectedIcon);
	end

	self.FormsDropdown:SetCount(#chrModelCategories);
end

function CharCustomizeMixin:GetAlteredFormsUnsafeLeftSpace()
	return self.SmallButtons:GetRight() - self:GetLeft();
end

function CharCustomizeMixin:UpdateAlteredFormsMaxWidth()
	if self.alteredFormsUseDropdown then
		return;
	end

	local totalScreenWidth = UIParent:GetWidth();
	local _point, _relativeTo, _relativePoint, alteredFormsRightOffset = self.AlteredForms:GetPoint(1);
	local alteredFormsMaxWidth = totalScreenWidth - self:GetAlteredFormsUnsafeLeftSpace() + alteredFormsRightOffset;	-- alteredFormsRightOffset is negative, so add it

	self.AlteredForms:SetMaxWidth(alteredFormsMaxWidth);
end

function CharCustomizeMixin:UpdateSmallButtons()
	if self.SmallButtons:GetRight() > CharacterCreateFrame.NameChoiceFrame:GetLeft() then
		self.SmallButtons:ClearAllPoints();
		self.SmallButtons:SetPoint("TOP", CharacterCreateFrame.NameChoiceFrame, "BOTTOM", 0, 0);
		self.SmallButtons:SetPoint("LEFT", 40);
	end
end

function CharCustomizeMixin:SetSelectedData(selectedRaceData, selectedSexID, viewingAlteredForm)
	self.selectedRaceData = selectedRaceData;
	self.selectedSexID = selectedSexID;
	self.viewingAlteredForm = viewingAlteredForm;
	self.viewingShapeshiftForm = nil;
	self.viewingChrModelID = nil;
end

function CharCustomizeMixin:SetViewingAlteredForm(viewingAlteredForm)
	self.viewingAlteredForm = viewingAlteredForm;

	if self.viewingShapeshiftForm then
		self:ClearViewingShapeshiftForm();
	end

	if self.viewingChrModelID then
		self:ClearViewingChrModel();
	end

	local resetCategory = true;
	self.parentFrame:SetViewingAlteredForm(viewingAlteredForm, resetCategory);
end

function CharCustomizeMixin:ClearViewingShapeshiftForm()
	local noShapeshiftForm = nil;
	self:SetViewingShapeshiftForm(noShapeshiftForm);
end

function CharCustomizeMixin:SetViewingShapeshiftForm(formID)
	if self.viewingShapeshiftForm ~= formID then
		self.viewingShapeshiftForm = formID;
		self.parentFrame:SetViewingShapeshiftForm(formID);
	end
end

function CharCustomizeMixin:ClearViewingChrModel()
	local noModelID = nil;
	local noShapeshiftID = nil
	self:SetViewingChrModel(noModelID, noShapeshiftID);
end

function CharCustomizeMixin:SetViewingChrModel(chrModelID)
	if self.viewingChrModelID ~= chrModelID then
		self.viewingChrModelID = chrModelID;
		local noShapeshiftID = nil
		self.parentFrame:SetViewingChrModel(chrModelID, noShapeshiftID);
	end
end

function CharCustomizeMixin:SetCharacterSex(sexID)
	self.parentFrame:SetCharacterSex(sexID);
end

function CharCustomizeMixin:GetFirstValidCategory()
	-- overrides CustomizationFrameBaseMixin
	local categories = self:GetCategories();
	local firstCategory = categories[1];

	-- If the first category is a Conditional ChrModel, use it.
	-- CGBarberShop::GetAvailableCustomizations() will put your current Conditional ChrModel first, if it needs to.
	if firstCategory.chrModelID then
		return firstCategory;
	end

	-- Look for non-ChrModel categories.
	for i, category in ipairs(categories) do
		if not category.chrModelID then
			return category;
		end
	end

	return firstCategory;
end

function CharCustomizeMixin:GetCategoryPool(categoryData)
	-- Overrides CustomizationFrameBaseMixin
	if categoryData.chrModelID then
		return self.pools:GetPool("CharCustomizeConditionalModelButtonTemplate");
	else
		return self.pools:GetPool(self.categoryButtonTemplate);
	end
end

function CharCustomizeMixin:ProcessCategory(categoryData, interactingOption, optionsToSetup)
	if categoryData.chrModelID then
		self.hasChrModels = true;
		if not self.firstChrModelID then
			self.firstChrModelID = categoryData.chrModelID;
		end
	end

	if categoryData.spellShapeshiftFormID then
		self.hasShapeshiftForms = true;
	end

	if categoryData.needsNativeFormCategory then
		self.needsNativeFormCategory = true;
	end

	return CustomizationFrameBaseMixin.ProcessCategory(self, categoryData, interactingOption, optionsToSetup);
end

function CharCustomizeMixin:UpdateOptionButtons(forceReset)
	self.hasShapeshiftForms = false;
	self.hasChrModels = false;	-- nothing using this right now, tracking it anyway
	self.needsNativeFormCategory = false;
	self.firstChrModelID = nil;

	CustomizationFrameBaseMixin.UpdateOptionButtons(self, forceReset);

	local raceAlteredFormsDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.RaceAlteredFormsDisabled);
	if not raceAlteredFormsDisabled then
		self:UpdateAlteredForms();
	end
end

function CharCustomizeMixin:UpdateOptionsContainer()
	-- Overrides CustomizationFrameBaseMixin

	-- Push options up into categories a little bit if we don't have enough
	-- vertical space for spacing at all.
	self.Options:UpdateSpacing();
	if self.Options:GetSpacing() < 0 then
		self.Options:SetPoint("TOPRIGHT", 30, -82);
	else
		self.Options:SetPoint("TOPRIGHT", self.Categories, "BOTTOMRIGHT", 30, -30);
	end

	-- This will update the spacing again based on the adjusted point above.
	self.Options:Layout();

	self.CustomizeOptionsContainerFrame:MarkDirty();
	self.CustomizeOptionsContainerFrame:Layout();
end

function CharCustomizeMixin:UpdateCategoriesContainer()
	self.Categories:Layout();

	CustomizationFrameBaseMixin.UpdateCategoriesContainer(self);

	if self.numSubcategories > 1 then
		-- Push the randomize button together with categories too if we're collapsing category buttons.
		local xOffset = self.Categories:IsSpacingAdjusted() and 15 or -20;
	else
		self.Categories:SetSize(30, 30);
	end

	self.CustomizeOptionsContainerFrame:MarkDirty();
	self.CustomizeOptionsContainerFrame:Layout();
end

function CharCustomizeMixin:UpdateModelDressState()
	local categoryData = self:GetBestCategoryData();
	self.parentFrame:SetModelDressState(not categoryData.undressModel);
end

function CharCustomizeMixin:SetSelectedCategory(categoryData, keepState, dontResetCamera)
	-- Below, we only call the setter for the first Set to call into C_Barbershop.
	-- We only need to set the second viewing state in Lua for the UI only.
	if categoryData.spellShapeshiftFormID then
		-- We are now viewing a Shapeshift and a ChrModel, so set both.
		self:SetViewingShapeshiftForm(categoryData.spellShapeshiftFormID)
		self.viewingChrModelID = categoryData.chrModelID
	elseif categoryData.chrModelID then
		-- We are now viewing ONLY a ChrModel, so unset Shapeshift.
		local noShapeshiftID = nil
		self:SetViewingChrModel(categoryData.chrModelID, noShapeshiftID)
		self.viewingShapeshiftForm = nil;
	end

	CustomizationFrameBaseMixin.SetSelectedCategory(self, categoryData, keepState, dontResetCamera);

	if not self.selectedSubcategoryData then
		self:UpdateModelDressState();
	end
end

function CharCustomizeMixin:SetSelectedSubcategory(categoryData, keepState, dontResetCamera)
	CustomizationFrameBaseMixin.SetSelectedSubcategory(self, categoryData, keepState, dontResetCamera);

	if self.selectedSubcategoryData then
		self:UpdateModelDressState();
	end
end

function CharCustomizeMixin:IsSelectedCategory(categoryData)
	-- Overrides CustomizationFrameBaseMixin
	if self:HasSelectedCategory() then
		-- Dragon Mounts have the same category ID until completion of [WOW10-13892]: GP ENG - Dragon Customization code clean-up.
		local selectedCategoryData = self:GetSelectedCategory();
		if selectedCategoryData.id == categoryData.id then
			-- Due to the same-category limitation of Dragons, we backup-check if the chrModelIDs are different.
			if selectedCategoryData.chrModelID or categoryData.chrModelID then
				return selectedCategoryData.chrModelID == categoryData.chrModelID;
			end

			return true;
		end
	end

	return false;
end

-- Overrides CustomizationFrameBaseMixin version.
function CharCustomizeMixin:UpdateZoomButtonStates()
	CustomizationFrameBaseMixin.UpdateZoomButtonStates(self);
	if (InputUtil.IsGamepadUIEnabled()) then
		self.SmallButtons:Hide();
	end

	self:UpdateSmallButtons();
end

-- Overrides CustomizationFrameBaseMixin version.
function CharCustomizeMixin:OnOptionButtonsUpdated()
	CustomizationFrameBaseMixin.OnOptionButtonsUpdated(self);

	if (InputUtil.IsGamepadUIEnabled()) then
		local options = self:GetDisplayedOptions();
		for _, v in ipairs(options) do
			SmartNavigation_ClearJumpNavigationOverrides(v);
		end
		SmartNavigation_ClearJumpNavigationOverrides(SDToggleButton);

		local firstOption = options[1];
		local lastOption = options[#options];

		if (firstOption) then
			local nameChoice = CharacterCreateFrame.NameChoiceFrame.EditBoxSurname;
			SmartNavigation_AddJumpNavigationOverride(firstOption, SMART_NAV_INPUT_DIRECTION.UP, nameChoice);
		end

		if (lastOption) then
			SmartNavigation_AddBidirectionalJumpNavigationOverride(lastOption, SMART_NAV_INPUT_DIRECTION.DOWN, SDToggleButton);
		end

		-- Category buttons also get reset when the option buttons are updated, so we can update the gamepad tab indicators now too.
		local prevCategoryFrame, nextCategoryFrame = self:GetCategoryFramesAdjacentToSelectedFrame();
		if prevCategoryFrame ~= nil then
			self.Categories.TabLeftInputPrompt:SetPressable();
		else
			self.Categories.TabLeftInputPrompt:SetDisabled();
		end
		if nextCategoryFrame ~= nil then
			self.Categories.TabRightInputPrompt:SetPressable();
		else
			self.Categories.TabRightInputPrompt:SetDisabled();
		end
	end
end

function CharCustomizeMixin:OnCategorySelected(customizationFrame, hadCategoryChanged)
	if (self == customizationFrame and hadCategoryChanged) then
		local firstDisplayedOption = self:GetFirstDisplayedOption();
		if (firstDisplayedOption) then
			SmartNavigation:SelectButton(firstDisplayedOption);
		else
			-- Default to the edit box if for some reason there are no displayed options for the selected category.
			SmartNavigation:SelectButton(CharacterCreateFrame.NameChoiceFrame.EditBox);
		end
	end
end

function CharCustomizeMixin:RegisterForInterfaceTransitions()
	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetupGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end

function CharCustomizeMixin:SmartNavigationCloseHandler()
	CharacterCreateFrame.BackButton:Click();
	return true;
end

function CharCustomizeMixin:SetupGamepad()
	self.bindings = GamepadMode.CreateBindingGroup("CharacterCreateCharacterCustomizeFrameBindings");
	self.bindings:AddAxisBinding(GAMEPAD_STICK_RIGHT, GenerateClosure(self.RotateSubjectOrZoomCameraUsingAxes, self));

	local finishAction = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_LEFT, function() self:GetParent().ForwardButton:Click(); end, FINISH);

	--[[
		This local function is needed because the customization frame gets loaded
		before the character create frame (who owns the randomize name button) but we
		want to control the randomize name binding in the customization frame.
	]]
	local function RandomizeName()
		CharacterCreateFrame.NameChoiceFrame.RandomNameButton:Click();
	end
	local randomizeName = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_MENU_LEFT, RandomizeName, ACTION_LABEL_RANDOMIZE_NAME);

	local randomAppearanceButton = self.RandomizeAppearanceButton;
	local randomizeAppearance = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_TOP,
																		   GenerateClosure(randomAppearanceButton.Click, randomAppearanceButton, nil, nil),
																		   ACTION_LABEL_RANDOMIZE_APPEARANCE);

	local prevCategory = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_SHOULDER_LEFT, GenerateClosure(self.SelectPrevCategoryFrame, self));
	prevCategory:SetCustomPromptFrame(self.Categories.TabLeftInputPrompt);

	local nextCategory = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_SHOULDER_RIGHT, GenerateClosure(self.SelectNextCategoryFrame, self));
	nextCategory:SetCustomPromptFrame(self.Categories.TabRightInputPrompt);

	local resetView = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_RIGHT_PRESS, function()
		self.SmallButtons.ResetCameraButton:Click();
	end, ACTION_LABEL_RESET_VIEW);

	self.footer = GamepadSharedUtility.CreatePromptedBindingFooter(self);
	self.footer:AddStandardSelectPrompt();
	self.footer:AddPromptedBinding(resetView);
	self.footer:AddPromptedBinding(finishAction);
	self.footer:AddPromptedBinding(randomizeAppearance);
	self.footer:AddPromptedBinding(randomizeName);
	self.footer:AddPromptedBinding(nextCategory);
	self.footer:AddPromptedBinding(prevCategory);
	self.footer:AddStandardBackPrompt();
	self.footer:Finalize();
	self.footer.inputLegend:ClearAllPoints();
	self.footer.inputLegend:SetPoint("BOTTOM", 0, 8);
end

function CharCustomizeMixin:InitializeGamepad()
	self.SmallButtons:Hide();
	self.RandomizeAppearanceButton:Hide();

	local nameEditBox = CharacterCreateFrame.NameChoiceFrame.EditBox;
	local surnameEditBox = CharacterCreateFrame.NameChoiceFrame.EditBoxSurname;
	local firstOptionClosure = GenerateClosure(self.GetFirstDisplayedOption, self);
	SmartNavigation_AddJumpNavigationOverride(nameEditBox, SMART_NAV_INPUT_DIRECTION.DOWN, firstOptionClosure);

	SmartNavigation_AddBidirectionalJumpNavigationOverride(nameEditBox, SMART_NAV_INPUT_DIRECTION.RIGHT, surnameEditBox);
	SmartNavigation_AddJumpNavigationOverride(surnameEditBox, SMART_NAV_INPUT_DIRECTION.RIGHT, firstOptionClosure);
	SmartNavigation_AddJumpNavigationOverride(surnameEditBox, SMART_NAV_INPUT_DIRECTION.DOWN, firstOptionClosure);

	EventRegistry:RegisterCallback("Customization.OnCategorySelected", self.OnCategorySelected, self);

	EventRegistry:RegisterCallback("CharCustomize.OnShow",
		function()
			GamepadMode.FrameControlsManager:FrameShown(self);

			SmartNavigation:SelectButton(CharacterCreateFrame.NameChoiceFrame.EditBox);
		end, self);

	EventRegistry:RegisterCallback("CharCustomize.OnHide",
		function()
			GamepadMode.FrameControlsManager:FrameHidden(self);
		end, self);
end

function CharCustomizeMixin:UninitializeGamepad()
	self.SmallButtons:Show();
	self.RandomizeAppearanceButton:Show();

	local nameEditBox = CharacterCreateFrame.NameChoiceFrame.EditBox;
	local surnameEditBox = CharacterCreateFrame.NameChoiceFrame.EditBoxSurname;
	SmartNavigation_ClearJumpNavigationOverrides(nameEditBox);
	SmartNavigation_ClearJumpNavigationOverrides(surnameEditBox);

	SmartNavigation_ClearJumpNavigationOverrides(SDToggleButton);

	EventRegistry:UnregisterCallback("Customization.OnCategorySelected", self);
	EventRegistry:UnregisterCallback("CharCustomize.OnShow", self);
	EventRegistry:UnregisterCallback("CharCustomize.OnHide", self);

	self.footer:HideAndDeactivateBindings();
	GamepadMode.DeactivateBindingGroup(self.bindings);
end

function CharCustomizeMixin:UnfocusGamepad()
	self.footer:HideAndDeactivateBindings();
	GamepadMode.DeactivateBindingGroup(self.bindings);
end

function CharCustomizeMixin:OnSmartNavFocus()
	GamepadMode.ActivateBindingGroup(self.bindings);
	self.footer:ShowAndActivateBindings();
end
