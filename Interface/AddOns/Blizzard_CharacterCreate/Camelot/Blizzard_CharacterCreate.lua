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
local FactionDetailsList;
local RaceDetailsList;
local ClassDetailsList;

local HUMAN_RACE_ID = 1;
local ORC_RACE_ID = 2;

local UPDATE_MOUSE_ROTATE = "mouseRotate";
local UPDATE_ALPHA_CHARACTER = "alphaCharacter";
local UPDATE_ROTATE_TO_TARGET = "rotateToTarget";

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

StaticPopupDialogs["CHARACTER_CREATE_FAILURE"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
    OnAccept = function(dialog, data)
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

	self.RotationConstant = 0.6;

	self.activeUpdates = {};

	self.LeftBlackBar:SetPoint("TOPLEFT", nil);
	self.RightBlackBar:SetPoint("TOPRIGHT", nil);
	self.TopBlackBar:SetPoint("TOPLEFT", nil);

	C_CharacterCreation.SetCharCustomizeFrame("CharacterCreateFrame");

	RaceAndClassFrame = self.RaceAndClassFrame;
	NameChoiceFrame = self.NameChoiceFrame;
	ClassTrialSpecs = self.ClassTrialSpecs;
	ZoneChoiceFrame = self.ZoneChoiceFrame;
	NewPlayerTutorial = self.NewPlayerTutorial;
	FactionDetailsList = self.DetailsListVerticalLayoutFrame.FactionDetailsList;
	RaceDetailsList = self.DetailsListVerticalLayoutFrame.RaceDetailsList;
	ClassDetailsList = self.DetailsListVerticalLayoutFrame.ClassDetailsList;

	CharCustomizeFrame:AttachToParentFrame(self);
	CharCustomizeFrame:SetOptionsSpacingConfiguration(CharCustomizeFrame.Categories, self.ForwardButton);

	self:ResetNavBlockers();

	self.ForwardButton.tooltip = function()
		return self.currentNavBlocker and RED_FONT_COLOR:WrapTextInColorCode(self.currentNavBlocker.error);
	end

	self.BackButton:UpdateText(BACK, BACKWARD_ARROW);

	self.BackButton:SetCustomizationFrame(CharCustomizeFrame);
	self.ForwardButton:SetCustomizationFrame(CharCustomizeFrame);
	self.NameChoiceFrame.RandomNameButton:SetCustomizationFrame(CharCustomizeFrame);

	self.DetailsListVerticalLayoutFrame:SetBottomFrame(SDToggleButton);
	FactionDetailsList.originalHeight = FactionDetailsList:GetHeight();
	RaceDetailsList.originalHeight = RaceDetailsList:GetHeight();
	ClassDetailsList.originalHeight = ClassDetailsList:GetHeight();

	self:SetSequence(0);
	self:SetCamera(0);
	self:OnDisplaySizeChanged();

	self:RegisterForInterfaceTransitions();
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

			-- Make sure realm confirmation dialog is marked to not show from now on.
			SetCVar("showCreateCharacterRealmConfirmDialog", 0);

			self.RaceAndClassFrame.ClassTrialCheckButton:ResetDesiredState();
			GlueParent_SetScreen("charselect");
			C_Log.LogMessage("From CharacterCreateMixin:OnEvent");
		else
			showError = errorCode;
		end
	elseif event == "RACE_FACTION_CHANGE_STARTED" then
		local changeType = ...;
		if changeType == "RACE" then
			StaticPopup_Show("PAID_SERVICE_IN_PROGRESS", RACE_CHANGE_IN_PROGRESS);
		elseif changeType == "FACTION" then
			StaticPopup_Show("PAID_SERVICE_IN_PROGRESS", FACTION_CHANGE_IN_PROGRESS);
		end
	elseif event == "RACE_FACTION_CHANGE_RESULT" then
		local success, errorCode = ...;
		if success then
			StaticPopup_Hide("PAID_SERVICE_IN_PROGRESS");
			GlueParent_SetScreen("charselect");
			C_Log.LogMessage("From RACE_FACTION_CHANGE_RESULT");
		else
			showError = errorCode;
		end
	elseif event == "CUSTOMIZE_CHARACTER_STARTED" then
		StaticPopup_Show("PAID_SERVICE_IN_PROGRESS", CHAR_CUSTOMIZE_IN_PROGRESS);
	elseif event == "CUSTOMIZE_CHARACTER_RESULT" then
		local success, errorCode = ...;
		if success then
			StaticPopup_Hide("PAID_SERVICE_IN_PROGRESS");
			GlueParent_SetScreen("charselect");
			C_Log.LogMessage("From CUSTOMIZE_CHARACTER_RESULT");
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
			CustomizationUtil.UpdateShowDebugTooltipInfo();
			if RaceAndClassFrame:IsShown() then
				RaceAndClassFrame:UpdateButtons();
			end
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
		StaticPopup_Show("CHARACTER_CREATE_FAILURE", _G[showError]);
	end
end

function CharacterCreateMixin:OnShow()
	C_CharacterCreation.SetInCharacterCreate(true);

	local _, selectedFaction;
	local existingCharacterID = self:GetExistingCharacterID();
	if existingCharacterID then
		C_CharacterCreation.CustomizeExistingCharacter(existingCharacterID);
		self.currentPaidServiceName = C_PaidServices.GetName();
		self.currentPaidServiceSurname = C_PaidServices.GetSurname();
		_, selectedFaction = C_PaidServices.GetCurrentFaction();
		local fullCharacterCreateDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.FullCharacterCreateDisabled);
		if not fullCharacterCreateDisabled then
			NameChoiceFrame.EditBox:SetText(self.currentPaidServiceName or "");
			NameChoiceFrame.EditBoxSurname:SetText(self.currentPaidServiceSurname or "");
		end
	else
		self.currentPaidServiceName = nil;
		C_CharacterCreation.ResetCharCustomize();
		if not C_GameRules.IsPlunderstorm() then
			NameChoiceFrame.EditBox:SetText("");
			NameChoiceFrame.EditBoxSurname:SetText("");
		end

		if C_Reincarnation.IsReincarnating() then
			local guid, charName = C_Reincarnation.GetReincarnatingCharacter();
			NameChoiceFrame.EditBox:SetText(charName);
			NameChoiceFrame.EditBox:Disable();
			NameChoiceFrame.EditBoxSurname:SetText(""); -- TODO (CAM-6168): Use surname from C_Reincarnation.GetReincarnatingCharacter
			NameChoiceFrame.EditBoxSurname:Disable();
			CharacterCreateRandomName:Disable();
		else
			NameChoiceFrame.EditBox:SetText("");
			NameChoiceFrame.EditBoxSurname:SetText("");
		end

		if C_GameRules.IsHardcoreActive() then
			if (C_Reincarnation.IsReincarnating()) then
				self.ForwardButton:SetText(DEATH_REINCARNATE_CHARACTER);
			else
				self.ForwardButton:SetText(CHARACTER_CREATE_ACCEPT);
			end
		end
	end

	local instantRotate = true;
	self:SetMode(CHAR_CREATE_MODE_CLASS_RACE, instantRotate);
	self:ResetNavBlockers();
	self:RefreshCurrentNavBlocker();

	self:UpdateRecruitInfo();

	RaceAndClassFrame:UpdateState(selectedFaction);
	self.DetailsListVerticalLayoutFrame:Layout();
	self:UpdateDetailsLists();
end

local rafHelpTipInfo = {
	buttonStyle = HelpTip.ButtonStyle.Okay,
	offsetY = 100,
	autoEdgeFlipping = true,
};

function CharacterCreateMixin:UpdateRecruitInfo()
	--[[
	local active, faction = C_RecruitAFriend.GetRecruitInfo();
	if active and not self:HasService() and C_CharacterCreation.UseBeginnerMode() then
		local recruiterIsHorde = (PLAYER_FACTION_GROUP[faction] == "Horde");
		rafHelpTipInfo.text = recruiterIsHorde and RECRUIT_A_FRIEND_FACTION_SUGGESTION_HORDE or RECRUIT_A_FRIEND_FACTION_SUGGESTION_ALLIANCE;
		rafHelpTipInfo.targetPoint = recruiterIsHorde and HelpTip.Point.RightEdgeCenter or HelpTip.Point.LeftEdgeCenter;
		rafHelpTipInfo.offsetX = recruiterIsHorde and 10 or -10;

		local anchorFrame = recruiterIsHorde and RaceAndClassFrame.HordeContainer.HordeRaces or RaceAndClassFrame.AllianceContainer.AllianceRaces;
		HelpTip:Show(anchorFrame, rafHelpTipInfo);
	end
	]]--
end

function CharacterCreateMixin:UpdateTimerunningChoice()
	-- Currently timerunning choice only affects the Class Trial button which is updated as part of this call.
	RaceAndClassFrame:UpdateState();
end

function CharacterCreateMixin:UpdateDetailsLists()
	local fullHeight = FactionDetailsList:GetHeight() + RaceDetailsList:GetHeight() + ClassDetailsList:GetHeight();
	local availableHeight = self.DetailsListVerticalLayoutFrame:GetAvailableSpace();

	if fullHeight > availableHeight then
		-- shrink each detail pane
		local spacing = 20;
		availableHeight = availableHeight - spacing;
		local heightPerPane = availableHeight / 3;

		FactionDetailsList:SetHeight(heightPerPane);
		RaceDetailsList:SetHeight(heightPerPane);
		ClassDetailsList:SetHeight(heightPerPane);
	else
		FactionDetailsList:SetHeight(FactionDetailsList.originalHeight);
		RaceDetailsList:SetHeight(RaceDetailsList.originalHeight);
		ClassDetailsList:SetHeight(ClassDetailsList.originalHeight);
		self.DetailsListVerticalLayoutFrame:Layout();
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
		C_CharacterServices.AssignRaceOrFactionChangeDistribution(self.vasInfo.selectedCharacterGUID, self:GetSelectedName(), self:GetSelectedSurname(), noIsValidateOnly, self.vasType);
	end
end

function CharacterCreateMixin:IsVASErrorUserFixable(errorID)
	return errorID == Enum.VasTransactionPurchaseResult.DbNameNotAvailable or errorID == Enum.VasTransactionPurchaseResult.DbDuplicateCharacterName;
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
		local text2 = nil;
		StaticPopup_Show("CHARACTER_CREATE_VAS_ERROR", displayMsg, text2, exitAfterError);
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
			local text2 = nil;
			StaticPopup_Show("CHARACTER_CREATE_VAS_ERROR", errorMsg, text2, exitAfterError);
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

-- Mouse rotation, model fading and rotate-to-target can all run at the same time, so they share
-- a single OnUpdate script through this dispatcher instead of overwriting each other's handler.
function CharacterCreateMixin:SetUpdateActive(updateKey, isActive)
	self.activeUpdates[updateKey] = isActive or nil;
	self:SetScript("OnUpdate", next(self.activeUpdates) and self.OnUpdateAnimations or nil);
end

function CharacterCreateMixin:OnUpdateAnimations(elapsed)
	if self.activeUpdates[UPDATE_MOUSE_ROTATE] then
		self:OnUpdateMouseRotate();
	end

	if self.activeUpdates[UPDATE_ALPHA_CHARACTER] then
		self:OnUpdateAlphaCharacter(elapsed);
	end

	if self.activeUpdates[UPDATE_ROTATE_TO_TARGET] then
		self:OnUpdateRotateSubjectToTarget(elapsed);
	end
end

function CharacterCreateMixin:OnMouseDown(button)
	if not RaceAndClassFrame:IsPlayingClassAnimtion() then
		self.lastCursorPosX = GetCursorPosition();
		self.mouseRotating = true;
		self:SetUpdateActive(UPDATE_ROTATE_TO_TARGET, false);
		self:SetUpdateActive(UPDATE_MOUSE_ROTATE, true);
	end
end

function CharacterCreateMixin:OnMouseUp(button)
	self:SetUpdateActive(UPDATE_MOUSE_ROTATE, false);
	self.mouseRotating = false;
end

function CharacterCreateMixin:OnKeyDown(key)
	if key == "ESCAPE" then
		self:NavBack();
		return false;
	elseif key == "ENTER" then
		self:NavForward();
		return false;
	elseif key == "PRINTSCREEN" then
		Screenshot();
		return false;
	end
	return true;
end

function CharacterCreateMixin:OnUpdateMouseRotate()
	local x = GetCursorPosition();
	if x ~= self.lastCursorPosX then
		RaceAndClassFrame:ClearClassAnimationCountdown();

		local diff = (x - self.lastCursorPosX) * self.RotationConstant;
		C_CharacterCreation.SetCharacterCreateFacing(C_CharacterCreation.GetCharacterCreateFacing() + diff);

		self.lastCursorPosX = x;
	end
end

function CharacterCreateMixin:UpdateBackgroundModel()
	local bgModelID = C_GameRules.GetGameRuleAsFloat(Enum.GameRule.CharacterCreateUseFixedBackgroundModel);
	bgModelID = (bgModelID > 0) and bgModelID or C_CharacterCreation.GetCreateBackgroundModel();
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

function CharacterCreateMixin:UpdateCharCustomizationFrame(alsoReset, dontResetCamera)
	local customizationCategoryData = C_CharacterCreation.GetAvailableCustomizations();
	if not customizationCategoryData then
		-- This means we are calling GetAvailableCustomizations when there is no character component set up. Do nothing
		return;
	end

	if alsoReset then
		CharCustomizeFrame:Reset();
	end

	CharCustomizeFrame:SetCustomizations(customizationCategoryData, dontResetCamera);
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
		self:SetUpdateActive(UPDATE_ALPHA_CHARACTER, false);
		return;
	end

	local currentAlpha = C_CharacterCreation.GetModelAlpha();
	local alphaDiff = targetAlpha - currentAlpha;
	self.perSecondAlpha = alphaDiff / duration;
	self.targetAlpha = targetAlpha;
	self:SetUpdateActive(UPDATE_ALPHA_CHARACTER, true);
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
		self:SetUpdateActive(UPDATE_ALPHA_CHARACTER, false);
	else
		C_CharacterCreation.SetModelAlpha(newAlpha);
	end
end

function CharacterCreateMixin:SetMode(mode, instantRotate)
	self:ResetSubjectRotation(mode, instantRotate);

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
		C_CharacterCreation.SetSelectedPreviewGearType(Enum.NewCharGear.Preview);

		if self:IsMode(CHAR_CREATE_MODE_CUSTOMIZE) then
			self.BottomBackgroundOverlay.FadeIn:Play();
			self:RemoveNavBlocker(CHARACTER_CREATION_REQUIREMENTS_NEED_ACHIEVEMENT);
		end
	elseif mode == CHAR_CREATE_MODE_CUSTOMIZE then
		if self:IsMode(CHAR_CREATE_MODE_CLASS_RACE) then
			RaceAndClassFrame:PlayCustomizationAnimation();

			C_CharacterCreation.SetBlurEnabled(true);
			C_CharacterCreation.SetSelectedPreviewGearType(Enum.NewCharGear.Start);

			self.BottomBackgroundOverlay.FadeOut:Play();

			CharCustomizeFrame:SetSelectedData(RaceAndClassFrame.selectedRaceData, RaceAndClassFrame.selectedSexID, C_CharacterCreation.IsViewingAlteredForm());

			-- We are entering customize mode. Grab the customizations for the selected race & sex and send it to CharCustomizeFrame before showing it
			local reset = true;
			self:UpdateCharCustomizationFrame(reset);

			ClassTrialSpecs:SetClass(RaceAndClassFrame.selectedClassID, RaceAndClassFrame.selectedSexID);
			ZoneChoiceFrame:Setup();

			CharacterCreateSelfFoundButton:CheckSelfFoundButton()

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
	FactionDetailsList:SetShown(mode == CHAR_CREATE_MODE_CLASS_RACE);
	RaceDetailsList:SetShown(mode == CHAR_CREATE_MODE_CLASS_RACE);
	ClassDetailsList:SetShown(mode == CHAR_CREATE_MODE_CLASS_RACE);
	CharCustomizeFrame:SetShown(mode == CHAR_CREATE_MODE_CUSTOMIZE);
	ClassTrialSpecs:SetShown(mode == CHAR_CREATE_MODE_CUSTOMIZE and (C_CharacterCreation.GetCharacterCreateType() == Enum.CharacterCreateType.TrialBoost));
	if not C_GameRules.IsPlunderstorm() then
		NameChoiceFrame:SetShown(mode == CHAR_CREATE_MODE_CUSTOMIZE);
	end
	ZoneChoiceFrame:SetShown(mode == CHAR_CREATE_MODE_ZONE_CHOICE);
	NewPlayerTutorial:SetShown(mode == CHAR_CREATE_MODE_CUSTOMIZE and C_CharacterCreation.UseBeginnerMode());

	self.currentMode = mode;
	self.creatingCharacter = false;
	self:UpdateForwardButton();
	self:UpdateBackButton();
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
	if self:IsMode(CHAR_CREATE_MODE_CLASS_RACE) then
		if Kiosk.IsEnabled() and not Kiosk.CanUserReturnToSplash then
			return;
		end

		if CharacterUpgrade_IsCreatedCharacterTrialBoost() or CharacterUpgrade_IsCreatedCharacterUpgrade() then
			CharacterUpgrade_ResetBoostData();
		end

		self:Exit();
	else
		self.RaceAndClassFrame.ClassTrialCheckButton:ResetDesiredState();
		self:UpdateMode(-1);
		self:CheckDynamicNavBlockers();
	end

	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CANCEL);
end

function CharacterCreateMixin:Exit()
	self.RaceAndClassFrame.ClassTrialCheckButton:ResetDesiredState();

	CharacterSelect.backFromCharCreate = true;
	local screenName = C_GameRules.GetGameModeGlueScreenName();
	if screenName then
		GlueParent_SetScreen(screenName);
	else
		GlueParent_SetScreen("charselect");
		C_Log.LogMessage("From CharacterCreateMixin:Exit");
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
		EventRegistry:RegisterCallback("Customization.OnSetCustomizations", self.CheckDynamicNavBlockers, self);
		EventRegistry:RegisterCallback("Customization.OnCategorySelected", function(owner, hadCategoryChange)
			if hadCategoryChange then
				self:SetMissingOptionsNavBlockersEnabled(false);
			end
		end, self);
	else
		EventRegistry:UnregisterCallback("Customization.OnSetCustomizations", self);
		EventRegistry:UnregisterCallback("Customization.OnCategorySelected", self);
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
	if C_GameRules.IsPlunderstorm() then
		return "";
	end
	return NameChoiceFrame.EditBox:GetText();
end

function CharacterCreateMixin:GetSelectedSurname()
	if (not NameChoiceFrame.EditBoxSurname:IsShown()) then
		return "";
	end
	return NameChoiceFrame.EditBoxSurname:GetText();
end

function CharacterCreateMixin:GetCreateCharacterFaction()
	return RaceAndClassFrame:GetCreateCharacterFaction();
end

function CharacterCreateMixin:CreateCharacter()
	if CharacterCreateSelfFound then
		C_CharacterCreation.ToggleSelfFoundMode(CharacterCreateSelfFound:GetChecked());
	end

	if self.paidServiceType then
		StaticPopup_Show("CONFIRM_PAID_SERVICE");
	elseif self.vasType == Enum.ValueAddedServiceType.PaidFactionChange or self.vasType == Enum.ValueAddedServiceType.PaidRaceChange then
		StaticPopup_Show("CONFIRM_VAS_FACTION_CHANGE");
	else
		self.creatingCharacter = true;
		self:UpdateForwardButton();

		-- TODO CAM-7227: Put hardcore confirmation button here

		C_CharacterCreation.CreateCharacter(self:GetSelectedName(), self:GetSelectedSurname(), ZoneChoiceFrame.useNPE, RaceAndClassFrame:GetCreateCharacterFaction());
		local screenName = C_GameRules.GetGameModeGlueScreenName();
		if screenName then
			GlueParent_SetScreen(screenName);
			C_Log.LogMessage("From CharacterCreateMixin:CreateCharacter");
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

function CharacterCreateMixin:ResetSubjectRotation(mode, instantRotate)
	self:RotateSubjectToTarget(C_CharacterCreation.GetDefaultCharacterCreateFacing(), instantRotate and 0 or ROTATION_ADJUST_SECONDS);
end

function CharacterCreateMixin:ZoomCamera(zoomAmount, zoomTime, force)
	C_CharacterCreation.ZoomCamera(zoomAmount, zoomTime or ZOOM_TIME_SECONDS, force or false);
end

function CharacterCreateMixin:GetCurrentCameraZoom()
	return C_CharacterCreation.GetCurrentCameraZoom();
end

function CharacterCreateMixin:RotateSubject(rotationAmount)
	C_CharacterCreation.SetCharacterCreateFacing(C_CharacterCreation.GetCharacterCreateFacing() + rotationAmount);
end

function CharacterCreateMixin:RotateSubjectToTarget(targetRotation, duration)
	if not self.mouseRotating then
		local currentRotation = C_CharacterCreation.GetCharacterCreateFacing();

		if duration == 0 then
			C_CharacterCreation.SetCharacterCreateFacing(targetRotation);
			self:SetUpdateActive(UPDATE_ROTATE_TO_TARGET, false);
			return;
		end

		local rotationDiff = targetRotation - currentRotation;
		self.isRotationNegative = (rotationDiff < 0);
		self.perSecondRotation = rotationDiff / duration;
		self.targetRotation = targetRotation;
		self:SetUpdateActive(UPDATE_ROTATE_TO_TARGET, true);
	end
end

function CharacterCreateMixin:OnUpdateRotateSubjectToTarget(elapsed)
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
		self:SetUpdateActive(UPDATE_ROTATE_TO_TARGET, false);
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
			PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_CREATE_NEW);
			self:UpdateMode(1);
		elseif self:IsMode(CHAR_CREATE_MODE_CUSTOMIZE) and ZoneChoiceFrame:ShouldShow() then
			PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_CREATE_NEW);
			self:UpdateMode(1);
			-- Suppress narration on the ForwardButton when transitioning.
			-- The mouse cursor is likely still over the button, and we don't want it to interrupt
			-- any OnShow narration. The flag is cleared when the mouse leaves.
			self.ForwardButton.suppressFocusNarration = true;
		else
			if (HardcorePopUpFrame and C_GameRules.IsHardcoreActive() and not HardcorePopUpFrame:IsShown()) then
				HardcorePopUpFrame:ShowCharacterCreationWarning();
			else
				PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CREATE_CHAR);
				self:CreateCharacter();
				self.ForwardButton:SetEnabled(false);
				local fullCharacterCreateDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.FullCharacterCreateDisabled);
				if fullCharacterCreateDisabled then
					CharacterCreateFrame:Exit();
				end
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

	if (InputUtil.IsGamepadUIEnabled()) then
		if self:IsMode(CHAR_CREATE_MODE_CLASS_RACE) then
			RaceAndClassFrame.footer:Refresh();
		end
	end
end

function CharacterCreateMixin:UpdateBackButton()
	if Kiosk.IsEnabled() then
		self.BackButton:SetEnabled(not self:IsMode(CHAR_CREATE_MODE_CLASS_RACE));
	end
end

function CharacterCreateMixin:RegisterForInterfaceTransitions()
	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetupGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end

function CharacterCreateMixin:SetupGamepad()
	CharCustomizeFrame:SetupGamepad();
end

function CharacterCreateMixin:InitializeGamepad()
	-- Applies to RaceAndClassFrame and CharCustomizeFrame.
	self.BackButton:Hide();
	self.NameChoiceFrame.RandomNameButton:Hide();
	self.ForwardButton:Hide();

	CharCustomizeFrame:InitializeGamepad();

	if CharCustomizeFrame:IsShown() and self:IsMode(CHAR_CREATE_MODE_CUSTOMIZE) then
		GamepadMode.FrameControlsManager:FrameShown(CharCustomizeFrame);
	end
end

function CharacterCreateMixin:UninitializeGamepad()
	-- Applies to RaceAndClassFrame and CharCustomizeFrame.
	self.BackButton:Show();
	self.ForwardButton:Show();

	if (GetLocale() == "enUS") then
		self.NameChoiceFrame.RandomNameButton:Show();	-- Random name button is for US locale only.
	end

	CharCustomizeFrame:UninitializeGamepad();
end

function CharacterCreateMixin:OnSmartNavFocus()
	if (self:IsMode(CHAR_CREATE_MODE_CLASS_RACE)) then
		GamepadMode.FrameControlsManager:FocusFrame(self.RaceAndClassFrame);
	elseif (self:IsMode(CHAR_CREATE_MODE_CUSTOMIZE)) then
		GamepadMode.FrameControlsManager:FocusFrame(CharCustomizeFrame);
	end
end

CharacterCreateNavButtonMixin = {};

function CharacterCreateNavButtonMixin:GetAppropriateTooltip()
	return CustomizationNoHeaderTooltip;
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
	end, self);
end

-- Suppress narration while the flag is set, so moving the mouse while still hovering
-- over the button doesn't interrupt narration when transitioning forward.
function CharacterCreateNavForwardButtonMixin:NarrationShouldIgnoreFocus()
	return self.suppressFocusNarration;
end

-- Suppress click-replay narration while the flag is set, so the GLOBAL_MOUSE_UP fired
-- immediately after the click doesn't interrupt narration when transitioning forward.
function CharacterCreateNavForwardButtonMixin:NarrationShouldIgnoreFocusReplay()
	return self.suppressFocusNarration;
end

-- Once the mouse leaves the button the suppression is no longer needed; the user has
-- deliberately moved away and hovering back should narrate normally.
function CharacterCreateNavForwardButtonMixin:OnLeave()
	CharacterCreateNavButtonMixin.OnLeave(self);
	self.suppressFocusNarration = nil;
end

CharacterCreateClassButtonMixin = CreateFromMixins(CustomizationMaskedButtonMixin);

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

function CharacterCreateClassButtonMixin:OnLeave()
	if self:IsDisabledByRace() or self.smartNavForcedRefresh then
		RaceAndClassFrame:SetClassValidRaces(nil);
	end
end

function CharacterCreateClassButtonMixin:NarrationGetName()
	return self.classData and self.classData.name or nil;
end

function CharacterCreateClassButtonMixin:NarrationGetContext()
	if not self:IsEnabled() then
		return NARRATION_STATUS_DISABLED_FORMAT:format(NARRATION_OBJECT_BUTTON);
	end

	if self:GetChecked() then
		return NARRATION_STATUS_SELECTED_FORMAT:format(NARRATION_OBJECT_BUTTON);
	end

	return NARRATION_OBJECT_BUTTON;
end

function CharacterCreateClassButtonMixin:NarrationGetDescription()
	local classDescription = nil;
	if self.classData and self.classData.description and self:IsEnabled() then
		classDescription = self.classData.description;
	end

	return classDescription;
end

function CharacterCreateClassButtonMixin:NarrationShouldIgnoreFocusReplay()
	return true;
end

function CharacterCreateClassButtonMixin:GetDebugName()
	return self.classData and self.classData.name or nil;
end

CharacterCreateRaceButtonMixin = CreateFromMixins(CustomizationMaskedButtonMixin);

function CharacterCreateRaceButtonMixin:GetAppropriateTooltip()
	return CharCreateTooltip;
end

function CharacterCreateRaceButtonMixin:SetRace(raceData, selectedRaceID, selectedFaction, layoutIndex)
	self.raceData = raceData;
	self.layoutIndex = layoutIndex;

	self:SetIconAtlas(raceData.createScreenIconAtlas);

	local fullCharacterCreateDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.FullCharacterCreateDisabled);
	if not fullCharacterCreateDisabled then
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

	self.New:SetShown(self.raceData.isAlliedRace and CharacterLoginUtil.IsNewAlliedRace(self.raceData.raceID));

	self.RaceName.Text:SetText(raceData.name);
	self.RaceName:SetShown(C_CharacterCreation.UseBeginnerMode());

	if selectedRaceID == raceData.raceID and selectedFaction == self.faction then
		self:SetChecked(true);
	else
		self:SetChecked(false);
	end

	self:UpdateHighlightTexture();
end

function CharacterCreateRaceButtonMixin:OnClick()
	local reselectClassButtonFocusedBySmartNav;
	if (InputUtil.IsGamepadUIEnabled()) then
		local smartNavCurrentButton = SmartNavigation:GetCurrentButton();

		-- Is the current button a class button?
		if (smartNavCurrentButton and smartNavCurrentButton.classData) then
			--[[
				Handle an edge case where the player is using gamepad mode and
				race button was clicked with the smart nav cursor being on a class
				button instead of the race button.

				If the smart nav cursor was on an invalid class which is now valid
				the invalid animation would continue to play or if it was on a valid class it
				wouldn't be playing when it should be.
			]]
			reselectClassButtonFocusedBySmartNav = true;
		end
	end

	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
	RaceAndClassFrame:SetCharacterRace(self.raceData.raceID, self.faction);

	if (reselectClassButtonFocusedBySmartNav) then
		local classButton = SmartNavigation:GetCurrentButton();
		classButton.smartNavForcedRefresh = true;
		SmartNavigation:ReselectCurrentButton();
		classButton.smartNavForcedRefresh = nil;
	end
end

function CharacterCreateRaceButtonMixin:NarrationGetName()
	if not self.raceData then
		return nil;
	end

	local factionName = nil;
	if self.faction == "Alliance" then
		factionName = FACTION_ALLIANCE;
	elseif self.faction == "Horde" then
		factionName = FACTION_HORDE;
	end

	return NarrationUtil.MakeNarrationString(self.raceData.name, factionName);
end

function CharacterCreateRaceButtonMixin:NarrationGetContext()
	if not self:IsEnabled() then
		return NARRATION_STATUS_DISABLED_FORMAT:format(NARRATION_OBJECT_BUTTON);
	end

	if self:GetChecked() then
		return NARRATION_STATUS_SELECTED_FORMAT:format(NARRATION_OBJECT_BUTTON);
	end

	return NARRATION_OBJECT_BUTTON;
end

CharacterCreateNarrationUtil = CharacterCreateNarrationUtil or {};

function CharacterCreateNarrationUtil.GetRacialTraitsNarration(raceData)
	if not raceData or not raceData.racialAbilities then
		return nil;
	end

	local racialTraits = {};
	for _, racialAbilityInfo in ipairs(raceData.racialAbilities) do
		if racialAbilityInfo.description and racialAbilityInfo.description ~= "" then
			table.insert(racialTraits, racialAbilityInfo.description);
		end
	end

	if #racialTraits == 0 then
		return nil;
	end

	local racialTraitsText = table.concat(racialTraits, NARRATION_SEPARATOR);
	return NarrationUtil.MakeNarrationString(RACIAL_TRAITS_TOOLTIP, racialTraitsText);
end

function CharacterCreateRaceButtonMixin:NarrationGetDescription()
	local raceDescription = self.raceData and self.raceData.loreDescription or nil;
	local racialTraitsNarration = CharacterCreateNarrationUtil.GetRacialTraitsNarration(self.raceData);

	return NarrationUtil.MakeNarrationString(racialTraitsNarration, raceDescription);
end

function CharacterCreateRaceButtonMixin:NarrationShouldIgnoreFocusReplay()
	return true;
end

function CharacterCreateRaceButtonMixin:GetDebugName()
	return self.raceData and self.raceData.name or nil;
end

CharacterCreateSpecButtonMixin = CreateFromMixins(CustomizationMaskedButtonMixin);

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

	if CustomizationUtil.ShouldShowDebugTooltipInfo() then
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
	return CharCreateTooltip;
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
	elseif race == "Harronir" then
		if sex == Enum.UnitSex.Female then
			return { displayID = 126275, spellVisualKitID = 258851 };
		else
			return { displayID = 126277, spellVisualKitID = 258851 };
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
	elseif race == "VoidElf" then
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
	self.rightStickScrollSpeed = 0;

	-- Choose a random faction to be used if Pandaren is chosen as the random race
	local randomFaction = math.random(0, 1);
	self.selectedFaction = PLAYER_FACTION_GROUP[randomFaction];

	self.AllianceContainer.Text:SetText(string.upper(FACTION_ALLIANCE));
	self.HordeContainer.Text:SetText(string.upper(FACTION_HORDE));

	self.ClassTrialCheckButton.Button:SetScript("OnEnter", function() self.ClassTrialCheckButton.OnEnter(self.ClassTrialCheckButton); end);
	self.ClassTrialCheckButton.Button:SetScript("OnLeave", function() self.ClassTrialCheckButton.OnLeave(self.ClassTrialCheckButton); end);

	local function ResetPoolFrame(_, frameToReset)
		SmartNavigation_ClearJumpNavigationOverrides(frameToReset);
	end

	self.Classes.originalHeight = self.Classes:GetHeight();
	self.Classes.originalWidth = self.Classes:GetWidth();

	self.buttonPool = CreateFramePoolCollection();
	self.buttonPool:CreatePool("CHECKBUTTON", self.BodyTypes, "CharCreateBodyTypeButtonTemplate", ResetPoolFrame);
	self.buttonPool:CreatePool("CHECKBUTTON", self.AllianceContainer.AllianceRaces, "CharacterCreateAllianceButtonTemplate", ResetPoolFrame);
	self.buttonPool:CreatePool("CHECKBUTTON", self.HordeContainer.HordeRaces, "CharacterCreateHordeButtonTemplate", ResetPoolFrame);
	self.buttonPool:CreatePool("CHECKBUTTON", self.Classes, "CharacterCreateClassButtonTemplate", ResetPoolFrame);

	local backButton = self:GetParent().BackButton;
	self.AllianceContainer.AllianceRaces:SetBottomFrame(backButton);
	self.HordeContainer.HordeRaces:SetBottomFrame(backButton);



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

	self:RegisterForInterfaceTransitions();
end

function CharacterCreateRaceAndClassMixin:GetCreateCharacterFaction()
	if self.selectedRaceData.isNeutralRace and self.selectedClassData.earlyFactionChoice then
		-- For neutral races, if the player selected an earlyFactionChoice class (DK) we ALWAYS need to pass back the selected faction, because the creation process will fail if we try to create a Neutral character of this class
		return self.selectedFaction;
	elseif self.ClassTrialCheckButton.Button:GetChecked() then
		-- Class Trials need to use no faction...their faction choice is sent up separately after the character is created
		return nil;
	elseif self.selectedRaceData.isNeutralRace then
		if C_CharacterCreation.IsUsingCharacterTemplate() or C_CharacterCreation.IsForcingCharacterTemplate() or ZoneChoiceFrame.useNPE or CharacterCreateFrame:HasService() or C_CharacterCreation.IsTimerunningEnabled() then
			-- For neutral races, if the player is using a character template, chose to start in the NPE or is using a paid service we need to pass back the selected faction (or timerunning which also skips the faction choice)
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
	return CharacterServices_CanTrialBoostCharacter() and
		not CharacterCreateFrame:HasService() and
		(C_CharacterCreation.GetCharacterCreateType() ~= Enum.CharacterCreateType.Boost) and
		not C_CharacterCreation.IsTimerunningEnabled();
end

function CharacterCreateRaceAndClassMixin:UpdateClassTrialButtonVisibility()
	local showTrialBoost = self:CanTrialBoostCharacter();
	local isVisibilityChanging = showTrialBoost ~= self.ClassTrialCheckButton:IsVisible();

	self.ClassTrialCheckButton:SetShown(showTrialBoost);
	self.ClassTrialCheckButton:UpdateDesiredState(showTrialBoost, isVisibilityChanging);
end

function CharacterCreateRaceAndClassMixin:OnShow()
	local useNewPlayerMode = C_CharacterCreation.UseBeginnerMode();
	local alwaysAllowAlliedRaces = C_GameRules.IsGameRuleActive(Enum.GameRule.AlwaysAllowAlliedRaces);

	self.ClassTrialCheckButton:ClearTooltipLines();
	self.ClassTrialCheckButton:AddTooltipLine(CHARACTER_TYPE_FRAME_TRIAL_BOOST_CHARACTER_TOOLTIP:format(C_CharacterCreation.GetTrialBoostStartingLevel()));

	if (InputUtil.IsGamepadUIEnabled()) then
		GamepadMode.FrameControlsManager:FrameShown(self);
	end
end

function CharacterCreateRaceAndClassMixin:OnHide()
	if (InputUtil.IsGamepadUIEnabled()) then
		GamepadMode.FrameControlsManager:FrameHidden(self);
	end
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
			self:GetParent():RotateSubjectToTarget(C_CharacterCreation.GetDefaultCharacterCreateFacing(), 0);

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
	CharacterCreateFrame:ResetSubjectRotation(nil, true);
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

	local fullCharacterCreateDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.FullCharacterCreateDisabled);
	if fullCharacterCreateDisabled then
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

	local classes = C_CharacterCreation.GetAvailableClasses();

	-- GetSelectedClass() returns a minimal data table. Search GetAvailableClasses() for the
	-- matching entry, which carries the full data (description, roleInfo, etc.).
	local selectedClass = C_CharacterCreation.GetSelectedClass();
	self.selectedClassData = selectedClass;
	for _, classData in ipairs(classes) do
		if classData.classID == selectedClass.classID then
			self.selectedClassData = classData;
			break;
		end
	end

	self.selectedClassID = self.selectedClassData.classID;
	self.selectedSexID = C_CharacterCreation.GetSelectedSex();

	local usingNewBGModel = CharacterCreateFrame:UpdateBackgroundModel();
	CharacterCreateFrame:UpdateBackgroundOverlays(self.selectedClassData, self.selectedRaceData);

	CharacterCreateFrame:RemoveNavBlocker(CHAR_FACTION_CHANGE_SWAP_FACTION);
	CharacterCreateFrame:RemoveNavBlocker(CHAR_FACTION_CHANGE_CHOOSE_RACE);
	CharacterCreateFrame:UpdateForwardButton();

	-- Auto-select a valid class if the current class is incompatible with the selected race.
	if self.selectedClassData.disabledReason == Enum.CreationClassDisabledReason.InvalidForSelectedRace then
		for _, classData in ipairs(classes) do
			if classData.enabled then
				C_CharacterCreation.SetSelectedClass(classData.classID);
				self.selectedClassData = classData;
				self.selectedClassID = classData.classID;
				break;
			end
		end
	end

	-- Update the three detail scrollboxes.
	FactionDetailsList:SetupFactionDetails(self.selectedRaceData, self.selectedFaction);
	RaceDetailsList:SetupRacialDetails(self.selectedRaceData);
	ClassDetailsList:SetupClassDetails(self.selectedClassData);

	self:UpdateButtons();
	self:UpdateClassTrialButtonVisibility();
end

function CharacterCreateRaceAndClassMixin:SetCharacterRace(raceID, faction)
	if self.selectedRaceID ~= raceID then
		CharacterCreateFrame:ResetSubjectRotation(nil, true);
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
		CharacterCreateFrame:ResetSubjectRotation(nil, true);
		self.allowClassAnimationsAfterSeconds = CLASS_ANIM_WAIT_TIME_SECONDS;
		self:ClearCurrentSpellVisualKit();
		C_CharacterCreation.SetSelectedSex(sexID);
	end

	self:UpdateState();
end

function CharacterCreateRaceAndClassMixin:GetRaceButtonTemplates(raceData)
	if raceData.isNeutralRace then
		return "CharacterCreateAllianceButtonTemplate", "CharacterCreateHordeButtonTemplate";
	elseif raceData.factionInternalName == "Alliance" then
		return "CharacterCreateAllianceButtonTemplate"
	else
		return "CharacterCreateHordeButtonTemplate"
	end
end

function CharacterCreateRaceAndClassMixin:LayoutButtons()
	self.BodyTypes:MarkDirty();
	self.AllianceContainer.AllianceRaces:MarkDirty();
	self.HordeContainer.HordeRaces:MarkDirty();
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
			currentFaction = GetBasicCharacterInfo(CharacterCreateFrame.vasInfo.selectedCharacterGUID).faction;
		end
		local currentClass = C_PaidServices.GetCurrentClassID();
		return (currentFaction ~= faction and C_CharacterCreation.IsRaceClassValid(raceData.raceID, currentClass));
	elseif CharacterCreateFrame.paidServiceType == PAID_RACE_CHANGE or CharacterCreateFrame.vasType == Enum.ValueAddedServiceType.PaidRaceChange then
		local _, currentFaction = C_PaidServices.GetCurrentFaction();
		if CharacterCreateFrame.vasType == Enum.ValueAddedServiceType.PaidRaceChange then
			currentFaction = GetBasicCharacterInfo(CharacterCreateFrame.vasInfo.selectedCharacterGUID).faction;
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
		self.buttonPool:ReleaseAllByTemplate("CharCreateBodyTypeButtonTemplate");
	end

	local sexes = {Enum.UnitSex.Male, Enum.UnitSex.Female};
	for index, sexID in ipairs(sexes) do
		local button = self.buttonPool:Acquire("CharCreateBodyTypeButtonTemplate");
		button:SetCustomizationFrame(CharCustomizeFrame);
		button:SetBodyType(sexID, self.selectedSexID, index);
		button:Show();
	end
end

function CharacterCreateRaceAndClassMixin:UpdateRaceButtons(releaseButtons)
	if releaseButtons then
		self.buttonPool:ReleaseAllByTemplate("CharacterCreateAllianceButtonTemplate");
		self.buttonPool:ReleaseAllByTemplate("CharacterCreateHordeButtonTemplate");
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

			button:SetCustomizationFrame(CharCustomizeFrame);
			button:SetRace(raceData, self.selectedRaceID, self.selectedFaction, templateCount[buttonTemplate]);
			button:Show();
		end
	end
end

local function SortClasses(classData1, classData2)
	return classLayoutIndices[classData1.fileName] < classLayoutIndices[classData2.fileName];
end

function CharacterCreateRaceAndClassMixin:UpdateClassButtons(releaseButtons)
	-- We need extra info about the spacing to make things line up properly when UI scale is adjusted higher.
	local ClassButtonSpacing = 30;
	local ClassIconSize = 66;
	local ClassButtonWidth = ClassIconSize;
	local ClassButtonNameSpacing = 50;
	local ClassButtonHeight = ClassIconSize + ClassButtonNameSpacing;

	if releaseButtons then
		self.buttonPool:ReleaseAllByTemplate("CharacterCreateClassButtonTemplate");
	end

	local classes = C_CharacterCreation.GetAvailableClasses();
	table.sort(classes, SortClasses);

	local spaceAvailable = self.Classes.AvailableSpace:GetWidth();
	local numClasses = #classes;
	local buttonSpacing = (numClasses * ClassButtonWidth) + ((numClasses - 1) * ClassButtonSpacing);
	local numRows = math.ceil(buttonSpacing / spaceAvailable);
	local scale = 1;

	if numRows == 1 then
		-- no overlap, use the original width
		self.Classes:SetHeight(self.Classes.originalHeight);
		self.Classes:SetWidth(self.Classes.originalWidth);
		spaceAvailable = self.Classes:GetWidth();
	else
		self.Classes:SetHeight(self.Classes.originalHeight * 2 - 20);
	end

	if spaceAvailable < self.Classes.originalWidth then
		ClassButtonSpacing = 20;
		local buffer = 40;
		spaceAvailable = spaceAvailable - buffer;
		self.Classes:SetWidth(spaceAvailable);
	end

	-- We never want to allow more than 2 rows even if UI scale is bumped up (generally has to be over 100% to hit this case).
	-- We'll scale down the class icons instead if necessary.
	if numRows > 2 then
		numRows = 2;

		local buttonsPerRow = math.ceil(numClasses / numRows);
		local rowSize = (buttonsPerRow * ClassButtonWidth) + ((buttonsPerRow - 1) * ClassButtonSpacing);
		local extraSpace = rowSize - spaceAvailable;
		local extraSpacePerButton = extraSpace / buttonsPerRow;
		scale = 1 / (1 + (extraSpacePerButton / ClassIconSize));
	end

	local stride = math.ceil(numClasses / numRows);
	local paddingX = ClassButtonSpacing;
	local paddingY = ClassButtonNameSpacing;
	local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, stride, paddingX, paddingY);

	local rowWidth = (((stride * ClassButtonWidth) + ((stride - 1) * ClassButtonSpacing))) * scale;
	local baseOffsetX = (spaceAvailable - rowWidth) / 2;
	local classesFrameHeight = self.Classes:GetHeight();
	local baseOffsetY = (classesFrameHeight - ClassButtonHeight) * 0.5;
	local initialAnchor = CreateAnchor("LEFT", self.Classes, "LEFT", baseOffsetX, baseOffsetY);

	local function FactoryFunction(index)
		local button = self.buttonPool:Acquire("CharacterCreateClassButtonTemplate");
		button:SetCustomizationFrame(CharCustomizeFrame);
		button:SetClass(classes[index], self.selectedClassID);
		button:Show();
		button:SetScale(scale);
		return button;
	end

	self.classButtons = AnchorUtil.GridLayoutFactoryByCount(FactoryFunction, numClasses, initialAnchor, layout);
end

function CharacterCreateRaceAndClassMixin:UpdateButtons()
	local isUsingGamepadUI = InputUtil.IsGamepadUIEnabled();
	if (isUsingGamepadUI) then
		self:StoreSmartNavButtonInfoForIdentificationAfterCustomizationButtonRefresh();
	end

	self.buttonPool:ReleaseAll();

	self:UpdateSexButtons();
	self:UpdateRaceButtons();
	local fullCharacterCreateDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.FullCharacterCreateDisabled);
	if not fullCharacterCreateDisabled then
		self:UpdateClassButtons();
	end

	if (isUsingGamepadUI) then
		self:RefreshSmartNavFocusAfterCustomizationButtonRefresh();
		RaceAndClassFrame:RefreshSmartNavCustomJumps();
	end

	self:LayoutButtons();
end

function CharacterCreateRaceAndClassMixin:SetClassValidRaces(classValidRaces)
	self.classValidRaces = classValidRaces;

	local isUsingGamepadUI = InputUtil.IsGamepadUIEnabled();
	if (isUsingGamepadUI) then
		--[[
			Make sure that smart nav returns to a button with the same data it currently is on
			after the release if possible. Handles edge case where smart nav cursor is on
			a race button, but mouse hovers over a class causing the valid races to change.
		]]
		self:StoreSmartNavButtonInfoForIdentificationAfterCustomizationButtonRefresh();
	end

	local releaseButtons = true;
	self:UpdateRaceButtons(releaseButtons);

	if (isUsingGamepadUI) then
		self:RefreshSmartNavFocusAfterCustomizationButtonRefresh();
		RaceAndClassFrame:RefreshSmartNavCustomJumps();
	end

	self:LayoutButtons();
end

function CharacterCreateRaceAndClassMixin:GetSelectedBodyTypeButton()
	local bodyTypeButtons = self.BodyTypes:GetLayoutChildren();
	for _, bodyTypeButton in ipairs(bodyTypeButtons) do
		if (self.selectedSexID == bodyTypeButton.sexID) then
			return bodyTypeButton;
		end
	end
end

function CharacterCreateRaceAndClassMixin:GetSelectedRaceButton()
	local allianceRaceButtons = self.AllianceContainer.AllianceRaces:GetLayoutChildren();
	local hordeRaceButtons = self.HordeContainer.HordeRaces:GetLayoutChildren();

	for _, button in ipairs(allianceRaceButtons) do
		if self.selectedRaceID == button.raceData.raceID then
			return button;
		end
	end

	for _, button in ipairs(hordeRaceButtons) do
		if self.selectedRaceID == button.raceData.raceID then
			return button;
		end
	end
end

function CharacterCreateRaceAndClassMixin:GetSelectedClassButton()
	if not self.classButtons then
		return;
	end

	for _, classButton in ipairs(self.classButtons) do
		if self.selectedClassData.classID == classButton.classData.classID then
			return classButton;
		end
	end
end

function CharacterCreateRaceAndClassMixin:RegisterForInterfaceTransitions()
	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetupGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end

function CharacterCreateRaceAndClassMixin:SetupGamepad()
	self.rightStickMaxScrollSpeed = GetCVarNumberOrDefault("SmartNavigationScrollSpeed");

	self.bindings = GamepadMode.CreateBindingGroup("CharacterCreateRaceAndClassFrameBindings");
	self.bindings:AddAxisBinding(GAMEPAD_STICK_RIGHT, GenerateClosure(self.GamepadHandleRStick, self));
	self.bindings:AddAxisBinding(GAMEPAD_STICK_LEFT, GenerateClosure(self.GamepadNavigateSection, self));

	local customizeAction = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_LEFT, function() self:GetParent().ForwardButton:Click(); end);
	customizeAction:SetLabelFunction(function()
		local forwardButton = self:GetParent().ForwardButton
		local text = forwardButton:GetText();
		if not text then
			return CUSTOMIZE;
		end
		local matchedText = string.match(text, "^([%w]+)");
		if not matchedText then
			return CUSTOMIZE;
		end
		return matchedText;
	end);

	local resetView = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_RIGHT_PRESS, function()
		local customizationFrame = CharCustomizeFrame.SmallButtons.ResetCameraButton:GetCustomizationFrame();
		customizationFrame:ResetSubjectRotation();
	end, ACTION_LABEL_RESET_VIEW);

	self.footer = GamepadSharedUtility.CreatePromptedBindingFooter(self);
	self.footer:AddStandardSelectPrompt();
	self.footer:AddPromptedBinding(resetView);
	self.footer:AddPromptedBinding(customizeAction);
	self.footer:AddStandardBackPrompt();
	self.footer:Finalize();
	self.footer.inputLegend:ClearAllPoints();
	self.footer.inputLegend:SetPoint("BOTTOM", self.Classes, "TOP", 0, 0);
end

function CharacterCreateRaceAndClassMixin:SmartNavigationCloseHandler()
	CharacterCreateFrame.BackButton:Click();
	return true;
end

function CharacterCreateRaceAndClassMixin:InitializeGamepad()
	if self:IsShown() and CharacterCreateFrame:IsMode(CHAR_CREATE_MODE_CLASS_RACE) then
		GamepadMode.FrameControlsManager:FrameShown(self);
		self:RefreshSmartNavCustomJumps();
	end

	self.rightStickScrollSpeed = 0;
end

function CharacterCreateRaceAndClassMixin:UninitializeGamepad()
	GamepadMode.DeactivateBindingGroup(self.bindings);
	self.footer:HideAndDeactivateBindings();
end

function CharacterCreateRaceAndClassMixin:UnfocusGamepad()
	GamepadMode.DeactivateBindingGroup(self.bindings);
	self.footer:HideAndDeactivateBindings();

	FactionDetailsList.ScrollBarHint:Hide();
	RaceDetailsList.ScrollBarHint:Hide();
	ClassDetailsList.ScrollBarHint:Hide();
end

function CharacterCreateRaceAndClassMixin:OnSmartNavFocus()
	GamepadMode.ActivateBindingGroup(self.bindings);
	self.footer:ShowAndActivateBindings();

	local selectedRaceButton = self:GetSelectedRaceButton();
	SmartNavigation:SelectButton(selectedRaceButton);

	FactionDetailsList.ScrollBarHint:SetOwner(FactionDetailsList.ScrollBar.Track.Thumb, "CENTER");
	FactionDetailsList.ScrollBarHint:Show();

	RaceDetailsList.ScrollBarHint:SetOwner(RaceDetailsList.ScrollBar.Track.Thumb, "CENTER");
	RaceDetailsList.ScrollBarHint:Show();

	ClassDetailsList.ScrollBarHint:SetOwner(ClassDetailsList.ScrollBar.Track.Thumb, "CENTER");
	ClassDetailsList.ScrollBarHint:Show();
end

--[[
	The purpose of this function is to store identfiying information of the current button
	smart nav is focusing on in the RaceAndClassFrame. This information is used after the
	various customization buttons are released and re-acquired from their respective frame
	pools to make sure that smart nav can be refocused on the same "logical" button it was
	on before the refresh since the actual frame that was focused may have been populated
	with different data and moved to a different location when it was re-acquired from the
	pool.
]]
function CharacterCreateRaceAndClassMixin:StoreSmartNavButtonInfoForIdentificationAfterCustomizationButtonRefresh()
	local currentlyFocusedSmartNavButton = SmartNavigation:GetCurrentButton();
	if (currentlyFocusedSmartNavButton) then
		self.storedSmartNavIdentifyingInfo = {};
		self.storedSmartNavIdentifyingInfo.sexID = currentlyFocusedSmartNavButton.sexID; 	    -- Focused on a body type button.
		self.storedSmartNavIdentifyingInfo.raceData = currentlyFocusedSmartNavButton.raceData;   -- Focused on a race button.
		self.storedSmartNavIdentifyingInfo.classData = currentlyFocusedSmartNavButton.classData; -- Focused on a class button.
	end
end

--[[
	The purpose of this function is to update the smart navigation cursor to refocus the
	same "logical" button that it was on before the customization buttons on the RaceAndClassFrame
	were released and re-acquired since the actual frame button may have changed position and displayed
	data.
]]
function CharacterCreateRaceAndClassMixin:RefreshSmartNavFocusAfterCustomizationButtonRefresh()
	if (not self.storedSmartNavIdentifyingInfo) then
		return;
	end

	if (self.storedSmartNavIdentifyingInfo.sexID) then
		local bodyTypeButtons = self.BodyTypes:GetLayoutChildren();
		for _, bodyTypeButton in ipairs(bodyTypeButtons) do
			if (bodyTypeButton.sexID == self.storedSmartNavIdentifyingInfo.sexID) then

				SmartNavigation:SelectButton(bodyTypeButton);
				break;
			end
		end
	elseif (self.storedSmartNavIdentifyingInfo.raceData) then
		local raceButtons;
		if (self.storedSmartNavIdentifyingInfo.raceData.factionInternalName == "Alliance") then
			raceButtons = self.AllianceContainer.AllianceRaces:GetLayoutChildren();
		else
			raceButtons = self.HordeContainer.HordeRaces:GetLayoutChildren();
		end

		for _, raceButton in ipairs(raceButtons) do
			if (raceButton.raceData.raceID == self.storedSmartNavIdentifyingInfo.raceData.raceID) then
				SmartNavigation:SelectButton(raceButton);
				break;
			end
		end
	elseif (self.storedSmartNavIdentifyingInfo.classData) then
		local classButtons = self.classButtons or {};
		for _, classButton in ipairs(classButtons) do
			if (self.storedSmartNavIdentifyingInfo.classData.classID == classButton.classData.classID) then
				SmartNavigation:SelectButton(classButton);
				break;
			end
		end
	end

	self.storedSmartNavIdentifyingInfo = nil;
end

function CharacterCreateRaceAndClassMixin:RefreshSmartNavCustomJumps()
	local allianceRaceButtons = self.AllianceContainer.AllianceRaces:GetLayoutChildren();
	local hordeRaceButtons = self.HordeContainer.HordeRaces:GetLayoutChildren();
	local bodyTypeButtons = self.BodyTypes:GetLayoutChildren();
	local classButtons = self.classButtons or {};

	local function SortClassButtons(classButton1, classButton2)
		return SortClasses(classButton1.classData, classButton2.classData);
	end
	table.sort(classButtons, SortClassButtons);

	local numAllianceRaceButtons = #allianceRaceButtons;
	local numHordeRaceButtons = #hordeRaceButtons;
	local numBodyTypeButtons = #bodyTypeButtons;
	local numClassButtons = #classButtons;

	local GetSelectedClassClosure = GenerateFlatClosure(self.GetSelectedClassButton, self);
	local GetSelectedRaceClosure = GenerateFlatClosure(self.GetSelectedRaceButton, self);

	local function GetClosestEnabledRaceButton(index, buttons)
		local curButton = nil;
		local curDiff = nil;

		for i, button in ipairs(buttons) do
			if button:IsEnabled() then
				local diff = math.abs(i - index);
				if (not curDiff) or (diff <= curDiff) then
					curButton = button;
					curDiff = diff;
				end
			end
		end

		return curButton;
	end

	SmartNavigation_AddJumpNavigationOverride(bodyTypeButtons[1], SMART_NAV_INPUT_DIRECTION.LEFT, GetSelectedRaceClosure);
	SmartNavigation_AddJumpNavigationOverride(bodyTypeButtons[2], SMART_NAV_INPUT_DIRECTION.RIGHT, SDToggleButton);

	SmartNavigation_AddJumpNavigationOverride(bodyTypeButtons[1], SMART_NAV_INPUT_DIRECTION.DOWN, GetSelectedClassClosure);
	SmartNavigation_AddJumpNavigationOverride(bodyTypeButtons[2], SMART_NAV_INPUT_DIRECTION.DOWN, GetSelectedClassClosure);

	local function SetupRaceButtons(buttons)
		local isHorde = buttons == hordeRaceButtons;
		local firstEnabledButton = nil;
		local lastEnabledButton = nil;

		for index, button in ipairs(buttons) do
			SmartNavigation_ClearJumpNavigationOverrides(button);

			if button:IsEnabled() then
				if not firstEnabledButton then
					firstEnabledButton = button;
					SmartNavigation_AddIgnoreInputNavigationOverride(firstEnabledButton, SMART_NAV_INPUT_DIRECTION.UP);
				end

				if lastEnabledButton then
					SmartNavigation_AddBidirectionalJumpNavigationOverride(lastEnabledButton, SMART_NAV_INPUT_DIRECTION.DOWN, button);
				end
				lastEnabledButton = button;

				local otherRaceButtons = hordeRaceButtons;
				local otherRaceDir = SMART_NAV_INPUT_DIRECTION.RIGHT;
				if isHorde then
					otherRaceButtons = allianceRaceButtons;
					otherRaceDir = SMART_NAV_INPUT_DIRECTION.LEFT;

					SmartNavigation_AddJumpNavigationOverride(button, SMART_NAV_INPUT_DIRECTION.RIGHT, GetSelectedClassClosure);
				end
				SmartNavigation_AddJumpNavigationOverride(button, otherRaceDir, GenerateFlatClosure(GetClosestEnabledRaceButton, index, otherRaceButtons));
			end
		end

		if lastEnabledButton then
			SmartNavigation_AddJumpNavigationOverride(lastEnabledButton, SMART_NAV_INPUT_DIRECTION.DOWN, GetSelectedClassClosure);
		end
	end

	SetupRaceButtons(allianceRaceButtons);
	SetupRaceButtons(hordeRaceButtons);

	do
		local firstEnabledButton = nil;
		local lastEnabledButton = nil;

		for index, classButton in ipairs(classButtons) do
			SmartNavigation_ClearJumpNavigationOverrides(classButton);

			-- Not required for disabled buttons but doesn't hurt to add it to disabled buttons just in case ui gets into weird state
			SmartNavigation_AddJumpNavigationOverride(classButton, SMART_NAV_INPUT_DIRECTION.UP, GenerateFlatClosure(self.GetSelectedBodyTypeButton, self));

			if classButton:IsEnabled() then
				if not firstEnabledButton then
					firstEnabledButton = classButton;
				else
					SmartNavigation_AddBidirectionalJumpNavigationOverride(lastEnabledButton, SMART_NAV_INPUT_DIRECTION.RIGHT, classButton);
				end
				lastEnabledButton = classButton;
			end
		end
		SmartNavigation_AddJumpNavigationOverride(firstEnabledButton, SMART_NAV_INPUT_DIRECTION.LEFT, GetSelectedRaceClosure);
		SmartNavigation_AddBidirectionalJumpNavigationOverride(lastEnabledButton, SMART_NAV_INPUT_DIRECTION.RIGHT, SDToggleButton);
	end
end

function CharacterCreateRaceAndClassMixin:GamepadHandleRStick(inX, inY)
	self.rightStickScrollSpeed = 0;
	if inX == 0 and inY == 0 then
		return;
	end

	local angleRad = math.atan2(inY, inX);
	if angleRad < 0 then
		angleRad = angleRad + (2.0 * math.pi);
	end

	local quarterPi = 0.25 * math.pi;
	local halfPi = 0.5 * math.pi;

	local isTop = (angleRad >= quarterPi) and (angleRad <= (halfPi + quarterPi));
	if isTop then
		self.rightStickScrollSpeed = inY * self.rightStickMaxScrollSpeed;
		return;
	end

	local isLeft = (angleRad > (halfPi + quarterPi)) and (angleRad < (math.pi + quarterPi));
	if isLeft then
		C_CharacterCreation.SetCharacterCreateFacing(C_CharacterCreation.GetCharacterCreateFacing() - CHARACTER_FACING_INCREMENT);
		return;
	end

	local isBottom = (angleRad >= (math.pi + quarterPi) and (angleRad <= ((2.0 * math.pi) - quarterPi)));
	if isBottom then
		self.rightStickScrollSpeed = inY * self.rightStickMaxScrollSpeed;
		return;
	end

	-- Right
	C_CharacterCreation.SetCharacterCreateFacing(C_CharacterCreation.GetCharacterCreateFacing() + CHARACTER_FACING_INCREMENT);
end

function CharacterCreateRaceAndClassMixin:OnUpdate(delta)
	if self.rightStickScrollSpeed == 0 then
		return;
	end

	local scrollDelta = self.rightStickScrollSpeed * delta;

	local factionScrollBox = FactionDetailsList.ScrollBox;
	local raceScrollBox = RaceDetailsList.ScrollBox;
	local classScrollBox = ClassDetailsList.ScrollBox;

	local factionScrollBoxOffset = factionScrollBox:GetDerivedScrollOffset();
	local raceScrollBoxOffset = raceScrollBox:GetDerivedScrollOffset();
	local classScrollBoxOffset = classScrollBox:GetDerivedScrollOffset();

	local factionScrollRange = factionScrollBox:GetDerivedScrollRange();
	local raceScrollRange = raceScrollBox:GetDerivedScrollRange();
	local classScrollRange = classScrollBox:GetDerivedScrollRange();

	if factionScrollRange > 0 then
		local newFactionScrollBoxOffset = Clamp((factionScrollBoxOffset - scrollDelta) / factionScrollRange, 0, 1);
		factionScrollBox:SetScrollPercentage(newFactionScrollBoxOffset);
	end

	if raceScrollRange > 0 then
		local newRaceScrollBoxOffset = Clamp((raceScrollBoxOffset - scrollDelta) / raceScrollRange, 0, 1);
		raceScrollBox:SetScrollPercentage(newRaceScrollBoxOffset);
	end

	if classScrollRange > 0 then
		local newClassScrollBoxOffset = Clamp((classScrollBoxOffset - scrollDelta) / classScrollRange, 0, 1);
		classScrollBox:SetScrollPercentage(newClassScrollBoxOffset);
	end
end

local INPUT_THRESHOLD = 0.5;
local STICK_RESET_THRESHOLD = 0.25;

function CharacterCreateRaceAndClassMixin:GamepadNavigateSection(x, y)
	self.waitingForStickReset = self.waitingForStickReset or false;
	if self.waitingForStickReset then
		if math.abs(x) <= STICK_RESET_THRESHOLD and math.abs(y) <= STICK_RESET_THRESHOLD then
			self.waitingForStickReset = false;
		else
			return;
		end
	end

	local directionHandler = nil;

	if math.abs(x) >= math.abs(y) then
		if x >= INPUT_THRESHOLD then
			self:GamepadNavigateHorizontalSection(1);
			self.waitingForStickReset = true;
		elseif x <= -INPUT_THRESHOLD then
			self:GamepadNavigateHorizontalSection(-1);
			self.waitingForStickReset = true;
		end
	else
		if y >= INPUT_THRESHOLD then
			self:GamepadNavigateVerticalSection(1);
			self.waitingForStickReset = true;
		elseif y <= -INPUT_THRESHOLD then
			self:GamepadNavigateVerticalSection(-1);
			self.waitingForStickReset = true;
		end
	end
end

local RACE_FRAME_GROUP = 1;
local CLASS_FRAME_GROUP = 2;
local BODY_FRAME_GROUP = 3;
local CHECKBOXTOGGLE_FRAME_GROUP = 4;

function CharacterCreateRaceAndClassMixin:GamepadNavigateHorizontalSection(dir)
	local currentButton = SmartNavigation:GetCurrentButton();
	if not currentButton then
		return;
	end

	local group = self:GamepadFindButtonGroup(currentButton);
	if not group then
		return;
	end

	if dir > 0 then
		if group == RACE_FRAME_GROUP then
			-- Race -> Body
			SmartNavigation:SelectButton(self:GetSelectedBodyTypeButton());
		elseif group == CLASS_FRAME_GROUP then
			-- Class -> Toggle
			SmartNavigation:SelectButton(SDToggleButton);
		elseif group == BODY_FRAME_GROUP then
			-- Body -> Toggle
			SmartNavigation:SelectButton(SDToggleButton);
		elseif group == CHECKBOXTOGGLE_FRAME_GROUP then
			-- Nothing
		end
	else
		if group == RACE_FRAME_GROUP then
			-- Nothing
		elseif group == CLASS_FRAME_GROUP then
			-- Class -> Race
			SmartNavigation:SelectButton(self:GetSelectedRaceButton());
		elseif group == BODY_FRAME_GROUP then
			-- Body -> Race
			SmartNavigation:SelectButton(self:GetSelectedRaceButton());
		elseif group == CHECKBOXTOGGLE_FRAME_GROUP then
			-- Toggle -> Class
			SmartNavigation:SelectButton(self:GetSelectedClassButton());
		end
	end
end

function CharacterCreateRaceAndClassMixin:GamepadNavigateVerticalSection(dir)
	local currentButton = SmartNavigation:GetCurrentButton();
	if not currentButton then
		return;
	end

	local group = self:GamepadFindButtonGroup(currentButton);
	if not group then
		return;
	end

	if dir > 0 then
		if group == RACE_FRAME_GROUP then
			-- Nothing
		elseif group == CLASS_FRAME_GROUP then
			-- Class -> Body
			SmartNavigation:SelectButton(self:GetSelectedBodyTypeButton());
		elseif group == BODY_FRAME_GROUP then
			-- Nothing
		elseif group == CHECKBOXTOGGLE_FRAME_GROUP then
			-- Toggle -> Body
			SmartNavigation:SelectButton(self:GetSelectedBodyTypeButton());
		end
	else
		if group == RACE_FRAME_GROUP then
			-- Race -> Class
			SmartNavigation:SelectButton(self:GetSelectedClassButton());
		elseif group == CLASS_FRAME_GROUP then
			-- Nothing
		elseif group == BODY_FRAME_GROUP then
			-- Body -> Class
			SmartNavigation:SelectButton(self:GetSelectedClassButton());
		elseif group == CHECKBOXTOGGLE_FRAME_GROUP then
			-- Nothing
		end
	end
end

function CharacterCreateRaceAndClassMixin:GamepadFindButtonGroup(currentButton)
	local allianceRaceButtons = self.AllianceContainer.AllianceRaces:GetLayoutChildren();
	local hordeRaceButtons = self.HordeContainer.HordeRaces:GetLayoutChildren();
	local bodyTypeButtons = self.BodyTypes:GetLayoutChildren();
	local classButtons = self.classButtons or {};

	local numAllianceRaceButtons = #allianceRaceButtons;
	local numHordeRaceButtons = #hordeRaceButtons;
	local numBodyTypeButtons = #bodyTypeButtons;
	local numClassButtons = #classButtons;

	for _, button in ipairs(allianceRaceButtons) do
		if currentButton == button then
			return RACE_FRAME_GROUP;
		end
	end

	for _, button in ipairs(hordeRaceButtons) do
		if currentButton == button then
			return RACE_FRAME_GROUP;
		end
	end

	for _, button in ipairs(classButtons) do
		if currentButton == button then
			return CLASS_FRAME_GROUP;
		end
	end

	for _, button in ipairs(bodyTypeButtons) do
		if currentButton == button then
			return BODY_FRAME_GROUP;
		end
	end

	if currentButton == SDToggleButton then
		return CHECKBOXTOGGLE_FRAME_GROUP;
	end

	return nil;
end

CharacterCreateFactionHeaderMixin = {};

function CharacterCreateFactionHeaderMixin:OnLoad()
	CustomizationFrameWithTooltipMixin.OnLoad(self);
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

NameChoiceMixin = {}

function NameChoiceMixin:OnLoad()
	if C_CharacterCreation.AreRegionalUniqueNamesEnabled() then
		self.Label:SetText(CHARACTER_CREATE_FULLNAME);

		local point, parent, relativePoint, sourceX, sourceY = self.NameAvailabilityState:GetPoint(1);
		self.NameAvailabilityState:SetPoint(point, self.EditBoxSurname, relativePoint, sourceX, sourceY);
	else
		self.EditBox.instructionsText = nil;
		self.EditBox.tooltipText = nil;
	end

	self.EditBoxSurname:SetShown(self.EditBoxSurname:ShouldShow());
end

function NameChoiceMixin:OnShow()
	self:RegisterEvent("RANDOM_CHARACTER_NAME_RESULT");
end

function NameChoiceMixin:OnHide()
	self:UnregisterEvent("RANDOM_CHARACTER_NAME_RESULT");

	CharacterCreateFrame:RemoveNavBlocker(CHARACTER_CREATION_REQUIREMENTS_PICK_NAME);
	self.NameAvailabilityState:UpdateNavBlocker(nil);
	self.NameAvailabilityState:ClearTimer();
end

function NameChoiceMixin:OnEvent(event, ...)
	if event == "RANDOM_CHARACTER_NAME_RESULT" then
		local success, name, surname = ...;

		if not success then
			-- Failed. Generate a random name locally.
			if C_CharacterCreation.AreRegionalUniqueNamesEnabled() then
				name = C_CharacterCreation.GenerateRandomName();
				surname = C_CharacterCreation.GenerateRandomSurname();
			else
			name = C_CharacterCreation.GenerateRandomName();
				surname = "";
			end
		end

		self.NameAvailabilityState.lastRandomName = name;
		self.NameAvailabilityState.lastRandomSurname = surname;
		self.EditBox:SetText(name);
		if (self.EditBoxSurname:IsShown()) then
			self.EditBoxSurname:SetText(surname);
		end
		self.RandomNameButton.pendingRequest = false;
	end
end

function NameChoiceMixin:OnTextChanged()
	local fullCharacterCreateDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.FullCharacterCreateDisabled);

	local selectedName = self.EditBox:GetText();
	local selectedNameIsEmpty = selectedName == "" or selectedName == PENDING_RANDOM_NAME;

	local selectedSurname = "";
	local selectedSurnameIsEmpty = false;
	if (self.EditBoxSurname:IsShown()) then
		selectedSurname = self.EditBoxSurname:GetText();
		selectedSurnameIsEmpty = selectedSurname == "" or selectedSurname == PENDING_RANDOM_NAME;
	end

	if (not fullCharacterCreateDisabled) and (selectedNameIsEmpty or selectedSurnameIsEmpty) then
		CharacterCreateFrame:AddNavBlocker(CHARACTER_CREATION_REQUIREMENTS_PICK_NAME, MEDIUM_PRIORITY);
		self.NameAvailabilityState:Hide();
	else
		CharacterCreateFrame:RemoveNavBlocker(CHARACTER_CREATION_REQUIREMENTS_PICK_NAME);
		self.NameAvailabilityState:CheckName(selectedName, selectedSurname);
	end
end

local function OnEditBoxSmartNavSelect(nameChoiceFrame)
	if nameChoiceFrame.NameAvailabilityState:IsShown() then
		nameChoiceFrame.NameAvailabilityState:ShowTooltip();
	end
end

local function OnEditBoxSmartNavDeselect(nameChoiceFrame)
	nameChoiceFrame.NameAvailabilityState:HideTooltip();
end

CharacterCreateEditBoxMixin = CreateFromMixins(NarrationEditBoxMixin);

function CharacterCreateEditBoxMixin:OnLoad()
	SharedEditBoxMixin.OnLoad(self);
end

function CharacterCreateEditBoxMixin:NarrationGetName()
	return MAIN_NAME;
end

function CharacterCreateEditBoxMixin:NarrationGetDescription()
	local text = NarrationEditBoxMixin.NarrationGetDescription(self);
	if text and text ~= "" then
		return NarrationUtil.MakeNarrationString(text, NARRATION_STATUS_REQUIRED);
	end

	return NARRATION_STATUS_REQUIRED;
end

function CharacterCreateEditBoxMixin:OnEscapePressed()
	CharacterCreateFrame:NavBack();
end

function CharacterCreateEditBoxMixin:OnEnterPressed()
	CharacterCreateFrame:NavForward();
end

function CharacterCreateEditBoxMixin:OnTextChanged()
	SharedEditBoxMixin.OnTextChanged(self);
	self:GetParent():OnTextChanged();
end

function CharacterCreateEditBoxMixin:OnTabPressed()
	if (not self:GetParent().EditBoxSurname:IsShown()) then
		return;
	end

	self:ClearFocus();
	EditBox_ClearHighlight(self);
	self:GetParent().EditBoxSurname:SetFocus();
end

function CharacterCreateEditBoxMixin:OnSmartNavSelect()
	OnEditBoxSmartNavSelect(self:GetParent());
end

function CharacterCreateEditBoxMixin:OnSmartNavDeselect()
	OnEditBoxSmartNavDeselect(self:GetParent());
end

CharacterCreateEditBoxSurnameMixin = CreateFromMixins(NarrationEditBoxMixin);

function CharacterCreateEditBoxSurnameMixin:OnLoad()
	SharedEditBoxMixin.OnLoad(self);
end

function CharacterCreateEditBoxSurnameMixin:OnEscapePressed()
	CharacterCreateFrame:NavBack();
end

function CharacterCreateEditBoxSurnameMixin:OnEnterPressed()
	CharacterCreateFrame:NavForward();
end

function CharacterCreateEditBoxSurnameMixin:OnTextChanged()
	SharedEditBoxMixin.OnTextChanged(self);
	self:GetParent():OnTextChanged();
end

function CharacterCreateEditBoxSurnameMixin:NarrationGetName()
	return SECONDARY_NAME;
end

function CharacterCreateEditBoxSurnameMixin:NarrationGetDescription()
	local text = NarrationEditBoxMixin.NarrationGetDescription(self);
	if text and text ~= "" then
		return NarrationUtil.MakeNarrationString(text, NARRATION_STATUS_REQUIRED);
	end

	return NARRATION_STATUS_REQUIRED;
end

function CharacterCreateEditBoxSurnameMixin:OnTabPressed()
	self:ClearFocus();
	EditBox_ClearHighlight(self);
	self:GetParent().EditBox:SetFocus();
end

function CharacterCreateEditBoxSurnameMixin:ShouldShow()
	return C_CharacterCreation.AreRegionalUniqueNamesEnabled();
end

function CharacterCreateEditBoxSurnameMixin:OnSmartNavSelect()
	OnEditBoxSmartNavSelect(self:GetParent());
end

function CharacterCreateEditBoxSurnameMixin:OnSmartNavDeselect()
	OnEditBoxSmartNavDeselect(self:GetParent());
end

CharacterCreateNameAvailabilityStateMixin = CreateFromMixins(TimedCallbackMixin, NarrationSkipTooltipsMixin);

function CharacterCreateNameAvailabilityStateMixin:OnLoad()
	self:SetCheckDelaySeconds(1);
	self:RegisterEvent("CHECK_CHARACTER_NAME_AVAILABILITY_RESULT");
	self:RegisterForInterfaceTransitions();
end

function CharacterCreateNameAvailabilityStateMixin:SetupAnchors(tooltip)
	tooltip:SetOwner(self, "ANCHOR_NONE");
	if (InputUtil.IsGamepadUIEnabled()) then
		tooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", self.tooltipXOffset, self.tooltipYOffset);
	else
		tooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", self.tooltipXOffset, self.tooltipYOffset);
	end
end

-- TODO (CAM-10501): Add surname logic
function CharacterCreateNameAvailabilityStateMixin:OnEvent(event, ...)
	local available, checkedName, reason = ...;

	-- First make sure that the checked name is still what is in the box
	if checkedName == self:GetParent().EditBox:GetText() then
		-- ok they match, so update the state
		self:UpdateState(available, _G[reason]);
	end
end

function CharacterCreateNameAvailabilityStateMixin:CheckName(nameToCheck, surnameToCheck)
	self:Hide();

	self:UpdateNavBlocker(nil);
	self:Cancel();

	local isFullNameLastRandom = (nameToCheck == self.lastRandomName) and (surnameToCheck == self.lastRandomSurname);
	local isFullNameCurrentPaid = (nameToCheck == CharacterCreateFrame.currentPaidServiceName) and (surnameToCheck == CharacterCreateFrame.currentPaidServiceSurname);
	if isFullNameLastRandom or isFullNameCurrentPaid then
		self:UpdateState(true);
	else
		self:RunCallbackAsync(function()
			local valid, reason = C_CharacterCreation.IsFullNameValid(nameToCheck, surnameToCheck);
			if not valid then
				self:UpdateState(false, _G[reason]);
				return;
			end

			-- The name is valid, so next request the availability be checked
			C_CharacterCreation.RequestCheckNameAvailability(nameToCheck, surnameToCheck);
		end);
	end
end

function CharacterCreateNameAvailabilityStateMixin:UpdateNavBlocker(navBlocker)
	if self.navBlocker then
		CharacterCreateFrame:RemoveNavBlocker(self.navBlocker);
	end

	local fullCharacterCreateDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.FullCharacterCreateDisabled);
	if (not fullCharacterCreateDisabled) and NameChoiceFrame:IsShown() and navBlocker then
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

	local nameChoice = self:GetParent();
	if InputUtil.IsGamepadUIEnabled() and (SmartNavigation:IsCurrentButton(nameChoice.EditBox) or SmartNavigation:IsCurrentButton(nameChoice.EditBoxSurname)) then
		self:ShowTooltip();
	end
end

function CharacterCreateNameAvailabilityStateMixin:NarrationGetName()
	if self.tooltipLines and self.tooltipLines[1] then
		return self.tooltipLines[1].text;
	end

	return nil;
end

function CharacterCreateNameAvailabilityStateMixin:NarrationGetContext()
	-- This is a visual-only status indicator, not an interactive button.
	-- Suppress the default behavior in GetRegionContext that narrates the object type.
	return nil;
end

function CharacterCreateNameAvailabilityStateMixin:OnHide()
	self:HideTooltip();
end

function CharacterCreateNameAvailabilityStateMixin:RegisterForInterfaceTransitions()
	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end

function CharacterCreateNameAvailabilityStateMixin:InitializeGamepad()
	self.tooltipXOffset = 5;
	self.tooltipYOffset = 10;
end

function CharacterCreateNameAvailabilityStateMixin:UninitializeGamepad()
	self.tooltipXOffset = 0;
	self.tooltipYOffset = 0;
end

CharacterCreateRandomNameButtonMixin = CreateFromMixins(NarrationSkipTooltipsMixin);

function CharacterCreateRandomNameButtonMixin:OnClick()
	if not self.pendingRequest then
		PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_LOOK);
		self:GetParent().EditBox:SetText(PENDING_RANDOM_NAME);
		if (self:GetParent().EditBoxSurname:IsShown()) then
			self:GetParent().EditBoxSurname:SetText(PENDING_RANDOM_NAME);
		end
		C_CharacterCreation.RequestRandomName();
		self.pendingRequest = true;
	end
end

function CharacterCreateRandomNameButtonMixin:NarrationGetName()
	return self.simpleTooltipLine;
end

CharacterCreateSelfFoundButtonMixin = {};

function CharacterCreateSelfFoundButtonMixin:OnClick()
	if ( self:GetChecked() ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
	self:ToggleSelfFound(self)
end

function CharacterCreateSelfFoundButtonMixin:OnEnter()
	GlueTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GlueTooltip:AddLine(SELF_FOUND_TOOLTIP_TOGGLE, 1.0, 0.78, 0.0, 1.0, true);
	GlueTooltip:AddLine(SELF_FOUND_TOOLTIP_INFO, 1.0, 0.78, 0.0, 1.0, true)
	GlueTooltip:Show();
end

function CharacterCreateSelfFoundButtonMixin:OnLeave()
	GlueTooltip:Hide();
end

function CharacterCreateSelfFoundButtonMixin:ToggleSelfFound()
	C_CharacterCreation.ToggleSelfFoundMode(self:GetChecked());
end

function CharacterCreateSelfFoundButtonMixin:CheckSelfFoundButton()
	if (C_GameRules.IsSelfFoundAllowed()) then
		CharacterCreateSelfFoundButton:Show();
	else
		CharacterCreateSelfFoundButton:Hide();
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

	local numSpecs = C_SpecializationInfo.GetNumSpecializationsForClassID(self.selectedClassID);

	for specIndex = 1, numSpecs do
		local button = self.specButtonPool:Acquire();

		local specData = {};
		specData.specID, specData.name, specData.description, specData.icon, specData.role, specData.isRecommended, specData.isAllowed = GetSpecializationInfoForClassID(self.selectedClassID, specIndex, self.selectedSexID + 1);

		button:SetCustomizationFrame(CharCustomizeFrame);
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

function CharacterCreateZoneChoiceMixin:NarrationGetName()
	return self.Title:GetText();
end

function CharacterCreateZoneChoiceMixin:OnShow()
	self.FadeIn:Play();

	local narrationInfo = NarrationUtil.RegionToNarrationInfo(self, NarrationUtil.TriggerType.Notification);
	if narrationInfo then
		EventRegistry:TriggerEvent("Narration.Speak", narrationInfo);
	end
end

function CharacterCreateZoneChoiceMixin:OnHide()
	self.FadeIn:Stop();
end

function CharacterCreateZoneChoiceMixin:Setup()
	local fullCharacterCreateDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.FullCharacterCreateDisabled);
	if fullCharacterCreateDisabled then
		return;
	end

	-- No zone choice / NPE for Timerunning characters.
	if (C_CharacterCreation.IsTimerunningEnabled()) then
		self:SetUseNPE(false);
		self.shouldShow = false;
		return;
	end

	local firstZoneChoiceInfo, secondZoneChoiceInfo = C_CharacterCreation.GetStartingZoneChoices();
	if not secondZoneChoiceInfo or CharacterCreateFrame:HasService() or (C_CharacterCreation.GetCharacterCreateType() ~= Enum.CharacterCreateType.Normal) then
		self:SetUseNPE(firstZoneChoiceInfo.isNPE);
		self.shouldShow = false;
		return;
	end

	self:SetUseNPE(true);
	self.shouldShow = true;

	-- If there is more than one choice, the normal starting zone will always be first
	self.NormalStartingZone:SetZoneInfo(firstZoneChoiceInfo.zoneName, firstZoneChoiceInfo.zoneImageAtlas);

	self:UpdateForScale();
end

function CharacterCreateZoneChoiceMixin:ShouldShow()
	local fullCharacterCreateDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.FullCharacterCreateDisabled);
	if fullCharacterCreateDisabled then
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

function CharacterCreateZoneChoiceMixin:UpdateForScale()
	-- reset
	self:SetScale(1);
	-- negative room means something is offscreen
	-- multiply by 2 because only 1 side is being measured
	local horizontalRoom = 2 * self.NPEZone:GetLeft();
	local verticalRoom = 2 * (GlueParent:GetHeight() - self.Title:GetTop());

	local desiredScale = 1;
	-- pick the worst one and scale based on that
	if verticalRoom < 0 and verticalRoom <= horizontalRoom then
		-- adding to 1 because room is negative
		desiredScale = 1 + (verticalRoom / self:GetHeight());
	elseif horizontalRoom < 0 and horizontalRoom <= verticalRoom then
		desiredScale = 1 + (horizontalRoom / self:GetWidth());
	end
	self:SetScale(desiredScale);
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
	local currentFaction = C_CharacterCreation.GetFactionForRace(C_CharacterCreation.GetSelectedRace());
	if (currentFaction == "Alliance") then
		RaceAndClassFrame:SetCharacterRace(HUMAN_RACE_ID);
	elseif (currentFaction == "Horde") then
		RaceAndClassFrame:SetCharacterRace(ORC_RACE_ID);
	end
end

CharCreateSDToggleMixin = {};

function CharCreateSDToggleMixin:OnLoad()
	if(C_GameRules.IsSDHDToggleEnabled()) then
		self:Show();
	else
		self:Hide();
	end
end

function CharCreateSDToggleMixin:OnShow()
	self:SetChecked(not C_GameRules.AccountHasSDEnabled());
end

function CharCreateSDToggleMixin:OnClick()
	local checked = self:GetChecked();

	if checked then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end

	C_GameRules.SetSDHDToggleValue(not checked);
	if(CharacterCreateFrame:IsMode(CHAR_CREATE_MODE_CUSTOMIZE)) then
		local alsoReset = true;
		local dontResetCamera = true;
		CharacterCreateFrame:UpdateCharCustomizationFrame(alsoReset, dontResetCamera);
	end
end

function CharCreateSDToggleMixin:OnEnter()
	GlueTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GlueTooltip:AddLine(CHARACTER_MODEL_TOGGLE_TOOLTIP_TITLE, 1.0, 1.0, 1.0, 1.0, true);
	GlueTooltip:AddLine(CHARACTER_MODEL_TOGGLE_TOOLTIP_BODY, 1.0, 0.78, 0.0, 1.0, true)
	GlueTooltip:Show();
end

function CharCreateSDToggleMixin:OnLeave()
	GlueTooltip:Hide();
end

function CharCreateSDToggleMixin:NarrationGetName()
	return self.Text:GetText();
end
