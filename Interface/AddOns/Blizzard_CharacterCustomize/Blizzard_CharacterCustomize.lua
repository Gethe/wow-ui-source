CHAR_CUSTOMIZE_MAX_SCALE = 0.75;

local showDebugTooltipInfo = GetCVarBool("debugTargetInfo");

CharCustomizeParentFrameBaseMixin = {};

function CharCustomizeParentFrameBaseMixin:SetCustomizationChoice(optionID, choiceID)
end

function CharCustomizeParentFrameBaseMixin:PreviewCustomizationChoice(optionID, choiceID)
end

function CharCustomizeParentFrameBaseMixin:ResetCustomizationPreview(clearSavedChoices)
end

function CharCustomizeParentFrameBaseMixin:MarkCustomizationChoiceAsSeen(choiceID)
end

function CharCustomizeParentFrameBaseMixin:MarkCustomizationOptionAsSeen(optionID)
end

function CharCustomizeParentFrameBaseMixin:SetViewingAlteredForm(viewingAlteredForm, resetCategory)
end

function CharCustomizeParentFrameBaseMixin:SetViewingShapeshiftForm(formID)
end

function CharCustomizeParentFrameBaseMixin:SetModelDressState(dressedState)
end

function CharCustomizeParentFrameBaseMixin:GetCurrentCameraZoom()
end

function CharCustomizeParentFrameBaseMixin:SetCameraZoomLevel(zoomLevel, keepCustomZoom)
end

function CharCustomizeParentFrameBaseMixin:ResetCharacterRotation()
end

function CharCustomizeParentFrameBaseMixin:ZoomCamera(zoomAmount)
end

function CharCustomizeParentFrameBaseMixin:RotateCharacter(rotationAmount)
end

function CharCustomizeParentFrameBaseMixin:RandomizeAppearance()
end

function CharCustomizeParentFrameBaseMixin:SetCameraDistanceOffset(offset)
end

function CharCustomizeParentFrameBaseMixin:SetCharacterSex(sexID)
end

function CharCustomizeParentFrameBaseMixin:OnButtonClick()
end

CharCustomizeBaseButtonMixin = {};

function CharCustomizeBaseButtonMixin:OnBaseButtonClick()
	CharCustomizeFrame:OnButtonClick();
end

CharCustomizeFrameWithTooltipMixin = {};

function CharCustomizeFrameWithTooltipMixin:OnLoad()
	if self.simpleTooltipLine then
		self:AddTooltipLine(self.simpleTooltipLine, HIGHLIGHT_FONT_COLOR);
	end
end

function CharCustomizeFrameWithTooltipMixin:ClearTooltipLines()
	self.tooltipLines = nil;
end

function CharCustomizeFrameWithTooltipMixin:AddTooltipLine(lineText, lineColor)
	if not self.tooltipLines then
		self.tooltipLines = {};
	end

	table.insert(self.tooltipLines, {text = lineText, color = lineColor or NORMAL_FONT_COLOR});
end

function CharCustomizeFrameWithTooltipMixin:AddBlankTooltipLine()
	self:AddTooltipLine(" ");
end

function CharCustomizeFrameWithTooltipMixin:GetAppropriateTooltip()
	return CharCustomizeNoHeaderTooltip;
end

function CharCustomizeFrameWithTooltipMixin:SetupAnchors(tooltip)
	if self.tooltipAnchor == "ANCHOR_TOPRIGHT" then
		tooltip:SetOwner(self, "ANCHOR_NONE");
		tooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", self.tooltipXOffset, self.tooltipYOffset);
	elseif self.tooltipAnchor == "ANCHOR_TOPLEFT" then
		tooltip:SetOwner(self, "ANCHOR_NONE");
		tooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", -self.tooltipXOffset, self.tooltipYOffset);
	elseif self.tooltipAnchor == "ANCHOR_BOTTOMRIGHT" then
		tooltip:SetOwner(self, "ANCHOR_NONE");
		tooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", self.tooltipXOffset, self.tooltipYOffset);
	elseif self.tooltipAnchor == "ANCHOR_BOTTOMLEFT" then
		tooltip:SetOwner(self, "ANCHOR_NONE");
		tooltip:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", -self.tooltipXOffset, self.tooltipYOffset);
	else
		tooltip:SetOwner(self, self.tooltipAnchor, self.tooltipXOffset, self.tooltipYOffset);
	end
end

function CharCustomizeFrameWithTooltipMixin:AddExtraStuffToTooltip()
end

function CharCustomizeFrameWithTooltipMixin:OnEnter()
	if self.tooltipLines then
		local tooltip = self:GetAppropriateTooltip();

		self:SetupAnchors(tooltip);

		if self.tooltipMinWidth then
			tooltip:SetMinimumWidth(self.tooltipMinWidth);
		end

		if self.tooltipPadding then
			tooltip:SetPadding(self.tooltipPadding, self.tooltipPadding, self.tooltipPadding, self.tooltipPadding);
		end

		for _, lineInfo in ipairs(self.tooltipLines) do
			GameTooltip_AddColoredLine(tooltip, lineInfo.text, lineInfo.color);
		end

		self:AddExtraStuffToTooltip();

		tooltip:Show();
	end
end

function CharCustomizeFrameWithTooltipMixin:OnLeave()
	local tooltip = self:GetAppropriateTooltip();
	tooltip:Hide();
end

CharCustomizeSmallButtonMixin = CreateFromMixins(CharCustomizeFrameWithTooltipMixin);

function CharCustomizeSmallButtonMixin:OnLoad()
	CharCustomizeFrameWithTooltipMixin.OnLoad(self);
	self.Icon:SetAtlas(self.iconAtlas);
	self.HighlightTexture:SetAtlas(self.iconAtlas);
end

function CharCustomizeSmallButtonMixin:OnMouseDown()
	if self:IsEnabled() then
		self.Icon:SetPoint("CENTER", self.PushedTexture);
	end
end

function CharCustomizeSmallButtonMixin:OnMouseUp()
	self.Icon:SetPoint("CENTER");
end

function CharCustomizeSmallButtonMixin:OnClick()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_LOOK);
end

CharCustomizeResetCameraButtonMixin = {};

function CharCustomizeResetCameraButtonMixin:OnClick()
	CharCustomizeSmallButtonMixin.OnClick(self);
	CharCustomizeFrame:ResetCharacterRotation();
	CharCustomizeFrame:UpdateCameraMode();
end

CharCustomizeRandomizeAppearanceButtonMixin = {};

function CharCustomizeRandomizeAppearanceButtonMixin:OnClick()
	CharCustomizeSmallButtonMixin.OnClick(self);
	CharCustomizeFrame:RandomizeAppearance();
end

CharCustomizeClickOrHoldButtonMixin = {};

function CharCustomizeClickOrHoldButtonMixin:OnHide()
	self.waitTimerSeconds = nil;
	self:SetScript("OnUpdate", nil);
end

function CharCustomizeClickOrHoldButtonMixin:DoClickAction()
end

function CharCustomizeClickOrHoldButtonMixin:DoHoldAction(elapsed)
end

function CharCustomizeClickOrHoldButtonMixin:OnClick()
	CharCustomizeSmallButtonMixin.OnClick(self);

	if not self.wasHeld then
		self:DoClickAction();
	end
end

function CharCustomizeClickOrHoldButtonMixin:OnUpdate(elapsed)
	if self.waitTimerSeconds then
		self.waitTimerSeconds = self.waitTimerSeconds - elapsed;
		if self.waitTimerSeconds >= 0 then
			return;
		else
			-- waitTimerSeconds is now negative, so add it to elapsed to remove any leftover wait time
			elapsed = elapsed + self.waitTimerSeconds;
			self.waitTimerSeconds = nil;
		end
	end

	self.wasHeld = true;
	self:DoHoldAction(elapsed);
end

function CharCustomizeClickOrHoldButtonMixin:OnMouseDown()
	CharCustomizeSmallButtonMixin.OnMouseDown(self);
	self.wasHeld = false;
	self.waitTimerSeconds = self.holdWaitTimeSeconds;
	self:SetScript("OnUpdate", self.OnUpdate);
end

function CharCustomizeClickOrHoldButtonMixin:OnMouseUp()
	CharCustomizeSmallButtonMixin.OnMouseUp(self);
	self.waitTimerSeconds = nil;
	self:SetScript("OnUpdate", nil);
end

CharCustomizeZoomButtonMixin = CreateFromMixins(CharCustomizeClickOrHoldButtonMixin);

function CharCustomizeZoomButtonMixin:DoClickAction()
	CharCustomizeFrame:ZoomCamera(self.clickAmount);
end

function CharCustomizeZoomButtonMixin:DoHoldAction(elapsed)
	CharCustomizeFrame:ZoomCamera(self.holdAmountPerSecond * elapsed);
end

CharCustomizeRotateButtonMixin = CreateFromMixins(CharCustomizeClickOrHoldButtonMixin);

function CharCustomizeRotateButtonMixin:DoClickAction()
	CharCustomizeFrame:RotateCharacter(self.clickAmount);
end

function CharCustomizeRotateButtonMixin:DoHoldAction(elapsed)
	CharCustomizeFrame:RotateCharacter(self.holdAmountPerSecond * elapsed);
end

CharCustomizeFrameWithExpandableTooltipMixin = {};

function CharCustomizeFrameWithExpandableTooltipMixin:ClearTooltipLines()
	self.tooltipLines = nil;
	self.expandedTooltipFrame = nil;
	self.postTooltipLines = nil;
end

function CharCustomizeFrameWithExpandableTooltipMixin:AddExpandedTooltipFrame(frame)
	self.expandedTooltipFrame = frame;
end

function CharCustomizeFrameWithExpandableTooltipMixin:AddPostTooltipLine(lineText, lineColor)
	if not self.postTooltipLines then
		self.postTooltipLines = {};
	end

	table.insert(self.postTooltipLines, {text = lineText, color = lineColor or NORMAL_FONT_COLOR});
end

local tooltipsExpanded = false;

function CharCustomizeFrameWithExpandableTooltipMixin:AddExtraStuffToTooltip()
	local tooltip = self:GetAppropriateTooltip();

	if self.expandedTooltipFrame then
		if tooltipsExpanded then
			GameTooltip_AddBlankLineToTooltip(tooltip);
			GameTooltip_InsertFrame(tooltip, self.expandedTooltipFrame);
			GameTooltip_AddBlankLineToTooltip(tooltip);
			GameTooltip_AddDisabledLine(tooltip, RIGHT_CLICK_FOR_LESS);
		else
			GameTooltip_AddBlankLineToTooltip(tooltip);
			GameTooltip_AddDisabledLine(tooltip, RIGHT_CLICK_FOR_MORE);
		end
	end

	if self.postTooltipLines then
		GameTooltip_AddBlankLineToTooltip(tooltip);

		for _, lineInfo in ipairs(self.postTooltipLines) do
			GameTooltip_AddColoredLine(tooltip, lineInfo.text, lineInfo.color);
		end
	end
end

CharCustomizeMaskedButtonMixin = CreateFromMixins(CharCustomizeFrameWithTooltipMixin);

function CharCustomizeMaskedButtonMixin:OnLoad()
	CharCustomizeFrameWithTooltipMixin.OnLoad(self);

	self.CircleMask:SetPoint("TOPLEFT", self, "TOPLEFT", self.circleMaskSizeOffset, -self.circleMaskSizeOffset);
	self.CircleMask:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -self.circleMaskSizeOffset, self.circleMaskSizeOffset);

	self.New:SetPoint("CENTER", self, "BOTTOM", 0, self.newTagYOffset);

	local hasRingSizes = self.ringWidth and self.ringHeight;
	if hasRingSizes then
		self.Ring:SetAtlas(self.ringAtlas);
		self.Ring:SetSize(self.ringWidth, self.ringHeight);
		self.Flash.Ring:SetAtlas(self.ringAtlas);
		self.Flash.Ring:SetSize(self.ringWidth, self.ringHeight);
		self.Flash.Ring2:SetAtlas(self.ringAtlas);
		self.Flash.Ring2:SetSize(self.ringWidth, self.ringHeight);
	else
		self.Ring:SetAtlas(self.ringAtlas, true);
		self.Flash.Ring:SetAtlas(self.ringAtlas, true);
		self.Flash.Ring2:SetAtlas(self.ringAtlas, true);
	end

	self.NormalTexture:AddMaskTexture(self.CircleMask);
	self.PushedTexture:AddMaskTexture(self.CircleMask);
	self.DisabledOverlay:AddMaskTexture(self.CircleMask);
	self.DisabledOverlay:SetAlpha(self.disabledOverlayAlpha);
	self.CheckedTexture:SetSize(self.checkedTextureSize, self.checkedTextureSize);
	self.Flash.Portrait:AddMaskTexture(self.CircleMask);

	if self.flipTextures then
		self.NormalTexture:SetTexCoord(1, 0, 0, 1);
		self.PushedTexture:SetTexCoord(1, 0, 0, 1);
		self.Flash.Portrait:SetTexCoord(1, 0, 0, 1);
	end

	if self.BlackBG then
		self.BlackBG:AddMaskTexture(self.CircleMask);
	end
end

function CharCustomizeMaskedButtonMixin:SetIconAtlas(atlas)
	self:SetNormalAtlas(atlas);
	self:SetPushedAtlas(atlas);
	self.Flash.Portrait:SetAtlas(atlas);
end

function CharCustomizeMaskedButtonMixin:ClearFlashTimer()
	if self.FlashTimer then
		self.FlashTimer:Cancel();
	end
end

function CharCustomizeMaskedButtonMixin:StartFlash()
	self:ClearFlashTimer();

	local function playFlash()
		self.Flash:Show();
		self.Flash.Anim:Play();
	end

	self.FlashTimer = C_Timer.NewTimer(0.8, playFlash);
end

function CharCustomizeMaskedButtonMixin:StopFlash()
	self:ClearFlashTimer();
	self.Flash.Anim:Stop();
	self.Flash:Hide();
end

function CharCustomizeMaskedButtonMixin:SetEnabledState(enabled)
	local buttonEnableState = enabled or self.allowSelectionOnDisable;
	self:SetEnabled(buttonEnableState);

	local normalTex = self:GetNormalTexture();
	if normalTex then
		normalTex:SetDesaturated(not enabled);
	end

	local pushedTex = self:GetPushedTexture();
	if pushedTex then
		pushedTex:SetDesaturated(not enabled);
	end

	self.Ring:SetAtlas(self.ringAtlas..(enabled and "" or "-disabled"));

	self.DisabledOverlay:SetShown(not enabled);
end

function CharCustomizeMaskedButtonMixin:OnMouseDown(button)
	if self:IsEnabled() then
		self.CheckedTexture:SetPoint("CENTER", self, "CENTER", 1, -1);
		self.CircleMask:SetPoint("TOPLEFT", self.PushedTexture, "TOPLEFT", self.circleMaskSizeOffset, -self.circleMaskSizeOffset);
		self.CircleMask:SetPoint("BOTTOMRIGHT", self.PushedTexture, "BOTTOMRIGHT", -self.circleMaskSizeOffset, self.circleMaskSizeOffset);
		self.Ring:SetPoint("CENTER", self, "CENTER", 1, -1);
		self.Flash:SetPoint("CENTER", self, "CENTER", 1, -1);
	end
end

function CharCustomizeMaskedButtonMixin:OnMouseUp(button)
	if button == "RightButton" and self.expandedTooltipFrame then
		tooltipsExpanded = not tooltipsExpanded;
		if GetMouseFocus() == self then
			self:OnEnter();
		end
	end

	self.CheckedTexture:SetPoint("CENTER");
	self.CircleMask:SetPoint("TOPLEFT", self.NormalTexture, "TOPLEFT", self.circleMaskSizeOffset, -self.circleMaskSizeOffset);
	self.CircleMask:SetPoint("BOTTOMRIGHT", self.NormalTexture, "BOTTOMRIGHT", -self.circleMaskSizeOffset, self.circleMaskSizeOffset);
	self.Ring:SetPoint("CENTER");
	self.Flash:SetPoint("CENTER");
end

function CharCustomizeMaskedButtonMixin:UpdateHighlightTexture()
	if self:GetChecked() then
		self.HighlightTexture:SetAtlas("charactercreate-ring-select");
		self.HighlightTexture:SetPoint("TOPLEFT", self.CheckedTexture);
		self.HighlightTexture:SetPoint("BOTTOMRIGHT", self.CheckedTexture);
	else
		self.HighlightTexture:SetAtlas(self.ringAtlas);
		self.HighlightTexture:SetPoint("TOPLEFT", self.Ring);
		self.HighlightTexture:SetPoint("BOTTOMRIGHT", self.Ring);
	end
end

CharCustomizeAlteredFormButtonMixin = CreateFromMixins(CharCustomizeMaskedButtonMixin);

function CharCustomizeAlteredFormButtonMixin:SetupAlteredFormButton(raceData, selectedSexID, isSelected, isAlteredForm, layoutIndex)
	self.layoutIndex = layoutIndex;
	self.isAlteredForm = isAlteredForm;

	local sexString;
	if selectedSexID == Enum.UnitSex.Male then
		sexString = "male";
	else
		sexString = "female";
	end

	local useHiRez = true;
	local atlas = GetRaceAtlas(strlower(raceData.fileName), sexString, useHiRez);
	self:SetIconAtlas(atlas);

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
	CharCustomizeFrame:SetViewingAlteredForm(self.isAlteredForm);
end

CharCustomizeCategoryButtonMixin = CreateFromMixins(CharCustomizeMaskedButtonMixin);

function CharCustomizeCategoryButtonMixin:SetCategory(categoryData, selectedCategoryID)
	self.categoryData = categoryData;
	self.categoryID = categoryData.id;
	self.layoutIndex = categoryData.orderIndex;

	self:ClearTooltipLines();

	if showDebugTooltipInfo then
		self:AddTooltipLine("Category ID: "..categoryData.id, HIGHLIGHT_FONT_COLOR);
	end

	self.New:SetShown(categoryData.hasNewChoices);

	if selectedCategoryID == categoryData.id then
		self:SetChecked(true);
		self:SetIconAtlas(categoryData.selectedIcon);
	else
		self:SetChecked(false);
		self:SetIconAtlas(categoryData.icon);
	end

	self:UpdateHighlightTexture();
end

function CharCustomizeCategoryButtonMixin:OnClick()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
	CharCustomizeFrame:SetSelectedCategory(self.categoryData);
end

CharCustomizeShapeshiftFormButtonMixin = CreateFromMixins(CharCustomizeCategoryButtonMixin);

function CharCustomizeShapeshiftFormButtonMixin:SetupAnchors(tooltip)
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", self.tooltipXOffset, self.tooltipYOffset);
end

function CharCustomizeShapeshiftFormButtonMixin:SetCategory(categoryData, selectedCategoryID)
	CharCustomizeCategoryButtonMixin.SetCategory(self, categoryData, selectedCategoryID);

	self:ClearTooltipLines();
	self:AddTooltipLine(categoryData.name);

	if showDebugTooltipInfo then
		self:AddBlankTooltipLine();
		self:AddTooltipLine("Category ID: "..categoryData.id, HIGHLIGHT_FONT_COLOR);
	end
end

CharCustomizeSexButtonMixin = CreateFromMixins(CharCustomizeMaskedButtonMixin);

function CharCustomizeSexButtonMixin:SetSex(sexID, selectedSexID, layoutIndex)
	self.sexID = sexID;
	self.layoutIndex = layoutIndex;

	self:ClearTooltipLines();

	if sexID == Enum.UnitSex.Male then
		self:AddTooltipLine(MALE, HIGHLIGHT_FONT_COLOR);
	else
		self:AddTooltipLine(FEMALE, HIGHLIGHT_FONT_COLOR);
	end

	local isSelected = selectedSexID == sexID;
	local baseAtlas, selectedAtlas = GetGenderAtlases(sexID);
	self:SetIconAtlas(isSelected and selectedAtlas or baseAtlas);

	self:SetChecked(isSelected);

	self:UpdateHighlightTexture();
end

function CharCustomizeSexButtonMixin:OnClick()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
	CharCustomizeFrame:SetCharacterSex(self.sexID);
end

CharCustomizeOptionSliderMixin = CreateFromMixins(SliderWithButtonsAndLabelMixin, CharCustomizeFrameWithTooltipMixin);

function CharCustomizeOptionSliderMixin:OnLoad()
	CharCustomizeFrameWithTooltipMixin.OnLoad(self);
end

function CharCustomizeOptionSliderMixin:SetupAnchors(tooltip)
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("BOTTOMLEFT", self.Slider.Thumb, "TOPRIGHT", self.tooltipXOffset, self.tooltipYOffset);
end

function CharCustomizeOptionSliderMixin:RefreshOption()
	self:SetupOption(self.optionData);
end

function CharCustomizeOptionSliderMixin:SetupOption(optionData)
	self.optionData = optionData;
	self.currentChoice = nil;

	local minValue = 1;
	local maxValue = #optionData.choices;
	local valueStep = 1;
	self:SetupSlider(minValue, maxValue, optionData.currentChoiceIndex, valueStep, optionData.name);
end

function CharCustomizeOptionSliderMixin:OnSliderValueChanged(value, userInput)
	SliderWithButtonsAndLabelMixin.OnSliderValueChanged(self, value);

	local newChoice = Round(value);
	local newChoiceData = self.optionData.choices[newChoice];

	local needToUpdateModel = false;
	if userInput and self.currentChoice ~= newChoice then
		needToUpdateModel = true;
	end

	self.currentChoice = newChoice;

	local currentChoiceTooltip = (newChoiceData.name ~= "") and CHARACTER_CUSTOMIZATION_CHOICE_TOOLTIP:format(newChoice, newChoiceData.name) or newChoice;

	self:ClearTooltipLines();
	self:AddTooltipLine(currentChoiceTooltip);

	if showDebugTooltipInfo then
		self:AddBlankTooltipLine();
		self:AddTooltipLine("Option ID: "..self.optionData.id, HIGHLIGHT_FONT_COLOR);
		self:AddTooltipLine("Choice ID: "..newChoiceData.id, HIGHLIGHT_FONT_COLOR);
	end

	local mouseFocus = GetMouseFocus();
	if DoesAncestryInclude(self, mouseFocus) and (mouseFocus:GetObjectType() ~= "Button") then
		self:OnEnter();
	end

	if needToUpdateModel then
		CharCustomizeFrame:SetCustomizationChoice(self.optionData.id, newChoiceData.id);
	end
end

CharCustomizeOptionCheckButtonMixin = CreateFromMixins(CharCustomizeFrameWithTooltipMixin);

function CharCustomizeOptionCheckButtonMixin:RefreshOption()
	self:SetupOption(self.optionData);
end

function CharCustomizeOptionCheckButtonMixin:SetupOption(optionData)
	self.optionData = optionData;
	self.checked = (optionData.currentChoiceIndex == 2);

	self.New:SetShown(optionData.hasNewChoices);

	if showDebugTooltipInfo then
		self:ClearTooltipLines();
		self:AddTooltipLine("Option ID: "..self.optionData.id, HIGHLIGHT_FONT_COLOR);
		self:AddTooltipLine("Choice ID: "..self.optionData.choices[optionData.currentChoiceIndex].id, HIGHLIGHT_FONT_COLOR);
	end

	self.Label:SetText(optionData.name);
	self.Button:SetChecked(self.checked);
end

function CharCustomizeOptionCheckButtonMixin:OnCheckButtonClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self.checked = not self.checked;

	local newChoiceIndex = self.checked and 2 or 1;
	local newChoiceData = self.optionData.choices[newChoiceIndex];

	if self.New:IsShown() then
		CharCustomizeFrame:MarkCustomizationOptionAsSeen(self.optionData.id);
	end

	CharCustomizeFrame:SetCustomizationChoice(self.optionData.id, newChoiceData.id);
end

CharCustomizeOptionSelectionPopoutMixin = CreateFromMixins(CharCustomizeFrameWithTooltipMixin);

function CharCustomizeOptionSelectionPopoutMixin:OnLoad()
	CharCustomizeFrameWithTooltipMixin.OnLoad(self);
	SelectionPopoutWithButtonsAndLabelMixin.OnLoad(self);
end

function CharCustomizeOptionSelectionPopoutMixin:SetupAnchors(tooltip)
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("BOTTOMRIGHT", self.Button, "TOPLEFT", self.tooltipXOffset, self.tooltipYOffset);
end

function CharCustomizeOptionSelectionPopoutMixin:OnEntrySelected(entryData)
	CharCustomizeFrame:OnOptionPopoutEntrySelected(self, entryData);
end

function CharCustomizeOptionSelectionPopoutMixin:OnEntryMouseEnter(entry)
	CharCustomizeFrame:OnOptionPopoutEntryMouseEnter(self, entry);

	local tooltipText = entry:GetTooltipText();
	if tooltipText or showDebugTooltipInfo then
		local tooltip = self:GetAppropriateTooltip();

		tooltip:SetOwner(self, "ANCHOR_NONE");
		tooltip:SetPoint("BOTTOMRIGHT", entry, "TOPLEFT", 0, 0);

		if tooltipText then
			GameTooltip_AddNormalLine(tooltip, tooltipText);
		end

		if showDebugTooltipInfo then
			if tooltipText then
				GameTooltip_AddBlankLineToTooltip(tooltip, tooltipText);
			end

			GameTooltip_AddHighlightLine(tooltip, "Choice ID: "..entry.selectionData.id);
		end

		tooltip:Show();
	end
end

function CharCustomizeOptionSelectionPopoutMixin:OnEntryMouseLeave(entry)
	CharCustomizeFrame:OnOptionPopoutEntryMouseLeave(self, entry);

	local tooltip = self:GetAppropriateTooltip();
	tooltip:Hide();
end

local POPOUT_CLEARANCE = 100;

function CharCustomizeOptionSelectionPopoutMixin:GetMaxPopoutHeight()
	return self:GetBottom() - POPOUT_CLEARANCE;
end

function CharCustomizeOptionSelectionPopoutMixin:RefreshOption()
	self:SetupOption(self.optionData);
end

function CharCustomizeOptionSelectionPopoutMixin:SetupOption(optionData)
	self.optionData = optionData;

	self:SetupSelections(optionData.choices, optionData.currentChoiceIndex, optionData.name);

	self.New:SetShown(optionData.hasNewChoices);

	self:ClearTooltipLines();

	local currentTooltip = self:GetTooltipText();
	if currentTooltip then
		self:AddTooltipLine(currentTooltip);
	end

	if showDebugTooltipInfo then
		if currentTooltip then
			self:AddBlankTooltipLine();
		end
		self:AddTooltipLine("Option ID: "..self.optionData.id, HIGHLIGHT_FONT_COLOR);
		self:AddTooltipLine("Choice ID: "..optionData.choices[optionData.currentChoiceIndex].id, HIGHLIGHT_FONT_COLOR);
	end
end

CharCustomizeSelectionPopoutDetailsMixin = {};

function CharCustomizeSelectionPopoutDetailsMixin:GetTooltipText()
	if self.SelectionName:IsShown() and self.SelectionName:IsTruncated() then
		return self.name;
	end

	return nil;
end

function CharCustomizeSelectionPopoutDetailsMixin:AdjustWidth(multipleColumns, defaultWidth)
	local width = defaultWidth;

	if self.ColorSwatch1:IsShown() or self.ColorSwatch2:IsShown() then
		if multipleColumns then
			width = self.SelectionNumber:GetWidth() + self.ColorSwatch2:GetWidth() + 18;
		end
	elseif self.SelectionName:IsShown() then
		if multipleColumns then
			width = 108;
		end
	else
		if multipleColumns then
			width = 42;
		end
	end

	self:SetWidth(Round(width));
end

local function GetNormalSelectionTextFontColor(selectionData, isSelected)
	if isSelected then
		return NORMAL_FONT_COLOR;
	else
		return DISABLED_FONT_COLOR;
	end
end

local eligibleChoiceColor = CreateColor(.808, 0.808, 0.808);
local ineligibleChoiceColor = CreateColor(.337, 0.337, 0.337);

local function GetFailedReqSelectionTextFontColor(selectionData, isSelected)
	if isSelected then
		return NORMAL_FONT_COLOR;
	elseif selectionData.ineligibleChoice then
		return ineligibleChoiceColor;
	else
		return eligibleChoiceColor;
	end
end

function CharCustomizeSelectionPopoutDetailsMixin:GetFontColors(selectionData, isSelected, hasAFailedReq)
	if self.selectable then
		local fontColorFunction = hasAFailedReq and GetFailedReqSelectionTextFontColor or GetNormalSelectionTextFontColor;
		local fontColor = fontColorFunction(selectionData, isSelected);
		local showAsNew = (selectionData.isNew and self.selectable);
		if showAsNew then
			return fontColor, HIGHLIGHT_FONT_COLOR;
		else
			return fontColor, fontColor;
		end
	else
		return NORMAL_FONT_COLOR, NORMAL_FONT_COLOR;
	end
end

function CharCustomizeSelectionPopoutDetailsMixin:UpdateFontColors(selectionData, isSelected, hasAFailedReq)
	local nameColor, numberColor = self:GetFontColors(selectionData, isSelected, hasAFailedReq);
	self.SelectionName:SetTextColor(nameColor:GetRGB());
	self.SelectionNumber:SetTextColor(numberColor:GetRGB());
end

local function startsWithOne(index)
	local indexString = tostring(index);
	return indexString:sub(1, 1) == "1";
end

function CharCustomizeSelectionPopoutDetailsMixin:SetShowAsNew(showAsNew)
	if showAsNew then
		self.SelectionNumber:SetShadowColor(NEW_FEATURE_SHADOW_COLOR:GetRGBA());

		local halfStringWidth = self.SelectionNumber:GetStringWidth() / 2;
		local extraOffset = startsWithOne(self.index) and 1 or 0;
		self.NewGlow:SetPoint("CENTER", self.SelectionNumber, "LEFT", halfStringWidth + extraOffset, -2);
		self.SelectionNumberBG:Show();
		self.NewGlow:Show();
	else
		self.SelectionNumber:SetShadowColor(BLACK_FONT_COLOR:GetRGBA());
		self.SelectionNumberBG:Hide();
		self.NewGlow:Hide();
	end
end

function CharCustomizeSelectionPopoutDetailsMixin:UpdateText(selectionData, isSelected, hasAFailedReq, hideNumber, hasColors)
	self:UpdateFontColors(selectionData, isSelected, hasAFailedReq);

	self.SelectionNumber:SetText(self.index);
	self.SelectionNumberBG:SetText(self.index);

	if hasColors then
		self.SelectionName:Hide();
		self.SelectionNumber:SetWidth(25);
		self.SelectionNumberBG:SetWidth(25);
	elseif selectionData.name ~= "" then
		self.SelectionName:Show();
		self.SelectionName:SetWidth(0);
		self.SelectionName:SetText(selectionData.name);
		self.SelectionNumber:SetWidth(25);
		self.SelectionNumberBG:SetWidth(25);
	else
		self.SelectionName:Hide();
		self.SelectionNumber:SetWidth(0);
		self.SelectionNumberBG:SetWidth(0);
	end

	self.SelectionNumber:SetShown(not hideNumber);

	local showAsNew = (self.selectable and not hideNumber and selectionData.isNew);
	self:SetShowAsNew(showAsNew);
end

function CharCustomizeSelectionPopoutDetailsMixin:SetupDetails(selectionData, index, isSelected, hasAFailedReq)
	self.name = selectionData.name;
	self.index = index;

	local color1 = selectionData.swatchColor1 or selectionData.swatchColor2;
	local color2 = selectionData.swatchColor1 and selectionData.swatchColor2;
	if color1 then
		if color2 then
			self.ColorSwatch2:Show();
			self.ColorSwatch2Glow:Show();
			self.ColorSwatch2:SetVertexColor(color2:GetRGB());
			self.ColorSwatch1:SetAtlas("charactercreate-customize-palette-half");
		else
			self.ColorSwatch2:Hide();
			self.ColorSwatch2Glow:Hide();
			self.ColorSwatch1:SetAtlas("charactercreate-customize-palette");
		end

		self.ColorSwatch1:Show();
		self.ColorSwatch1Glow:Show();
		self.ColorSwatch1:SetVertexColor(color1:GetRGB());
	elseif selectionData.name ~= "" then
		self.ColorSwatch1:Hide();
		self.ColorSwatch1Glow:Hide();
		self.ColorSwatch2:Hide();
		self.ColorSwatch2Glow:Hide();
	else
		self.ColorSwatch1:Hide();
		self.ColorSwatch1Glow:Hide();
		self.ColorSwatch2:Hide();
		self.ColorSwatch2Glow:Hide();
	end

	self.ColorSelected:SetShown(self.selectable and color1 and isSelected);

	local hideNumber = (not self.selectable and (color1 or (selectionData.name ~= "")));
	if hideNumber then
		self.SelectionName:SetPoint("LEFT", self, "LEFT", 0, 0);
		self.ColorSwatch1:SetPoint("LEFT", self, "LEFT", 0, 0);
		self.ColorSwatch2:SetPoint("LEFT", self, "LEFT", 18, -2);
	else
		self.SelectionName:SetPoint("LEFT", self.SelectionNumber, "RIGHT", 0, 0);
		self.ColorSwatch1:SetPoint("LEFT", self.SelectionNumber, "RIGHT", 0, 0);
		self.ColorSwatch2:SetPoint("LEFT", self.SelectionNumber, "RIGHT", 18, -2);
	end

	self:UpdateText(selectionData, isSelected, hasAFailedReq, hideNumber, color1);
end

CharCustomizeSelectionPopoutButtonMixin = CreateFromMixins(SelectionPopoutButtonMixin);

function CharCustomizeSelectionPopoutButtonMixin:UpdateButtonDetails()
	local currentSelectedData = self:GetCurrentSelectedData();
	self.SelectionDetails:SetupDetails(currentSelectedData, self.selectedIndex);

	local maxNameWidth = 126;
	if self.SelectionDetails.SelectionName:GetWidth() > maxNameWidth then
		self.SelectionDetails.SelectionName:SetWidth(maxNameWidth);
	end

	self.SelectionDetails:Layout();
end

CharCustomizeSelectionPopoutEntryMixin = CreateFromMixins(SelectionPopoutEntryMixin);

function CharCustomizeSelectionPopoutEntryMixin:OnLoad()
	SelectionPopoutEntryMixin.OnLoad(self);

	self.SelectionDetails.SelectionName:SetPoint("RIGHT");
end

function CharCustomizeSelectionPopoutEntryMixin:ClearNewFlag()
	self.selectionData.isNew = false;
	self.parentButton:UpdatePopout();
end

function CharCustomizeSelectionPopoutEntryMixin:SetupEntry(selectionData, index, isSelected, multipleColumns, hasAFailedReq)
	self.isNew = selectionData.isNew;
	SelectionPopoutEntryMixin.SetupEntry(self, selectionData, index, isSelected, multipleColumns, hasAFailedReq);	
end

function CharCustomizeSelectionPopoutEntryMixin:OnEnter()
	SelectionPopoutEntryMixin.OnEnter(self);

	if not self.isSelected then
		self.HighlightBGTex:SetAlpha(0.15);

		self.SelectionDetails.SelectionNumber:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		self.SelectionDetails.SelectionName:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	end
end

function CharCustomizeSelectionPopoutEntryMixin:OnLeave()
	SelectionPopoutEntryMixin.OnLeave(self);

	if not self.isSelected then
		self.HighlightBGTex:SetAlpha(0);
		self.SelectionDetails:UpdateFontColors(self.selectionData, self.isSelected, self.popoutHasAFailedReq);
	end
end

CharCustomizeMixin = {};

function CharCustomizeMixin:OnLoad()
	self:RegisterEvent("CVAR_UPDATE");

	self.pools = CreateFramePoolCollection();
	self.pools:CreatePool("CHECKBUTTON", self.Categories, "CharCustomizeCategoryButtonTemplate");
	self.pools:CreatePool("FRAME", self.Options, "CharCustomizeOptionCheckButtonTemplate");
	self.pools:CreatePool("CHECKBUTTON", self.AlteredForms, "CharCustomizeShapeshiftFormButtonTemplate");

	-- Keep the selectionPopout and sliders in different pools because we need to be careful not to release the option the player is interacting with
	self.selectionPopoutPool = CreateFramePool("BUTTON", self.Options, "CharCustomizeOptionSelectionPopoutTemplate");
	self.sliderPool = CreateFramePool("FRAME", self.Options, "CharCustomizeOptionSliderTemplate");

	-- Keep the altered forms buttons in a different pool because we only want to release those when we enter this screen
	self.alteredFormsPools = CreateFramePoolCollection();
	self.alteredFormsPools:CreatePool("CHECKBUTTON", self.AlteredForms, "CharCustomizeAlteredFormButtonTemplate");
	self.alteredFormsPools:CreatePool("CHECKBUTTON", self.AlteredForms, "CharCustomizeAlteredFormSmallButtonTemplate");
end

function CharCustomizeMixin:OnEvent(event, ...)
	if event == "CVAR_UPDATE" then
		local cvarName, cvarValue = ...;
		if cvarName == "debugTargetInfo" then
			showDebugTooltipInfo = (cvarValue == "1");
			if self:IsShown() then
				self:RefreshCustomizations();
			end
		end
	end
end

function CharCustomizeMixin:OnHide()
	local clearSavedChoices = true;
	self:ResetCustomizationPreview(clearSavedChoices);
	self:SaveSeenChoices();
end

function CharCustomizeMixin:AttachToParentFrame(parentFrame)
	self.parentFrame = parentFrame;
	self:SetParent(parentFrame);
end

function CharCustomizeMixin:OnButtonClick()
	self.parentFrame:OnButtonClick();
end

function CharCustomizeMixin:SetCustomizationChoice(optionID, choiceID)
	self.parentFrame:SetCustomizationChoice(optionID, choiceID);
end

function CharCustomizeMixin:PreviewCustomizationChoice(optionID, choiceID)
	self.parentFrame:PreviewCustomizationChoice(optionID, choiceID);
end

function CharCustomizeMixin:ResetCustomizationPreview(clearSavedChoices)
	self.parentFrame:ResetCustomizationPreview(clearSavedChoices);
end

function CharCustomizeMixin:MarkCustomizationChoiceAsSeen(choiceID)
	self.parentFrame:MarkCustomizationChoiceAsSeen(choiceID);
end

function CharCustomizeMixin:MarkCustomizationOptionAsSeen(optionID)
	self.parentFrame:MarkCustomizationOptionAsSeen(optionID);
end

function CharCustomizeMixin:SaveSeenChoices()
	self.parentFrame:SaveSeenChoices();
end

function CharCustomizeMixin:Reset()
	self.selectedCategoryData = nil;
end

function CharCustomizeMixin:NeedsCategorySelected()
	if not self.selectedCategoryData then
		return true;
	end

	for _, categoryData in ipairs(self.categories) do
		if self.selectedCategoryData.id == categoryData.id then
			return false;
		end
	end

	return true;
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
	if self.selectedRaceData.alternateFormRaceData then
		local normalForm = buttonPool:Acquire();
		local normalFormSelected = not self.viewingShapeshiftForm and not self.viewingAlteredForm;
		normalForm:SetupAlteredFormButton(self.selectedRaceData, self.selectedSexID, normalFormSelected, false, -1);
		normalForm:Show();

		local alteredForm = buttonPool:Acquire();
		local alteredFormSelected = not self.viewingShapeshiftForm and self.viewingAlteredForm;
		alteredForm:SetupAlteredFormButton(self.selectedRaceData.alternateFormRaceData, self.selectedSexID, alteredFormSelected, true, 0);
		alteredForm:Show();
	elseif self.hasShapeshiftForms then
		local normalForm = buttonPool:Acquire();
		local normalFormSelected = not self.viewingShapeshiftForm;
		normalForm:SetupAlteredFormButton(self.selectedRaceData, self.selectedSexID, normalFormSelected, false, -1);
		normalForm:Show();
	end

	self.AlteredForms:Layout();
end

function CharCustomizeMixin:SetSelectedData(selectedRaceData, selectedSexID, viewingAlteredForm)
	self.selectedRaceData = selectedRaceData;
	self.selectedSexID = selectedSexID;
	self.viewingAlteredForm = viewingAlteredForm;
	self.viewingShapeshiftForm = nil;
end

function CharCustomizeMixin:SetViewingAlteredForm(viewingAlteredForm)
	self.viewingAlteredForm = viewingAlteredForm;

	if self.viewingShapeshiftForm then
		self:ClearViewingShapeshiftForm();
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

function CharCustomizeMixin:SetCharacterSex(sexID)
	self.parentFrame:SetCharacterSex(sexID);
end

local function SortCategories(a, b)
	return a.orderIndex < b.orderIndex;
end

function CharCustomizeMixin:RefreshCustomizations()
	if self.categories then
		self:SetCustomizations(self.categories);
	end
end

function CharCustomizeMixin:SetCustomizations(categories)
	self.categories = categories;

	local keepState = (self.selectedCategoryData ~= nil);

	if self:NeedsCategorySelected() then
		table.sort(self.categories, SortCategories);
		self:SetSelectedCategory(self.categories[1], keepState);
	else
		self:SetSelectedCategory(self.selectedCategoryData, keepState);
	end
end

function CharCustomizeMixin:GetOptionPool(optionType)
	if optionType == Enum.ChrCustomizationOptionType.SelectionPopout then
		return self.selectionPopoutPool;
	elseif optionType == Enum.ChrCustomizationOptionType.Checkbox then
		return self.pools:GetPool("CharCustomizeOptionCheckButtonTemplate");
	elseif optionType == Enum.ChrCustomizationOptionType.Slider then
		return self.sliderPool;
	end
end

function CharCustomizeMixin:GetCategoryPool(categoryData)
	if categoryData.spellShapeshiftFormID then
		return self.pools:GetPool("CharCustomizeShapeshiftFormButtonTemplate");
	else
		return self.pools:GetPool("CharCustomizeCategoryButtonTemplate");
	end
end

-- Releases all sliders EXCEPT the one the player is currently dragging (if they are dragging one).
-- Returns the currently dragging slider if there was one
function CharCustomizeMixin:ReleaseNonDraggingSliders()
	local draggingSlider;
	local releaseSliders = {};

	for optionSlider in pairs(self.sliderPool.activeObjects) do
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
function CharCustomizeMixin:ReleaseClosedPopoutOptions()
	local openPopout;
	local releasePopouts = {};

	for selectionPopout in pairs(self.selectionPopoutPool.activeObjects) do
		if selectionPopout.Button.Popout:IsShown() then
			openPopout = selectionPopout;
		else
			table.insert(releasePopouts, selectionPopout);
		end
	end

	for _, releasePopout in ipairs(releasePopouts) do
		self.selectionPopoutPool:Release(releasePopout);
	end

	return openPopout;
end

function CharCustomizeMixin:UpdateOptionButtons(forceReset)
	self.pools:ReleaseAll();

	local interactingOption;

	if forceReset then
		self.sliderPool:ReleaseAll();
		self.selectionPopoutPool:ReleaseAll();
	else
		local draggingSlider = self:ReleaseNonDraggingSliders();
		local openPopout = self:ReleaseClosedPopoutOptions();
		interactingOption = draggingSlider or openPopout;
	end

	self.hasShapeshiftForms = false;
	self.numNormalCategories = 0;

	local optionsToSetup = {};

	for _, categoryData in ipairs(self.categories) do
		local showCategory = not self.selectedCategoryData.spellShapeshiftFormID or categoryData.spellShapeshiftFormID;

		if showCategory then
			local categoryPool = self:GetCategoryPool(categoryData);
			local button = categoryPool:Acquire();
			button:SetCategory(categoryData, self.selectedCategoryData.id);
			button:Show();

			if categoryData.spellShapeshiftFormID then
				self.hasShapeshiftForms = true;
			else
				self.numNormalCategories = self.numNormalCategories + 1;
			end

			if self.selectedCategoryData.id == categoryData.id then
				for _, optionData in ipairs(categoryData.options) do
					local optionPool = self:GetOptionPool(optionData.optionType);
					if optionPool then
						local optionFrame;

						if interactingOption and interactingOption.optionData.id == optionData.id then
							-- This option is being interacted with and so was not released.
							optionFrame = interactingOption;
						else
							optionFrame = optionPool:Acquire();
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
		end
	end

	self.Categories:Layout();
	self.Options:Layout();

	for optionFrame, optionData in pairs(optionsToSetup) do
		optionFrame:SetupOption(optionData);
	end

	self:UpdateAlteredFormButtons();

	if self.numNormalCategories > 1 then
		self.Categories:Show();
		self.RandomizeAppearanceButton:SetPoint("RIGHT", self.Categories, "LEFT", -20, 0);
	else
		self.Categories:Hide();
		self.Categories:SetSize(1, 105);
		self.RandomizeAppearanceButton:SetPoint("RIGHT", self.Categories, "RIGHT", -10, 0);
	end
end

function CharCustomizeMixin:UpdateModelDressState()
	self.parentFrame:SetModelDressState(not self.selectedCategoryData.undressModel);
end

function CharCustomizeMixin:UpdateCameraDistanceOffset()
	self.parentFrame:SetCameraDistanceOffset(self.selectedCategoryData.cameraDistanceOffset);
end

function CharCustomizeMixin:UpdateZoomButtonStates()
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

function CharCustomizeMixin:UpdateCameraMode(keepCustomZoom)
	self.parentFrame:SetCameraZoomLevel(self.selectedCategoryData.cameraZoomLevel, keepCustomZoom);
	self:UpdateZoomButtonStates();
end

function CharCustomizeMixin:SetSelectedCategory(categoryData, keepState)
	if categoryData.spellShapeshiftFormID or self.viewingShapeshiftForm then
		self:SetViewingShapeshiftForm(categoryData.spellShapeshiftFormID);
	end

	self.selectedCategoryData = categoryData;
	self:UpdateOptionButtons(not keepState);
	self:UpdateModelDressState();
	self:UpdateCameraDistanceOffset();
	self:UpdateCameraMode(keepState);
end

function CharCustomizeMixin:ResetCharacterRotation()
	self.parentFrame:ResetCharacterRotation();
end

function CharCustomizeMixin:OnMouseWheel(delta)
	self:ZoomCamera((delta > 0) and 20 or -20);
end

function CharCustomizeMixin:ZoomCamera(zoomAmount)
	self.parentFrame:ZoomCamera(zoomAmount);
	self:UpdateZoomButtonStates();
end

function CharCustomizeMixin:RotateCharacter(rotationAmount)
	self.parentFrame:RotateCharacter(rotationAmount);
end

function CharCustomizeMixin:RandomizeAppearance()
	self.parentFrame:RandomizeAppearance();
end

function CharCustomizeMixin:HidePopouts(exemptPopout)
	local selectionPopoutPool = self:GetOptionPool(Enum.ChrCustomizationOptionType.SelectionPopout);
	if selectionPopoutPool then
		for selectionPopout in selectionPopoutPool:EnumerateActive() do
			if selectionPopout ~= exemptPopout then
				selectionPopout:HidePopout();
			end
		end
	end
end

function CharCustomizeMixin:ResetPreviewIfDirty()
	if self.previewIsDirty then
		self.previewIsDirty = false;
		self:ResetCustomizationPreview();
	end
end

function CharCustomizeMixin:OnOptionPopoutEntrySelected(option, entryData)
	self.previewIsDirty = false;
	self:SetCustomizationChoice(option.optionData.id, entryData.id);
end

function CharCustomizeMixin:OnOptionPopoutEntryMouseEnter(option, entry)
	if not entry.isSelected then
		self.previewIsDirty = false;
		self:PreviewCustomizationChoice(option.optionData.id, entry.selectionData.id);
	end

	if entry.isNew then
		self:MarkCustomizationChoiceAsSeen(entry.selectionData.id);
	end
end

function CharCustomizeMixin:OnOptionPopoutEntryMouseLeave(option, entry)
	self.previewIsDirty = true;
end

function CharCustomizeMixin:OnUpdate()
	self:ResetPreviewIfDirty();
end
