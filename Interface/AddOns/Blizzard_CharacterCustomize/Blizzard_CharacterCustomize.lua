CHAR_CUSTOMIZE_MAX_SCALE = 0.75;
CHAR_CUSTOMIZE_LOCK_WIDTH = 24;

local showDebugTooltipInfo = GetCVarBool("debugTargetInfo");

CharCustomizeOptionFrameBaseMixin = {};

function CharCustomizeOptionFrameBaseMixin:SetupOption(optionData)
	-- Override
end

function CharCustomizeOptionFrameBaseMixin:SetOptionData(optionData)
	self.optionData = optionData;
end

function CharCustomizeOptionFrameBaseMixin:GetOptionData()
	return self.optionData;
end

function CharCustomizeOptionFrameBaseMixin:RefreshOption()
	self:SetupOption(self:GetOptionData());
end

function CharCustomizeOptionFrameBaseMixin:GetCurrentChoiceIndex()
	return self:GetOptionData().currentChoiceIndex;
end

function CharCustomizeOptionFrameBaseMixin:HasChoice()
	return self:GetCurrentChoice() ~= nil;
end

function CharCustomizeOptionFrameBaseMixin:GetChoice(index)
	if index then
		return self:GetOptionData().choices[index];
	end
end

function CharCustomizeOptionFrameBaseMixin:GetCurrentChoice()
	return self:GetChoice(self:GetCurrentChoiceIndex());
end

function CharCustomizeOptionFrameBaseMixin:HasSound()
	return self:GetOptionData().isSound;
end

function CharCustomizeOptionFrameBaseMixin:GetSoundKit(entryOverride)
	if self:HasSound() then
		if entryOverride then
			return entryOverride.selectionData.soundKit;
		end

		local choice = self:GetCurrentChoice();
		if choice then
			return choice.soundKit;
		end
	end
end

function CharCustomizeOptionFrameBaseMixin:SetupAudio(audioInterface)
	assert(self:HasSound());
	self:ShutdownAudio();

	audioInterface:SetParent(self);
	audioInterface:SetPoint("RIGHT", self.Label, "LEFT", -40, 0);
	audioInterface:Show();
	audioInterface:SetupAudio(self:GetSoundKit());
	self.audioInterface = audioInterface;
end

function CharCustomizeOptionFrameBaseMixin:ShutdownAudio()
	local interface = self.audioInterface;
	self.audioInterface = nil;

	if interface then
		interface:StopAudio();
	end
end

function CharCustomizeOptionFrameBaseMixin:GetAudioInterface()
	return self.audioInterface;
end

local function GetAppropriateTooltip()
	return CharCustomizeNoHeaderTooltip;
end

CharCustomizeFrameWithTooltipMixin = CreateFromMixins(RingedFrameWithTooltipMixin);
function CharCustomizeFrameWithTooltipMixin:GetAppropriateTooltip()
	return GetAppropriateTooltip();
end

CharCustomizeMaskedButtonMixin = CreateFromMixins(RingedMaskedButtonMixin)
function CharCustomizeMaskedButtonMixin:GetAppropriateTooltip()
	return GetAppropriateTooltip();
end

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

function CharCustomizeParentFrameBaseMixin:SetViewingChrModel(chrModelID)
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

function CharCustomizeFrameWithExpandableTooltipMixin:AddExtraStuffToTooltip()
	local tooltip = self:GetAppropriateTooltip();

	if self.expandedTooltipFrame then
		if self.tooltipsExpanded then
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

CharCustomizeAlteredFormButtonMixin = CreateFromMixins(CharCustomizeMaskedButtonMixin);

function CharCustomizeAlteredFormButtonMixin:SetupAlteredFormButton(raceData, isSelected, isAlteredForm, layoutIndex)
	self.layoutIndex = layoutIndex;
	self.isAlteredForm = isAlteredForm;

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
	local selected = false;
	if categoryData.chrModelID then
		if CharCustomizeFrame.viewingChrModelID then
			selected = categoryData.chrModelID == CharCustomizeFrame.viewingChrModelID;
		else
			selected = categoryData.chrModelID == CharCustomizeFrame.firstChrModelID;
		end
	else
		selected = selectedCategoryID == categoryData.id;
	end
	if selected then
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

CharCustomizeRidingDrakeButtonMixin = CreateFromMixins(CharCustomizeCategoryButtonMixin);

function CharCustomizeRidingDrakeButtonMixin:SetupAnchors(tooltip)
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", self.tooltipXOffset, self.tooltipYOffset);
end

function CharCustomizeRidingDrakeButtonMixin:SetCategory(categoryData, selectedCategoryID)
	CharCustomizeCategoryButtonMixin.SetCategory(self, categoryData, selectedCategoryID);
	self:ClearTooltipLines();
	self:AddTooltipLine(categoryData.name);

	if showDebugTooltipInfo then
		self:AddBlankTooltipLine();
		self:AddTooltipLine("Category ID: "..categoryData.id, HIGHLIGHT_FONT_COLOR);
	end
end

CharCustomizeBodyTypeButtonMixin = CreateFromMixins(CharCustomizeMaskedButtonMixin);

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
	CharCustomizeFrame:SetCharacterSex(self.sexID);
end

CharCustomizeOptionSliderMixin = CreateFromMixins(CharCustomizeOptionFrameBaseMixin, SliderWithButtonsAndLabelMixin, CharCustomizeFrameWithTooltipMixin);

function CharCustomizeOptionSliderMixin:OnLoad()
	CharCustomizeFrameWithTooltipMixin.OnLoad(self);
end

function CharCustomizeOptionSliderMixin:SetupAnchors(tooltip)
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("BOTTOMLEFT", self.Slider.Thumb, "TOPRIGHT", self.tooltipXOffset, self.tooltipYOffset);
end

function CharCustomizeOptionSliderMixin:SetupOption(optionData)
	self:SetOptionData(optionData);
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

CharCustomizeOptionCheckButtonMixin = CreateFromMixins(CharCustomizeOptionFrameBaseMixin, CharCustomizeFrameWithTooltipMixin);

function CharCustomizeOptionCheckButtonMixin:SetupOption(optionData)
	self:SetOptionData(optionData);
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

local function IsSoundMuted()
	return not GetCVarBool("Sound_EnableSFX") or not GetCVarBool("Sound_EnableAllSound");
end

CharCustomizeAudioInterfacePlayButtonMixin = {};

function CharCustomizeAudioInterfacePlayButtonMixin:OnClick()
	local parent = self:GetParent();
	if parent:IsPlaying() then
		parent:StopAudio();
	else
		parent:PlayAudio(parent.soundKit);
	end
end

function CharCustomizeAudioInterfacePlayButtonMixin:OnEnter()
	GameTooltip_ShowSimpleTooltip(GetAppropriateTooltip(), CHAR_CUSTOMIZATION_TOOLTIP_PLAY_VOICE_SAMPLE, nil, false, self, "ANCHOR_LEFT");
end

function CharCustomizeAudioInterfacePlayButtonMixin:OnLeave()
	GetAppropriateTooltip():Hide();
end

function CharCustomizeAudioInterfacePlayButtonMixin:GetStateTextures()
	local parent = self:GetParent();
	if parent:IsPlaying() then
		return "charactercreate-customize-stopbutton", "charactercreate-customize-stopbutton-down";
	else
		return "charactercreate-customize-playbutton", "charactercreate-customize-playbutton-down";
	end
end

function CharCustomizeAudioInterfacePlayButtonMixin:UpdateStateTextures()
	local normalAtlas, pressedAtlas = self:GetStateTextures();
	self.NormalTexture:SetAtlas(normalAtlas);
	self.PushedTexture:SetAtlas(pressedAtlas);
	self:UpdateHighlightForState();
end

CharCustomizeAudioInterfaceMuteButtonMixin = {};

function CharCustomizeAudioInterfaceMuteButtonMixin:CharCustomizeAudioInterfaceMuteButton_OnLoad()
	self:UpdateStateTextures();
end

function CharCustomizeAudioInterfaceMuteButtonMixin:GetStateTextures()
	if IsSoundMuted() then
		return "charactercreate-customize-speakeronbutton", "charactercreate-customize-speakeronbutton-down";
	else
		return "charactercreate-customize-speakeroffbutton", "charactercreate-customize-speakeroffbutton-down";
	end
end

function CharCustomizeAudioInterfaceMuteButtonMixin:UpdateStateTextures()
	local normal, pressed = self:GetStateTextures();
	self:SetNormalAtlas(normal);
	self:SetPushedAtlas(pressed);
	self:UpdateHighlightForState();
end

function CharCustomizeAudioInterfaceMuteButtonMixin:OnClick()
	self.PulseAnim:Stop();

	if (IsSoundMuted()) then
		SetCVar("Sound_EnableSFX", 1);
		SetCVar("Sound_EnableAllSound", 1);
	else
		SetCVar("Sound_EnableSFX", self:GetParent().previousSFXSetting or 0);
		SetCVar("Sound_EnableAllSound", self:GetParent().previousAllSoundSetting or 0);
		self:GetParent():StopAudio();
	end

	self:UpdateStateTextures();
	self:OnEnter();
end

function CharCustomizeAudioInterfaceMuteButtonMixin:GetTooltipText()
	return IsSoundMuted() and CHAR_CUSTOMIZATION_TOOLTIP_UNMUTE_SOUND or CHAR_CUSTOMIZATION_TOOLTIP_MUTE_SOUND;
end

function CharCustomizeAudioInterfaceMuteButtonMixin:OnEnter()
	GameTooltip_ShowSimpleTooltip(GetAppropriateTooltip(), self:GetTooltipText(), nil, false, self, "ANCHOR_LEFT");
end

function CharCustomizeAudioInterfaceMuteButtonMixin:OnLeave()
	GetAppropriateTooltip():Hide();
end

CharCustomizeAudioInterfaceMixin = {};

function CharCustomizeAudioInterfaceMixin:OnEvent(event, ...)
	if event == "SOUNDKIT_FINISHED" then
		local soundHandle = ...;
		if self.soundHandle == soundHandle then
			self:OnPlaybackFinished();
		end
	end
end

function CharCustomizeAudioInterfaceMixin:SetupAudio(soundKit)
	self:StopAudio();

	local isMuted = IsSoundMuted();
	self.previousSFXSetting = GetCVar("Sound_EnableSFX");
	self.previousAllSoundSetting = GetCVar("Sound_EnableAllSound");
	self.soundKit = soundKit;
	self.PlayWaveform.Waveform:SetValue(0);
	self.PlayButton:Show();
	self.MuteButton:SetShown(isMuted);
	self.PlayButton:SetEnabled(soundKit ~= nil);
end

function CharCustomizeAudioInterfaceMixin:IsPlaying()
	return self.isPlaying;
end

function CharCustomizeAudioInterfaceMixin:PlayAudioInternal()
	local runFinishCallback = true;
	local _, soundHandle = PlaySound(self.soundKit, nil, nil, runFinishCallback);
	self.soundHandle = soundHandle;
	return self.soundHandle ~= nil;
end

function CharCustomizeAudioInterfaceMixin:PlayAudio(soundKit)
	if IsSoundMuted() then
		self.MuteButton.PulseAnim:Play();
	else
		self:StopAudio();

		if soundKit then
			self:RegisterEvent("SOUNDKIT_FINISHED");
			self.remainingCount = GetSoundEntryCount(soundKit);
			self.soundKit = soundKit;

			if self:PlayAudioInternal() then
				self.isPlaying = true;
				self.PlayButton:UpdateStateTextures();
				self.waveformTicker = C_Timer.NewTicker(.05, function()
					self:OnAudioPlayingTick();
				end);
			end
		end
	end
end

function CharCustomizeAudioInterfaceMixin:StopAudio()
	if self.waveformTicker then
		self.waveformTicker:Cancel();
		self.waveformTicker = nil;
	end

	self.PlayWaveform.Waveform:SetValue(0);

	if self.soundHandle then
		StopSound(self.soundHandle);
		self.soundHandle = nil;
	end

	self.remainingCount = 0;
	self.isPlaying = false;
	self.PlayButton:UpdateStateTextures();

	self:UnregisterEvent("SOUNDKIT_FINISHED");
end

function CharCustomizeAudioInterfaceMixin:OnPlaybackFinished()
	self.remainingCount = self.remainingCount - 1;

	if self.remainingCount > 0 then
		C_Timer.After(.5, function() self:CheckResumePlayback() end);
	else
		self:StopAudio();
	end
end

function CharCustomizeAudioInterfaceMixin:CheckResumePlayback()
	if self.remainingCount > 0 then
		if not self:PlayAudioInternal() then
			self:StopAudio();
		end
	end
end

function CharCustomizeAudioInterfaceMixin:OnAudioPlayingTick()
	self.PlayWaveform.Waveform:SetValue(math.random(65, 80)/100);
end

CharCustomizeOptionSelectionPopoutMixin = CreateFromMixins(CharCustomizeOptionFrameBaseMixin, CharCustomizeFrameWithTooltipMixin);

function CharCustomizeOptionSelectionPopoutMixin:OnLoad()
	CharCustomizeFrameWithTooltipMixin.OnLoad(self);
	SelectionPopoutWithButtonsAndLabelMixin.OnLoad(self);

	EventRegistry:RegisterCallback("CharCustomize.SetMissingOptionWarningEnabled", self.SetMissingOptionWarningEnabled, self);
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

	local tooltipText, tooltipLockedText = entry:GetTooltipText();
	if tooltipText or showDebugTooltipInfo then
		local tooltip = self:GetAppropriateTooltip();

		tooltip:SetOwner(self, "ANCHOR_NONE");
		tooltip:SetPoint("BOTTOMRIGHT", entry, "TOPLEFT", 0, 0);

		if tooltipText then
			GameTooltip_AddHighlightLine(tooltip, tooltipText);
		end

		if tooltipLockedText then
			GameTooltip_AddNormalLine(tooltip, tooltipLockedText);
		end

		if showDebugTooltipInfo then
			if tooltipText then
				GameTooltip_AddBlankLineToTooltip(tooltip, tooltipText);
			end

			GameTooltip_AddHighlightLine(tooltip, "Choice ID: "..entry.selectionData.id);
		end

		tooltip:Show();
	end

	if self:HasSound() and not entry.isSelected then
		self:GetAudioInterface():PlayAudio(self:GetSoundKit(entry));
	end
end

function CharCustomizeOptionSelectionPopoutMixin:OnEntryMouseLeave(entry)
	CharCustomizeFrame:OnOptionPopoutEntryMouseLeave(self, entry);

	local tooltip = self:GetAppropriateTooltip();
	tooltip:Hide();
	if self:GetAudioInterface() then
		self:GetAudioInterface():StopAudio();
	end
end

local POPOUT_CLEARANCE = 100;

function CharCustomizeOptionSelectionPopoutMixin:GetMaxPopoutHeight()
	return self:GetBottom() - POPOUT_CLEARANCE;
end

function CharCustomizeOptionSelectionPopoutMixin:SetupOption(optionData)
	self:SetOptionData(optionData);

	self:SetupSelections(optionData.choices, optionData.currentChoiceIndex, optionData.name);
	self.New:SetShown(optionData.hasNewChoices);

	self:ClearTooltipLines();

	local currentTooltip = self:GetTooltipText();
	if currentTooltip then
		self:AddTooltipLine(currentTooltip, HIGHLIGHT_FONT_COLOR);
	end

	if showDebugTooltipInfo then
		if currentTooltip then
			self:AddBlankTooltipLine();
		end
		self:AddTooltipLine("Option ID: "..self.optionData.id, HIGHLIGHT_FONT_COLOR);
		self:AddTooltipLine("Choice ID: "..optionData.choices[optionData.currentChoiceIndex].id, HIGHLIGHT_FONT_COLOR);
	end
end

function CharCustomizeOptionSelectionPopoutMixin:GetOrCreateWarningTexture(enabled)
	if not self.Button.WarningTexture then
		self.Button.WarningTexture = self.Button:CreateTexture(nil, nil, "MissionOptionWarningTemplate");
		self.Button.WarningTexture:ClearAllPoints();
		self.Button.WarningTexture:SetPoint("BOTTOM", self.Button, "TOP", 0, -23);
	end

	return self:GetWarningTexture();
end

function CharCustomizeOptionSelectionPopoutMixin:GetWarningTexture()
	return self.Button.WarningTexture;
end

function CharCustomizeOptionSelectionPopoutMixin:SetMissingOptionWarningEnabled(externallyEnabled)
	local showWarning = externallyEnabled and not self:HasChoice();
	if showWarning then
		self:GetOrCreateWarningTexture():Show();
		self:GetWarningTexture().PulseAnim:Play();
	elseif self:GetWarningTexture() then
		self:GetWarningTexture():Hide();
	end
end

CharCustomizeSelectionPopoutDetailsMixin = {};

function CharCustomizeSelectionPopoutDetailsMixin:GetTooltipText()
	local name, lockedText;
	if (self.SelectionName:IsShown() and self.SelectionName:IsTruncated()) or self.lockedText or self.name=="Charger" then
		name = self.name;
	end
	if self.lockedText then
		lockedText = BARBERSHOP_CUSTOMIZATION_SOURCE_FORMAT:format(self.lockedText);
	end
	return name, lockedText;
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

	if self:GetParent().popoutHasALockedChoice then
		width = width + CHAR_CUSTOMIZE_LOCK_WIDTH;
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

function CharCustomizeSelectionPopoutDetailsMixin:SetupDetails(selectionData, index, isSelected, hasAFailedReq, hasALockedChoice)
	if not index then
		self.SelectionName:SetText(CHARACTER_CUSTOMIZE_POPOUT_UNSELECTED_OPTION);
		self.SelectionName:Show();
		self.SelectionName:SetWidth(0);
		self.SelectionName:SetPoint("LEFT", self, "LEFT", 0, 0);
		self.SelectionNumber:Hide();
		self.SelectionNumberBG:Hide();
		self.ColorSwatch1:Hide();
		self.ColorSwatch1Glow:Hide();
		self.ColorSwatch2:Hide();
		self.ColorSwatch2Glow:Hide();
		self:SetShowAsNew(false);
		return;
	end
	self.name = selectionData.name;
	self.index = index;
	self.lockedText = selectionData.isLocked and selectionData.lockedText;

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

	self.LockIcon:SetShown(selectionData.isLocked);
	if self.selectable then
		if selectionData.isLocked then
			self.SelectionName:SetPoint("RIGHT", -CHAR_CUSTOMIZE_LOCK_WIDTH, 0);		
		else
			self.SelectionName:SetPoint("RIGHT", 0, 0);
		end
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
	self.SelectionDetails.LockIcon:Hide();

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

function CharCustomizeSelectionPopoutEntryMixin:SetupEntry(selectionData, index, isSelected, multipleColumns, hasAFailedReq, hasALockedChoice)
	self.isNew = selectionData.isNew;
	SelectionPopoutEntryMixin.SetupEntry(self, selectionData, index, isSelected, multipleColumns, hasAFailedReq, hasALockedChoice);
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
	self.pools:CreatePool("CHECKBUTTON", self.AlteredForms, "CharCustomizeRidingDrakeButtonTemplate");
	self.pools:CreatePool("FRAME", self, "CharCustomizeAudioInterface", function(pool, audioInterface)
		FramePool_HideAndClearAnchors(pool, audioInterface);
		audioInterface:StopAudio();
	end);

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

function CharCustomizeMixin:OnShow()
	EventRegistry:TriggerEvent("CharCustomize.OnShow", self);
end

function CharCustomizeMixin:OnHide()
	local clearSavedChoices = true;
	self:ResetCustomizationPreview(clearSavedChoices);
	self:SaveSeenChoices();
    EventRegistry:TriggerEvent("CharCustomize.OnHide", self);
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
	if self.selectedRaceData.alternateFormRaceData and self.selectedRaceData.alternateFormRaceData.createScreenIconAtlas then
		local normalForm = buttonPool:Acquire();
		local normalFormSelected = not self.viewingShapeshiftForm and not self.viewingAlteredForm;
		normalForm:SetupAlteredFormButton(self.selectedRaceData, normalFormSelected, false, -1);
		normalForm:Show();

		local alteredForm = buttonPool:Acquire();
		local alteredFormSelected = not self.viewingShapeshiftForm and self.viewingAlteredForm;
		alteredForm:SetupAlteredFormButton(self.selectedRaceData.alternateFormRaceData, alteredFormSelected, true, 0);
		alteredForm:Show();
	elseif self.hasShapeshiftForms then
		local normalForm = buttonPool:Acquire();
		local normalFormSelected = not self.viewingShapeshiftForm;
		normalForm:SetupAlteredFormButton(self.selectedRaceData, normalFormSelected, false, -1);
		normalForm:Show();
	end

	self.AlteredForms:Layout();
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
	self:SetViewingChrModel(noModelID);
end

function CharCustomizeMixin:SetViewingChrModel(chrModelID)
	if self.viewingChrModelID ~= chrModelID then
		self.viewingChrModelID = chrModelID;
		self.parentFrame:SetViewingChrModel(chrModelID);
	end
end

function CharCustomizeMixin:SetCharacterSex(sexID)
	self.parentFrame:SetCharacterSex(sexID);
end

local function SortCategories(a, b)
	return a.orderIndex < b.orderIndex;
end

function CharCustomizeMixin:RefreshCustomizations()
	local categories = self:GetCategories();
	if categories then
		self:SetCustomizations(categories);
	end
end

function CharCustomizeMixin:GetFirstValidCategory()
	-- This filters out any categories with a charmodel id, since we don't want to auto select those

	local categories = self:GetCategories();
	for i, category in ipairs(categories) do
		if not category.chrModelID then
			return category;
		end
	end

	return categories[1];
end

function CharCustomizeMixin:GetCategory(categoryIndex)
	return self:GetCategories()[categoryIndex];
end

function CharCustomizeMixin:GetCategories()
	return self.categories;
end

function CharCustomizeMixin:SetCustomizations(categories)
	self.categories = categories;

	local keepState = self:HasSelectedCategory();

	if self:NeedsCategorySelected() then
		table.sort(self.categories, SortCategories);
		self:SetSelectedCategory(self:GetFirstValidCategory(), keepState);
	else
		self:SetSelectedCategory(self.selectedCategoryData, keepState);
	end

	self:AddMissingOptions();

	EventRegistry:TriggerEvent("CharCustomize.OnSetCustomizations");
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
	if categoryData.chrModelID then
		return self.pools:GetPool("CharCustomizeRidingDrakeButtonTemplate");
	elseif categoryData.spellShapeshiftFormID then
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
	self.hasChrModels = false;	-- nothing using this right now, tracking it anyway
	self.firstChrModelID = nil;
	self.numNormalCategories = 0;

	local optionsToSetup = {};

	for _, categoryData in ipairs(self:GetCategories()) do
		local showCategory = not self.selectedCategoryData.spellShapeshiftFormID or categoryData.spellShapeshiftFormID;

		if showCategory then
			local categoryPool = self:GetCategoryPool(categoryData);
			local button = categoryPool:Acquire();

			if categoryData.chrModelID then
				self.hasChrModels = true;
				if not self.firstChrModelID then
					self.firstChrModelID = categoryData.chrModelID;
				end
			elseif categoryData.spellShapeshiftFormID then
				self.hasShapeshiftForms = true;
			else
				self.numNormalCategories = self.numNormalCategories + 1;
			end

			button:SetCategory(categoryData, self.selectedCategoryData.id);
			button:Show();

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

		if optionFrame:HasSound() then
			optionFrame:SetupAudio(self.pools:Acquire("CharCustomizeAudioInterface"));
		end
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
	local hadCategoryChange = not self:IsSelectedCategory(categoryData);

	if categoryData.chrModelID then
		self:SetViewingChrModel(categoryData.chrModelID);
	elseif categoryData.spellShapeshiftFormID or self.viewingShapeshiftForm then
		self:SetViewingShapeshiftForm(categoryData.spellShapeshiftFormID);
	end

	self.selectedCategoryData = categoryData;
	self:UpdateOptionButtons(not keepState);
	self:UpdateModelDressState();
	self:UpdateCameraDistanceOffset();
	self:UpdateCameraMode(keepState);

	EventRegistry:TriggerEvent("CharCustomize.OnCategorySelected", self, hadCategoryChange);
end

function CharCustomizeMixin:HasSelectedCategory()
	return self.selectedCategoryData ~= nil;
end

function CharCustomizeMixin:GetSelectedCategory()
	return self.selectedCategoryData;
end

function CharCustomizeMixin:IsSelectedCategory(categoryData)
	if self:HasSelectedCategory() then
		return self:GetSelectedCategory().id == categoryData.id;
	end

	return false;
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

function CharCustomizeMixin:AddMissingOptions()
	self.missingOptions = nil;

	for categoryIndex, category in ipairs(self:GetCategories()) do
		for optionIndex, option in ipairs(category.options) do
			if not option.currentChoiceIndex then
				self:AddMissingOption(categoryIndex, optionIndex);
			end
		end
	end
end

function CharCustomizeMixin:AddMissingOption(categoryIndex, optionIndex)
	if not self.missingOptions then
		self.missingOptions = {};
	end

	table.insert(self.missingOptions, { categoryIndex = categoryIndex, optionIndex = optionIndex });
end

function CharCustomizeMixin:GetMissingOptions()
	return self.missingOptions;
end

function CharCustomizeMixin:HasMissingOptions()
	return self:GetMissingOptions() ~= nil;
end

function CharCustomizeMixin:GetNextMissingOption()
	local missingOptions = self:GetMissingOptions();
	if missingOptions then
		for index, missingOption in ipairs(missingOptions) do
			return missingOption.categoryIndex, missingOption.optionIndex;
		end
	end
end

function CharCustomizeMixin:HighlightNextMissingOption()
	local categoryIndex, optionIndex = self:GetNextMissingOption();
	if categoryIndex then
		local keepState = true;
		self:SetSelectedCategory(self:GetCategory(categoryIndex), keepState);
		self:SetMissingOptionWarningEnabled(true);
	end
end

function CharCustomizeMixin:DisableMissingOptionWarnings()
	self:SetMissingOptionWarningEnabled(false);
end

function CharCustomizeMixin:SetMissingOptionWarningEnabled(enabled)
	EventRegistry:TriggerEvent("CharCustomize.SetMissingOptionWarningEnabled", enabled);
end