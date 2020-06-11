local showDebugTooltipInfo = GetCVarBool("debugTargetInfo");

local CHAR_CREATE_MODE_CLASS_RACE = 1;
local CHAR_CREATE_MODE_CUSTOMIZE = 2;
local CHAR_CREATE_MODE_ZONE_CHOICE = 3;

local FORWARD_ARROW = true;
local BACKWARD_ARROW = false;
local PENDING_RANDOM_NAME = "...";

local ZONE_CHOICE_ZOOM_AMOUNT = 100;
local ZOOM_TIME_SECONDS = 0.25;
local ROTATION_ADJUST_SECONDS = 0.25;
local CLASS_ANIM_WAIT_TIME_SECONDS = 5;

local RaceAndClassFrame;
local NameChoiceFrame;
local ClassTrialSpecs;
local ZoneChoiceFrame;

NineSliceUtil.AddLayout("CharacterCreateThickBorder", {
	TopLeftCorner =	{ atlas = "charactercreate-DiamondMetal-CornerTopLeft-8x", },
	TopRightCorner =	{ atlas = "charactercreate-DiamondMetal-CornerTopRight-8x", },
	BottomLeftCorner =	{ atlas = "charactercreate-DiamondMetal-CornerBottomLeft-8x", },
	BottomRightCorner =	{ atlas = "charactercreate-DiamondMetal-CornerBottomRight-8x", },
	TopEdge = { atlas = "_charactercreate-DiamondMetal-EdgeTop-8x", },
	BottomEdge = { atlas = "_charactercreate-DiamondMetal-EdgeBottom-8x", },
	LeftEdge = { atlas = "!charactercreate-DiamondMetal-EdgeLeft-8x", },
	RightEdge = { atlas = "!charactercreate-DiamondMetal-EdgeRight-8x", },
});

GlueDialogTypes["CHARACTER_CREATE_FAILURE"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
    OnAccept = function ()
        CharacterCreateFrame:SetMode(CHAR_CREATE_MODE_CUSTOMIZE);
    end,
}

CharacterCreateMixin = CreateFromMixins(CharCustomizeParentFrameBaseMixin);

function CharacterCreateMixin:OnLoad()
	DefaultScaleFrameMixin.OnLoad(self);

	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("CHARACTER_CREATION_RESULT");
	self:RegisterEvent("RACE_FACTION_CHANGE_STARTED");
	self:RegisterEvent("RACE_FACTION_CHANGE_RESULT");
	self:RegisterEvent("CUSTOMIZE_CHARACTER_STARTED");
	self:RegisterEvent("CUSTOMIZE_CHARACTER_RESULT");
	self:RegisterEvent("CHAR_CREATE_BEGIN_ANIMATIONS");
	self:RegisterEvent("CHAR_CREATE_ANIM_KIT_FINISHED");

	self.LeftBlackBar:SetPoint("TOPLEFT", nil);
	self.RightBlackBar:SetPoint("TOPRIGHT", nil);

	C_CharacterCreation.SetCharCustomizeFrame("CharacterCreateFrame");

	RaceAndClassFrame = self.RaceAndClassFrame;
	NameChoiceFrame = self.NameChoiceFrame;
	ClassTrialSpecs = self.ClassTrialSpecs;
	ZoneChoiceFrame = self.ZoneChoiceFrame;

	CharCustomizeFrame:AttachToParentFrame(self);

	self.navBlockers = {};

	self.ForwardButton.tooltip = function()
		return self.currentNavBlocker and RED_FONT_COLOR:WrapTextInColorCode(self.currentNavBlocker.error);
	end

	self.BackButton:UpdateText(BACK, BACKWARD_ARROW);

	self:SetSequence(0);
	self:SetCamera(0);
end

function CharacterCreateMixin:OnEvent(event, ...)
	DefaultScaleFrameMixin.OnEvent(self, event, ...);

	local showError;
	if event == "CHARACTER_CREATION_RESULT" then
		local success, errorCode, guid = ...;
		if success then
			if guid then
				if (C_CharacterCreation.GetCharacterCreateType() == Enum.CharacterCreateType.TrialBoost and IsConnectedToServer()) then
					CharacterSelect_SetPendingTrialBoost(true, RaceAndClassFrame:GetBoostCharacterFactionID(), ClassTrialSpecs.selectedSpecID, guid);
				end
				CharacterSelect.selectGuid = guid;
			elseif C_CharacterCreation.IsUsingCharacterTemplate() then
				CharacterSelect.selectLast = true;
			end
			GlueParent_SetScreen("charselect");
		else
			showError = errorCode;
		end
	elseif event == "RACE_FACTION_CHANGE_STARTED" then
		local changeType = ...;
		if changeType == "RACE" then
			GlueDialog_Show("PAID_SERVICE_IN_PROGRESS", RACE_CHANGE_IN_PROGRESS);
		elseif changeType == "FACTION" then
			GlueDialog_Show("PAID_SERVICE_IN_PROGRESS", FACTION_CHANGE_IN_PROGRESS);
		end
	elseif event == "RACE_FACTION_CHANGE_RESULT" then
		local success, errorCode = ...;
		if success then
			GlueDialog_Hide("PAID_SERVICE_IN_PROGRESS");
			GlueParent_SetScreen("charselect");
		else
			showError = errorCode;
		end
	elseif event == "CUSTOMIZE_CHARACTER_STARTED" then
		GlueDialog_Show("PAID_SERVICE_IN_PROGRESS", CHAR_CUSTOMIZE_IN_PROGRESS);
	elseif event == "CUSTOMIZE_CHARACTER_RESULT" then
		local success, errorCode = ...;
		if success then
			GlueDialog_Hide("PAID_SERVICE_IN_PROGRESS");
			GlueParent_SetScreen("charselect");
		else
			showError = errorCode;
		end
	elseif event == "CHAR_CREATE_BEGIN_ANIMATIONS" then
		if self.currentMode == CHAR_CREATE_MODE_CLASS_RACE then
			RaceAndClassFrame:PlayClassAnimations();
		else
			RaceAndClassFrame:PlayCustomizationAnimation();
		end
	elseif event == "CHAR_CREATE_ANIM_KIT_FINISHED" then
		local animKitID, spellVisualKitID = ...;
		RaceAndClassFrame:OnAnimKitFinished(animKitID, spellVisualKitID);
	end

	if showError then
		self:UpdateForwardButton();
		GlueDialog_Show("CHARACTER_CREATE_FAILURE", _G[showError]);
	end
end

function CharacterCreateMixin:OnShow()
	C_CharacterCreation.SetInCharacterCreate(true);

	local selectedFaction;
	if self.paidServiceType then
		C_CharacterCreation.CustomizeExistingCharacter(self.paidServiceCharacterID);
		self.currentPaidServiceName = C_PaidServices.GetName();
		selectedFaction = C_PaidServices.GetCurrentFaction();
		NameChoiceFrame.EditBox:SetText(self.currentPaidServiceName);
	else
		self.currentPaidServiceName = nil;
		C_CharacterCreation.ResetCharCustomize();
		NameChoiceFrame.EditBox:SetText("");
	end

	local instantRotate = true;
	self:SetMode(CHAR_CREATE_MODE_CLASS_RACE, instantRotate);

	RaceAndClassFrame:UpdateState(selectedFaction);
end

function CharacterCreateMixin:OnHide()
	C_CharacterCreation.SetInCharacterCreate(false);
	self:ClearPaidServiceInfo();
	self.currentMode = 0;
end

function CharacterCreateMixin:SetPaidServiceInfo(serviceType, characterID)
	self.paidServiceType = serviceType;
	self.paidServiceCharacterID = characterID;
end

function CharacterCreateMixin:ClearPaidServiceInfo()
	self.paidServiceType = nil;
	self.paidServiceCharacterID = nil;
end

function CharacterCreateMixin:OnMouseDown(button)
	if not RaceAndClassFrame:IsPlayingClassAnimtion() then
		self.lastCursorPosX = GetCursorPosition();
		self.mouseRotating = true;
		self:SetScript("OnUpdate", self.OnUpdateMouseRotate);
	end
end

function CharacterCreateMixin:OnMouseUp(button)
	self:SetScript("OnUpdate", nil);
	self.mouseRotating = false;
end

function CharacterCreateMixin:OnKeyDown(key)
	if key == "ESCAPE" then
		self:NavBack();
	elseif key == "ENTER" then
		self:NavForward();
	elseif key == "PRINTSCREEN" then
		Screenshot();
	end
end

function CharacterCreateMixin:OnUpdateMouseRotate()
	local x = GetCursorPosition();
	if x ~= self.lastCursorPosX then
		RaceAndClassFrame.allowClassAnimationsAfterSeconds = nil;

		local diff = (x - self.lastCursorPosX) * CHARACTER_ROTATION_CONSTANT;
		C_CharacterCreation.SetCharacterCreateFacing(C_CharacterCreation.GetCharacterCreateFacing() + diff);

		self.lastCursorPosX = x;
	end
end

function CharacterCreateMixin:UpdateBackgroundModel()
	local bgModelID = C_CharacterCreation.GetCreateBackgroundModel();
	if bgModelID ~= self.bgModelID then
		C_CharacterCreation.SetCharCustomizeBackground(bgModelID);
		ResetModel(self);
		self.bgModelID = bgModelID;
		return true;
	end

	return false;
end

local classBGAlphaValues = {
	DEATHKNIGHT = 0.5,
};

local raceBGAlphaValues = {
	Pandaren = 0.75,
};

local factionBGAlphaValues = {
	Horde = 0.6,
};

function CharacterCreateMixin:UpdateBackgroundOverlays(selectedClassData, selectedRaceData)
	local alphaAmount = 1;
	if classBGAlphaValues[selectedClassData.fileName] then
		alphaAmount = classBGAlphaValues[selectedClassData.fileName];
	elseif raceBGAlphaValues[selectedRaceData.fileName] then
		alphaAmount = raceBGAlphaValues[selectedRaceData.fileName];
	elseif factionBGAlphaValues[selectedRaceData.factionInternalName] then
		alphaAmount = factionBGAlphaValues[selectedRaceData.factionInternalName];
	end

	self.BottomBackgroundOverlay.FadeOut:Stop();
	self.BottomBackgroundOverlay.FadeIn:Stop();

	for _, texture in ipairs(self.BGTex) do
		texture:SetAlpha(alphaAmount);
	end

	self.BottomBackgroundOverlay.FadeOut.AlphaAnim:SetFromAlpha(alphaAmount);
	self.BottomBackgroundOverlay.FadeIn.AlphaAnim:SetToAlpha(alphaAmount);
end

function CharacterCreateMixin:UpdateCharCustomizationFrame(alsoReset)
	local customizationCategoryData = C_CharacterCreation.GetAvailableCustomizations();
	if not customizationCategoryData then
		-- This means we are calling GetAvailableCustomizations when there is no character component set up. Do nothing
		return;
	end

	if alsoReset then
		CharCustomizeFrame:Reset();
	end

	CharCustomizeFrame:SetCustomizations(customizationCategoryData);
end

local raceZoneChoiceZoomAmounts = {
	Gnome = 50,
	Pandaren = 50,
};

local factionZoneChoiceZoomAmounts = {
	Horde = 50,
};

function CharacterCreateMixin:EnableZoneChoiceMode(enable)
	local zoomAmount = ZONE_CHOICE_ZOOM_AMOUNT;
	if raceZoneChoiceZoomAmounts[RaceAndClassFrame.selectedRaceData.fileName] then
		zoomAmount = raceZoneChoiceZoomAmounts[RaceAndClassFrame.selectedRaceData.fileName];
	elseif factionZoneChoiceZoomAmounts[RaceAndClassFrame.selectedRaceData.factionInternalName] then
		zoomAmount = factionZoneChoiceZoomAmounts[RaceAndClassFrame.selectedRaceData.factionInternalName];
	end

	local force = true;
	self:ZoomCamera(enable and zoomAmount or -zoomAmount, ZOOM_TIME_SECONDS, force);

	if enable then
		C_CharacterCreation.SetModelsHiddenState(true);
	else
		C_Timer.After(ZOOM_TIME_SECONDS, function() C_CharacterCreation.SetModelsHiddenState(false); end);
	end
end

function CharacterCreateMixin:SetMode(mode, instantRotate)
	self:ResetCharacterRotation(mode, instantRotate);

	if self.currentMode == mode then
		return;
	end

	if mode == CHAR_CREATE_MODE_CLASS_RACE then
		RaceAndClassFrame.allowClassAnimationsAfterSeconds = CLASS_ANIM_WAIT_TIME_SECONDS;

		C_CharacterCreation.SetViewingAlteredForm(false);

		if self.currentMode == CHAR_CREATE_MODE_CUSTOMIZE then
			local useBlending = true;
			RaceAndClassFrame:PlayClassIdleAnimation(useBlending);
		end
		
		RaceAndClassFrame:PlayClassAnimations();

		C_CharacterCreation.SetBlurEnabled(false);

		self:SetCameraZoomLevel(0);
		self:SetModelDressState(true);
		C_CharacterCreation.SetSelectedPreviewGearType(Enum.PreviewGearType.Awesome);

		if self.currentMode == CHAR_CREATE_MODE_CUSTOMIZE then
			self.BottomBackgroundOverlay.FadeIn:Play();
		end
	elseif mode == CHAR_CREATE_MODE_CUSTOMIZE then
		if self.currentMode == CHAR_CREATE_MODE_CLASS_RACE then
			RaceAndClassFrame:PlayCustomizationAnimation();

			C_CharacterCreation.SetBlurEnabled(true);
			C_CharacterCreation.SetSelectedPreviewGearType(Enum.PreviewGearType.Starting);

			self.BottomBackgroundOverlay.FadeOut:Play();

			CharCustomizeFrame:SetSelectedData(RaceAndClassFrame.selectedRaceData, RaceAndClassFrame.selectedSexID, C_CharacterCreation.IsViewingAlteredForm());

			-- We are entering customize mode. Grab the customizations for the selected race & sex and send it to CharCustomizeFrame before showing it
			local reset = true;
			self:UpdateCharCustomizationFrame(reset);

			ClassTrialSpecs:SetClass(RaceAndClassFrame.selectedClassID, RaceAndClassFrame.selectedSexID);
			ZoneChoiceFrame:Setup();
		else
			self:EnableZoneChoiceMode(false);
		end
	else
		self:EnableZoneChoiceMode(true);
	end

	RaceAndClassFrame:SetShown(mode == CHAR_CREATE_MODE_CLASS_RACE);
	CharCustomizeFrame:SetShown(mode == CHAR_CREATE_MODE_CUSTOMIZE);
	ClassTrialSpecs:SetShown(mode == CHAR_CREATE_MODE_CUSTOMIZE and (C_CharacterCreation.GetCharacterCreateType() == Enum.CharacterCreateType.TrialBoost));
	NameChoiceFrame:SetShown(mode == CHAR_CREATE_MODE_CUSTOMIZE);
	ZoneChoiceFrame:SetShown(mode == CHAR_CREATE_MODE_ZONE_CHOICE);

	self.currentMode = mode;
	self:UpdateForwardButton();
end

function CharacterCreateMixin:UpdateMode(offset)
	self:SetMode(Clamp(self.currentMode + offset, CHAR_CREATE_MODE_CLASS_RACE, CHAR_CREATE_MODE_ZONE_CHOICE))
end

function CharacterCreateMixin:NavBack()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CANCEL);
	if self.currentMode == CHAR_CREATE_MODE_CLASS_RACE then
		if( IsKioskGlueEnabled() ) then
			GlueParent_SetScreen("kioskmodesplash");
		else
			if CharacterUpgrade_IsCreatedCharacterTrialBoost() then
				CharacterUpgrade_ResetBoostData();
			end

			CharacterSelect.backFromCharCreate = true;
			GlueParent_SetScreen("charselect");
		end
	else
		self:UpdateMode(-1);
	end
end

local function SortBlockers(a, b)
	return a.priority < b.priority;
end

local HIGH_PRIORITY = 1;
local MEDIUM_PRIORITY = 2;
local LOW_PRIORITY = 3;

function CharacterCreateMixin:AddNavBlocker(navBlocker, priority)
	for i, currentBlocker in ipairs(self.navBlockers) do
		if currentBlocker.error == navBlocker then
			-- This blocker is already in there, do nothing
			return;
		end
	end

	table.insert(self.navBlockers, {error = navBlocker, priority = priority or MEDIUM_PRIORITY});
	table.sort(self.navBlockers, SortBlockers);

	self:RefreshCurrentNavBlocker();
end

function CharacterCreateMixin:RemoveNavBlocker(navBlocker)
	for i, currentBlocker in ipairs(self.navBlockers) do
		if currentBlocker.error == navBlocker then
			table.remove(self.navBlockers, i);
			self:RefreshCurrentNavBlocker();
			return;
		end
	end
end

function CharacterCreateMixin:RefreshCurrentNavBlocker()
	self.currentNavBlocker = self.navBlockers[1];
	self:UpdateForwardButton();
end

function CharacterCreateMixin:CanNavForward()
	return not self.currentNavBlocker;
end

function CharacterCreateMixin:GetSelectedName()
	return NameChoiceFrame.EditBox:GetText();
end

function CharacterCreateMixin:GetCreateCharacterFaction()
	return RaceAndClassFrame:GetCreateCharacterFaction();
end

function CharacterCreateMixin:CreateCharacter()
	if self.paidServiceType then
		GlueDialog_Show("CONFIRM_PAID_SERVICE");
	else
		if Kiosk.IsEnabled() then
			KioskModeSplash:SetAutoEnterWorld(true);
		end

		C_CharacterCreation.CreateCharacter(self:GetSelectedName(), ZoneChoiceFrame.useNPE, RaceAndClassFrame:GetCreateCharacterFaction());
	end
end

function CharacterCreateMixin:SetCustomizationChoice(optionID, choiceID)
	C_CharacterCreation.SetCustomizationChoice(optionID, choiceID);

	-- When a customization choice is made, that may force other options to change (if the current choices are no longer valid)
	-- So grab all the latest data and update CharCustomizationFrame
	self:UpdateCharCustomizationFrame();
end

function CharacterCreateMixin:PreviewCustomizationChoice(optionID, choiceID)
	-- It is important that we DON'T call UpdateCharCustomizationFrame here because we want to keep the current selections
	C_CharacterCreation.SetCustomizationChoice(optionID, choiceID);
end

function CharacterCreateMixin:SetCameraZoomLevel(zoomLevel, keepCustomZoom)
	C_CharacterCreation.SetCameraZoomLevel(zoomLevel, keepCustomZoom);
end

function CharacterCreateMixin:SetModelDressState(dressedState)
	C_CharacterCreation.SetModelDressState(dressedState);
end

function CharacterCreateMixin:SetViewingAlteredForm(viewingAlteredForm)
	C_CharacterCreation.SetViewingAlteredForm(viewingAlteredForm);
	self:UpdateCharCustomizationFrame();
end

function CharacterCreateMixin:GetTargetRotation(mode)
	return 0;
end

function CharacterCreateMixin:ResetCharacterRotation(mode, instantRotate)
	self:RotateCharacterToTarget(self:GetTargetRotation(mode or self.currentMode), instantRotate and 0 or ROTATION_ADJUST_SECONDS);
end

function CharacterCreateMixin:ZoomCamera(zoomAmount, zoomTime, force)
	C_CharacterCreation.ZoomCamera(zoomAmount, zoomTime or ZOOM_TIME_SECONDS, force or false);
end

function CharacterCreateMixin:GetCurrentCameraZoom()
	return C_CharacterCreation.GetCurrentCameraZoom();
end

function CharacterCreateMixin:RotateCharacter(rotationAmount)
	C_CharacterCreation.SetCharacterCreateFacing(C_CharacterCreation.GetCharacterCreateFacing() + rotationAmount);
end

function CharacterCreateMixin:RotateCharacterToTarget(targetRotation, duration)
	if not self.mouseRotating then
		local currentRotation = C_CharacterCreation.GetCharacterCreateFacing();
		if targetRotation == currentRotation then
			return;
		end

		if duration == 0 then
			C_CharacterCreation.SetCharacterCreateFacing(targetRotation);
			return;
		end

		local rotationDiff = targetRotation - currentRotation;
		self.isRotationNegative = (rotationDiff < 0);
		self.perSecondRotation = rotationDiff / duration;
		self.targetRotation = targetRotation;
		self:SetScript("OnUpdate", self.OnUpdateRotateCharacterToTarget);
	end
end

function CharacterCreateMixin:OnUpdateRotateCharacterToTarget(elapsed)
	local rotateAmount = self.perSecondRotation * elapsed;
	local currentRotation = C_CharacterCreation.GetCharacterCreateFacing();
	local newRotation = currentRotation + rotateAmount;
	local reachedTarget = false;
	if self.isRotationNegative then
		reachedTarget = (newRotation <= self.targetRotation);
	else
		reachedTarget = (newRotation >= self.targetRotation);
	end
	if reachedTarget then
		C_CharacterCreation.SetCharacterCreateFacing(self.targetRotation);
		self:SetScript("OnUpdate", nil);
	else
		C_CharacterCreation.SetCharacterCreateFacing(newRotation);
	end
end

function CharacterCreateMixin:RandomizeAppearance()
	C_CharacterCreation.RandomizeCharCustomization();
	self:UpdateCharCustomizationFrame();
end

function CharacterCreateMixin:NavForward()
	if self:CanNavForward() then
		if self.currentMode == CHAR_CREATE_MODE_CLASS_RACE then
			PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_CREATE_NEW);
			self:UpdateMode(1);
		elseif self.currentMode == CHAR_CREATE_MODE_CUSTOMIZE and ZoneChoiceFrame:ShouldShow() then
			PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_CREATE_NEW);
			self:UpdateMode(1);
		else
			PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CREATE_CHAR);
			self:CreateCharacter();
			self.ForwardButton:SetEnabled(false);
		end
	end
end

function CharacterCreateMixin:UpdateForwardButton()
	if self.currentMode == CHAR_CREATE_MODE_CLASS_RACE then
		self.ForwardButton:UpdateText(CUSTOMIZE, FORWARD_ARROW);
	elseif self.currentMode == CHAR_CREATE_MODE_CUSTOMIZE then
		if ZoneChoiceFrame:ShouldShow() then
			self.ForwardButton:UpdateText(NEXT, FORWARD_ARROW);
		else
			self.ForwardButton:UpdateText(FINISH);
		end
	else
		self.ForwardButton:UpdateText(FINISH);
	end

	self.ForwardButton:SetEnabled(self:CanNavForward());
end

CharacterCreateNavButtonMixin = {};

function CharacterCreateNavButtonMixin:GetAppropriateTooltip()
	return CharCustomizeNoHeaderTooltip;
end

function CharacterCreateNavButtonMixin:UpdateText(text, arrow)
	if arrow == FORWARD_ARROW then
		self:SetFormattedText("%s  %s", text, CreateAtlasMarkup("common-icon-forwardarrow", 8, 13, 0, 0));
	elseif arrow == BACKWARD_ARROW then
		self:SetFormattedText("%s  %s", CreateAtlasMarkup("common-icon-backarrow", 8, 13, 0, 0), text);
	else
		self:SetText(text);
	end
end

function CharacterCreateNavButtonMixin:OnClick(button)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	CharacterCreateFrame[self.charCreateOnClickMethod](CharacterCreateFrame, button);
end

CharacterCreateSexButtonMixin = CreateFromMixins(CharCustomizeMaskedButtonMixin);

function CharacterCreateSexButtonMixin:SetSex(sexID, selectedSexID, layoutIndex)
	self.sexID = sexID;
	self.layoutIndex = layoutIndex;

	self:ClearTooltipLines();

	if sexID == Enum.Unitsex.Male then
		self:AddTooltipLine(MALE);
	else
		self:AddTooltipLine(FEMALE);
	end

	local atlas = GetGenderAtlas(sexID);
	self:SetNormalAtlas(atlas);
	self:SetPushedAtlas(atlas);

	if selectedSexID == sexID then
		self:SetChecked(true);
	else
		self:SetChecked(false);
	end

	self:UpdateHighlightTexture();
end

function CharacterCreateSexButtonMixin:OnClick()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
	RaceAndClassFrame:SetCharacterSex(self.sexID);
end

CharacterCreateClassButtonMixin = CreateFromMixins(CharCustomizeMaskedButtonMixin);

local classLayoutIndices = {
	WARRIOR = 1,
	HUNTER = 2,
	MAGE = 3,
	ROGUE = 4,
	PRIEST = 5,
	WARLOCK = 6,
	PALADIN = 7,
	DRUID = 8,
	SHAMAN = 9,
	MONK = 10,
	DEMONHUNTER = 11,
	DEATHKNIGHT = 12,
};

function CharacterCreateClassButtonMixin:SetClass(classData, selectedClassID)
	self.classData = classData;
	self.layoutIndex = classLayoutIndices[classData.fileName];

	local atlas = GetClassAtlas(strlower(classData.fileName));
	self:SetNormalAtlas(atlas);
	self:SetPushedAtlas(atlas);

	local buttonEnabled;
	if CharacterCreateFrame.paidServiceType then
		buttonEnabled = (selectedClassID == classData.classID);
	else
		buttonEnabled = classData.enabled;
	end

	self:SetEnabledState(buttonEnabled);
	self.ClassName:SetText(classData.name);

	self:ClearTooltipLines();
	self:AddTooltipLine(_G["CLASS_"..classData.fileName.."_2"]);
	self:AddBlankTooltipLine();
	self:AddTooltipLine(_G["CLASS_INFO_"..classData.fileName.."_ROLE_TT"]);

	local tooltipDisabledReason;
	if not classData.enabled then
		if classData.disabledReason == Enum.CreationClassDisabledReason.DoesNotHaveExpansion then
			tooltipDisabledReason = CHAR_CREATE_NEED_EXPANSION;
		elseif classData.disabledReason == Enum.CreationClassDisabledReason.InvalidForTemplates then
			tooltipDisabledReason = CHAR_CREATE_CLASS_DISABLED_TEMPLATE;
		elseif classData.disabledReason == Enum.CreationClassDisabledReason.InvalidForNewPlayers then
			tooltipDisabledReason = CHAR_CREATE_NEW_PLAYER;
		elseif classData.disabledReason == Enum.CreationClassDisabledReason.InvalidForSelectedRace then
			local validRaces = C_CharacterCreation.GetValidRacesForClass(classData.classID, Enum.CharacterCreateRaceMode.AllRaces);
			local validRaceNames = {};
			for i, raceData in ipairs(validRaces) do
				tinsert(validRaceNames, raceData.name);
			end
			local validRaceConcat = table.concat(validRaceNames, ", ");
			tooltipDisabledReason = CLASS_DISABLED.."|n|n"..validRaceConcat;
		else
			if classData.fileName and _G[classData.fileName.."_DISABLED"] then
				tooltipDisabledReason = _G[classData.fileName.."_DISABLED"];
			else
				tooltipDisabledReason = CHAR_CREATE_CLASS_DISABLED_GENERIC;
			end
		end
	end

	if tooltipDisabledReason then
		self:AddBlankTooltipLine();
		self:AddTooltipLine(tooltipDisabledReason, RED_FONT_COLOR);
	end

	if showDebugTooltipInfo then
		self:AddBlankTooltipLine();
		self:AddTooltipLine("Class ID: "..classData.classID, HIGHLIGHT_FONT_COLOR);
	end

	if selectedClassID == classData.classID then
		self:SetChecked(true);
	else
		self:SetChecked(false);
	end

	self:UpdateHighlightTexture();
end

function CharacterCreateClassButtonMixin:OnClick()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
	RaceAndClassFrame:SetCharacterClass(self.classData.classID);
end

function CharacterCreateClassButtonMixin:SetEnabledState(enabled)
	CharCustomizeMaskedButtonMixin.SetEnabledState(self, enabled);
	self.ClassName:SetFontObject(enabled and "GameFontNormalMed3" or "GameFontDisableMed3");
end

CharacterCreateRaceButtonMixin = CreateFromMixins(CharCustomizeFrameWithExpandableTooltipMixin, CharCustomizeMaskedButtonMixin);

function CharacterCreateRaceButtonMixin:GetAppropriateTooltip()
	return CharCustomizeTooltip;
end

function CharacterCreateRaceButtonMixin:AddExtraStuffToTooltip()
	CharCustomizeFrameWithExpandableTooltipMixin.AddExtraStuffToTooltip(self);

	if showDebugTooltipInfo then
		local tooltip = self:GetAppropriateTooltip();
		GameTooltip_AddBlankLineToTooltip(tooltip);
		GameTooltip_AddHighlightLine(tooltip, "Race ID: "..self.raceData.raceID);
	end
end

function CharacterCreateRaceButtonMixin:SetRace(raceData, selectedSexID, selectedRaceID, selectedFaction, layoutIndex)
	self.raceData = raceData;
	self.layoutIndex = layoutIndex;

	local sexString;
	if selectedSexID == Enum.Unitsex.Male then
		sexString = "male";
	else
		sexString = "female";
	end

	local useHiRez = true;
	local atlas = GetRaceAtlas(strlower(raceData.fileName), sexString, useHiRez);
	self:SetNormalAtlas(atlas);
	self:SetPushedAtlas(atlas);

	self:SetEnabledState(RaceAndClassFrame:IsRaceValid(raceData, self.faction));

	self:ClearTooltipLines();
	self:AddTooltipLine(raceData.name, HIGHLIGHT_FONT_COLOR);
	self:AddBlankTooltipLine();
	self:AddTooltipLine(raceData.loreDescription);

	self:AddExpandedTooltipFrame(RaceAndClassFrame.RacialAbilityList);

	if selectedRaceID == raceData.raceID and selectedFaction == self.faction then
		self:SetChecked(true);
	else
		self:SetChecked(false);
	end

	self:UpdateHighlightTexture();
end

function CharacterCreateRaceButtonMixin:OnEnter()
	RaceAndClassFrame.RacialAbilityList:SetupRacialAbilties(self.raceData.racialAbilities);
	CharCustomizeFrameWithExpandableTooltipMixin.OnEnter(self);
end

function CharacterCreateRaceButtonMixin:OnClick()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
	RaceAndClassFrame:SetCharacterRace(self.raceData.raceID, self.faction);
end

CharacterCreateSpecButtonMixin = CreateFromMixins(CharCustomizeMaskedButtonMixin);

function CharacterCreateSpecButtonMixin:SetSpec(specData, selectedSpecID, layoutIndex)
	self.specData = specData;
	self.layoutIndex = layoutIndex;

	self:SetNormalTexture(specData.icon);
	self:SetPushedTexture(specData.icon);

	self:SetEnabledState(specData.isRecommended or specData.isAllowed);

	if specData.isRecommended then
		self.SpecName:SetText(RECOMMENDED_CHAR_SPEC:format(specData.name));
	else
		self.SpecName:SetText(specData.name);
	end
	self.RoleName:SetText(_G["ROLE_"..specData.role]);

	self:ClearTooltipLines();
	self:AddTooltipLine(specData.name, HIGHLIGHT_FONT_COLOR);
	self:AddTooltipLine(specData.description);

	if not self:IsEnabled() then
		self:AddBlankTooltipLine();
		self:AddTooltipLine(CLASS_TRIAL_RECOMMENDED_SPEC_ONLY, RED_FONT_COLOR);
	end

	if showDebugTooltipInfo then
		self:AddBlankTooltipLine();
		self:AddTooltipLine("Spec ID: "..specData.specID, HIGHLIGHT_FONT_COLOR);
	end

	if selectedSpecID == specData.specID then
		self:SetChecked(true);
	else
		self:SetChecked(false);
	end

	self:UpdateHighlightTexture();
end

function CharacterCreateSpecButtonMixin:GetAppropriateTooltip()
	return CharCustomizeTooltip;
end

function CharacterCreateSpecButtonMixin:OnClick()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
	ClassTrialSpecs:SetSelectedSpec(self.specData.specID);
end

function CharacterCreateSpecButtonMixin:SetEnabledState(enabled)
	CharCustomizeMaskedButtonMixin.SetEnabledState(self, enabled);
	self.SpecName:SetFontObject(enabled and "GameFontNormalMed3" or "GameFontDisableMed3");
	self.RoleName:SetFontObject(enabled and "GameFontHighlight" or "GameFontDisable");
end

CharacterCreateRaceAndClassMixin = {}

function CharacterCreateRaceAndClassMixin:OnLoad()
	-- Choose a random faction to be used if Pandaren is chosen as the random race
	local randomFaction = math.random(0, 1);
	self.selectedFaction = PLAYER_FACTION_GROUP[randomFaction];

	self.AllianceHeader.Text:SetText(string.upper(FACTION_ALLIANCE));
	self.AllianceHeader:AddTooltipLine(CHOOSE_THE_ALLIANCE);

	self.HordeHeader.Text:SetText(string.upper(FACTION_HORDE));
	self.HordeHeader:AddTooltipLine(CHOOSE_THE_HORDE);

	self.ClassTrialCheckButton.Button:SetScript("OnEnter", function() self.ClassTrialCheckButton.OnEnter(self.ClassTrialCheckButton); end);
	self.ClassTrialCheckButton.Button:SetScript("OnLeave", function() self.ClassTrialCheckButton.OnLeave(self.ClassTrialCheckButton); end);

	self.buttonPool = CreateFramePoolCollection();
	self.buttonPool:CreatePool("CHECKBUTTON", self.Sexes, "CharacterCreateSexButtonTemplate");
	self.buttonPool:CreatePool("CHECKBUTTON", self.AllianceRaces, "CharacterCreateAllianceButtonTemplate");
	self.buttonPool:CreatePool("CHECKBUTTON", self.AllianceAlliedRaces, "CharacterCreateAllianceAlliedRaceButtonTemplate");
	self.buttonPool:CreatePool("CHECKBUTTON", self.HordeRaces, "CharacterCreateHordeButtonTemplate");
	self.buttonPool:CreatePool("CHECKBUTTON", self.HordeAlliedRaces, "CharacterCreateHordeAlliedRaceButtonTemplate");
	self.buttonPool:CreatePool("CHECKBUTTON", self.Classes, "CharacterCreateClassButtonTemplate");
end

function CharacterCreateRaceAndClassMixin:GetCreateCharacterFaction()
	if self.ClassTrialCheckButton.Button:GetChecked() then
		-- Class Trials need to use no faction...their faction choice is sent up separately after the character is created
		return nil;
	elseif self.selectedRaceData.isNeutralRace then
		if C_CharacterCreation.IsUsingCharacterTemplate() or self.selectedClassData.earlyFactionChoice or ZoneChoiceFrame.useNPE or CharacterCreateFrame.paidServiceType then
			-- For neutral races, if the player is using a character template, selected an earlyFactionChoice class (DK) or chose to start in the NPE we need to pass back the selected faction
			return self.selectedFaction;
		else
			-- Otherwise they start as neutral so pass back nil
			return nil;
		end
	else
		return self.selectedFaction;
	end
end

function CharacterCreateRaceAndClassMixin:GetBoostCharacterFactionID()
	return PLAYER_FACTION_GROUP[self.selectedFaction];
end

function CharacterCreateRaceAndClassMixin:OnShow()
	local isNewPlayerRestricted = C_CharacterCreation.IsNewPlayerRestricted();
	self.AllianceAlliedRaces:SetShown(not isNewPlayerRestricted);
	self.HordeAlliedRaces:SetShown(not isNewPlayerRestricted);

	self.ClassTrialCheckButton:ClearTooltipLines();
	self.ClassTrialCheckButton:AddTooltipLine(CHARACTER_TYPE_FRAME_TRIAL_BOOST_CHARACTER_TOOLTIP:format(C_CharacterCreation.GetTrialBoostStartingLevel()));
	self.ClassTrialCheckButton:SetShown(not isNewPlayerRestricted and not CharacterCreateFrame.paidServiceType);
end

function CharacterCreateRaceAndClassMixin:OnHide()
	self:DestroyTargetDummies();
end

function CharacterCreateRaceAndClassMixin:SetupTargetDummies()
end

function CharacterCreateRaceAndClassMixin:DestroyTargetDummies()
end

function CharacterCreateRaceAndClassMixin:PlayClassAnimations()
end

function CharacterCreateRaceAndClassMixin:StopClassAnimations()
	C_CharacterCreation.StopAllSpellVisualKitsOnCharacter();
end

function CharacterCreateRaceAndClassMixin:OnAnimKitFinished(animKitID, spellVisualKitID)
end

function CharacterCreateRaceAndClassMixin:PlayClassIdleAnimation(useBlending)
	self:StopClassAnimations();
	C_CharacterCreation.PlayClassIdleAnimationOnCharacter(not useBlending);
end

function CharacterCreateRaceAndClassMixin:PlayCustomizationAnimation()
	self:StopClassAnimations();
	C_CharacterCreation.PlayCustomizationIdleAnimationOnCharacter();
end

function CharacterCreateRaceAndClassMixin:IsPlayingClassAnimtion()
	return false;
end

function CharacterCreateRaceAndClassMixin:ClearCurrentSpellVisualKit()
end

function CharacterCreateRaceAndClassMixin:UpdateState(selectedFaction)
	self.selectedRaceID = C_CharacterCreation.GetSelectedRace();
	self.selectedRaceData = C_CharacterCreation.GetRaceDataByID(self.selectedRaceID);

	if selectedFaction then
		self.selectedFaction = selectedFaction;
	elseif not self.selectedRaceData.isNeutralRace then
		self.selectedFaction = self.selectedRaceData.factionInternalName;
	end

	if not self:IsRaceValid(self.selectedRaceData, self.selectedFaction) then
		local randomRaceData = self:GetRandomValidRaceData();
		self:SetCharacterRace(randomRaceData.raceID, randomRaceData.factionInternalName)
		return;
	end

	self.selectedClassData = C_CharacterCreation.GetSelectedClass();
	self.selectedClassID = self.selectedClassData.classID;
	self.selectedSexID = C_CharacterCreation.GetSelectedSex();

	local usingNewBGModel = CharacterCreateFrame:UpdateBackgroundModel();
	CharacterCreateFrame:UpdateBackgroundOverlays(self.selectedClassData, self.selectedRaceData);

	CharacterCreateFrame:RemoveNavBlocker(CHAR_FACTION_CHANGE_SWAP_FACTION);
	CharacterCreateFrame:RemoveNavBlocker(CHAR_FACTION_CHANGE_CHOOSE_RACE);
	self:UpdateButtons();
end

function CharacterCreateRaceAndClassMixin:SetCharacterRace(raceID, faction)
	if self.selectedRaceID ~= raceID then
		CharacterCreateFrame:ResetCharacterRotation();
		self.allowClassAnimationsAfterSeconds = CLASS_ANIM_WAIT_TIME_SECONDS;
		self:ClearCurrentSpellVisualKit();
		C_CharacterCreation.SetSelectedRace(raceID);
	end

	self:UpdateState(faction);
end

function CharacterCreateRaceAndClassMixin:SetCharacterClass(classID)
	self.allowClassAnimationsAfterSeconds = 0;
	if self.selectedClassID ~= classID then
		self:ClearCurrentSpellVisualKit();
		C_CharacterCreation.SetSelectedClass(classID);
	elseif not self:IsPlayingClassAnimtion() then
		self:ClearCurrentSpellVisualKit();
		self:PlayClassAnimations();
	end

	self:UpdateState();
end

function CharacterCreateRaceAndClassMixin:SetCharacterSex(sexID)
	if self.selectedSexID ~= sexID  then
		CharacterCreateFrame:ResetCharacterRotation();
		self.allowClassAnimationsAfterSeconds = CLASS_ANIM_WAIT_TIME_SECONDS;
		self:ClearCurrentSpellVisualKit();
		C_CharacterCreation.SetSelectedSex(sexID);
	end

	self:UpdateState();
end

function CharacterCreateRaceAndClassMixin:GetRaceButtonTemplates(raceData)
	if raceData.isNeutralRace then
		if raceData.isAlliedRace then
			return "CharacterCreateAllianceAlliedRaceButtonTemplate", "CharacterCreateHordeAlliedRaceButtonTemplate";
		else
			return "CharacterCreateAllianceButtonTemplate", "CharacterCreateHordeButtonTemplate";
		end
	elseif raceData.factionInternalName == "Alliance" then
		return raceData.isAlliedRace and "CharacterCreateAllianceAlliedRaceButtonTemplate" or "CharacterCreateAllianceButtonTemplate"
	else
		return raceData.isAlliedRace and "CharacterCreateHordeAlliedRaceButtonTemplate" or "CharacterCreateHordeButtonTemplate"
	end
end

function CharacterCreateRaceAndClassMixin:LayoutButtons()
	self.Sexes:MarkDirty();
	self.AllianceRaces:MarkDirty();
	self.AllianceAlliedRaces:MarkDirty();
	self.HordeRaces:MarkDirty();
	self.HordeAlliedRaces:MarkDirty();
	self.Classes:MarkDirty();
end

function CharacterCreateRaceAndClassMixin:IsRaceValid(raceData, faction)
	if not raceData.enabled then
		return false;
	end

	if CharacterCreateFrame.paidServiceType == PAID_CHARACTER_CUSTOMIZATION then
		local notForPaidService = false;
		local currentRace = C_PaidServices.GetCurrentRaceID(notForPaidService);
		local currentFaction = C_PaidServices.GetCurrentFaction();
		return (currentRace == raceData.raceID and currentFaction == faction);
	elseif CharacterCreateFrame.paidServiceType == PAID_FACTION_CHANGE then
		local currentFaction = C_PaidServices.GetCurrentFaction();
		local currentClass = C_PaidServices.GetCurrentClassID();
		return (currentFaction ~= faction and C_CharacterCreation.IsRaceClassValid(raceData.raceID, currentClass));
	elseif CharacterCreateFrame.paidServiceType == PAID_RACE_CHANGE then
		local currentFaction = C_PaidServices.GetCurrentFaction();
		local notForPaidService = false;
		local currentRace = C_PaidServices.GetCurrentRaceID(notForPaidService);
		local currentClass = C_PaidServices.GetCurrentClassID();
		return (currentFaction == faction and currentRace ~= raceData.raceID and C_CharacterCreation.IsRaceClassValid(raceData.raceID, currentClass));
	end

	return true;
end

function CharacterCreateRaceAndClassMixin:GetAllValidRaces()
	local validRaces = {};

	local races = C_CharacterCreation.GetAvailableRaces(Enum.CharacterCreateRaceMode.AllRaces);
	for _, raceData in ipairs(races) do
		if self:IsRaceValid(raceData, raceData.factionInternalName) then
			table.insert(validRaces, raceData);
		end
	end

	return validRaces;
end

function CharacterCreateRaceAndClassMixin:GetRandomValidRaceData()
	local validRaces = self:GetAllValidRaces();
	local randomIndex = math.random(1, #validRaces);
	return validRaces[randomIndex];
end

function CharacterCreateRaceAndClassMixin:UpdateButtons()
	self.buttonPool:ReleaseAll();
	self.frameCount = {};

	local sexes = {Enum.Unitsex.Male, Enum.Unitsex.Female};
	for index, sexID in ipairs(sexes) do
		local button = self.buttonPool:Acquire("CharacterCreateSexButtonTemplate");
		button:SetSex(sexID, self.selectedSexID, index);
		button:Show();
	end

	local races = C_CharacterCreation.GetAvailableRaces(Enum.CharacterCreateRaceMode.AllRaces);
	for _, raceData in ipairs(races) do
		local buttonTemplates = {self:GetRaceButtonTemplates(raceData)};
		for _, buttonTemplate in pairs(buttonTemplates) do
			local button = self.buttonPool:Acquire(buttonTemplate);
			if not button then
				return;
			end

			if not self.frameCount[buttonTemplate] then
				self.frameCount[buttonTemplate] = 1;
			else
				self.frameCount[buttonTemplate] = self.frameCount[buttonTemplate] + 1;
			end

			button:SetRace(raceData, self.selectedSexID, self.selectedRaceID, self.selectedFaction, self.frameCount[buttonTemplate]);
			button:Show();
		end
	end

	local classes = C_CharacterCreation.GetAvailableClasses();
	for _, classData in pairs(classes) do
		local button = self.buttonPool:Acquire("CharacterCreateClassButtonTemplate");
		button:SetClass(classData, self.selectedClassID);
		button:Show();
	end

	self:LayoutButtons();
end

CharacterCreateFactionHeaderMixin = {};

function CharacterCreateFactionHeaderMixin:OnLoad()
	CharCustomizeFrameWithTooltipMixin.OnLoad(self);
end

function CharacterCreateFactionHeaderMixin:SetupAnchors(tooltip)
	if self.tooltipAnchor == "ANCHOR_TOPRIGHT" then
		tooltip:SetOwner(GlueParent, "ANCHOR_NONE");
		tooltip:SetPoint("TOPRIGHT", GlueParent, "TOPRIGHT", -self.tooltipXOffset, self.tooltipYOffset);
	elseif self.tooltipAnchor == "ANCHOR_TOPLEFT" then
		tooltip:SetOwner(GlueParent, "ANCHOR_NONE");
		tooltip:SetPoint("TOPLEFT", GlueParent, "TOPLEFT", self.tooltipXOffset, self.tooltipYOffset);
	else
		tooltip:SetOwner(self, self.tooltipAnchor, self.tooltipXOffset, self.tooltipYOffset);
	end
end

ClassTrialCheckButtonMixin = {};

function ClassTrialCheckButtonMixin:OnShow()
	ResizeCheckButtonMixin.OnShow(self);
	self.Button:SetChecked(C_CharacterCreation.GetCharacterCreateType() == Enum.CharacterCreateType.TrialBoost);
end

function ClassTrialCheckButtonMixin:OnCheckButtonClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	C_CharacterCreation.SetCharacterCreateType(self.Button:GetChecked() and Enum.CharacterCreateType.TrialBoost or Enum.CharacterCreateType.Normal);
end

CharacterCreateFrameRacialAbilityMixin = {};

function CharacterCreateFrameRacialAbilityMixin:SetRacialAbility(racialAbilityData, index)
	self.racialAbilityData = racialAbilityData;
	self.layoutIndex = index + 1;

	self.Icon:SetTexture(racialAbilityData.icon);
	self.Text:SetText(racialAbilityData.description);

	self:Layout();
end

CharacterCreateRacialAbilityListMixin = {}

function CharacterCreateRacialAbilityListMixin:OnLoad()
	self.buttonPool = CreateFramePool("FRAME", self, "CharacterCreateFrameRacialAbilityTemplate");
end

function CharacterCreateRacialAbilityListMixin:SetupRacialAbilties(racialAbilities)
	self.buttonPool:ReleaseAll();

	for index, racialAbilityInfo in ipairs(racialAbilities) do
		local button = self.buttonPool:Acquire();
		button:SetRacialAbility(racialAbilityInfo, index);
		button:Show();
	end

	self:Layout();
end

CharacterCreateEditBoxMixin = {}

function CharacterCreateEditBoxMixin:OnLoad()
	SharedEditBoxMixin.OnLoad(self);
	self:RegisterEvent("RANDOM_CHARACTER_NAME_RESULT");
end

function CharacterCreateEditBoxMixin:OnHide()
	CharacterCreateFrame:RemoveNavBlocker(CHARACTER_CREATION_REQUIREMENTS_PICK_NAME);
end

function CharacterCreateEditBoxMixin:OnEscapePressed()
	CharacterCreateFrame:NavBack();
end

function CharacterCreateEditBoxMixin:OnEnterPressed()
	CharacterCreateFrame:NavForward();
end

function CharacterCreateEditBoxMixin:OnTextChanged()
	local selectedName = self:GetText();
	if selectedName == "" or selectedName == PENDING_RANDOM_NAME then
		CharacterCreateFrame:AddNavBlocker(CHARACTER_CREATION_REQUIREMENTS_PICK_NAME, HIGH_PRIORITY);
		self.NameAvailabilityState:Hide();
	else
		CharacterCreateFrame:RemoveNavBlocker(CHARACTER_CREATION_REQUIREMENTS_PICK_NAME);
		self.NameAvailabilityState:CheckName(selectedName);
	end
end

function CharacterCreateEditBoxMixin:OnEvent(event, ...)
	if event == "RANDOM_CHARACTER_NAME_RESULT" then
		local success, name = ...;
		if not success then
			-- Failed.  Generate a random name locally.
			name = C_CharacterCreation.GenerateRandomName();
		end

		self.NameAvailabilityState.lastRandomName = name;
		self:SetText(name);

		self:GetParent().RandomNameButton.pendingRequest = false;
		PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_LOOK);
	end
end

CharacterCreateNameAvailabilityStateMixin = {};

function CharacterCreateNameAvailabilityStateMixin:OnLoad()
	self:RegisterEvent("CHECK_CHARACTER_NAME_AVAILABILITY_RESULT");
end

function CharacterCreateNameAvailabilityStateMixin:OnHide()
	if self.Timer then
		self.Timer:Cancel();
	end
	
	if self.navBlocker then
		CharacterCreateFrame:RemoveNavBlocker(self.navBlocker);
	end
end

function CharacterCreateNameAvailabilityStateMixin:SetupAnchors(tooltip)
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", self.tooltipXOffset, self.tooltipYOffset);
end

function CharacterCreateNameAvailabilityStateMixin:OnEvent(event, ...)
	local available, checkedName = ...;

	-- First make sure that the checked name is still what is in the box
	if checkedName == self:GetParent():GetText() then
		-- ok they match, so update the state
		self:UpdateState(available, CHAR_CREATE_NAME_IN_USE);
	end
end

local CHECK_NAME_WAIT_TIME_SECONDS = 1;

function CharacterCreateNameAvailabilityStateMixin:CheckName(nameToCheck)
	self:Hide();

	self:UpdateNavBlocker(nil);

	if self.Timer then
		self.Timer:Cancel();
	end

	local function checkName()
		local valid, reason = C_CharacterCreation.IsCharacterNameValid(nameToCheck);
		if not valid then
			self:UpdateState(false, _G[reason]);
			return;
		end

		-- The name is valid, so next request the availability be checked
		C_CharacterCreation.RequestCheckNameAvailability(nameToCheck);
	end

	if nameToCheck == self.lastRandomName or nameToCheck == CharacterCreateFrame.currentPaidServiceName then
		self:UpdateState(true);
	else
		self.Timer = C_Timer.NewTimer(CHECK_NAME_WAIT_TIME_SECONDS, checkName);
	end
end

function CharacterCreateNameAvailabilityStateMixin:UpdateNavBlocker(navBlocker)
	if self.navBlocker then
		CharacterCreateFrame:RemoveNavBlocker(self.navBlocker);
	end

	if self:IsShown() and navBlocker then
		CharacterCreateFrame:AddNavBlocker(navBlocker);
		self.navBlocker = navBlocker;
	else
		self.navBlocker = nil;
	end
end

function CharacterCreateNameAvailabilityStateMixin:UpdateState(available, failureReason)
	self:ClearTooltipLines();

	if available then
		self:AddTooltipLine(CHAR_CREATE_NAME_AVILABLE, GREEN_FONT_COLOR);
		self:SetNormalAtlas("common-icon-checkmark");
		self:SetHighlightAtlas("common-icon-checkmark", "ADD");
		self:SetSize(23, 20);
	else
		self:UpdateNavBlocker(failureReason);
		self:AddTooltipLine(failureReason, RED_FONT_COLOR);
		self:SetNormalAtlas("common-icon-redx");
		self:SetHighlightAtlas("common-icon-redx", "ADD");
		self:SetSize(20, 20);
	end

	self:Show();
end

CharacterCreateRandomNameButtonMixin = {};

function CharacterCreateRandomNameButtonMixin:OnClick()
	if not self.pendingRequest then
		PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_LOOK);
		self:GetParent().EditBox:SetText(PENDING_RANDOM_NAME);
		C_CharacterCreation.RequestRandomName();
		self.pendingRequest = true;
	end
end

CharacterCreateClassTrialSpecsMixin = {};

function CharacterCreateClassTrialSpecsMixin:OnLoad()
	self.specButtonPool = CreateFramePool("CHECKBUTTON", self, "CharacterCreateSpecButtonTemplate");
end

function CharacterCreateClassTrialSpecsMixin:UpdateNavBlocker()
	if self:IsShown() and not self.selectedSpecID then
		CharacterCreateFrame:AddNavBlocker(CHARACTER_CREATION_REQUIREMENTS_PICK_SPEC);
	else
		CharacterCreateFrame:RemoveNavBlocker(CHARACTER_CREATION_REQUIREMENTS_PICK_SPEC);
	end
end

function CharacterCreateClassTrialSpecsMixin:OnHide()
	CharacterCreateFrame:RemoveNavBlocker(CHARACTER_CREATION_REQUIREMENTS_PICK_SPEC);
end

function CharacterCreateClassTrialSpecsMixin:SetClass(selectedClassID, selectedSexID)
	if self.selectedClassID ~= selectedClassID then
		self.selectedClassID = selectedClassID;
		self.selectedSpecID = nil;
	end
	self.selectedSexID = selectedSexID;
	self:UpdateButtons();
end

function CharacterCreateClassTrialSpecsMixin:SetSelectedSpec(selectedSpecID)
	self.selectedSpecID = selectedSpecID;
	self:UpdateButtons();
end

function CharacterCreateClassTrialSpecsMixin:UpdateButtons()
	self.specButtonPool:ReleaseAll();

	local numSpecs = GetNumSpecializationsForClassID(self.selectedClassID);

	for specIndex = 1, numSpecs do
		local button = self.specButtonPool:Acquire();

		local specData = {};
		specData.specID, specData.name, specData.description, specData.icon, specData.role, specData.isRecommended, specData.isAllowed = GetSpecializationInfoForClassID(self.selectedClassID, specIndex, self.selectedSexID + 1);

		button:SetSpec(specData, self.selectedSpecID, specIndex);
		button:Show();
	end

	self:UpdateNavBlocker();
	self:Layout();
end

CharacterCreateZoneChoiceMixin = {}

function CharacterCreateZoneChoiceMixin:OnLoad()
	self.NPEZone:SetZoneInfo(EXILES_REACH, "charactercreate-startingzone-exilesreach");
	self:SetUseNPE(true);
end

function CharacterCreateZoneChoiceMixin:OnShow()
	self.FadeIn:Play();
end

function CharacterCreateZoneChoiceMixin:OnHide()
	self.FadeIn:Stop();
end

function CharacterCreateZoneChoiceMixin:Setup()
	local firstZoneChoiceInfo, secondZoneChoiceInfo = C_CharacterCreation.GetStartingZoneChoices(RaceAndClassFrame.selectedFaction);

	if not secondZoneChoiceInfo or CharacterCreateFrame.paidServiceType then
		self:SetUseNPE(firstZoneChoiceInfo.isNPE);
		self.shouldShow = false;
		return;
	end

	self.shouldShow = true;

	-- If there is more than one choice, the normal starting zone will always be first
	self.NormalStartingZone:SetZoneInfo(firstZoneChoiceInfo.zoneName, firstZoneChoiceInfo.zoneImageAtlas);
end

function CharacterCreateZoneChoiceMixin:ShouldShow()
	return self.shouldShow;
end

function CharacterCreateZoneChoiceMixin:UpdateButtons()
	self.NPEZone.ZoneNameButton.Button:SetChecked(self.useNPE);
	self.NormalStartingZone.ZoneNameButton.Button:SetChecked(not self.useNPE);
end

function CharacterCreateZoneChoiceMixin:SetUseNPE(useNPE)
	self.useNPE = useNPE;
	self:UpdateButtons();
end

CharacterCreateStartingZoneMixin = {};

function CharacterCreateStartingZoneMixin:SetZoneInfo(zoneName, zoneAtlas)
	self.ZoneArt.BGTex:SetAtlas(zoneAtlas);
	self.ZoneNameButton.Label:SetText(zoneName);
end

CharacterCreateStartingZoneArtMixin = {};

function CharacterCreateStartingZoneArtMixin:OnEnter()
	self:GetParent().ZoneNameButton.Button:LockHighlight();
end

function CharacterCreateStartingZoneArtMixin:OnLeave()
	self:GetParent().ZoneNameButton.Button:UnlockHighlight();
end

function CharacterCreateStartingZoneArtMixin:OnClick()
	ZoneChoiceFrame:SetUseNPE(self:GetParent().isNPE);
end

CharacterCreateStartingZoneButtonMixin = {};

function CharacterCreateStartingZoneButtonMixin:OnCheckButtonClick()
	ZoneChoiceFrame:SetUseNPE(self:GetParent().isNPE);
end
