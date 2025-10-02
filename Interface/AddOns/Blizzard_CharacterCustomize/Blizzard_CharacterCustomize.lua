-- Character-Customization-specific implementations of CustomizationUI mixins

CHAR_CUSTOMIZE_MAX_SCALE = 0.75;

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

----------------- Character Customize Frame -----------------

CharCustomizeMixin = CreateFromMixins(CustomizationFrameBaseMixin);

function CharCustomizeMixin:OnLoad()
	self:CustomizationFrameBase_OnLoad();

	self.pools:CreatePool("CHECKBUTTON", self.AlteredForms, "CharCustomizeConditionalModelButtonTemplate");

	-- Keep the altered forms buttons in a different pool because we only want to release those when we enter this screen
	self.alteredFormsPools = CreateFramePoolCollection();
	self.alteredFormsPools:CreatePool("CHECKBUTTON", self.AlteredForms, "CharCustomizeAlteredFormButtonTemplate");
	self.alteredFormsPools:CreatePool("CHECKBUTTON", self.AlteredForms, "CharCustomizeAlteredFormSmallButtonTemplate");

	self.Categories:SetFixedMaxSpace(400);
	self.AlteredForms:SetRefreshCallback(GenerateClosure(self.UpdateAlteredFormsMaxWidth, self));
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

function CharCustomizeMixin:GetAlteredFormsUnsafeLeftSpace()
	return self.SmallButtons:GetRight() - self:GetLeft();
end

function CharCustomizeMixin:UpdateAlteredFormsMaxWidth()
	local totalScreenWidth = UIParent:GetWidth();
	local _point, _relativeTo, _relativePoint, alteredFormsRightOffset = self.AlteredForms:GetPoint(1);
	local alteredFormsMaxWidth = totalScreenWidth - self:GetAlteredFormsUnsafeLeftSpace() + alteredFormsRightOffset;	-- alteredFormsRightOffset is negative, so add it

	self.AlteredForms:SetMaxWidth(alteredFormsMaxWidth);
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
		self:UpdateAlteredFormButtons();
	end
end

function CharCustomizeMixin:UpdateOptionsContainer()
	-- Overrides CustomizationFrameBaseMixin

	-- Push options up into categories a little bit if we don't have enough
	-- vertical space for spacing at all.
	self.Options:UpdateSpacing();
	if self.Options:GetSpacing() < 0 then
		self.Options:SetPoint("TOPRIGHT", -33, -267);
	else
		self.Options:SetPoint("TOPRIGHT", -33, -297);
	end

	-- This will update the spacing again based on the adjusted point above.
	self.Options:Layout();
end

function CharCustomizeMixin:UpdateCategoriesContainer()
	self.Categories:Layout();

	CustomizationFrameBaseMixin.UpdateCategoriesContainer(self);

	if self.numSubcategories > 1 then
		-- Push the randomize button together with categories too if we're collapsing category buttons.
		local xOffset = self.Categories:IsSpacingAdjusted() and 15 or -20;
		self.RandomizeAppearanceButton:SetPoint("RIGHT", self.Categories, "LEFT", xOffset, 0);
	else
		self.Categories:SetSize(1, 105);
		self.RandomizeAppearanceButton:SetPoint("RIGHT", self.Categories, "RIGHT", -10, 0);
	end
end

function CharCustomizeMixin:UpdateModelDressState()
	local categoryData = self:GetBestCategoryData();
	self.parentFrame:SetModelDressState(not categoryData.undressModel);
end

function CharCustomizeMixin:SetSelectedCategory(categoryData, keepState)
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

	CustomizationFrameBaseMixin.SetSelectedCategory(self, categoryData, keepState);

	if not self.selectedSubcategoryData then
		self:UpdateModelDressState();
	end
end

function CharCustomizeMixin:SetSelectedSubcategory(categoryData, keepState)
	CustomizationFrameBaseMixin.SetSelectedSubcategory(self, categoryData, keepState);

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
