CHAR_CUSTOMIZE_MAX_SCALE = 0.75;
CHAR_CUSTOMIZE_LOCK_WIDTH = 24;

local POPOUT_CLEARANCE = 60;

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
			return entryOverride.choiceData.soundKit;
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
	local selected = selectedCategoryID == categoryData.id;
	if categoryData.chrModelID and not categoryData.subcategory and not CharCustomizeFrame.needsNativeFormCategory then
		if CharCustomizeFrame.viewingChrModelID then
			selected = categoryData.chrModelID == CharCustomizeFrame.viewingChrModelID;
		else
			selected = categoryData.chrModelID == CharCustomizeFrame.firstChrModelID;
		end
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

	local hadCategoryChange = false;

	if self.categoryData.subcategory then
		hadCategoryChange = not CharCustomizeFrame:IsSelectedSubcategory(self.categoryData);
		if hadCategoryChange then 
			CharCustomizeFrame:SetSelectedSubcategory(self.categoryData);
		end
	else
		-- If selecting a new main Category, we need to clear the Subcategory and 
		-- force it to pick a new best valid one in SetCategory().
		hadCategoryChange = not CharCustomizeFrame:IsSelectedCategory(self.categoryData);
		if hadCategoryChange then 
	CharCustomizeFrame:SetSelectedCategory(self.categoryData);
			CharCustomizeFrame:SetSelectedSubcategory(nil);
		end
	end

	-- If we didn't change category with this click, then we won't run SetCustomizations(), 
	-- which would have updated our button's state. So, update it here.
	if not hadCategoryChange then
		self:SetChecked(true);
		self:SetIconAtlas(self.categoryData.selectedIcon);
	end
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

	local mouseFoci = GetMouseFoci();
	for _, mouseFocus in ipairs(mouseFoci) do
	if DoesAncestryInclude(self, mouseFocus) and (mouseFocus:GetObjectType() ~= "Button") then
		self:OnEnter();
			break;
		end
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
	local tooltipOwner = self;
	GameTooltip_ShowSimpleTooltip(GetAppropriateTooltip(), CHAR_CUSTOMIZATION_TOOLTIP_PLAY_VOICE_SAMPLE, SimpleTooltipConstants.NoOverrideColor, SimpleTooltipConstants.DoNotWrapText, tooltipOwner, "ANCHOR_LEFT");
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
	local tooltipOwner = self;
	GameTooltip_ShowSimpleTooltip(GetAppropriateTooltip(), self:GetTooltipText(), SimpleTooltipConstants.NoOverrideColor, SimpleTooltipConstants.DoNotWrapText, tooltipOwner, "ANCHOR_LEFT");
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

CharCustomizeDropdownWithSteppersAndLabelMixin = CreateFromMixins(CharCustomizeOptionFrameBaseMixin, CharCustomizeFrameWithTooltipMixin);

function CharCustomizeDropdownWithSteppersAndLabelMixin:OnLoad()
	CharCustomizeFrameWithTooltipMixin.OnLoad(self);
	DropdownWithSteppersAndLabelMixin.OnLoad(self);

	self.Dropdown:SetMenuAnchor(AnchorUtil.CreateAnchor("TOPRIGHT", self.Dropdown, "BOTTOMRIGHT"));
	self.Dropdown:EnableMouseWheel(true);

	EventRegistry:RegisterCallback("CharCustomize.SetMissingOptionWarningEnabled", self.SetMissingOptionWarningEnabled, self);
end

function CharCustomizeDropdownWithSteppersAndLabelMixin:SetupAnchors(tooltip)
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("BOTTOMRIGHT", self.Dropdown, "TOPLEFT", self.tooltipXOffset, self.tooltipYOffset);
end

do
	local function GetChoiceConstraints(optionData)
		local hasAFailedReq = false;
		local hasALockedChoice = false;
		for choiceIndex, choiceData in ipairs(optionData.choices) do
			if choiceData.ineligibleChoice then
				hasAFailedReq = true;
			end
			if choiceData.isLocked then
				hasALockedChoice = true;
			end
		end
		return hasAFailedReq, hasALockedChoice;
	end
		
	local function CanSelect(choiceData)
		return (not choiceData.disabled) and (not choiceData.isLocked);
	end
	
	function CharCustomizeDropdownWithSteppersAndLabelMixin:SetupOption(optionData)
		self:SetOptionData(optionData);
	
		self:SetText(optionData.name);
	
		self.New:SetShown(optionData.hasNewChoices);
	
		self:ClearTooltipLines();
	
		local currentTooltip = self.Dropdown.SelectionDetails:GetTooltipText();
		if currentTooltip then
			self:AddTooltipLine(currentTooltip, HIGHLIGHT_FONT_COLOR);
		end

		local currentChoice = optionData.choices[optionData.currentChoiceIndex];
		if showDebugTooltipInfo then
			if currentTooltip then
				self:AddBlankTooltipLine();
			end
			self:AddTooltipLine("Option ID: "..optionData.id, HIGHLIGHT_FONT_COLOR);
			self:AddTooltipLine("Choice ID: "..currentChoice.id, HIGHLIGHT_FONT_COLOR);
		end

		local rootDescription = MenuUtil.CreateRootMenuDescription(MenuStyle2Mixin);
	
		--[[
		The compositor is disabled here for multiple reasons:
		1) We're not concerned with these frames becoming tainted as there shouldn't be any
		functionality we need to protect in customization.
		2) The compositor isn't being leveraged anyways: the contents of these frames are
		in the CharCustomizeDropdownElementTemplate template.
		3) Performance concerns. Customization regenerates all options without consideration of
		the options actually changing, and since compositor isn't used here, it adds to the cumulatively
		large overhead of rebuilding all of the menu descriptions.
		]]--
		rootDescription:DisableCompositor();
	
		-- Again for performance reasons.
		rootDescription:DisableReacquireFrames();
	
		local columns = MenuConstants.AutoCalculateColumns;
		local padding = 0;
		local compactionMargin = 100;
		rootDescription:SetGridMode(MenuConstants.VerticalGridDirection, columns, padding, compactionMargin);

		rootDescription:AddMenuAcquiredCallback(function(menu)
			menu:SetScale(self.Dropdown:GetEffectiveScale());
		end);
	
		local hasAFailedReq, hasALockedChoice = GetChoiceConstraints(optionData);
	
		--[[
		These functions cannot be defined as file locals because optionData, hasAFailedReq and hasALockedChoice
		and 'self' all require capture.
		]]

		local function IsSelected(choiceData)
			return optionData.currentChoiceIndex == choiceData.choiceIndex;
		end
	
		local function OnSelect(choiceData, menuInputData, menu)
			RunNextFrame(function() 
				CharCustomizeFrame.previewIsDirty = false;
				CharCustomizeFrame:SetCustomizationChoice(optionData.id, choiceData.id);
			end);
	
			-- If the selection was done via mouse-wheel, reinitialize and keep the menu open.
			if menuInputData.context == MenuInputContext.MouseWheel then
				return MenuResponse.Refresh;
			end
		end
		
		local function OnEnter(button)
			local description = button:GetElementDescription();
			local choiceData = description:GetData();
			CharCustomizeFrame:PreviewChoice(optionData, choiceData);
	
			local tooltipText, tooltipLockedText = button.SelectionDetails:GetTooltipText();
			if tooltipText or showDebugTooltipInfo then
				local tooltip = self:GetAppropriateTooltip();

				tooltip:SetOwner(self, "ANCHOR_NONE");
					tooltip:SetPoint("BOTTOMRIGHT", button, "TOPLEFT", 0, 0);

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

					GameTooltip_AddHighlightLine(tooltip, "Choice ID: "..choiceData.id);
				end

				tooltip:Show();
			end

			if self:HasSound() and not IsSelected(choiceData) then
				self:GetAudioInterface():PlayAudio(self:GetSoundKit(choiceData));
			end
	
			local selected = IsSelected(choiceData);
			if not selected then
				button.HighlightBGTex:SetAlpha(0.15);
				button.SelectionDetails.SelectionNumber:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
				button.SelectionDetails.SelectionName:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
			end
		end

		local function OnLeave(button)
			CharCustomizeFrame.previewIsDirty = true;

			local tooltip = self:GetAppropriateTooltip();
			tooltip:Hide();
				
			if self:GetAudioInterface() then
				self:GetAudioInterface():StopAudio();
			end
			
			local description = button:GetElementDescription();
			local choiceData = description:GetData();
			local selected = IsSelected(choiceData);
			if not selected then
				button.HighlightBGTex:SetAlpha(0);
				button.SelectionDetails:UpdateFontColors(choiceData, selected, hasAFailedReq);
			end
		end
	
		local function FinalizeLayout(button, description, menu, columns, rows)
			-- Frames have size overrides if their containing menu has multiple columns.
			local hasMultipleColumns = columns > 1;
			button.SelectionDetails:AdjustWidth(hasMultipleColumns, hasALockedChoice);
			button:Layout();
		end

		for choiceIndex, choiceData in ipairs(optionData.choices) do
			choiceData.choiceIndex = choiceIndex;

			local optionDescription = rootDescription:CreateTemplate("CharCustomizeDropdownElementTemplate");
			optionDescription:AddInitializer(function(button, description, menu)
				button.HighlightBGTex:SetAlpha(0);
	
				button:SetScript("OnClick", function(button, buttonName)
					description:Pick(MenuInputContext.MouseButton, buttonName);
				end);
				
				local selected = IsSelected(choiceData);
				
				button.SelectionDetails:Init(choiceData, choiceIndex, selected, hasAFailedReq, hasALockedChoice);

				--[[
				We will have 2 Layout() calls. One for the reference width, and another to account
				for the column count changing in FinalizeLayout below.
				]]--
				button:Layout();
			end);

			optionDescription:SetOnEnter(OnEnter);
			optionDescription:SetOnLeave(OnLeave);
			optionDescription:SetIsSelected(IsSelected);
			optionDescription:SetCanSelect(CanSelect);
			optionDescription:SetResponder(OnSelect);
			optionDescription:SetRadio(true);
			optionDescription:SetData(choiceData);
			optionDescription:SetFinalizeGridLayout(FinalizeLayout);
		end
		
		-- Setup the dropdown button.
		do
			--[[
			Dropdown shares the same details frame as the elements, but expects 'selected' and
			'hasAFailedReq' to be always be false.
			]]--

			local selected = false;
			local failedReq = false;
			local clampNameSize = true;
			self.Dropdown.SelectionDetails:Init(currentChoice, optionData.currentChoiceIndex, selected, failedReq, clampNameSize);
			self.Dropdown.SelectionDetails:Layout();
		end
		
		-- TODO Should be converted to a generator function.
		self.Dropdown:RegisterMenu(rootDescription);
	end
end

function CharCustomizeDropdownWithSteppersAndLabelMixin:GetOrCreateWarningTexture(enabled)
	if not self.Dropdown.WarningTexture then
		self.Dropdown.WarningTexture = self.Dropdown:CreateTexture(nil, nil, "MissionOptionWarningTemplate");
		self.Dropdown.WarningTexture:ClearAllPoints();
		self.Dropdown.WarningTexture:SetPoint("BOTTOM", self.Dropdown, "TOP", 0, -23);
	end

	return self:GetWarningTexture();
end

function CharCustomizeDropdownWithSteppersAndLabelMixin:GetWarningTexture()
	return self.Dropdown.WarningTexture;
end

function CharCustomizeDropdownWithSteppersAndLabelMixin:SetMissingOptionWarningEnabled(externallyEnabled)
	local showWarning = externallyEnabled and not self:HasChoice();
	if showWarning then
		self:GetOrCreateWarningTexture():Show();
		self:GetWarningTexture().PulseAnim:Play();
	elseif self:GetWarningTexture() then
		self:GetWarningTexture():Hide();
	end
end

CharCustomizeDropdownElementDetailsMixin = {};

function CharCustomizeDropdownElementDetailsMixin:GetTooltipText()
	local name;
	if self.lockedText or (self.SelectionName:IsShown() and self.SelectionName:IsTruncated()) then
		name = self.name;
	end

	if not self.lockedText then
		return name;
	end

	return name, BARBERSHOP_CUSTOMIZATION_SOURCE_FORMAT:format(self.lockedText);
end

function CharCustomizeDropdownElementDetailsMixin:AdjustWidth(multipleColumns, hasALockedChoice)
	local width = 116;
	if multipleColumns then
	if self.ColorSwatch1:IsShown() or self.ColorSwatch2:IsShown() then
			width = self.SelectionNumber:GetWidth() + self.ColorSwatch2:GetWidth() + 18;
	elseif self.SelectionName:IsShown() then
			width = 108;
	else
			width = 42;
		end
	end

	if hasALockedChoice then
		width = width + CHAR_CUSTOMIZE_LOCK_WIDTH;
	end

	self:SetWidth(Round(width));
end

local function GetNormalSelectionTextFontColor(choiceData, isSelected)
	if isSelected then
		return NORMAL_FONT_COLOR;
	else
		return DISABLED_FONT_COLOR;
	end
end

local eligibleChoiceColor = CreateColor(.808, 0.808, 0.808);
local ineligibleChoiceColor = CreateColor(.337, 0.337, 0.337);

local function GetFailedReqSelectionTextFontColor(choiceData, isSelected)
	if isSelected then
		return NORMAL_FONT_COLOR;
	elseif choiceData.ineligibleChoice then
		return ineligibleChoiceColor;
	else
		return eligibleChoiceColor;
	end
end

function CharCustomizeDropdownElementDetailsMixin:GetFontColors(choiceData, isSelected, hasAFailedReq)
	if self.selectable then
		local fontColorFunction = hasAFailedReq and GetFailedReqSelectionTextFontColor or GetNormalSelectionTextFontColor;
		local fontColor = fontColorFunction(choiceData, isSelected);
		local showAsNew = (choiceData.isNew and self.selectable);
		if showAsNew then
			return fontColor, HIGHLIGHT_FONT_COLOR;
		else
			return fontColor, fontColor;
		end
	else
		return NORMAL_FONT_COLOR, NORMAL_FONT_COLOR;
	end
end

function CharCustomizeDropdownElementDetailsMixin:UpdateFontColors(choiceData, isSelected, hasAFailedReq)
	local nameColor, numberColor = self:GetFontColors(choiceData, isSelected, hasAFailedReq);
	self.SelectionName:SetTextColor(nameColor:GetRGB());
	self.SelectionNumber:SetTextColor(numberColor:GetRGB());
end

local function startsWithOne(index)
	local indexString = tostring(index);
	return indexString:sub(1, 1) == "1";
end

function CharCustomizeDropdownElementDetailsMixin:SetShowAsNew(showAsNew)
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

function CharCustomizeDropdownElementDetailsMixin:UpdateText(choiceData, isSelected, hasAFailedReq, hideNumber, hasColors)
	self:UpdateFontColors(choiceData, isSelected, hasAFailedReq);

	self.SelectionNumber:SetText(self.index);
	self.SelectionNumberBG:SetText(self.index);

	if hasColors then
		self.SelectionName:Hide();
		self.SelectionNumber:SetWidth(25);
		self.SelectionNumberBG:SetWidth(25);
	elseif choiceData.name ~= "" then
		self.SelectionName:Show();
		self.SelectionName:SetWidth(0);
		self.SelectionName:SetText(choiceData.name);

		-- Truncates selected customization text
		local margins = 2;
		local selectionNumberWidth = 25;
		local maxWidth = self:GetParent():GetWidth() - margins - (not hideNumber and selectionNumberWidth or 0);
		if self.SelectionName:GetWidth() > maxWidth then
			self.SelectionName:SetWidth(maxWidth);
		end

		self.SelectionNumber:SetWidth(selectionNumberWidth);
		self.SelectionNumberBG:SetWidth(selectionNumberWidth);
	else
		self.SelectionName:Hide();
		self.SelectionNumber:SetWidth(0);
		self.SelectionNumberBG:SetWidth(0);
	end

	self.SelectionNumber:SetShown(not hideNumber);

	local showAsNew = (self.selectable and not hideNumber and choiceData.isNew);
	self:SetShowAsNew(showAsNew);
end

function CharCustomizeDropdownElementDetailsMixin:Init(choiceData, index, isSelected, hasAFailedReq, hasALockedChoice, clampNameSize)
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

	self.name = choiceData.name;
	self.index = index;
	self.lockedText = choiceData.isLocked and choiceData.lockedText;

	local color1 = choiceData.swatchColor1 or choiceData.swatchColor2;
	local color2 = choiceData.swatchColor1 and choiceData.swatchColor2;
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
	elseif choiceData.name ~= "" then
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

	local hideNumber = (not self.selectable and (color1 or (choiceData.name ~= "")));
	if hideNumber then
		self.SelectionName:SetPoint("LEFT", self, "LEFT", 0, 0);
		self.ColorSwatch1:SetPoint("LEFT", self, "LEFT", 0, 0);
		self.ColorSwatch2:SetPoint("LEFT", self, "LEFT", 18, -2);
	else
		self.SelectionName:SetPoint("LEFT", self.SelectionNumber, "RIGHT", 0, 0);
		self.ColorSwatch1:SetPoint("LEFT", self.SelectionNumber, "RIGHT", 0, 0);
		self.ColorSwatch2:SetPoint("LEFT", self.SelectionNumber, "RIGHT", 18, -2);
	end

	self.LockIcon:SetShown(choiceData.isLocked);
	if self.selectable then
		if choiceData.isLocked then
			self.SelectionName:SetPoint("RIGHT", -CHAR_CUSTOMIZE_LOCK_WIDTH, 0);		
		else
			self.SelectionName:SetPoint("RIGHT", 0, 0);
		end
	end

	self:UpdateText(choiceData, isSelected, hasAFailedReq, hideNumber, color1);

	if clampNameSize then
		local maxNameWidth = 126;
		if self.SelectionName:GetWidth() > maxNameWidth then
			self.SelectionName:SetWidth(maxNameWidth);
		end
	end
end

CharCustomizeDropdownMixin = {};

do
	local xy = 1;
	function CharCustomizeDropdownMixin:OnMouseDown()
		if WowStyle1FilterDropdownMixin.OnMouseDown(self) then
			self.SelectionDetails:AdjustPointsOffset(xy, -xy);
		end
	end

	function CharCustomizeDropdownMixin:OnMouseUp()
		if WowStyle1FilterDropdownMixin.OnMouseUp(self) then
			self.SelectionDetails:AdjustPointsOffset(-xy, xy);
		end
	end
end

function CharCustomizeDropdownMixin:OnDisable()
	WowStyle1FilterDropdownMixin.OnDisable(self);

	self.SelectionDetails:ClearPointsOffset();
end


CharCustomizeDropdownElementMixin = {};

function CharCustomizeDropdownElementMixin:OnLoad()
	self.SelectionDetails.SelectionName:SetPoint("RIGHT");
end

CharCustomizeMixin = {};

function CharCustomizeMixin:OnLoad()
	self:RegisterEvent("CVAR_UPDATE");

	self.pools = CreateFramePoolCollection();
	self.pools:CreatePool("CHECKBUTTON", self.Categories, "CharCustomizeCategoryButtonTemplate");
	self.pools:CreatePool("FRAME", self.Options, "CharCustomizeOptionCheckButtonTemplate");
	self.pools:CreatePool("CHECKBUTTON", self.AlteredForms, "CharCustomizeConditionalModelButtonTemplate");
	self.pools:CreatePool("FRAME", self, "CharCustomizeAudioInterface", function(pool, audioInterface)
		Pool_HideAndClearAnchors(pool, audioInterface);
		audioInterface:StopAudio();
	end);

	-- Keep the dropdowns and sliders in different pools because we need to be careful not to release the option the player is interacting with
	self.dropdownPool = CreateFramePool("BUTTON", self.Options, "CharCustomizeDropdownWithSteppersAndLabelTemplate");
	self.sliderPool = CreateFramePool("FRAME", self.Options, "CharCustomizeOptionSliderTemplate");

	-- Keep the altered forms buttons in a different pool because we only want to release those when we enter this screen
	self.alteredFormsPools = CreateFramePoolCollection();
	self.alteredFormsPools:CreatePool("CHECKBUTTON", self.AlteredForms, "CharCustomizeAlteredFormButtonTemplate");
	self.alteredFormsPools:CreatePool("CHECKBUTTON", self.AlteredForms, "CharCustomizeAlteredFormSmallButtonTemplate");

	self.Categories:SetFixedMaxSpace(400);
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

-- Used to set up spacing adjustments when resolution and UI scale don't leave enough room.
function CharCustomizeMixin:SetOptionsSpacingConfiguration(topFrame, bottomFrame)
	self.Options:SetTopFrame(topFrame);
	self.Options:SetBottomFrame(bottomFrame, POPOUT_CLEARANCE);
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
	self.selectedSubcategoryData = nil;
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

function CharCustomizeMixin:NeedsSubcategorySelected()
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
		local notChrModel = not self.viewingShapeshiftForm and not self.viewingChrModelID;
		local normalFormSelected = notChrModel and not self.viewingAlteredForm;
		normalForm:SetupAlteredFormButton(self.selectedRaceData, normalFormSelected, false, -1);
		normalForm:Show();

		local alteredForm = buttonPool:Acquire();
		local alteredFormSelected = notChrModel and self.viewingAlteredForm;
		alteredForm:SetupAlteredFormButton(self.selectedRaceData.alternateFormRaceData, alteredFormSelected, true, 0);
		alteredForm:Show();
	elseif self.needsNativeFormCategory then
		local normalForm = buttonPool:Acquire();
		local normalFormSelected = not self.viewingChrModelID and not self.viewingShapeshiftForm;
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

function CharCustomizeMixin:RefreshCustomizations()
	local categories = self:GetCategories();
	if categories then
		self:SetCustomizations(categories);
	end
end

function CharCustomizeMixin:GetFirstValidSubcategory()
	local categories = self:GetCategories();

	for i, category in ipairs(categories) do
		if category.subcategory then
			return category;
		end
	end

	return self:GetFirstValidCategory();
end

function CharCustomizeMixin:GetFirstValidCategory()
	local categories = self:GetCategories();
	local firstCategory = categories[1];

	-- If the first category is a shapeshift, use it.
	-- CGBarberShop::GetAvailableCustomizations() will put your current shapeshift form first, if it needs to.
	if firstCategory.spellShapeshiftFormID then
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

function CharCustomizeMixin:GetCategory(categoryIndex)
	return self:GetCategories()[categoryIndex];
end

function CharCustomizeMixin:GetCategories()
	return self.categories;
end

function CharCustomizeMixin:SetCustomizations(categories)
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

	EventRegistry:TriggerEvent("CharCustomize.OnSetCustomizations");
end

function CharCustomizeMixin:GetOptionPool(optionType)
	if optionType == Enum.ChrCustomizationOptionType.Dropdown then
		return self.dropdownPool;
	elseif optionType == Enum.ChrCustomizationOptionType.Checkbox then
		return self.pools:GetPool("CharCustomizeOptionCheckButtonTemplate");
	elseif optionType == Enum.ChrCustomizationOptionType.Slider then
		return self.sliderPool;
	end
end

function CharCustomizeMixin:GetCategoryPool(categoryData)
	if categoryData.chrModelID then
		return self.pools:GetPool("CharCustomizeConditionalModelButtonTemplate");
	else
		return self.pools:GetPool("CharCustomizeCategoryButtonTemplate");
	end
end

-- Releases all sliders EXCEPT the one the player is currently dragging (if they are dragging one).
-- Returns the currently dragging slider if there was one
function CharCustomizeMixin:ReleaseNonDraggingSliders()
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
function CharCustomizeMixin:ReleaseClosedDropdowns()
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

function CharCustomizeMixin:UpdateOptionButtons(forceReset)
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

	self.hasShapeshiftForms = false;
	self.hasChrModels = false;	-- nothing using this right now, tracking it anyway
	self.needsNativeFormCategory = false;
	self.firstChrModelID = nil;
	self.numSubcategories = 0;

	local optionsToSetup = {};
	for _, categoryData in ipairs(self:GetCategories()) do
		local categoryPool = self:GetCategoryPool(categoryData);
		local button = categoryPool:Acquire();

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

		if (fallbackToCategory and categoryMatches) or subcategoryMatches then
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

	self.Categories:Layout();

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

	for optionFrame, optionData in pairs(optionsToSetup) do
		optionFrame:SetupOption(optionData);

		if optionFrame:HasSound() then
			optionFrame:SetupAudio(self.pools:Acquire("CharCustomizeAudioInterface"));
		end
	end

	local raceAlteredFormsDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.RaceAlteredFormsDisabled);
	if not raceAlteredFormsDisabled then
		self:UpdateAlteredFormButtons();
	end

	if self.numSubcategories > 1 then
		self.Categories:Show();

		-- Push the randomize button together with categories too if we're collapsing category buttons.
		local xOffset = self.Categories:IsSpacingAdjusted() and 15 or -20;
		self.RandomizeAppearanceButton:SetPoint("RIGHT", self.Categories, "LEFT", xOffset, 0);
	else
		self.Categories:Hide();
		self.Categories:SetSize(1, 105);
		self.RandomizeAppearanceButton:SetPoint("RIGHT", self.Categories, "RIGHT", -10, 0);
	end
end

function CharCustomizeMixin:GetBestCategoryData()
	-- Prefer Subcategory if we have one.
	if self.selectedSubcategoryData then
		return self.selectedSubcategoryData;
	else
		return self.selectedCategoryData;
	end
end

function CharCustomizeMixin:UpdateModelDressState()
	local categoryData = self:GetBestCategoryData();
	self.parentFrame:SetModelDressState(not categoryData.undressModel);
end

function CharCustomizeMixin:UpdateCameraDistanceOffset()
	local categoryData = self:GetBestCategoryData();
	self.parentFrame:SetCameraDistanceOffset(categoryData.cameraDistanceOffset);
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
	local categoryData = self:GetBestCategoryData();
	self.parentFrame:SetCameraZoomLevel(categoryData.cameraZoomLevel, keepCustomZoom);
	self:UpdateZoomButtonStates();
end

function CharCustomizeMixin:SetSelectedCategory(categoryData, keepState)
	local hadCategoryChange = not self:IsSelectedCategory(categoryData);

	if categoryData.spellShapeshiftFormID or self.viewingShapeshiftForm then
		self:SetViewingShapeshiftForm(categoryData.spellShapeshiftFormID);
	elseif categoryData.chrModelID then
		self:SetViewingChrModel(categoryData.chrModelID);
	end

	self.selectedCategoryData = categoryData;
	if not self.selectedSubcategoryData then
	self:UpdateOptionButtons(not keepState);
	self:UpdateModelDressState();
	self:UpdateCameraDistanceOffset();
	self:UpdateCameraMode(keepState);
	end

	EventRegistry:TriggerEvent("CharCustomize.OnCategorySelected", self, hadCategoryChange);
end

function CharCustomizeMixin:SetSelectedSubcategory(categoryData, keepState)
	if not categoryData then
		self.selectedSubcategoryData = nil;
		return;
	end

	local hadCategoryChange = not self:IsSelectedSubcategory(categoryData);

	self.selectedSubcategoryData = categoryData;
	self:UpdateOptionButtons(not keepState);
	self:UpdateModelDressState();
	self:UpdateCameraDistanceOffset();
	self:UpdateCameraMode(keepState);

	EventRegistry:TriggerEvent("CharCustomize.OnCategorySelected", self, hadCategoryChange);
end

function CharCustomizeMixin:HasSelectedSubcategory()
	return self.selectedSubcategoryData ~= nil;
end

function CharCustomizeMixin:GetSelectedSubcategory()
	return self.selectedSubcategoryData;
end

function CharCustomizeMixin:IsSelectedSubcategory(subcategoryData)
	if self:HasSelectedSubcategory() then
		return self:GetSelectedSubcategory().id == subcategoryData.id;
	end

	return false;
end

function CharCustomizeMixin:HasSelectedCategory()
	return self.selectedCategoryData ~= nil;
end

function CharCustomizeMixin:GetSelectedCategory()
	return self.selectedCategoryData;
end

function CharCustomizeMixin:IsSelectedCategory(categoryData)
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

function CharCustomizeMixin:ResetPreviewIfDirty()
	if self.previewIsDirty then
		self.previewIsDirty = false;
		self:ResetCustomizationPreview();
	end
end

function CharCustomizeMixin:PreviewChoice(optionData, choiceData)
	local selected = optionData.currentChoiceIndex == choiceData.choiceIndex;
	if not selected then
		self.previewIsDirty = false;
		self:PreviewCustomizationChoice(optionData.id, choiceData.id);
	end

	if choiceData.isNew then
		self:MarkCustomizationChoiceAsSeen(choiceData.id);
end
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
	if missingOptions and #missingOptions > 0 then
		local missingOption = missingOptions[1];
		return missingOption.categoryIndex, missingOption.optionIndex;
	end
end

function CharCustomizeMixin:HighlightNextMissingOption()
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

function CharCustomizeMixin:DisableMissingOptionWarnings()
	self:SetMissingOptionWarningEnabled(false);
end

function CharCustomizeMixin:SetMissingOptionWarningEnabled(enabled)
	EventRegistry:TriggerEvent("CharCustomize.SetMissingOptionWarningEnabled", enabled);
end