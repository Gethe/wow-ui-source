local showDebugTooltipInfo = GetCVarBool("debugTargetInfo");

local CHAR_CREATE_MODE_CLASS_RACE = 1;
local CHAR_CREATE_MODE_CUSTOMIZE = 2;
local CHAR_CREATE_MODE_STARTING_ZONE = 3;

local FORWARD_ARROW = true;
local BACKWARD_ARROW = false;
local PENDING_RANDOM_NAME = "...";

local RaceAndClassFrame;
local NameChoiceFrame;
local ClassTrialSpecs;

CharacterCreateMixin = {};

function CharacterCreateMixin:OnLoad()
	self:RegisterEvent("CHARACTER_CREATION_RESULT");
	self:RegisterEvent("RACE_FACTION_CHANGE_STARTED");
	self:RegisterEvent("RACE_FACTION_CHANGE_RESULT");
	self:RegisterEvent("CUSTOMIZE_CHARACTER_STARTED");
	self:RegisterEvent("CUSTOMIZE_CHARACTER_RESULT");

	C_CharacterCreation.SetCharCustomizeFrame("CharacterCreateFrame");

	RaceAndClassFrame = self.RaceAndClassFrame;
	NameChoiceFrame = self.NameChoiceFrame;
	ClassTrialSpecs = self.ClassTrialSpecs;

	CharCustomizeFrame:AttachToParentFrame(self);
	CharCustomizeFrame:SetScale(RaceAndClassFrame:GetScale());

	self.navBlockers = {};

	self.ForwardButton.tooltip = function()
		return self.currentNavBlocker and self.currentNavBlocker.error;
	end

	self.BackButton:UpdateText(BACK, BACKWARD_ARROW);

	self:SetSequence(0);
	self:SetCamera(0);
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
	end

	if showError then
		self:UpdateForwardButton();
		GlueDialog_Show("OKAY", _G[showError]);
	end
end

function CharacterCreateMixin:OnShow()
	C_CharacterCreation.SetInCharacterCreate(true);

	if self.paidServiceType then
		C_CharacterCreation.CustomizeExistingCharacter(self.paidServiceCharacterID);
		NameChoiceFrame.EditBox:SetText(C_PaidServices.GetName());
	else
		C_CharacterCreation.ResetCharCustomize();
		NameChoiceFrame.EditBox:SetText("");
	end

	self:SetMode(CHAR_CREATE_MODE_CLASS_RACE);
	RaceAndClassFrame:UpdateState();
end

function CharacterCreateMixin:OnHide()
	C_CharacterCreation.SetInCharacterCreate(false);
	self:ClearPaidServiceInfo();
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
	self.lastCursorPosX = GetCursorPosition();
	self:SetScript("OnUpdate", self.OnUpdate);
end

function CharacterCreateMixin:OnMouseUp(button)
	self:SetScript("OnUpdate", nil);
end

function CharacterCreateMixin:OnUpdate()
	local x = GetCursorPosition();
	local diff = (x - self.lastCursorPosX) * CHARACTER_ROTATION_CONSTANT;
	C_CharacterCreation.SetCharacterCreateFacing(C_CharacterCreation.GetCharacterCreateFacing() + diff);
	self.lastCursorPosX = x;
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

function CharacterCreateMixin:SetMode(mode)
	if self.currentMode == mode then
		return;
	end

	self.currentMode = mode;
	self:UpdateForwardButton();

	RaceAndClassFrame:SetShown(self.currentMode == CHAR_CREATE_MODE_CLASS_RACE);
	NameChoiceFrame:SetShown(self.currentMode == CHAR_CREATE_MODE_CUSTOMIZE);

	if self.currentMode == CHAR_CREATE_MODE_CLASS_RACE then
		self:ResetCharacterRotation();
		
		C_CharacterCreation.SetBlurEnabled(false);

		self:SetCameraZoomLevel(0);
		self:SetModelDressState(true);
		C_CharacterCreation.SetSelectedPreviewGearType(Enum.PreviewGearType.Awesome);

		self.BottomBackgroundOverlay.FadeIn:Play();
	elseif self.currentMode == CHAR_CREATE_MODE_CUSTOMIZE then
		-- Have to do this BEFORE entering customization mode or else the camera will jump
		C_CharacterCreation.SetBlurEnabled(true);

		-- We are entering customize mode. Grab the customizations for the selected race & sex and send it to CharCustomizeFrame before showing it
		local reset = true;
		self:UpdateCharCustomizationFrame(reset);

		CharCustomizeFrame:SetSelectedData(RaceAndClassFrame.selectedRaceData, RaceAndClassFrame.selectedSexID, C_CharacterCreation.IsViewingAlteredForm());
		ClassTrialSpecs:SetClass(RaceAndClassFrame.selectedClassID, RaceAndClassFrame.selectedSexID);

		C_CharacterCreation.SetSelectedPreviewGearType(Enum.PreviewGearType.Starting);

		self.BottomBackgroundOverlay.FadeOut:Play();
	end

	CharCustomizeFrame:SetShown(self.currentMode == CHAR_CREATE_MODE_CUSTOMIZE);
	ClassTrialSpecs:SetShown(self.currentMode == CHAR_CREATE_MODE_CUSTOMIZE and (C_CharacterCreation.GetCharacterCreateType() == Enum.CharacterCreateType.TrialBoost));
end

function CharacterCreateMixin:UpdateMode(offset)
	-- TODO: Add starting zone mode
	self:SetMode(Clamp(self.currentMode + offset, CHAR_CREATE_MODE_CLASS_RACE, CHAR_CREATE_MODE_CUSTOMIZE))
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

		C_CharacterCreation.CreateCharacter(self:GetSelectedName(), RaceAndClassFrame:GetCreateCharacterFaction());
	end
end

function CharacterCreateMixin:SetCustomizationChoice(optionID, choiceID)
	C_CharacterCreation.SetCustomizationChoice(optionID, choiceID);

	-- When a customization choice is made, that may force other options to change (if the current choices are no longer valid)
	-- So grab all the latest data and update CharCustomizationFrame 
	self:UpdateCharCustomizationFrame();
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

function CharacterCreateMixin:ResetCharacterRotation()
	C_CharacterCreation.SetCharacterCreateFacing(-15);
end

function CharacterCreateMixin:ZoomCamera(zoomAmount)
	C_CharacterCreation.ZoomCamera(zoomAmount);
end

function CharacterCreateMixin:GetCurrentCameraZoom()
	return C_CharacterCreation.GetCurrentCameraZoom();
end

function CharacterCreateMixin:RotateCharacter(rotationAmount)
	C_CharacterCreation.SetCharacterCreateFacing(C_CharacterCreation.GetCharacterCreateFacing() + rotationAmount);
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
		else
			-- TODO: Add starting zone mode
			PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CREATE_CHAR);
			self:CreateCharacter();
			self.ForwardButton:SetEnabled(false);
		end
	end
end

function CharacterCreateMixin:UpdateForwardButton()
	if self.currentMode == CHAR_CREATE_MODE_CLASS_RACE then
		self.ForwardButton:UpdateText(CUSTOMIZE, FORWARD_ARROW);
	-- TODO: Add starting zone mode
	--[[elseif self.currentMode == CHAR_CREATE_MODE_CUSTOMIZE then
		if C_CharacterCreation.IsNewPlayerRestricted() then
			self.ForwardButton:UpdateText(FINISH);
		else
			self.ForwardButton:UpdateText(NEXT, FORWARD_ARROW);
		end]]--
	else
		self.ForwardButton:UpdateText(FINISH);
	end

	self.ForwardButton:SetEnabled(self:CanNavForward());
end

CharacterCreateNavButtonMixin = {};

function CharacterCreateNavButtonMixin:GetAppropriateTooltip()
	return GlueTrueScaleNoHeaderTooltip;
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
	PRIEST = 4,
	ROGUE = 5,
	DRUID = 6,
	PALADIN = 7,
	WARLOCK = 8,
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
	return GlueTrueScaleTooltip;
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

	local buttonEnabled = false;
	if CharacterCreateFrame.paidServiceType == PAID_CHARACTER_CUSTOMIZATION then
		buttonEnabled = (selectedRaceID == raceData.raceID and selectedFaction == self.faction);
	elseif CharacterCreateFrame.paidServiceType == PAID_FACTION_CHANGE then
		local currentFaction = C_PaidServices.GetCurrentFaction();
		local currentClass = C_PaidServices.GetCurrentClassID();

		if currentFaction ~= self.faction and C_CharacterCreation.IsRaceClassValid(raceData.raceID, currentClass) then
			buttonEnabled = true;
		elseif selectedRaceID == raceData.raceID and selectedFaction == self.faction then
			-- The player is doing a faction change and this is their current race
			-- Enable the button for now, but don't let the player nav forward (it will be disabled as soon as they select an eligible race)
			buttonEnabled = true;
			CharacterCreateFrame:AddNavBlocker(CHAR_FACTION_CHANGE_SWAP_FACTION);
		end
	elseif CharacterCreateFrame.paidServiceType == PAID_RACE_CHANGE then
		local currentFaction = C_PaidServices.GetCurrentFaction();
		local currentRace = C_PaidServices.GetCurrentRaceID();
		local currentClass = C_PaidServices.GetCurrentClassID();

		if currentFaction == self.faction and currentRace ~= raceData.raceID and C_CharacterCreation.IsRaceClassValid(raceData.raceID, currentClass) then
			buttonEnabled = true;
		elseif selectedRaceID == raceData.raceID and selectedFaction == self.faction then
			-- The player is doing a race change and this is their current race
			-- Enable the button for now, but don't let the player nav forward (it will be disabled as soon as they select an eligible race)
			buttonEnabled = true;
			CharacterCreateFrame:AddNavBlocker(CHAR_FACTION_CHANGE_CHOOSE_RACE);
		end
	else
		buttonEnabled = raceData.enabled;
	end

	self:SetEnabledState(buttonEnabled);

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
	return GlueTrueScaleTooltip;
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
	elseif self.selectedRaceData.isNeutralRace and not self.selectedClassData.earlyFactionChoice then
		-- For neutral races, if the class selected is not an earlyFactionChoice class (DK) we also need to use no faction because they are Nuetral at level 1
		return nil;
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
	-- Always hiding the class trial button until after the CN/alpha build
	--self.ClassTrialCheckButton:SetShown(not isNewPlayerRestricted and not CharacterCreateFrame.paidServiceType);

	self:SetupTargetDummies(true);
	self:PlayClassAnimations(true);

	self:UpdateState();
end

function CharacterCreateRaceAndClassMixin:OnHide()
	self:DestroyTargetDummies();
	self:StopClassAnimations();
end

-- TODO: Move these into WowEdit once we decide if per-class control (and not class/race combo control) is enough for our needs
function CharacterCreateRaceAndClassMixin:SetupTargetDummies(reset)
end

function CharacterCreateRaceAndClassMixin:DestroyTargetDummies()
end

function CharacterCreateRaceAndClassMixin:PlayClassAnimations(reset)
end

function CharacterCreateRaceAndClassMixin:StopClassAnimations()
end

function CharacterCreateRaceAndClassMixin:UpdateState(selectedFaction)
	self.selectedRaceID = C_CharacterCreation.GetSelectedRace();
	self.selectedRaceData = C_CharacterCreation.GetRaceDataByID(self.selectedRaceID);

	if selectedFaction then
		self.selectedFaction = selectedFaction;
	elseif not self.selectedRaceData.isNeutralRace then
		self.selectedFaction = self.selectedRaceData.factionInternalName;
	end

	self.selectedClassData = C_CharacterCreation.GetSelectedClass();
	self.selectedClassID = self.selectedClassData.classID;
	self.selectedSexID = C_CharacterCreation.GetSelectedSex();

	local usingNewBGModel = CharacterCreateFrame:UpdateBackgroundModel();
	CharacterCreateFrame:UpdateBackgroundOverlays(self.selectedClassData, self.selectedRaceData);

	CharacterCreateFrame:RemoveNavBlocker(CHAR_FACTION_CHANGE_SWAP_FACTION);
	CharacterCreateFrame:RemoveNavBlocker(CHAR_FACTION_CHANGE_CHOOSE_RACE);
	self:UpdateButtons();

	self:SetupTargetDummies(usingNewBGModel);
	self:PlayClassAnimations(usingNewBGModel);
end

function CharacterCreateRaceAndClassMixin:SetCharacterRace(raceID, faction)
	if self.selectedRaceID ~= raceID then
		C_CharacterCreation.SetSelectedRace(raceID);
	end

	self:UpdateState(faction);
end

function CharacterCreateRaceAndClassMixin:SetCharacterClass(classID)
	if self.selectedClassID ~= classID then
		C_CharacterCreation.SetSelectedClass(classID);
	end

	self:UpdateState();
end

function CharacterCreateRaceAndClassMixin:SetCharacterSex(sexID)
	if self.selectedSexID ~= sexID  then
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
	ResizeLayoutMixin.OnLoad(self);
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
	BaseLayoutMixin.OnLoad(self);
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

function CharacterCreateEditBoxMixin:UpdateState()
	local selectedName = self:GetText();
	if selectedName == "" or selectedName == PENDING_RANDOM_NAME then
		CharacterCreateFrame:AddNavBlocker(CHARACTER_CREATION_REQUIREMENTS_PICK_NAME, HIGH_PRIORITY);
		self.ClearButton:Hide();
	else
		CharacterCreateFrame:RemoveNavBlocker(CHARACTER_CREATION_REQUIREMENTS_PICK_NAME);
		self.ClearButton:Show();
	end
end

function CharacterCreateEditBoxMixin:OnEvent(event, ...)
	if event == "RANDOM_CHARACTER_NAME_RESULT" then
		local success, name = ...;
		if not success then
			-- Failed.  Generate a random name locally.
			self:SetText(C_CharacterCreation.GenerateRandomName());
		else
			-- Succeeded.  Use what the server sent.
			self:SetText(name);
		end
		self:GetParent().RandomNameButton.pendingRequest = false;
		PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_LOOK);
	end
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
	BaseLayoutMixin.OnLoad(self);
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
