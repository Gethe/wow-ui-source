local showDebugTooltipInfo = GetCVarBool("debugTargetInfo");

local CHAR_CREATE_MODE_CLASS_RACE = 1;
local CHAR_CREATE_MODE_CUSTOMIZE = 2;
local CHAR_CREATE_MODE_ZONE_CHOICE = 3;

local FORWARD_ARROW = true;
local BACKWARD_ARROW = false;
local PENDING_RANDOM_NAME = "...";

local ZONE_CHOICE_ZOOM_AMOUNT = 100;
local ZONE_CHOICE_ZOOM_TIME = 0.6;
local ZOOM_TIME_SECONDS = 0.25;
local ROTATION_ADJUST_SECONDS = 0.25;
local CLASS_ANIM_WAIT_TIME_SECONDS = 3;

local HIGH_PRIORITY = 1;
local MEDIUM_PRIORITY = 2;
local LOW_PRIORITY = 3;

local RaceAndClassFrame;
local NameChoiceFrame;
local ClassTrialSpecs;
local ZoneChoiceFrame;
local NewPlayerTutorial;

local EVOKER_CLASS_ID = 13;
local HUMAN_RADE_ID = 1;
local ORC_RACE_ID = 2;

NineSliceUtil.AddLayout("CharacterCreateThickBorder", {
	TopLeftCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerTopLeft", },
	TopRightCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerTopRight", },
	BottomLeftCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerBottomLeft", },
	BottomRightCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerBottomRight", },
	TopEdge = { atlas = "_UI-Frame-DiamondMetal-EdgeTop", },
	BottomEdge = { atlas = "_UI-Frame-DiamondMetal-EdgeBottom", },
	LeftEdge = { atlas = "!UI-Frame-DiamondMetal-EdgeLeft", },
	RightEdge = { atlas = "!UI-Frame-DiamondMetal-EdgeRight", },
});

GlueDialogTypes["CHARACTER_CREATE_FAILURE"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
    OnAccept = function ()
		if CharacterCreateFrame:IsShown() then
			CharacterCreateFrame:SetMode(CHAR_CREATE_MODE_CUSTOMIZE);
		end
    end,
}

CharacterCreateMixin = CreateFromMixins(CharCustomizeParentFrameBaseMixin);

function CharacterCreateMixin:OnLoad()
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("CHARACTER_CREATION_RESULT");
	self:RegisterEvent("RACE_FACTION_CHANGE_STARTED");
	self:RegisterEvent("RACE_FACTION_CHANGE_RESULT");
	self:RegisterEvent("CUSTOMIZE_CHARACTER_STARTED");
	self:RegisterEvent("CUSTOMIZE_CHARACTER_RESULT");
	self:RegisterEvent("CHAR_CREATE_BEGIN_ANIMATIONS");
	self:RegisterEvent("CHAR_CREATE_ANIM_KIT_FINISHED");
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("STORE_VAS_PURCHASE_ERROR");
	self:RegisterEvent("ASSIGN_VAS_RESPONSE");

	self.LeftBlackBar:SetPoint("TOPLEFT", nil);
	self.RightBlackBar:SetPoint("TOPRIGHT", nil);

	C_CharacterCreation.SetCharCustomizeFrame("CharacterCreateFrame");

	RaceAndClassFrame = self.RaceAndClassFrame;
	NameChoiceFrame = self.NameChoiceFrame;
	ClassTrialSpecs = self.ClassTrialSpecs;
	ZoneChoiceFrame = self.ZoneChoiceFrame;
	NewPlayerTutorial = self.NewPlayerTutorial;

	CharCustomizeFrame:AttachToParentFrame(self);

	self:ResetNavBlockers();

	self.ForwardButton.tooltip = function()
		return self.currentNavBlocker and RED_FONT_COLOR:WrapTextInColorCode(self.currentNavBlocker.error);
	end

	self.BackButton:UpdateText(BACK, BACKWARD_ARROW);

	self:SetSequence(0);
	self:SetCamera(0);
	self:OnDisplaySizeChanged();
end

function CharacterCreateMixin:OnDisplaySizeChanged()
	local width = GetScreenWidth();
	local height = GetScreenHeight();

	local MAX_ASPECT = 16 / 9;
	local currentAspect = width / height;
	local isSuperWideScreen = (currentAspect - MAX_ASPECT) > 0.001;

	self.LeftBackgroundWidescreenOverlay:SetShown(isSuperWideScreen);
	self.RightBackgroundWidescreenOverlay:SetShown(isSuperWideScreen);
end

function CharacterCreateMixin:OnEvent(event, ...)
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

			self.RaceAndClassFrame.ClassTrialCheckButton:ResetDesiredState();
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
		if self:IsMode(CHAR_CREATE_MODE_CLASS_RACE) then
			RaceAndClassFrame:PlayClassAnimations();
		else
			RaceAndClassFrame:PlayCustomizationAnimation();
		end
	elseif event == "CHAR_CREATE_ANIM_KIT_FINISHED" then
		local animKitID, spellVisualKitID = ...;
		RaceAndClassFrame:OnAnimKitFinished(animKitID, spellVisualKitID);
	elseif event == "CVAR_UPDATE" then
		local cvarName, cvarValue = ...;
		if cvarName == "debugTargetInfo" then
			showDebugTooltipInfo = (cvarValue == "1");
			RaceAndClassFrame:UpdateButtons();
		end
	elseif event == "DISPLAY_SIZE_CHANGED" then
		self:OnDisplaySizeChanged();
	elseif event == "STORE_VAS_PURCHASE_ERROR" then
		self:OnStoreVASPurchaseError();
	elseif event == "ASSIGN_VAS_RESPONSE" then
		local token, storeError, vasPurchaseResult = ...;
		self:OnAssignVASResponse(token, storeError, vasPurchaseResult);
	end

	if showError then
		self:UpdateForwardButton();
		GlueDialog_Show("CHARACTER_CREATE_FAILURE", _G[showError]);
	end
end

function CharacterCreateMixin:OnShow()
	C_CharacterCreation.SetInCharacterCreate(true);

	local _, selectedFaction;
	local existingCharacterID = self:GetExistingCharacterID();
	if existingCharacterID then
		C_CharacterCreation.CustomizeExistingCharacter(existingCharacterID);
		self.currentPaidServiceName = C_PaidServices.GetName();
		_, selectedFaction = C_PaidServices.GetCurrentFaction();
		if C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.CharacterCreateFullEnabled) then
			NameChoiceFrame.EditBox:SetText(self.currentPaidServiceName);
		end
	else
		self.currentPaidServiceName = nil;
		C_CharacterCreation.ResetCharCustomize();
		if C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.CharacterCreateFullEnabled) then
			NameChoiceFrame.EditBox:SetText("");
		end
	end

	local instantRotate = true;
	self:SetMode(CHAR_CREATE_MODE_CLASS_RACE, instantRotate);
	self:ResetNavBlockers();
	self:RefreshCurrentNavBlocker();

	self:UpdateRecruitInfo();

	RaceAndClassFrame:UpdateState(selectedFaction);

	if IsKioskGlueEnabled() then
		local templateIndex = Kiosk.GetCharacterTemplateSetIndex();
		if templateIndex then
			C_CharacterCreation.SetCharacterTemplate(templateIndex);
		else
			C_CharacterCreation.ClearCharacterTemplate();
		end
	end
end

local rafHelpTipInfo = {
	buttonStyle = HelpTip.ButtonStyle.Okay,
	offsetY = 100,
	autoEdgeFlipping = true,
};

function CharacterCreateMixin:UpdateRecruitInfo()
	local active, faction = C_RecruitAFriend.GetRecruitInfo();
	if active and not self:HasService() and C_CharacterCreation.UseBeginnerMode() then
		local recruiterIsHorde = (PLAYER_FACTION_GROUP[faction] == "Horde");
		rafHelpTipInfo.text = recruiterIsHorde and RECRUIT_A_FRIEND_FACTION_SUGGESTION_HORDE or RECRUIT_A_FRIEND_FACTION_SUGGESTION_ALLIANCE;
		rafHelpTipInfo.targetPoint = recruiterIsHorde and HelpTip.Point.RightEdgeCenter or HelpTip.Point.LeftEdgeCenter;
		rafHelpTipInfo.offsetX = recruiterIsHorde and 10 or -10;

		local anchorFrame = recruiterIsHorde and RaceAndClassFrame.HordeRaces or RaceAndClassFrame.AllianceRaces;
		HelpTip:Show(anchorFrame, rafHelpTipInfo);
	end
end

function CharacterCreateMixin:OnHide()
	C_CharacterCreation.SetInCharacterCreate(false);
	RaceAndClassFrame:StopClassAnimations();
	self:ClearPaidServiceInfo();
	self:ClearVASInfo();
	self.creatingCharacter = false;
	self.currentMode = 0;
end

function CharacterCreateMixin:OnButtonClick()
	C_CharacterCreation.OnPlayerInteraction();
end

function CharacterCreateMixin:SetPaidServiceInfo(serviceType, characterID)
	self.paidServiceType = serviceType;
	self.paidServiceCharacterID = characterID;
	C_CharacterCreation.SetPaidService(serviceType ~= nil);
end

function CharacterCreateMixin:SetVASInfo(vasType, info)
	self.vasType = vasType;
	self.vasInfo = info;
	C_CharacterCreation.SetPaidService(vasType ~= nil);
end

function CharacterCreateMixin:ClearPaidServiceInfo()
	self.paidServiceType = nil;
	self.paidServiceCharacterID = nil;
	C_CharacterCreation.SetPaidService(false);
end

function CharacterCreateMixin:ClearVASInfo()
	self.vasType = nil;
	self.vasInfo = nil;
	C_CharacterCreation.SetPaidService(false);
end

function CharacterCreateMixin:BeginVASTransaction()
	if self.vasType == Enum.ValueAddedServiceType.PaidFactionChange or self.vasType == Enum.ValueAddedServiceType.PaidRaceChange then
		local noIsValidateOnly = false;
		C_CharacterServices.AssignRaceOrFactionChangeDistribution(self.vasInfo.selectedCharacterGUID, CharacterCreateFrame:GetSelectedName(), noIsValidateOnly, self.vasType);
	end
end

function CharacterCreateMixin:IsVASErrorUserFixable(errorID)
	return errorID == Enum.VasError.NameNotAvailable or errorID == Enum.VasError.DuplicateCharacterName;
end

function CharacterCreateMixin:OnStoreVASPurchaseError()
	if self.vasType then
		local displayMsg = VASErrorData_GetCombinedMessage(self.vasInfo.selectedCharacterGUID);
		local errors = C_StoreSecure.GetVASErrors();
		local exitAfterError = false;
		for index, errorID in ipairs(errors) do
			if not self:IsVASErrorUserFixable(errorID) then
				exitAfterError = true;
				break;
			end
		end
		GlueDialog_Show("CHARACTER_CREATE_VAS_ERROR", displayMsg, exitAfterError);
	end
end

function CharacterCreateMixin:OnAssignVASResponse(token, storeError, vasPurchaseResult)
	if self.vasType then
		local purchaseComplete, errorMsg = IsVASAssignmentValid(storeError, vasPurchaseResult, self.vasInfo.selectedCharacterGUID);
		if purchaseComplete then
			CharacterSelect.selectGuid = self.vasInfo.selectedCharacterGUID;
			CharacterCreateFrame:Exit();
		else
			local exitAfterError = not self:IsVASErrorUserFixable(vasPurchaseResult);
			GlueDialog_Show("CHARACTER_CREATE_VAS_ERROR", errorMsg, exitAfterError);
		end
	end
end

function CharacterCreateMixin:HasService()
	return (self.paidServiceType or self.vasType) and true or false;
end

function CharacterCreateMixin:GetExistingCharacterID()
	if self.paidServiceType then
		return self.paidServiceCharacterID;
	elseif self.vasType then
		return self.vasInfo.characterIndex;
	end
	return nil;
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
		RaceAndClassFrame:ClearClassAnimationCountdown();

		local diff = (x - self.lastCursorPosX) * CHARACTER_ROTATION_CONSTANT;
		C_CharacterCreation.SetCharacterCreateFacing(C_CharacterCreation.GetCharacterCreateFacing() + diff);

		self.lastCursorPosX = x;
	end
end

local PLUNDERSTORM_BACKGROUND_MODEL_ID = 2575493;
function CharacterCreateMixin:UpdateBackgroundModel()
	local bgModelID = C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.CharacterCreateUseFixedBackgroundModel) and PLUNDERSTORM_BACKGROUND_MODEL_ID or C_CharacterCreation.GetCreateBackgroundModel();
	if bgModelID ~= self.bgModelID then
		C_CharacterCreation.SetCharCustomizeBackground(bgModelID);
		ResetModel(self);
		self.bgModelID = bgModelID;
		return true;
	end

	return false;
end

local classBGAlphaValues = {
	DEMONHUNTER = 0.7,
	DEATHKNIGHT = 0.8,
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
	self:ZoomCamera(enable and zoomAmount or -zoomAmount, ZONE_CHOICE_ZOOM_TIME, force);

	if enable then
		self:AlphaCharacterToTarget(0);
	else
		self:AlphaCharacterToTarget(1, ZOOM_TIME_SECONDS);
	end
end

function CharacterCreateMixin:AlphaCharacterToTarget(targetAlpha, duration)
	duration = duration or 0;

	if duration == 0 then
		C_CharacterCreation.SetModelAlpha(targetAlpha);
		self:SetScript("OnUpdate", nil);
		return;
	end

	local currentAlpha = C_CharacterCreation.GetModelAlpha();
	local alphaDiff = targetAlpha - currentAlpha;
	self.perSecondAlpha = alphaDiff / duration;
	self.targetAlpha = targetAlpha;
	self:SetScript("OnUpdate", self.OnUpdateAlphaCharacter);
end

function CharacterCreateMixin:OnUpdateAlphaCharacter(elapsed)
	local alphaAmount = self.perSecondAlpha * elapsed;
	local currentAlpha = C_CharacterCreation.GetModelAlpha();
	local newAlpha = currentAlpha + alphaAmount;

	local reachedTarget;
	if self.perSecondAlpha < 0 then
		reachedTarget = (newAlpha <= self.targetAlpha);
	else
		reachedTarget = (newAlpha >= self.targetAlpha);
	end

	if reachedTarget then
		C_CharacterCreation.SetModelAlpha(self.targetAlpha);
		self:SetScript("OnUpdate", nil);
	else
		C_CharacterCreation.SetModelAlpha(newAlpha);
	end
end

function CharacterCreateMixin:SetMode(mode, instantRotate)
	self:ResetCharacterRotation(mode, instantRotate);

	if self:IsMode(mode) then
		self.creatingCharacter = false;
		self:UpdateForwardButton();
		return;
	end

	if mode == CHAR_CREATE_MODE_CLASS_RACE then
		C_CharacterCreation.SetViewingAlteredForm(false);

		if self:IsMode(CHAR_CREATE_MODE_CUSTOMIZE) then
			local useBlending = true;
			RaceAndClassFrame:PlayClassIdleAnimation(useBlending, CLASS_ANIM_WAIT_TIME_SECONDS);
		else
			RaceAndClassFrame.allowClassAnimationsAfterSeconds = CLASS_ANIM_WAIT_TIME_SECONDS;
		end

		C_CharacterCreation.SetBlurEnabled(false);

		self:SetCameraZoomLevel(0);
		self:SetModelDressState(true);
		C_CharacterCreation.SetSelectedPreviewGearType(Enum.PreviewGearType.Awesome);

		if self:IsMode(CHAR_CREATE_MODE_CUSTOMIZE) then
			self.BottomBackgroundOverlay.FadeIn:Play();
			self:RemoveNavBlocker(CHARACTER_CREATION_REQUIREMENTS_NEED_ACHIEVEMENT);
		end
	elseif mode == CHAR_CREATE_MODE_CUSTOMIZE then
		if self:IsMode(CHAR_CREATE_MODE_CLASS_RACE) then
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

			if not RaceAndClassFrame.selectedRaceData.enabled then
				self:AddNavBlocker(CHARACTER_CREATION_REQUIREMENTS_NEED_ACHIEVEMENT, HIGH_PRIORITY);
			end
		else
			self:EnableZoneChoiceMode(false);
		end
	else
		self:EnableZoneChoiceMode(true);
	end

	RaceAndClassFrame:SetShown(mode == CHAR_CREATE_MODE_CLASS_RACE);
	CharCustomizeFrame:SetShown(mode == CHAR_CREATE_MODE_CUSTOMIZE);
	ClassTrialSpecs:SetShown(mode == CHAR_CREATE_MODE_CUSTOMIZE and (C_CharacterCreation.GetCharacterCreateType() == Enum.CharacterCreateType.TrialBoost));
	if C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.CharacterCreateFullEnabled) then
		NameChoiceFrame:SetShown(mode == CHAR_CREATE_MODE_CUSTOMIZE);
	end
	ZoneChoiceFrame:SetShown(mode == CHAR_CREATE_MODE_ZONE_CHOICE);
	NewPlayerTutorial:SetShown(mode == CHAR_CREATE_MODE_CUSTOMIZE and C_CharacterCreation.UseBeginnerMode());

	self.currentMode = mode;
	self.creatingCharacter = false;
	self:UpdateForwardButton();
end

function CharacterCreateMixin:UpdateMode(offset)
	if self.currentMode then
		self:SetMode(Clamp(self.currentMode + offset, CHAR_CREATE_MODE_CLASS_RACE, CHAR_CREATE_MODE_ZONE_CHOICE))
	end
end

function CharacterCreateMixin:IsMode(mode)
	return self.currentMode == mode;
end

function CharacterCreateMixin:NavBack()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CANCEL);
	if self:IsMode(CHAR_CREATE_MODE_CLASS_RACE) then
		if( IsKioskGlueEnabled() ) then
			GlueParent_SetScreen("kioskmodesplash");
		else
			if CharacterUpgrade_IsCreatedCharacterTrialBoost() then
				CharacterUpgrade_ResetBoostData();
			end

			self:Exit();
		end
	else
		self.RaceAndClassFrame.ClassTrialCheckButton:ResetDesiredState();
		self:UpdateMode(-1);
		self:CheckDynamicNavBlockers();
	end
end

function CharacterCreateMixin:Exit()
	self.RaceAndClassFrame.ClassTrialCheckButton:ResetDesiredState();

	CharacterSelect.backFromCharCreate = true;
	if C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.CharacterCreateFullEnabled) then
		GlueParent_SetScreen("charselect");
	else
		GlueParent_SetScreen("plunderstorm");
	end
end

local function SortBlockers(a, b)
	return a.priority < b.priority;
end

function CharacterCreateMixin:AddNavBlocker(navBlocker, priority)
	for i, currentBlocker in ipairs(self.navBlockers) do
		if currentBlocker.error == navBlocker then
			-- This blocker is already in there, do nothing
			return;
		end
	end

	table.insert(self.navBlockers, {error = navBlocker, priority = priority or LOW_PRIORITY});
	table.sort(self.navBlockers, SortBlockers);

	self:RefreshCurrentNavBlocker();

	EventRegistry:TriggerEvent("CharacterCreate.AddNavBlocker");
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

function CharacterCreateMixin:ResetNavBlockers()
	self.navBlockers = {};
end

function CharacterCreateMixin:RefreshCurrentNavBlocker()
	self.currentNavBlocker = self.navBlockers[1];
	self:UpdateForwardButton();
end

function CharacterCreateMixin:CanNavForward()
	return not self.currentNavBlocker and not self.creatingCharacter;
end

function CharacterCreateMixin:HasMissingCustomizationOptions()
	return self:IsMode(CHAR_CREATE_MODE_CUSTOMIZE) and CharCustomizeFrame:HasMissingOptions();
end

function CharacterCreateMixin:CheckDynamicNavBlockers()
	local hasMissingOptions = self:HasMissingCustomizationOptions();
	self:SetMissingOptionsNavBlockersEnabled(hasMissingOptions);

	if hasMissingOptions then
		EventRegistry:RegisterCallback("CharCustomize.OnSetCustomizations", self.CheckDynamicNavBlockers, self);
		EventRegistry:RegisterCallback("CharCustomize.OnCategorySelected", function(owner, hadCategoryChange)
			if hadCategoryChange then
				self:SetMissingOptionsNavBlockersEnabled(false);
			end
		end, self);

	end
end

function CharacterCreateMixin:SetMissingOptionsNavBlockersEnabled(enabled)
	if enabled then
		CharCustomizeFrame:HighlightNextMissingOption();
		CharacterCreateFrame:AddNavBlocker(CHARACTER_CREATION_REQUIREMENTS_MISSING_REQUIRED_OPTIONS, MEDIUM_PRIORITY);
	else
		CharCustomizeFrame:DisableMissingOptionWarnings();
		CharacterCreateFrame:RemoveNavBlocker(CHARACTER_CREATION_REQUIREMENTS_MISSING_REQUIRED_OPTIONS);
	end
end

function CharacterCreateMixin:GetSelectedName()
	if not C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.CharacterCreateFullEnabled) then
		return "";
	end
	return NameChoiceFrame.EditBox:GetText();
end

function CharacterCreateMixin:GetCreateCharacterFaction()
	return RaceAndClassFrame:GetCreateCharacterFaction();
end

function CharacterCreateMixin:CreateCharacter()
	if self.paidServiceType then
		GlueDialog_Show("CONFIRM_PAID_SERVICE");
	elseif self.vasType == Enum.ValueAddedServiceType.PaidFactionChange or self.vasType == Enum.ValueAddedServiceType.PaidRaceChange then
		GlueDialog_Show("CONFIRM_VAS_FACTION_CHANGE");
	else
		if Kiosk.IsEnabled() then
			KioskModeSplash:SetAutoEnterWorld(true);
		end

		self.creatingCharacter = true;
		self:UpdateForwardButton();

		C_CharacterCreation.CreateCharacter(self:GetSelectedName(), ZoneChoiceFrame.useNPE, RaceAndClassFrame:GetCreateCharacterFaction());
		if not C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.CharacterCreateFullEnabled) then
			GlueParent_SetScreen("plunderstorm");
		end
	end
end

function CharacterCreateMixin:SetCustomizationChoice(optionID, choiceID)
	C_CharacterCreation.SetCustomizationChoice(optionID, choiceID);

	-- When a customization choice is made, that may force other options to change (if the current choices are no longer valid)
	-- So grab all the latest data and update CharCustomizationFrame
	self:UpdateCharCustomizationFrame();
end

function CharacterCreateMixin:ResetCustomizationPreview(clearSavedChoices)
	C_CharacterCreation.ClearPreviewChoices(clearSavedChoices);
end

function CharacterCreateMixin:PreviewCustomizationChoice(optionID, choiceID)
	-- It is important that we DON'T call UpdateCharCustomizationFrame here because we want to keep the current selections
	C_CharacterCreation.PreviewCustomizationChoice(optionID, choiceID);
end

function CharacterCreateMixin:MarkCustomizationChoiceAsSeen(choiceID)
	C_CharacterCreation.MarkCustomizationChoiceAsSeen(choiceID);
end

function CharacterCreateMixin:MarkCustomizationOptionAsSeen(optionID)
	C_CharacterCreation.MarkCustomizationOptionAsSeen(optionID);
end

function CharacterCreateMixin:SaveSeenChoices()
	C_CharacterCreation.SaveSeenChoices();
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

function CharacterCreateMixin:ResetCharacterRotation(mode, instantRotate)
	self:RotateCharacterToTarget(C_CharacterCreation.GetDefaultCharacterCreateFacing(), instantRotate and 0 or ROTATION_ADJUST_SECONDS);
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

function CharacterCreateMixin:SetCharacterSex(sexID)
	RaceAndClassFrame:SetCharacterSex(sexID);
end

function CharacterCreateMixin:NavForward()
	self:CheckDynamicNavBlockers();

	if self:CanNavForward() then
		if self:IsMode(CHAR_CREATE_MODE_CLASS_RACE) then
			if C_CharacterCreation.IsNewPlayerRestricted() and C_CharacterCreation.GetSelectedClass().classID == EVOKER_CLASS_ID then
				GlueDialog_Show("EVOKER_NEW_PLAYER_WARNING");
			else
				PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_CREATE_NEW);
				self:UpdateMode(1);
			end
		elseif self:IsMode(CHAR_CREATE_MODE_CUSTOMIZE) and ZoneChoiceFrame:ShouldShow() then
			PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_CREATE_NEW);
			self:UpdateMode(1);
		else
			PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CREATE_CHAR);
			self:CreateCharacter();
			self.ForwardButton:SetEnabled(false);
			if not C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.CharacterCreateFullEnabled) then
				CharacterCreateFrame:Exit();
			end
		end
	end
end

function CharacterCreateMixin:UpdateForwardButton()
	self.ForwardButton:SetEnabled(self:CanNavForward());

	if self:IsMode(CHAR_CREATE_MODE_CLASS_RACE) then
		if RaceAndClassFrame.selectedRaceData and not RaceAndClassFrame.selectedRaceData.enabled then
			self.ForwardButton:UpdateText(PREVIEW, FORWARD_ARROW);
		else
			self.ForwardButton:UpdateText(CUSTOMIZE, FORWARD_ARROW);
		end
	elseif self:IsMode(CHAR_CREATE_MODE_CUSTOMIZE) then
		if ZoneChoiceFrame:ShouldShow() then
			self.ForwardButton:UpdateText(NEXT, FORWARD_ARROW);
		else
			self.ForwardButton:UpdateText(FINISH);
		end
	else
		self.ForwardButton:UpdateText(FINISH);
	end
end

CharacterCreateNavButtonMixin = {};

function CharacterCreateNavButtonMixin:GetAppropriateTooltip()
	return CharCustomizeNoHeaderTooltip;
end

function CharacterCreateNavButtonMixin:OnEnter()
	local tooltipText = GetValueOrCallFunction(self, "tooltip");
	if tooltipText then
		local tooltip = self:GetAppropriateTooltip();
		tooltip:SetOwner(self, "ANCHOR_LEFT");
		tooltip:SetText(tooltipText);
	end
end

function CharacterCreateNavButtonMixin:OnLeave()
	local tooltip = self:GetAppropriateTooltip();
	tooltip:Hide();
end

function CharacterCreateNavButtonMixin:UpdateText(text, arrow)
	local appendArrowName = self:IsEnabled() and "" or "-disable";

	if arrow == FORWARD_ARROW then
		self:SetFormattedText("%s  %s", text, CreateAtlasMarkup("common-icon-forwardarrow"..appendArrowName, 8, 13, 0, 0));
	elseif arrow == BACKWARD_ARROW then
		self:SetFormattedText("%s  %s", CreateAtlasMarkup("common-icon-backarrow"..appendArrowName, 8, 13, 0, 0), text);
	else
		self:SetText(text);
	end
end

function CharacterCreateNavButtonMixin:OnClick(button)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	CharacterCreateFrame[self.charCreateOnClickMethod](CharacterCreateFrame, button);
end

CharacterCreateNavForwardButtonMixin = {};

function CharacterCreateNavForwardButtonMixin:OnLoad_NavForward()
	EventRegistry:RegisterCallback("CharacterCreate.AddNavBlocker", function()
		if self:IsMouseMotionFocus() then
			self:OnLeave();
			self:OnEnter();
		end
	end);
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
	EVOKER = 13,
};

function CharacterCreateClassButtonMixin:SetClass(classData, selectedClassID)
	self.classData = classData;
	self.layoutIndex = classLayoutIndices[classData.fileName];

	local atlas = GetClassAtlas(strlower(classData.fileName));
	self:SetIconAtlas(atlas);

	local buttonEnabled;
	if CharacterCreateFrame:HasService() then
		buttonEnabled = (selectedClassID == classData.classID);
	else
		buttonEnabled = classData.enabled;
	end

	self:SetEnabledState(buttonEnabled);
	self.ClassName:SetText(classData.name);

	-- Prevent tooltip of far right elements from overlapping races buttons
	if (self.layoutIndex > 11) then
		self.tooltipAnchor = "ANCHOR_LEFT";
	end


	self:ClearTooltipLines();
	self:AddTooltipLine(classData.description);
	self:AddBlankTooltipLine();
	self:AddTooltipLine(classData.roleInfo);

	local tooltipDisabledReason;
	if not classData.enabled then
		if classData.disabledReason == Enum.CreationClassDisabledReason.DoesNotHaveExpansion then
			local currentExpansionName = _G["EXPANSION_NAME"..LE_EXPANSION_LEVEL_CURRENT];
			tooltipDisabledReason = CHAR_CREATE_NEED_EXPANSION:format(currentExpansionName);
		elseif classData.disabledReason == Enum.CreationClassDisabledReason.InvalidForTemplates then
			tooltipDisabledReason = CHAR_CREATE_CLASS_DISABLED_TEMPLATE;
		elseif classData.disabledReason == Enum.CreationClassDisabledReason.InvalidForNewPlayers then
			tooltipDisabledReason = CHAR_CREATE_NEW_PLAYER;
		elseif classData.disabledReason == Enum.CreationClassDisabledReason.LimitServer then
			tooltipDisabledReason = CHAR_CREATE_EVOKER_DUPLICATE;
		elseif classData.disabledReason == Enum.CreationClassDisabledReason.LimitLevel then
			tooltipDisabledReason = CHAR_CREATE_EVOKER_LEVEL_REQUIREMENT;
		elseif classData.disabledReason == Enum.CreationClassDisabledReason.InvalidForSelectedRace then
			local validRaces = C_CharacterCreation.GetValidRacesForClass(classData.classID);
			local validAllianceRaceNames = {};
			local validHordeRaceNames = {};
			for _, raceData in ipairs(validRaces) do
				if not raceData.isAlliedRace or not C_CharacterCreation.UseBeginnerMode() then
					if raceData.isNeutralRace or (raceData.factionInternalName == "Alliance") then
						tinsert(validAllianceRaceNames, raceData.name);
					end

					if raceData.isNeutralRace or (raceData.factionInternalName == "Horde") then
						tinsert(validHordeRaceNames, raceData.name);
					end
				end
			end

				-- Sort alphabetically
				table.sort(validAllianceRaceNames);
				table.sort(validHordeRaceNames);

				local validAllianceRacesString = table.concat(validAllianceRaceNames, ", ");
				local validHordeRacesString = table.concat(validHordeRaceNames, ", ");

				tooltipDisabledReason = CLASS_DISABLED_FACTIONS:format(validAllianceRacesString, validHordeRacesString);
		else
			tooltipDisabledReason = classData.disabledString;
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
	RingedMaskedButtonMixin.SetEnabledState(self, enabled);
	self.ClassName:SetFontObject(enabled and "GameFontNormalMed2" or "GameFontDisableMed2");
end

function CharacterCreateClassButtonMixin:IsDisabledByRace()
	return not self.classData.enabled and (self.classData.disabledReason == Enum.CreationClassDisabledReason.InvalidForSelectedRace);
end

function CharacterCreateClassButtonMixin:OnEnter()
	CharCustomizeFrameWithTooltipMixin.OnEnter(self);
	if not CharacterCreateFrame:HasService() and self:IsDisabledByRace() then
		local validRaces = C_CharacterCreation.GetValidRacesForClass(self.classData.classID);
		local validRacesMap = {};
		for _, raceData in ipairs(validRaces) do
			validRacesMap[raceData.raceID] = true;
		end
		RaceAndClassFrame:SetClassValidRaces(validRacesMap);
	end
end

function CharacterCreateClassButtonMixin:OnLeave()
	CharCustomizeFrameWithTooltipMixin.OnLeave(self);
	if self:IsDisabledByRace() then
		RaceAndClassFrame:SetClassValidRaces(nil);
	end
end

CharacterCreateRaceButtonMixin = CreateFromMixins(CharCustomizeMaskedButtonMixin, CharCustomizeFrameWithExpandableTooltipMixin);

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

function CharacterCreateRaceButtonMixin:SetRace(raceData, selectedRaceID, selectedFaction, layoutIndex)
	self.raceData = raceData;
	self.layoutIndex = layoutIndex;

	self:SetIconAtlas(raceData.createScreenIconAtlas);

	if C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.CharacterCreateFullEnabled) then
		local isValidRace = RaceAndClassFrame:IsRaceValid(raceData, self.faction);
		self.allowSelectionOnDisable = not CharacterCreateFrame:HasService() and (raceData.disabledReason == Enum.CreationRaceDisabledReason.DoesNotHaveAchievement);
		self:SetEnabledState(isValidRace);

		if isValidRace and RaceAndClassFrame.classValidRaces then
			self:StartFlash();
		else
			self:StopFlash();
		end
	else
		self.allowSelectionOnDisable = true;
		self:SetEnabledState(true);
	end

	self.RaceName.Text:SetText(raceData.name);
	self.RaceName:SetShown(C_CharacterCreation.UseBeginnerMode());

	if not raceData.isAlliedRace then
		if C_CharacterCreation.UseBeginnerMode() then
			self.tooltipXOffset = 16;
		else
			self.tooltipXOffset = 113;
		end
	end

	self:ClearTooltipLines();
	self:AddTooltipLine(raceData.name, HIGHLIGHT_FONT_COLOR);
	self:AddBlankTooltipLine();
	self:AddTooltipLine(raceData.loreDescription);

	if C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.CharacterCreateFullEnabled) then
		self:AddExpandedTooltipFrame(RaceAndClassFrame.RacialAbilityList);

		if not raceData.enabled then
			if raceData.disabledReason == Enum.CreationRaceDisabledReason.DoesNotHaveExpansion then
				local currentExpansionName = _G["EXPANSION_NAME"..LE_EXPANSION_LEVEL_CURRENT];
				self:AddPostTooltipLine(CHAR_CREATE_NEED_EXPANSION:format(currentExpansionName), RED_FONT_COLOR);
			elseif raceData.disabledReason == Enum.CreationRaceDisabledReason.RaceLimitServer then
				self:AddPostTooltipLine(CHAR_CREATE_DRACTHYR_DUPLICATE, RED_FONT_COLOR);
			elseif raceData.disabledReason == Enum.CreationRaceDisabledReason.RaceLimitLevel then
				self:AddPostTooltipLine(CHAR_CREATE_DRACTHYR_LEVEL_REQUIREMENT, RED_FONT_COLOR);
			else
				local requirements = C_CharacterCreation.GetAlliedRaceAchievementRequirements(raceData.raceID);
				if requirements then
					self:AddPostTooltipLine(ALLIED_RACE_UNLOCK_TEXT, RED_FONT_COLOR);

					for _, requirement in ipairs(requirements) do
						self:AddPostTooltipLine(DASH_WITH_TEXT:format(requirement), RED_FONT_COLOR);
					end

					local embassy = (self.faction == "Horde") and CHAR_CREATE_HORDE_EMBASSY or CHAR_CREATE_ALLIANCE_EMBASSY;
					self:AddPostTooltipLine(DASH_WITH_TEXT:format(embassy), RED_FONT_COLOR);
				end
			end
		end
	end

	if selectedRaceID == raceData.raceID and selectedFaction == self.faction then
		self:SetChecked(true);
	else
		self:SetChecked(false);
	end

	self:UpdateHighlightTexture();
end

function CharacterCreateRaceButtonMixin:OnEnter()
	RaceAndClassFrame.RacialAbilityList:SetupRacialAbilties(self.raceData.racialAbilities);
	CharCustomizeFrameWithTooltipMixin.OnEnter(self);
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

	local specDescription = ReplaceGenderTokens(specData.description, RaceAndClassFrame.selectedSexID + 1);
	self:AddTooltipLine(specDescription);

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
	RingedMaskedButtonMixin.SetEnabledState(self, enabled);
	self.SpecName:SetFontObject(enabled and "GameFontNormalMed2" or "GameFontDisableMed2");
	self.RoleName:SetFontObject(enabled and "GameFontHighlight" or "GameFontDisable");
end

local function GetDruidCatModelInfo(race, sex)
	if race == "NightElf" then
		if sex == Enum.UnitSex.Female then
			return { displayID = 29405, spellVisualKitID = 131927 };
		else
			return { displayID = 892, spellVisualKitID = 131927 };
		end
	elseif race == "Tauren" then
		if sex == Enum.UnitSex.Female then
			return { displayID = 29410, spellVisualKitID = 134580 };
		else
			return { displayID = 29412, spellVisualKitID = 134580 };
		end
	elseif race == "Worgen" then
		if sex == Enum.UnitSex.Female then
			return { displayID = 33664, spellVisualKitID = 134578 };
		else
			return { displayID = 33661, spellVisualKitID = 134578 };
		end
	elseif race == "Troll" then
		if sex == Enum.UnitSex.Female then
			return { displayID = 33665, spellVisualKitID = 134582 };
		else
			return { displayID = 33666, spellVisualKitID = 134582 };
		end
	elseif race == "HighmountainTauren" then
		if sex == Enum.UnitSex.Female then
			return { displayID = 80597, spellVisualKitID = 134581 };
		else
			return { displayID = 80598, spellVisualKitID = 134581 };
		end
	elseif race == "ZandalariTroll" then
		if sex == Enum.UnitSex.Female then
			return { displayID = 85195, spellVisualKitID = 134583 };
		else
			return { displayID = 85194, spellVisualKitID = 134583 };
		end
	elseif race == "KulTiran" then
		if sex == Enum.UnitSex.Female then
			return { displayID = 86100, spellVisualKitID = 134579 };
		else
			return { displayID = 86524, spellVisualKitID = 134579 };
		end
	end
end

local function GetDHMetaModelInfo(race, sex)
	local metaFormScale = 0.7;

	if race == "NightElf" then
		if sex == Enum.UnitSex.Female then
			return { displayID = 63247, spellVisualKitID = 131909, scale = metaFormScale, equipWeapons = true, weaponScale = 1.15 };
		else
			return { displayID = 65312, spellVisualKitID = 131909, scale = metaFormScale, equipWeapons = true, weaponScale = 1.15 };
		end
	elseif race == "BloodElf" then
		if sex == Enum.UnitSex.Female then
			return { displayID = 67673, spellVisualKitID = 131909, scale = metaFormScale, equipWeapons = true, weaponScale = 1.15 };
		else
			return { displayID = 67675, spellVisualKitID = 131909, scale = metaFormScale, equipWeapons = true, weaponScale = 1.15 };
		end
	end
end

local function GetDHNormalModelInfo()
	return { showPlayerModel = true, playerModelSpellVisualKitID = 131914, auxModelInfoFunc = GetDHMetaModelInfo, destroyAuxModel = true };
end

local function GetDruidNormalModelInfo()
	return { showPlayerModel = true, playerModelSpellVisualKitID = 131928, auxModelInfoFunc = GetDruidCatModelInfo, destroyAuxModel = true };
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
	self.buttonPool:CreatePool("CHECKBUTTON", self.BodyTypes, "CharCustomizeBodyTypeButtonTemplate");
	self.buttonPool:CreatePool("CHECKBUTTON", self.AllianceRaces, "CharacterCreateAllianceButtonTemplate");
	self.buttonPool:CreatePool("CHECKBUTTON", self.AllianceAlliedRaces, "CharacterCreateAllianceAlliedRaceButtonTemplate");
	self.buttonPool:CreatePool("CHECKBUTTON", self.HordeRaces, "CharacterCreateHordeButtonTemplate");
	self.buttonPool:CreatePool("CHECKBUTTON", self.HordeAlliedRaces, "CharacterCreateHordeAlliedRaceButtonTemplate");
	self.buttonPool:CreatePool("CHECKBUTTON", self.Classes, "CharacterCreateClassButtonTemplate");

	self.createdModelIndices = {};

	self.spellVisualKitStartAction =
	{
		-- Druid
		[129374] = { auxModelInfoFunc = GetDruidCatModelInfo, createAuxModel = true, hideAuxModel = true },

		-- Demon Hunter
		[129051] = { auxModelInfoFunc = GetDHMetaModelInfo, createAuxModel = true, hideAuxModel = true },
	};

	self.spellVisualKitCompletionAction =
	{
		-- Druid
		[129374] = { hidePlayerModel = true, auxModelInfoFunc = GetDruidCatModelInfo, showAuxModel = true, startAuxModelAnim = true, onCompletionFunc = GetDruidNormalModelInfo },

		-- Demon Hunter
		[129051] = { hidePlayerModel = true, auxModelInfoFunc = GetDHMetaModelInfo, showAuxModel = true, startAuxModelAnim = true, onCompletionFunc = GetDHNormalModelInfo },
	}
end

function CharacterCreateRaceAndClassMixin:GetCreateCharacterFaction()
	if self.selectedRaceData.isNeutralRace and self.selectedClassData.earlyFactionChoice then
		-- For neutral races, if the player selected an earlyFactionChoice class (DK) we ALWAYS need to pass back the selected faction, because the creation process will fail if we try to create a Neutral character of this class
		return self.selectedFaction;
	elseif self.ClassTrialCheckButton.Button:GetChecked() then
		-- Class Trials need to use no faction...their faction choice is sent up separately after the character is created
		return nil;
	elseif self.selectedRaceData.isNeutralRace then
		if C_CharacterCreation.IsUsingCharacterTemplate() or C_CharacterCreation.IsForcingCharacterTemplate() or ZoneChoiceFrame.useNPE or CharacterCreateFrame:HasService() then
			-- For neutral races, if the player is using a character template, chose to start in the NPE or is using a paid service we need to pass back the selected faction
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

function CharacterCreateRaceAndClassMixin:CanTrialBoostCharacter()
	return C_CharacterServices.IsTrialBoostEnabled() and
		not IsKioskGlueEnabled() and
		not C_CharacterCreation.IsNewPlayerRestricted() and
		not C_CharacterCreation.IsTrialAccountRestricted() and
		not CharacterCreateFrame:HasService() and
		(self.selectedClassID ~= EVOKER_CLASS_ID) and
		(C_CharacterCreation.GetCharacterCreateType() ~= Enum.CharacterCreateType.Boost);
end

function CharacterCreateRaceAndClassMixin:UpdateClassTrialButtonVisibility()
	local showTrialBoost = self:CanTrialBoostCharacter() and C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.CharacterCreateFullEnabled);
	local isVisibilityChanging = showTrialBoost ~= self.ClassTrialCheckButton:IsVisible();

	self.ClassTrialCheckButton:SetShown(showTrialBoost);
	self.ClassTrialCheckButton:UpdateDesiredState(showTrialBoost, isVisibilityChanging);
end

function CharacterCreateRaceAndClassMixin:OnShow()
	local useNewPlayerMode = C_CharacterCreation.UseBeginnerMode();
	local alwaysAllowAlliedRaces = C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.AlwaysAllowAlliedRaces);

	self.AllianceAlliedRaces:SetShown(not useNewPlayerMode or alwaysAllowAlliedRaces);
	self.HordeAlliedRaces:SetShown(not useNewPlayerMode or alwaysAllowAlliedRaces);

	self.ClassTrialCheckButton:ClearTooltipLines();
	self.ClassTrialCheckButton:AddTooltipLine(CHARACTER_TYPE_FRAME_TRIAL_BOOST_CHARACTER_TOOLTIP:format(C_CharacterCreation.GetTrialBoostStartingLevel()));
end

function CharacterCreateRaceAndClassMixin:OnHide()
end

function CharacterCreateRaceAndClassMixin:ClearTimer()
	if self.Timer then
		self.Timer:Cancel();
	end
end

function CharacterCreateRaceAndClassMixin:PerformAnimAction(animAction)
	if animAction then
		if animAction.hidePlayerModel then
			C_CharacterCreation.SetPlayerModelHiddenState(true);
		elseif animAction.showPlayerModel then
			C_CharacterCreation.SetPlayerModelHiddenState(false);
		end

		if animAction.auxModelInfoFunc then
			local auxModelInfo = animAction.auxModelInfoFunc(self.selectedRaceData.fileName, self.selectedSexID);
			if auxModelInfo then
				if animAction.createAuxModel then
					local needsAnim = true;
					local useCharFacing = true;
					self.createdModelIndices[auxModelInfo.displayID] = C_CharacterCreation.CreateAuxModel(auxModelInfo.displayID, needsAnim, useCharFacing, auxModelInfo.position, auxModelInfo.scale);
				elseif animAction.destroyAuxModel and self.createdModelIndices[auxModelInfo.displayID] then
					C_CharacterCreation.DestroyAuxModel(self.createdModelIndices[auxModelInfo.displayID]);
					self.createdModelIndices[auxModelInfo.displayID] = nil;
				end

				if self.createdModelIndices[auxModelInfo.displayID] then
					if auxModelInfo.equipWeapons then
						C_CharacterCreation.EquipWeaponsOnAuxModel(self.createdModelIndices[auxModelInfo.displayID], auxModelInfo.weaponScale);
					end

					if animAction.startAuxModelAnim and auxModelInfo.spellVisualKitID then
						local noBlending = true;
						C_CharacterCreation.PlaySpellVisualKitOnAuxModel(self.createdModelIndices[auxModelInfo.displayID], auxModelInfo.spellVisualKitID, noBlending);
						self.currentSpellVisualKitID = auxModelInfo.spellVisualKitID;

						if animAction.onCompletionFunc then
							self.spellVisualKitCompletionAction[auxModelInfo.spellVisualKitID] = animAction.onCompletionFunc();
						end
					end

					if animAction.hideAuxModel then
						C_CharacterCreation.SetAuxModelHiddenState(self.createdModelIndices[auxModelInfo.displayID], true);
					elseif animAction.showAuxModel then
						C_CharacterCreation.SetAuxModelHiddenState(self.createdModelIndices[auxModelInfo.displayID], false);
					end
				end
			end
		end

		if animAction.playerModelSpellVisualKitID then
			local doNotStartTargetingSequence = false;
			local noBlending = true;
			C_CharacterCreation.PlaySpellVisualKitOnCharacter(animAction.playerModelSpellVisualKitID, doNotStartTargetingSequence, noBlending);
			self.currentSpellVisualKitID = animAction.playerModelSpellVisualKitID;
		end

		return true;
	end

	return false;
end

function CharacterCreateRaceAndClassMixin:PlayClassAnimations()
	self:ClearTimer();

	local function playAnims()
		self:StopClassAnimations();

		local spellVisualKitID = self.selectedClassData.spellVisualKitID;
		if spellVisualKitID then
			self:GetParent():RotateCharacterToTarget(C_CharacterCreation.GetDefaultCharacterCreateFacing(), 0);

			self.currentSpellVisualKitID = spellVisualKitID;

			local startTargetingSequence = true;
			local noBlending = (self.allowClassAnimationsAfterSeconds == 0);
			C_CharacterCreation.PlaySpellVisualKitOnCharacter(spellVisualKitID, startTargetingSequence, noBlending);

			self:PerformAnimAction(self.spellVisualKitStartAction[spellVisualKitID]);

			if self.selectedClassData.groundSpellVisualKitID then
				self.currentGroundSpellVisualKitID = self.selectedClassData.groundSpellVisualKitID;
				C_CharacterCreation.PlaySpellVisualKitOnGround(self.selectedClassData.groundSpellVisualKitID);
			end
		end
	end

	if not self.allowClassAnimationsAfterSeconds then
		return;
	else
		if self.allowClassAnimationsAfterSeconds > 0 then
			self.Timer = C_Timer.NewTimer(self.allowClassAnimationsAfterSeconds, playAnims);
		else
			playAnims();
		end
	end
end

function CharacterCreateRaceAndClassMixin:StopClassAnimations()
	self:ClearTimer();
	self.currentSpellVisualKitID = nil;
	C_CharacterCreation.StopAllSpellVisualKitsOnCharacter();
	C_CharacterCreation.SetPlayerModelHiddenState(false);
end

function CharacterCreateRaceAndClassMixin:StopActiveGroundEffect()
	if self.currentGroundSpellVisualKitID then
		C_CharacterCreation.StopSpellVisualKit(self.currentGroundSpellVisualKitID);
		self.currentGroundSpellVisualKitID = nil;
	end
end

function CharacterCreateRaceAndClassMixin:OnAnimKitFinished(animKitID, spellVisualKitID)
	if self.currentSpellVisualKitID == spellVisualKitID then
		if not self:PerformAnimAction(self.spellVisualKitCompletionAction[spellVisualKitID]) then
			local useBlending = true;
			self:PlayClassIdleAnimation(useBlending);
		end
	end
end

function CharacterCreateRaceAndClassMixin:PlayClassIdleAnimation(useBlending, overrideAnimLoopWaitTimeSeconds)
	self:StopClassAnimations();
	CharacterCreateFrame:ResetCharacterRotation(nil, true);
	C_CharacterCreation.PlayClassIdleAnimationOnCharacter(not useBlending);

	self.allowClassAnimationsAfterSeconds = overrideAnimLoopWaitTimeSeconds or self.selectedClassData.animLoopWaitTimeSeconds;
	self:PlayClassAnimations();
end

function CharacterCreateRaceAndClassMixin:DestroyCreatedModels()
	for _, modelIndex in pairs(self.createdModelIndices) do
		C_CharacterCreation.DestroyAuxModel(modelIndex);
	end

	self.createdModelIndices = {};
end

function CharacterCreateRaceAndClassMixin:PlayCustomizationAnimation()
	self:StopClassAnimations();
	self:DestroyCreatedModels();
	C_CharacterCreation.PlayCustomizationIdleAnimationOnCharacter();
end

function CharacterCreateRaceAndClassMixin:IsPlayingClassAnimtion()
	return (self.currentSpellVisualKitID ~= nil);
end

function CharacterCreateRaceAndClassMixin:ClearCurrentSpellVisualKit()
	self:ClearTimer();
	self.currentSpellVisualKitID = nil;
	self.currentGroundSpellVisualKitID = nil;
end

function CharacterCreateRaceAndClassMixin:ClearClassAnimationCountdown()
	self.allowClassAnimationsAfterSeconds = nil;
	self:ClearTimer();
end

function CharacterCreateRaceAndClassMixin:InitBlockedRaces()
	local blockedRaces = C_CharacterCreation.GetBlockedRaces();
	self.blockedRaces = {};
	for _, raceBlockInfo in ipairs(blockedRaces) do
		self.blockedRaces[raceBlockInfo.raceID] = raceBlockInfo.blockReason;
	end
end

function CharacterCreateRaceAndClassMixin:IsRaceBlocked(raceID)
	return self.blockedRaces[raceID] ~= nil;
end

function CharacterCreateRaceAndClassMixin:UpdateState(selectedFaction)
	self.selectedRaceID = C_CharacterCreation.GetSelectedRace();
	self.selectedRaceData = C_CharacterCreation.GetRaceDataByID(self.selectedRaceID);

	if not C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.CharacterCreateFullEnabled) then
		self.selectedRaceData.enabled = true;
	end

	if selectedFaction then
		self.selectedFaction = selectedFaction;
	elseif not self.selectedRaceData.isNeutralRace then
		self.selectedFaction = self.selectedRaceData.factionInternalName;
	end

	self:InitBlockedRaces();

	if not self:IsRaceValid(self.selectedRaceData, self.selectedFaction) and CharacterCreateFrame:HasService() then
		local randomRaceData = self:GetRandomValidRaceData();
		if randomRaceData then
			self:SetCharacterRace(randomRaceData.raceID, randomRaceData.factionInternalName);
			return;
		else
			CharacterCreateFrame:AddNavBlocker(CHARACTER_CREATION_REQUIREMENTS_PAID_SERVICE_NO_VALID_RACE, HIGH_PRIORITY);
		end
	else
		CharacterCreateFrame:RemoveNavBlocker(CHARACTER_CREATION_REQUIREMENTS_PAID_SERVICE_NO_VALID_RACE);
	end

	self.selectedClassData = C_CharacterCreation.GetSelectedClass();
	self.selectedClassID = self.selectedClassData.classID;
	self.selectedSexID = C_CharacterCreation.GetSelectedSex();

	local usingNewBGModel = CharacterCreateFrame:UpdateBackgroundModel();
	CharacterCreateFrame:UpdateBackgroundOverlays(self.selectedClassData, self.selectedRaceData);

	CharacterCreateFrame:RemoveNavBlocker(CHAR_FACTION_CHANGE_SWAP_FACTION);
	CharacterCreateFrame:RemoveNavBlocker(CHAR_FACTION_CHANGE_CHOOSE_RACE);
	CharacterCreateFrame:UpdateForwardButton();
	self:UpdateButtons();
	self:UpdateClassTrialButtonVisibility();
end

function CharacterCreateRaceAndClassMixin:SetCharacterRace(raceID, faction)
	if self.selectedRaceID ~= raceID then
		CharacterCreateFrame:ResetCharacterRotation(nil, true);
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
		self:StopActiveGroundEffect();
		self:ClearCurrentSpellVisualKit();
		self:PlayClassAnimations();
	end

	self:UpdateState();
end

function CharacterCreateRaceAndClassMixin:SetCharacterSex(sexID)
	if self.selectedSexID ~= sexID  then
		CharacterCreateFrame:ResetCharacterRotation(nil, true);
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
	self.BodyTypes:MarkDirty();
	self.AllianceRaces:MarkDirty();
	self.AllianceAlliedRaces:MarkDirty();
	self.HordeRaces:MarkDirty();
	self.HordeAlliedRaces:MarkDirty();
end

function CharacterCreateRaceAndClassMixin:IsRaceValid(raceData, faction)
	if not raceData.enabled then
		return false;
	end

	if self.classValidRaces and not self.classValidRaces[raceData.raceID] then
		return false;
	end

	if CharacterCreateFrame.paidServiceType == PAID_CHARACTER_CUSTOMIZATION then
		local notForPaidService = false;
		local currentRace = C_PaidServices.GetCurrentRaceID(notForPaidService);
		local _, currentFaction = C_PaidServices.GetCurrentFaction();
		return (currentRace == raceData.raceID and currentFaction == faction);
	elseif CharacterCreateFrame.paidServiceType == PAID_FACTION_CHANGE or CharacterCreateFrame.vasType == Enum.ValueAddedServiceType.PaidFactionChange then
		local _, currentFaction = C_PaidServices.GetCurrentFaction();
		if CharacterCreateFrame.vasType == Enum.ValueAddedServiceType.PaidFactionChange then
			currentFaction = select(29, GetCharacterInfoByGUID(CharacterCreateFrame.vasInfo.selectedCharacterGUID));
		end
		local currentClass = C_PaidServices.GetCurrentClassID();
		return (currentFaction ~= faction and C_CharacterCreation.IsRaceClassValid(raceData.raceID, currentClass));
	elseif CharacterCreateFrame.paidServiceType == PAID_RACE_CHANGE or CharacterCreateFrame.vasType == Enum.ValueAddedServiceType.PaidRaceChange then
		local _, currentFaction = C_PaidServices.GetCurrentFaction();
		if CharacterCreateFrame.vasType == Enum.ValueAddedServiceType.PaidRaceChange then
			currentFaction = select(29, GetCharacterInfoByGUID(CharacterCreateFrame.vasInfo.selectedCharacterGUID));
		end
		local notForPaidService = false;
		local currentRace = C_PaidServices.GetCurrentRaceID(notForPaidService);
		local currentClass = C_PaidServices.GetCurrentClassID();
		return (currentFaction == faction and currentRace ~= raceData.raceID and C_CharacterCreation.IsRaceClassValid(raceData.raceID, currentClass));
	end

	if self:IsRaceBlocked(raceData.raceID) then
		return false;
	end

	return true;
end

function CharacterCreateRaceAndClassMixin:GetAllValidRaces()
	local validRaces = {};

	local races = C_CharacterCreation.GetAvailableRaces();
	for _, raceData in ipairs(races) do
		if self:IsRaceValid(raceData, raceData.factionInternalName) then
			table.insert(validRaces, raceData);
		end
	end

	return validRaces;
end

function CharacterCreateRaceAndClassMixin:GetRandomValidRaceData()
	local validRaces = self:GetAllValidRaces();
	local numValidRaces = #validRaces;
	local randomIndex = (numValidRaces > 1) and math.random(1, numValidRaces) or numValidRaces;
	return validRaces[randomIndex];
end

function CharacterCreateRaceAndClassMixin:UpdateSexButtons(releaseButtons)
	if releaseButtons then
		self.buttonPool:ReleaseAllByTemplate("CharCustomizeBodyTypeButtonTemplate");
	end

	local sexes = {Enum.UnitSex.Male, Enum.UnitSex.Female};
	for index, sexID in ipairs(sexes) do
		local button = self.buttonPool:Acquire("CharCustomizeBodyTypeButtonTemplate");
		button:SetBodyType(sexID, self.selectedSexID, index);
		button:Show();
	end
end

function CharacterCreateRaceAndClassMixin:UpdateRaceButtons(releaseButtons)
	if releaseButtons then
		self.buttonPool:ReleaseAllByTemplate("CharacterCreateAllianceButtonTemplate");
		self.buttonPool:ReleaseAllByTemplate("CharacterCreateAllianceAlliedRaceButtonTemplate");
		self.buttonPool:ReleaseAllByTemplate("CharacterCreateHordeButtonTemplate");
		self.buttonPool:ReleaseAllByTemplate("CharacterCreateHordeAlliedRaceButtonTemplate");
	end

	local templateCount = {};

	local races = C_CharacterCreation.GetAvailableRaces();
	for _, raceData in ipairs(races) do
		local buttonTemplates = {self:GetRaceButtonTemplates(raceData)};
		for _, buttonTemplate in pairs(buttonTemplates) do
			local button = self.buttonPool:Acquire(buttonTemplate);
			if not button then
				return;
			end

			if not templateCount[buttonTemplate] then
				templateCount[buttonTemplate] = 1;
			else
				templateCount[buttonTemplate] = templateCount[buttonTemplate] + 1;
			end

			button:SetRace(raceData, self.selectedRaceID, self.selectedFaction, templateCount[buttonTemplate]);
			button:Show();
		end
	end
end

local function SortClasses(classData1, classData2)
	return classLayoutIndices[classData1.fileName] < classLayoutIndices[classData2.fileName];
end

function CharacterCreateRaceAndClassMixin:UpdateClassButtons(releaseButtons)
	if releaseButtons then
		self.buttonPool:ReleaseAllByTemplate("CharacterCreateClassButtonTemplate");
	end

	local classes = C_CharacterCreation.GetAvailableClasses();
	table.sort(classes, SortClasses);

	local lastButton;
	for i, classData in ipairs(classes) do
		local button = self.buttonPool:Acquire("CharacterCreateClassButtonTemplate");
		button:SetClass(classData, self.selectedClassID);

		if i == 1 then
			button:SetPoint("TOPLEFT", self.Classes, "TOPLEFT", 0, 0);
		else
			button:SetPoint("TOPLEFT", lastButton, "TOPRIGHT", 15, 0);
		end

		lastButton = button;

		button:Show();
	end
end

function CharacterCreateRaceAndClassMixin:UpdateButtons()
	self.buttonPool:ReleaseAll();

	self:UpdateSexButtons();
	self:UpdateRaceButtons();
	if C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.CharacterCreateFullEnabled) then
		self:UpdateClassButtons();
	end

	self:LayoutButtons();
end

function CharacterCreateRaceAndClassMixin:SetClassValidRaces(classValidRaces)
	self.classValidRaces = classValidRaces;

	local releaseButtons = true;
	self:UpdateRaceButtons(releaseButtons);
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
	ResizeCheckButtonMixin.OnCheckButtonClick(self);

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:UpdateCharacterCreateTypeFromChecked();
end

function ClassTrialCheckButtonMixin:UpdateDesiredState(showTrialBoost, isVisibilityChanging)
	if isVisibilityChanging then
		if showTrialBoost then
			-- Predicated on the assumption that if the button shows then it's legal to use class trial
			self:ReapplyDesiredState();
		else
			self:SaveDesiredStateAndUncheck();
		end
	end
end

function ClassTrialCheckButtonMixin:ReapplyDesiredState()
	if self:GetDesiredState() ~= nil then
		self.Button:SetChecked(self:GetDesiredState());
		self:UpdateCharacterCreateTypeFromChecked();
		self:ResetDesiredState();
	end
end

function ClassTrialCheckButtonMixin:SaveDesiredStateAndUncheck()
	local currentState = self.Button:GetChecked();

	self:ResetDesiredState();
	self.Button:SetChecked(false);
	self:UpdateCharacterCreateTypeFromChecked();
	self:SetDesiredState(currentState);
end

function ClassTrialCheckButtonMixin:UpdateCharacterCreateTypeFromChecked()
	C_CharacterCreation.SetCharacterCreateType(self.Button:GetChecked() and Enum.CharacterCreateType.TrialBoost or Enum.CharacterCreateType.Normal);
end

function ClassTrialCheckButtonMixin:SetDesiredState(desiredState)
	self.desiredState = desiredState;
end

function ClassTrialCheckButtonMixin:ResetDesiredState()
	self:SetDesiredState(nil);
end

function ClassTrialCheckButtonMixin:GetDesiredState()
	return self.desiredState;
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
	self.NameAvailabilityState:UpdateNavBlocker(nil);
	self.NameAvailabilityState:ClearTimer();
end

function CharacterCreateEditBoxMixin:OnEscapePressed()
	CharacterCreateFrame:NavBack();
end

function CharacterCreateEditBoxMixin:OnEnterPressed()
	CharacterCreateFrame:NavForward();
end

function CharacterCreateEditBoxMixin:OnTextChanged()
	local selectedName = self:GetText();
	if C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.CharacterCreateFullEnabled) and (selectedName == "" or selectedName == PENDING_RANDOM_NAME) then
		CharacterCreateFrame:AddNavBlocker(CHARACTER_CREATION_REQUIREMENTS_PICK_NAME, MEDIUM_PRIORITY);
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
	end
end

CharacterCreateNameAvailabilityStateMixin = {};

function CharacterCreateNameAvailabilityStateMixin:OnLoad()
	self:RegisterEvent("CHECK_CHARACTER_NAME_AVAILABILITY_RESULT");
end

function CharacterCreateNameAvailabilityStateMixin:ClearTimer()
	if self.Timer then
		self.Timer:Cancel();
		self.Timer = nil;
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
	self:ClearTimer();

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

	if C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.CharacterCreateFullEnabled) and NameChoiceFrame:IsShown() and navBlocker then
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
	if not C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.CharacterCreateFullEnabled) then
		return;
	end

	local firstZoneChoiceInfo, secondZoneChoiceInfo = C_CharacterCreation.GetStartingZoneChoices();
	if not secondZoneChoiceInfo or CharacterCreateFrame:HasService() or (C_CharacterCreation.GetCharacterCreateType() ~= Enum.CharacterCreateType.Normal) then
		self:SetUseNPE(firstZoneChoiceInfo.isNPE);
		self.shouldShow = false;
		return;
	end

	self.shouldShow = true;

	-- If there is more than one choice, the normal starting zone will always be first
	self.NormalStartingZone:SetZoneInfo(firstZoneChoiceInfo.zoneName, firstZoneChoiceInfo.zoneImageAtlas);
end

function CharacterCreateZoneChoiceMixin:ShouldShow()
	if not C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.CharacterCreateFullEnabled) then
		return false;
	end
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
	ResizeCheckButtonMixin.OnCheckButtonClick(self);

	ZoneChoiceFrame:SetUseNPE(self:GetParent().isNPE);
end

function SelectOtherRaceAvailable()
	currentFaction = C_CharacterCreation.GetFactionForRace(C_CharacterCreation.GetSelectedRace());
	if (currentFaction == "Alliance") then
		RaceAndClassFrame:SetCharacterRace(HUMAN_RADE_ID);
	elseif (currentFaction == "Horde") then
		RaceAndClassFrame:SetCharacterRace(ORC_RACE_ID);
	end
end
