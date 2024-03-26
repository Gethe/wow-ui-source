-- See CharacterServicesFlowMixin for more documentation

CHARACTER_UPGRADE_CREATE_CHARACTER_DATA = nil;

local UPGRADE_BONUS_LEVEL = 60;

CURRENCY_KRW = 3;

local classDefaultProfessionMap = {
	["WARRIOR"] = "PLATE",
	["PALADIN"] = "PLATE",
	["HUNTER"] = "LEATHERMAIL",
	["ROGUE"] = "LEATHERMAIL",
	["PRIEST"] = "CLOTH",
	["DEATHKNIGHT"] = "PLATE",
	["SHAMAN"] = "LEATHERMAIL",
	["MAGE"] = "CLOTH",
	["WARLOCK"] = "CLOTH",
	["MONK"] = "LEATHERMAIL",
	["DRUID"] = "LEATHERMAIL",
	["DEMONHUNTER"] = "LEATHERMAIL",
};

local defaultProfessions = {
	["PLATE"] = { [1] = 164, [2] = 186 },
	["LEATHERMAIL"] = { [1] = 165, [2] = 393 },
	["CLOTH"] = { [1] = 197, [2] = 333 },
};

GlueDialogTypes["PRODUCT_ASSIGN_TO_TARGET_FAILED"] = {
	text = BLIZZARD_STORE_INTERNAL_ERROR,
	button1 = OKAY,
	escapeHides = true,
};

GlueDialogTypes["BOOST_FACTION_CHANGE_IN_PROGRESS"] = {
	text = CHARACTER_BOOST_ERROR_PENDING_FACTION_CHANGE,
	button1 = OKAY,
	escapeHides = true,
};

GlueDialogTypes["MUST_LOG_IN_FIRST"] = {
	text = MUST_LOG_IN_FIRST,
	button1 = OKAY,
	escapeHides = true,
};

local function IsCharacterEligibleForVeteranBonus(level, isTrialBoost, revokedCharacterUpgrade)
	return false;
end

local function IsBoostFlowValidForCharacter(flowData, class, level, boostInProgress, isTrialBoost, revokedCharacterUpgrade, vasServiceInProgress, isExpansionTrialCharacter, raceFilename, hasWowToken)
	if (boostInProgress or vasServiceInProgress or hasWowToken) then
		return false;
	end

	if (flowData.level < 70) and (raceFilename == "Dracthyr") then
		return false;
	end

	if isExpansionTrialCharacter and CanUpgradeExpansion()  then
		return false;
	elseif isTrialBoost then
		return true;
	elseif revokedCharacterUpgrade then
		if level > flowData.level then
			return false;
		end
	elseif level >= flowData.level then
		return false;
	end

	return true;
end

local function CanBoostCharacter(class, level, boostInProgress, isTrialBoost, revokedCharacterUpgrade, vasServiceInProgress, isExpansionTrialCharacter, raceFilename, hasWowToken)
	return IsBoostFlowValidForCharacter(CharacterUpgradeFlow.data, class, level, boostInProgress, isTrialBoost, revokedCharacterUpgrade, vasServiceInProgress, isExpansionTrialCharacter, raceFilename, hasWowToken);
end

local function clearButtonScripts(button)
	button:SetScript("OnClick", nil);
	button:SetScript("OnDoubleClick", nil);
	button:SetScript("OnDragStart", nil);
	button:SetScript("OnDragStop", nil);
	button:SetScript("OnMouseDown", nil);
	button:SetScript("OnMouseUp", nil);
	button:SetScript("OnEnter", nil);
	button:SetScript("OnLeave", nil);

	-- Are these necessary?
	button.upButton:SetScript("OnClick", nil);
	button.downButton:SetScript("OnClick", nil);
	button.upButton:Hide();
	button.downButton:Hide();
end

CharacterSelectBlockBase = {};

function CharacterSelectBlockBase:SetCharacterSelectErrorFrameShown(showError)
	local errorFrame = CharacterUpgradeMaxCharactersFrame;
	if showError then
		self.frame:Hide(); -- Hide the flow manager

		if not errorFrame.initialized then
			errorFrame:SetPoint("TOP", CharacterServicesMaster, "TOP", -30, 0);
			errorFrame:SetFrameLevel(CharacterServicesMaster:GetFrameLevel() + 2);
			errorFrame:SetParent(CharacterServicesMaster);
			errorFrame.initialized = true;
		end
	end

	errorFrame:SetShown(showError);
end

function CharacterSelectBlockBase:GetStepOptionFrames()
	local optionFrames = self.frame.CharacterSelectBlockOptionFrames;
	local conjunctionFrames = self.frame.CharacterSelectBlockConjunctionFrames;

	if not optionFrames then
		self.OPTION_INDEX_STEP_LABEL = 1;
		self.OPTION_INDEX_CREATE_NEW_CHARACTER = 2;
		self.OPTION_INDEX_CREATE_TRIAL_CHARACTER = 3;
		self.OPTION_INDEX_CREATE_TRIAL_CHARACTER_HINT = 4;

		-- Put all options (select char, create new, create trial) into this container
		-- The anchor data is used when the given frame is the first one being anchored to the block
		-- When anchoring subsequent frames they just use offsets from the "or labels" and always
		-- anchor topleft -> bottomleft of the previous frame
		optionFrames = {
			[self.OPTION_INDEX_STEP_LABEL] = {
				frame = self.frame.StepActiveLabel,
				point = "LEFT", relativeFrame = self.frame.StepNumber, relativePoint ="RIGHT", offsetX = 9, offsetY = 3,
				offsetXConjunction = 0, offsetYConjunction = -8,
			},

			[self.OPTION_INDEX_CREATE_NEW_CHARACTER] = {
				frame = self.frame.ControlsFrame.CreateCharacterButton,
				needsConjunction = true,
				point = "LEFT", relativeFrame = self.frame.StepNumber, relativePoint ="RIGHT", offsetX = 9, offsetY = 3,
				offsetXConjunction = 10, offsetYConjunction = -5,
			},

			[self.OPTION_INDEX_CREATE_TRIAL_CHARACTER] = {
				frame = self.frame.ControlsFrame.CreateCharacterClassTrialButton,
				needsConjunction = true,
				point = "TOPLEFT", relativeFrame = self.frame.StepNumber, relativePoint ="TOPRIGHT", offsetX = 10, offsetY = 0,
				offsetXConjunction = 10, offsetYConjunction = -5,
			},

			[self.OPTION_INDEX_CREATE_TRIAL_CHARACTER_HINT] = {
				frame = self.frame.ControlsFrame.ClassTrialButtonHintText,
				offsetXConjunction = 13, offsetYConjunction = -5,
			},
		};

		conjunctionFrames = {
			{ frame = self.frame.ControlsFrame.OrLabel, },
			{ frame = self.frame.ControlsFrame.OrLabel2, },
		};

		self.frame.CharacterSelectBlockOptionFrames = optionFrames;
		self.frame.CharacterSelectBlockConjunctionFrames = conjunctionFrames;
	end

	return optionFrames, conjunctionFrames;
end

function CharacterSelectBlockBase:SetOptionUsed(optionIndex, used)
	local optionFrames = self:GetStepOptionFrames();
	optionFrames[optionIndex].used = used;
end

function CharacterSelectBlockBase:ResetStepOptionFrames()
	local optionFrames, conjunctionFrames = self:GetStepOptionFrames();

	for i, optionData in ipairs(optionFrames) do
		optionData.frame:Hide();
		optionData.frame:ClearAllPoints();
	end

	for i, conjunctionData in ipairs(conjunctionFrames) do
		conjunctionData.frame:Hide();
		conjunctionData.frame:ClearAllPoints();
	end
end

function CharacterSelectBlockBase:LayoutOptionFrames()
	local optionFrames, conjunctionFrames = self:GetStepOptionFrames();
	local previousFrameData;
	local optionCount = 0;

	for i, optionFrameData in ipairs(optionFrames) do
		if optionFrameData.used then
			if optionCount > 0 and optionFrameData.needsConjunction then
				local conjunctionFrameData = conjunctionFrames[optionCount];
				local conjunctionFrame = conjunctionFrameData.frame;
				conjunctionFrame:Show();
				conjunctionFrame:SetPoint("TOPLEFT", previousFrameData.frame, "BOTTOMLEFT", -previousFrameData.offsetXConjunction, previousFrameData.offsetYConjunction);
				previousFrameData = conjunctionFrameData;
			end

			optionFrameData.frame:Show();

			if optionCount == 0 then
				optionFrameData.frame:SetPoint(optionFrameData.point, optionFrameData.relativeFrame, optionFrameData.relativePoint, optionFrameData.offsetX, optionFrameData.offsetY);
			else
				optionFrameData.frame:SetPoint("TOPLEFT", previousFrameData.frame, "BOTTOMLEFT", optionFrameData.offsetXConjunction, optionFrameData.offsetYConjunction);
			end

			previousFrameData = optionFrameData;
			optionCount = optionCount + 1;
		end
	end
end

function CharacterSelectBlockBase:SaveResultInfo(characterSelectButton, playerguid)
	self.index = characterSelectButton:GetElementData().index;
	self.charid = GetCharIDFromIndex(self.index);
	self.playerguid = playerguid;
end

function CharacterSelectBlockBase:ClearResultInfo()
	self.index = nil;
	self.charid = nil;
	self.playerguid = nil;
end

function CharacterSelectBlockBase:OnRewind()
	self:ClearResultInfo();
end

function CharacterSelectBlockBase:GetServiceInfoByCharacterID(characterID)
	local serviceInfo = { checkAutoSelect = true, checkTrialBoost = true };
	local raceFilename, _, class, _, level, _, _, _, _, _, _, _, playerguid, _, _, _, boostInProgress, _, _, isTrialBoost, _, revokedCharacterUpgrade, vasServiceInProgress, _, _, isExpansionTrialCharacter, _, _, _, _, _, characterServiceRequiresLogin, _, _, _, hasWowToken = select(3, GetCharacterInfo(characterID));
	serviceInfo.playerguid = playerguid
	serviceInfo.requiresLogin = characterServiceRequiresLogin
	serviceInfo.isTrialBoost = isTrialBoost
	serviceInfo.isEligible = CanBoostCharacter(class, level, boostInProgress, isTrialBoost, revokedCharacterUpgrade, vasServiceInProgress, isExpansionTrialCharacter, raceFilename, hasWowToken);
	serviceInfo.hasBonus = IsCharacterEligibleForVeteranBonus(level, isTrialBoost, revokedCharacterUpgrade);
	return serviceInfo;
end

local function IsUsingValidProductForTrialBoost(flowData)
	local boostType = flowData.boostType;
	local requiredBoost = C_CharacterServices.GetActiveClassTrialBoostType();
	return boostType ~= nil and boostType == requiredBoost;
end

local function IsUsingValidProductForCreateNewCharacterBoost()
	-- To prevent player confusion, when trial boost create is shown, do not show the normal boost create character button
	-- As different products are added this may need to be updated to reflect specific cases, but for now it's
	-- sufficient to make trial/normal create mutually exclusive.
	return not C_CharacterServices.IsTrialBoostEnabled() or not IsUsingValidProductForTrialBoost(CharacterUpgradeFlow.data);
end

function CharacterSelectBlockBase:Initialize(results)
	for i = 1, 3 do
		if (self.frame.BonusResults[i]) then
			self.frame.BonusResults[i]:Hide();
		end
	end
	self.seenPopup = false;
	self.frame.NoBonusResult:Hide();
	CharacterSelect_SetScrollEnabled(true);

	self:ClearResultInfo();
	self.lastSelectedIndex = CharacterSelect.selectedIndex;

	local numCharacters = GetNumCharacters();
	local numDisplayedCharacters = math.min(numCharacters, MAX_CHARACTERS_DISPLAYED);

	if (CharacterUpgrade_IsCreatedCharacterUpgrade()) then
		CharacterSelect_UpdateButtonState();

		if (self.createNum < numCharacters) then
			CharacterSelectCharacterFrame.ScrollBox:ScrollToEnd(ScrollBoxConstants.NoScrollInterpolation);

			CharacterSelect.selectedIndex = numCharacters;
			UpdateCharacterSelection(CharacterSelect);

			self.index = CharacterSelect.selectedIndex;
			self.charid = GetCharIDFromIndex(CharacterSelect.selectedIndex);
			self.playerguid = select(15, GetCharacterInfo(self.charid));

			local buttons = CharacterSelectCharacterFrame.ScrollBox:GetFrames();
			local button = buttons[#buttons];
			clearButtonScripts(button);

			CharacterServicesMaster_Update();

			return;
		end
	end

	CharacterServicesCharacterSelector:Show();
	CharacterServicesCharacterSelector:UpdateDisplay(self);

	self.frame.ControlsFrame.BonusLabel:SetHeight(self.frame.ControlsFrame.BonusLabel.BonusText:GetHeight());
	self.frame.ControlsFrame.BonusLabel:SetPoint("BOTTOM", CharSelectServicesFlowFrame, "BOTTOM", 10, 60);
	self.frame.ControlsFrame.BonusLabel:SetShown(CharacterUpgradeFlow.hasVeteran);

	-- Setup the step option frames
	self:ResetStepOptionFrames();

	local hasEligibleBoostCharacter = CharacterServicesCharacterSelector:HasAnyEligibleCharacter();
	local canCreateCharacter = CanCreateCharacter();
	local canShowCreateNewCharacterButton = canCreateCharacter and IsUsingValidProductForCreateNewCharacterBoost();
	local canCreateTrialBoostCharacter = canCreateCharacter and (C_CharacterServices.IsTrialBoostEnabled() and IsUsingValidProductForTrialBoost(CharacterUpgradeFlow.data));

	self:SetOptionUsed(self.OPTION_INDEX_STEP_LABEL, hasEligibleBoostCharacter);
	self:SetOptionUsed(self.OPTION_INDEX_CREATE_NEW_CHARACTER, canShowCreateNewCharacterButton);
	self:SetOptionUsed(self.OPTION_INDEX_CREATE_TRIAL_CHARACTER, canCreateTrialBoostCharacter);
	self:SetOptionUsed(self.OPTION_INDEX_CREATE_TRIAL_CHARACTER_HINT, canCreateTrialBoostCharacter and not (hasEligibleBoostCharacter or canShowCreateNewCharacterButton));

	self:LayoutOptionFrames();

	local canCreateBoostableCharacter = canCreateCharacter and (canShowCreateNewCharacterButton or canCreateTrialBoostCharacter);
	local showBoostError = not (canCreateBoostableCharacter or hasEligibleBoostCharacter);
	self:SetCharacterSelectErrorFrameShown(showBoostError);
end

function CharacterSelectBlockBase:ShouldShowPopup()
	local _, _, raceFilename = GetCharacterInfo(self.charid);
	local raceData = C_CharacterCreation.GetRaceDataByID(C_CharacterCreation.GetRaceIDFromName(raceFilename));
	local seenPopupBefore = self.seenPopup;
	self.seenPopup = true;
	local isTrialBoost = select(22, GetCharacterInfo(self.charid));
	return not isTrialBoost and raceData.isAlliedRace and not raceData.hasHeritageArmor and not seenPopupBefore;
end

function CharacterSelectBlockBase:GetPopupText()
	local _, _, raceFilename, _, _, _, _, _, _, _, _, _, _, _, _, _, _, gender = GetCharacterInfo(self.charid);
	local raceData = C_CharacterCreation.GetRaceDataByID(C_CharacterCreation.GetRaceIDFromName(raceFilename));

	if GetCurrentRegionName() == "CN" then
		return ReplaceGenderTokens(BOOST_ALLIED_RACE_HERITAGE_ARMOR_WARNING_CN:format(raceData.name), gender+1);
	else
		return ReplaceGenderTokens(BOOST_ALLIED_RACE_HERITAGE_ARMOR_WARNING:format(raceData.name), gender+1);
	end
end

function CharacterSelectBlockBase:IsFinished()
	return self.charid ~= nil;
end

function CharacterSelectBlockBase:GetResult()
	return { charid = self.charid; playerguid = self.playerguid }
end

function CharacterSelectBlockBase:FormatResult()
	local name, _, _, class, classFileName, _, level, _, _, _, _, _, _, _, _, prof1, prof2, _, _, _, _, isTrialBoost, _, revokedCharacterUpgrade = GetCharacterInfo(self.charid);
	local classColor = NORMAL_FONT_COLOR;
	if classFileName and RAID_CLASS_COLORS[classFileName] then
		classColor = RAID_CLASS_COLORS[classFileName];
	end
	return SELECT_CHARACTER_RESULTS_FORMAT:format(classColor.colorStr, name, level, class);
end

function CharacterSelectBlockBase:OnHide()
	local index = self.lastSelectedIndex;
	if (self:IsFinished()) then
		index = self.index;
	end

	CharacterServicesCharacterSelector:ResetState(index);
end

function CharacterSelectBlockBase:OnAdvance()
	CharacterSelect_SetScrollEnabled(false);
	CharacterServicesCharacterSelector:Hide();

	CharacterSelectCharacterFrame.ScrollBox:ForEachFrame(function(button)
		local enable = button:GetElementData().index == self.index;
		CharacterSelect_SetCharacterButtonEnabled(button, enable);
		CharacterSelect_SetButtonSelected(button, enable);
		CharacterSelect_SetArrowButtonShown(button, enable);
	end);
end

SpecSelectBlockBase = {};

-- There are currently no script overrides to recommended specs, add them here if necessary.
local recommendedSpecOverride = {};

function GetRecommendedSpecButton(ownerFrame, overrideSpecID)
	-- There may be multiple recommended specs for now, so determine the best one based on class.
	-- However, if there's an overrideSpec it wins all the time.
	local recommendedSpecID = recommendedSpecOverride[ownerFrame.classFilename];
	overrideSpecID = overrideSpecID or recommendedSpecID;

	for _, specButton in ipairs(ownerFrame.SpecButtons) do
		if overrideSpecID and (specButton:GetID() == overrideSpecID) then
			return specButton;
		elseif not overrideSpecID and specButton.isRecommended then
			return specButton;
		end
	end
end

function ClickRecommendedSpecButton(ownerFrame, overrideSpecID)
	local specButton = GetRecommendedSpecButton(ownerFrame, overrideSpecID);
	if specButton then
		specButton:Click();
	end
end

local function createTooltipText(description, gender, isRecommended, isTrialBoost)
	local tooltipText = ReplaceGenderTokens(description, gender);

	if (not isRecommended) then
		local warningText = CHARACTER_BOOST_RECOMMENDED_SPEC_ONLY;
		if (isTrialBoost) then
			warningText = CHARACTER_BOOST_RECOMMENDED_SPEC_ONLY_TRIAL_VERSION;
		end

		warningText = CreateColor(1, 0, 0, 1):WrapTextInColorCode(warningText);
		tooltipText = CreateColor(.5, .5, .5, 1):WrapTextInColorCode(tooltipText)..warningText;
	end

	return tooltipText;
end

-- Spec selection buttons are used in two locations during character creation at this point:
-- Boosts, and Class Trials
-- This data allows customization of button placement, hit insets, spec name truncation, etc...
-- Unused fields left in place as documentation for what will be referenced.

local defaultSpecButtonLayoutData = {
	initialAnchor = { point = "TOPLEFT", relativeKey = nil, relativePoint = "TOPLEFT", x = 83, y = -73 },
	subsequentAnchor = { point = "TOP", relativePoint = "BOTTOM", x = 0, y = -35 },
	buttonInsets = nil, -- numerically indexed, ordering matches SetHitInsets API
	specNameWidth = nil,
	specNameFont = nil,
}

local function CreateSpecButton(parent, buttonIndex, layoutData)
	local frame = CreateFrame("CheckButton", nil, parent, "CharacterUpgradeSelectSpecRadioButtonTemplate");
	local relativeFrame, anchorData;

	if (buttonIndex == 1) then
		anchorData = layoutData.initialAnchor;
		relativeFrame = parent;
	else
		anchorData = layoutData.subsequentAnchor;
		relativeFrame = parent.SpecButtons[buttonIndex - 1];
	end

	if (anchorData.relativeKey) then
		relativeFrame = relativeFrame[anchorData.relativeKey];
	end

	frame:SetPoint(anchorData.point, relativeFrame, anchorData.relativePoint, anchorData.x, anchorData.y);

	if (layoutData.buttonInsets) then
		frame:SetHitRectInsets(unpack(layoutData.buttonInsets));
	end

	if (layoutData.specNameWidth) then
		frame.SpecName:SetWidth(layoutData.specNameWidth);
	end

	if (layoutData.specNameFont) then
		frame.SpecName:SetFontObject(layoutData.specNameFont);
	end

	return frame;
end

local function CharacterServices_IsCurrentSpecializationAllowed(classID, gender, currentSpecID)
	for i = 1, 4 do
		local specID, _, _, _, _, isRecommended, isAllowed = GetSpecializationInfoForClassID(classID, i, gender);
		if specID == currentSpecID then
			return isRecommended or isAllowed;
		end
	end

	return false;
end

function CharacterServices_UpdateSpecializationButtons(classID, gender, parentFrame, owner, allowAllSpecs, isTrialBoost, currentSpecID, allowAutoSelectSpec)
	local numSpecs = GetNumSpecializationsForClassID(classID);

	if not parentFrame.SpecButtons then
		parentFrame.SpecButtons = {}
	end

	local layoutData = parentFrame.layoutData or defaultSpecButtonLayoutData;

	-- Examine all specs to determine which text to show for available specs
	local availableSpecsToChoose = 0;

	if allowAllSpecs then
		availableSpecsToChoose = numSpecs;
	else
		for i = 1, 4 do
			local specID, _, _, _, _, isRecommended, isAllowed = GetSpecializationInfoForClassID(classID, i, gender);

			if isRecommended or isAllowed then
				availableSpecsToChoose = availableSpecsToChoose + 1;
			end
		end
	end

	local hasActualChoice = (availableSpecsToChoose > 1);
	local canChooseFromAllSpecs = allowAllSpecs or (hasActualChoice and availableSpecsToChoose == numSpecs);
	local isCurrentSpecAllowed = canChooseFromAllSpecs or CharacterServices_IsCurrentSpecializationAllowed(classID, gender, currentSpecID);
	local autoSelectedSpecID;

	for i = 1, 4 do
		if not parentFrame.SpecButtons[i] then
			parentFrame.SpecButtons[i] = CreateSpecButton(parentFrame, i, layoutData);
		end

		local button = parentFrame.SpecButtons[i];
		button.owner = owner;
		button.isRecommended = nil;

		if i <= numSpecs then
			local specID, name, description, icon, role, isRecommended, isAllowed = GetSpecializationInfoForClassID(classID, i, gender + 1);
			local allowed = allowAllSpecs or isAllowed or isRecommended;
			local isCurrentSpec = specID == currentSpecID;

			-- We prefer to show a player's current spec instead of a recommended spec. We should only show
			-- the recommended spec if you're boosting a brand new character.
			local showRecommendedLabel;
			if isCurrentSpecAllowed then
				showRecommendedLabel = isCurrentSpec;
			else
				showRecommendedLabel = isRecommended;
			end

			button:SetID(specID);
			button.SpecIcon:SetTexture(icon);
			button.SpecIcon:SetDesaturated(not allowed);
			button.Frame:SetDesaturated(not allowed);
			button.SpecName:SetText(name);
			button.RoleIcon:SetAtlas(GetMicroIconForRole(role), TextureKitConstants.IgnoreAtlasSize);
			button.RoleIcon:SetDesaturated(not allowed);
			button.RoleName:SetText(_G["ROLE_"..role]);
			button:SetEnabled(allowed);
			button.Recommended:SetShown(showRecommendedLabel);
			button.isRecommended = isRecommended;

			if showRecommendedLabel then
				autoSelectedSpecID = specID;
				if not hasActualChoice then
					button.Recommended:SetText(CHAR_SPEC_AVAILABLE);
				elseif isCurrentSpec then
					button.Recommended:SetText(CHARACTER_UPGRADE_FLOW_CHAR_SPEC_CURRENT);
				elseif isRecommended then
					button.Recommended:SetText(CHAR_SPEC_RECOMMENEDED);
				end
			end

			if allowed then
				button.SpecName:SetTextColor(1, .82, 0, 1);
			else
				button.SpecName:SetTextColor(.5, .5, .5, 1);
			end

			if showRecommendedLabel then
				button.SpecName:SetPoint("TOPLEFT", button.Frame, "TOPRIGHT", 6, -3);
				button.RoleName:SetPoint("TOPLEFT", button.Recommended, "BOTTOMLEFT");
			else
				button.SpecName:SetPoint("TOPLEFT", button.Frame, "TOPRIGHT", 6, -8);
				button.RoleName:SetPoint("TOPLEFT", button.SpecName, "BOTTOMLEFT");
			end

			button:SetChecked(false);
			button:Show();
			button.tooltipTitle = name;
			button.tooltip = createTooltipText(description, gender, allowed, isTrialBoost);
		else
			button:Hide();
		end
	end

	if allowAutoSelectSpec and owner.OnUpdateSpecButtons then
		owner:OnUpdateSpecButtons(autoSelectedSpecID);
	end

	return numSpecs;
end

function SpecSelectBlockBase:SpecSelectBlockInitializeHelper(results, wasFromRewind, flow, parent, callback, allowAutoSelectSpec)
	if not wasFromRewind then
		self.selected = nil;
	end

	self.specButtonClickedCallback = callback;

	local _, _, _, _, classFilename, classID, experienceLevel, _, _, _, _, _, _, _, playerguid, _, _, gender, _, _, _, _, _, _, _, _, specID = GetCharacterInfo(results.charid);
	self.classID = classID;
	self.frame.ControlsFrame.classFilename = classFilename;

	local isNewCharacter = experienceLevel < 10;
	if isNewCharacter then
		self.currentSpecID = nil;
	else
		self.currentSpecID = specID;
	end

	-- When boosting to level 100, prevent the selection of non-recommended specs, but still auto-select from
	-- the limited number of specs that the user can choose from
	local flags = flow.data.flags or 0;
	local restrictToRecommendedSpecs = bit.band(flags, Enum.CharacterServiceInfoFlag.RestrictToRecommendedSpecs) == Enum.CharacterServiceInfoFlag.RestrictToRecommendedSpecs;

	return CharacterServices_UpdateSpecializationButtons(classID, gender+1, parent, self, not restrictToRecommendedSpecs, nil, self.currentSpecID, allowAutoSelectSpec);
end

function SpecSelectBlockBase:OnUpdateSpecButtons(autoSelectedSpecID)
	local overrideSpec = self.selected or autoSelectedSpecID;
	if overrideSpec then
		ClickRecommendedSpecButton(self:GetSpecButtonContainer(), overrideSpec);
	end
end

function SpecSelectBlockBase:IsFinished(wasFromRewind)
	return not wasFromRewind and self.selected ~= nil;
end

function SpecSelectBlockBase:GetResult()
	return { spec = self.selected, classId = self.classID };
end

function SpecSelectBlockBase:FormatResult()
	return GetSpecializationNameForSpecID(self.selected);
end

function SpecSelectBlockBase:ShouldShowPopup()
	-- If it ever becomes possible to select non-recommended specs, then re-enable this.
	--local role = select(5, GetSpecializationInfoForSpecID(self.selected));
	--return role == "HEALER";
	return false;
end

function SpecSelectBlockBase:GetPopupText()
	return string.format(BOOST_NOT_RECOMMEND_SPEC_WARNING, GetSpecializationNameForSpecID(self.selected));
end


local CharacterUpgradeCharacterSelectBlock = Mixin(
	{ FrameName = "CharacterUpgradeSelectCharacterFrame", Back = false, Next = false, Finish = false, AutoAdvance = true, ResultsLabel = SELECT_CHARACTER_RESULTS_LABEL, ActiveLabel = SELECT_CHARACTER_ACTIVE_LABEL, Popup = "BOOST_ALLIED_RACE_HERITAGE_ARMOR_WARNING" },
	CharacterSelectBlockBase
);
local CharacterUpgradeSpecSelectBlock = Mixin(
	{ FrameName = "CharacterUpgradeSelectSpecFrame", Back = true, Next = true, Finish = false, ActiveLabel = SELECT_SPEC_ACTIVE_LABEL, ResultsLabel = SELECT_SPEC_RESULTS_LABEL, Popup = "BOOST_NOT_RECOMMEND_SPEC_WARNING" },
	SpecSelectBlockBase
);
local CharacterUpgradeFactionSelectBlock = { FrameName = "CharacterUpgradeSelectFactionFrame", Back = true, Next = true, Finish = false, ActiveLabel = SELECT_FACTION_ACTIVE_LABEL, ResultsLabel = SELECT_FACTION_RESULTS_LABEL };
local CharacterUpgradeEndStep = { Back = true, Next = false, Finish = true, HiddenStep = true, SkipOnRewind = true };

CharacterUpgradeFlow = Mixin(
	{
		FinishLabel = CHARACTER_UPGRADE_FINISH_LABEL,

		Steps = {
			[1] = CharacterUpgradeCharacterSelectBlock,
			[2] = CharacterUpgradeSpecSelectBlock,
			[3] = CharacterUpgradeFactionSelectBlock,
			[4] = CharacterUpgradeEndStep,
		}
	},
	CharacterServicesFlowMixin
);

function CharacterUpgradeFlow:SetAutoSelectGuid(guid)
	self.autoSelectGuid = guid;
end

function CharacterUpgradeFlow:GetAutoSelectGuid()
	return self.autoSelectGuid;
end

function CharacterUpgradeFlow:SetTrialBoostGuid(guid)
	self:SetAutoSelectGuid(guid);
	self.isTrialBoost = guid ~= nil;

	if self.isTrialBoost then
		CharacterUpgradeFactionSelectBlock.SkipOnRewind = true;
	else
		CharacterUpgradeFactionSelectBlock.SkipOnRewind = nil;
	end
end

function CharacterUpgradeFlow:IsTrialBoost()
	return self.isTrialBoost;
end

function CharacterUpgradeFlow:IsUnrevoke()
	-- This is copy-pasted below as ShouldSkipSpecSelect(), please update both functions together
	if self:IsTrialBoost() then
		return false;
	end

	local results = self:BuildResults(self:GetNumSteps());
	if not results.charid then
		-- We haven't chosen a character yet.
		return nil;
	end

	local revokedCharacterUpgrade = select(24, GetCharacterInfo(results.charid));
	return revokedCharacterUpgrade;
end

function CharacterUpgradeFlow:ShouldSkipSpecSelect()
	-- This is copy-pasted above as IsUnrevoke(), please update both functions together
	-- This was the original behavior of IsUnrevoke(), but this logic doesn't technically prove that the boost is an unrevoke
	-- Presumably we will eventually want some clearer factoring of different upgrade types - VAS 20200805
	if self:IsTrialBoost() then
		return false;
	end

	local results = self:BuildResults(self:GetNumSteps());
	if not results.charid then
		-- We haven't chosen a character yet.
		return nil;
	end

	local experienceLevel = select(7, GetCharacterInfo(results.charid));
	return experienceLevel >= self.data.level;
end

function CharacterUpgradeFlow:Initialize(controller)
	CharacterUpgradeSecondChanceWarningFrame.warningAccepted = false;
	CharacterUpgradeSecondChanceWarningFrame:Hide();

	CharacterServicesFlowMixin.Initialize(self, controller);

	self.hasVeteran = nil;
end

function CharacterUpgradeFlow:Rewind(controller)
	self:SetAutoSelectGuid(nil);
	return CharacterServicesFlowMixin.Rewind(self, controller);
end

function CharacterUpgradeFlow:OnHide()
	self:SetAutoSelectGuid(nil);
	return CharacterServicesFlowMixin.OnHide(self);
end

function CharacterUpgradeFlow:OnAdvance(controller, results)
	if (self.step == 1) then
		local level = select(7, GetCharacterInfo(results.charid));
		if (level >= UPGRADE_BONUS_LEVEL) then
			self.Steps[2].ExtraOffset = 45;
		else
			self.Steps[2].ExtraOffset = 0;
		end
		local factionGroup = C_CharacterServices.GetFactionGroupByIndex(results.charid);
		self.Steps[3].SkipOnRewind = (factionGroup ~= "Neutral");
	end

	local block = self:GetCurrentStep();
	if not block.HiddenStep and self.step ~= 1 then
		local extraOffset = 0;
		if (self.step == 2) then
			extraOffset = 15;
		end
		self:MoveBlock(block, -60 - extraOffset);
	end
end

local function ValidateSpec(results)
	if not results.spec and CharacterUpgradeFlow:ShouldSkipSpecSelect() then
		local _, _, _, _, classFilename, classID, experienceLevel, _, _, _, _, _, _, _, playerguid, _, _, gender, _, _, _, _, _, _, _, _, specID = GetCharacterInfo(results.charid);
		results.spec = specID;
		results.classId = classID;
	end
end

function CharacterUpgradeFlow:Finish(controller)
	if (not CharacterUpgradeSecondChanceWarningFrame.warningAccepted) then
		CharacterUpgradeSecondChanceWarningBackground.ConfirmButton:SetText(self:GetFinishLabel());

		if ( self:IsTrialBoost() ) then
			if ( C_StoreSecure.GetCurrencyID() == CURRENCY_KRW ) then
				CharacterUpgradeSecondChanceWarningBackground.Text:SetText(CHARACTER_UPGRADE_KRW_FINISH_TRIAL_BOOST_BUTTON_POPUP_TEXT);
			else
				CharacterUpgradeSecondChanceWarningBackground.Text:SetText(CHARACTER_UPGRADE_FINISH_TRIAL_BOOST_BUTTON_POPUP_TEXT);
			end
		else
			if ( C_StoreSecure.GetCurrencyID() == CURRENCY_KRW ) then
				CharacterUpgradeSecondChanceWarningBackground.Text:SetText(CHARACTER_UPGRADE_KRW_FINISH_BUTTON_POPUP_TEXT);
			else
				CharacterUpgradeSecondChanceWarningBackground.Text:SetText(CHARACTER_UPGRADE_FINISH_BUTTON_POPUP_TEXT);
			end
		end

		CharacterUpgradeSecondChanceWarningFrame:Show();
		return false;
	end

	local results = self:BuildResults(self:GetNumSteps());
	if self:IsUnrevoke() then
		local guid = select(15, GetCharacterInfo(results.charid));
		C_CharacterServices.RequestManualUnrevoke(guid);
	else

		if (not results.faction) then
			-- Non neutral character, convert faction group to id.
			results.faction = PLAYER_FACTION_GROUP[C_CharacterServices.GetFactionGroupByIndex(results.charid)];
		end
		local guid = select(15, GetCharacterInfo(results.charid));
		if (guid ~= results.playerguid) then
			-- Bail because guid has changed!
			message(CHARACTER_UPGRADE_CHARACTER_LIST_CHANGED_ERROR);
			self:Restart(controller);
			return false;
		end

		self:SetTrialBoostGuid(nil);

		CharacterServicesMaster.pendingGuid = results.playerguid;

		ValidateSpec(results);
		C_CharacterServices.AssignUpgradeDistribution(results.playerguid, results.faction, results.spec, results.classId, self.data.boostType, 0);
	end
	return true;
end

function CharacterUpgradeFlow:GetFinishLabel()
	-- "Level Up!" is replaced with "Unlock!" when unlocking a trial boost character.
	if self:IsTrialBoost() then
		return CHARACTER_UPGRADE_UNLOCK_TRIAL_CHARACTER_FINISH_LABEL;
	end

	if self:IsUnrevoke() then
		return CHARACTER_UPGRADE_UNREVOKE_CHARACTER_FINISH_LABEL;
	end

	return CharacterServicesFlowMixin.GetFinishLabel(self);
end

local function clearAllButtonScripts()
	CharacterSelectCharacterFrame.ScrollBox:ForEachFrame(clearButtonScripts);
end

function CharacterUpgrade_IsCreatedCharacterUpgrade()
	return C_CharacterCreation.GetCharacterCreateType() == Enum.CharacterCreateType.Boost;
end

function CharacterUpgrade_IsCreatedCharacterTrialBoost()
	return C_CharacterCreation.GetCharacterCreateType() == Enum.CharacterCreateType.TrialBoost;
end

function CharacterUpgrade_ResetBoostData()
	C_CharacterCreation.SetCharacterCreateType(Enum.CharacterCreateType.Normal);
	CHARACTER_UPGRADE_CREATE_CHARACTER_DATA = nil;
end

function IsExpansionTrialCharacter(characterGUID)
	local isExpansionTrialCharacter = select(28, GetCharacterInfoByGUID(characterGUID));
	return isExpansionTrialCharacter;
end

function GetAvailableBoostTypesForCharacterByGUID(characterGUID)
	local availableBoosts = {};
	local upgradeDistributions = C_SharedCharacterServices.GetUpgradeDistributions();
	if upgradeDistributions then
		local raceFilename, _, class, _, level, _, _, _, _, _, _, _, playerguid, _, _, _, boostInProgress, _, _, isTrialBoost, _, revokedCharacterUpgrade, vasServiceInProgress = select(3, GetCharacterInfoByGUID(characterGUID));
		for boostType, data in pairs(upgradeDistributions) do
			if IsBoostFlowValidForCharacter(C_CharacterServices.GetCharacterServiceDisplayData(boostType), class, level, boostInProgress, isTrialBoost, revokedCharacterUpgrade, vasServiceInProgress, raceFilename) then
				availableBoosts[#availableBoosts + 1] = boostType;
			end
		end
	end

	return availableBoosts;
end

local g_filteringByBoostsOnly = nil;
function CharacterUpgradeCharacterSelectBlock_IsFilteringByBoostable()
	return g_filteringByBoostsOnly;
end

function CharacterUpgradeCharacterSelectBlock_SetFilteringByBoostable(boostsOnly)
	g_filteringByBoostsOnly = boostsOnly;
end

function CharacterUpgradeCharacterSelectBlock_IsCharacterBoostable(characterIndex)
	local raceFilename, _, class, _, level, _, _, _, _, _, _, _, playerguid, _, _, _, boostInProgress, _, _, isTrialBoost, _, revokedCharacterUpgrade, vasServiceInProgress, _, _, isExpansionTrialCharacter, _, _, _, _, _, characterServiceRequiresLogin, _, _, _, hasWowToken = select(3, GetCharacterInfo(GetCharIDFromIndex(characterIndex)));
	local canBoostCharacter = CanBoostCharacter(class, level, boostInProgress, isTrialBoost, revokedCharacterUpgrade, vasServiceInProgress, isExpansionTrialCharacter, raceFilename, hasWowToken);
	return canBoostCharacter;
end

function CharacterUpgradeSelectCharacterFrame_OnLoad(self)
	local controls = self.ControlsFrame;
	local buttonWidth = max(controls.CreateCharacterButton:GetTextWidth(), controls.CreateCharacterClassTrialButton:GetTextWidth()) + 50;
	controls.CreateCharacterButton:SetWidth(buttonWidth);
	controls.CreateCharacterClassTrialButton:SetWidth(buttonWidth);

	controls.OrLabel2:SetPoint("TOPLEFT", controls.CreateCharacterButton, "BOTTOMLEFT", 0, -5);
end

function CharacterUpgrade_SetupFlowForNewCharacter(characterType)
	if characterType == Enum.CharacterCreateType.Boost then
		CharacterUpgradeCharacterSelectBlock.createNum = GetNumCharacters();

		if CharacterServicesMaster.flow then
			CHARACTER_UPGRADE_CREATE_CHARACTER_DATA = CharacterServicesMaster.flow.data;
		end
	end
end

function CharacterUpgrade_BeginNewCharacterCreation(characterType)
	CharacterUpgrade_SetupFlowForNewCharacter(characterType);
	CharacterSelect_CreateNewCharacter(characterType);
end

function CharacterUpgradeCreateCharacter_OnClick(self)
	CharacterUpgrade_BeginNewCharacterCreation(Enum.CharacterCreateType.Boost);
end

function CharacterUpgradeClassTrial_OnClick(self)
	CharSelectServicesFlowFrame:Hide();
	CharacterUpgrade_BeginNewCharacterCreation(Enum.CharacterCreateType.TrialBoost);
end

function CharacterUpgradeSpecSelectBlock:Initialize(results, wasFromRewind)
	local allowAutoSelect = true;
	self:SpecSelectBlockInitializeHelper(results, wasFromRewind, CharacterUpgradeFlow, self.frame.ControlsFrame, CharacterServicesMaster_Update, allowAutoSelect)
end

function CharacterUpgradeSpecSelectBlock:SkipIf(results)
	return CharacterUpgradeFlow:ShouldSkipSpecSelect();
end

function CharacterUpgradeSpecSelectBlock:GetSpecButtonContainer()
	return self.frame.ControlsFrame;
end

function CharacterUpgradeSelectSpecRadioButton_OnClick(self, button, down)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	local owner = self.owner;

	if owner then
		if owner.selected == self:GetID() then
			self:SetChecked(true);
			return;
		else
			owner.selected = self:GetID();
			self:SetChecked(true);
		end

		if owner.specButtonClickedCallback then
			owner.specButtonClickedCallback();
		end
	end

	for _, button in ipairs(self:GetParent().SpecButtons) do
		if button:GetID() ~= self:GetID() then
			button:SetChecked(false);
		end
	end
end

function CharacterUpgradeFactionSelectBlock:Initialize(results)
	self.selected = nil;
	self.SkipOnRewind = self:SkipIf(results);
end

function CharacterUpgradeFactionSelectBlock:IsFinished(wasFromRewind)
	return not wasFromRewind and self.selected ~= nil;
end

function CharacterUpgradeFactionSelectBlock:GetResult()
	return { faction = self.selected };
end

function CharacterUpgradeFactionSelectBlock:FormatResult()
	return SELECT_FACTION_RESULTS_FORMAT:format(PLAYER_FACTION_COLORS_HEX[self.selected], FACTION_LABELS[self.selected]);
end

function CharacterUpgradeFactionSelectBlock:SkipIf(results)
	return C_CharacterServices.GetFactionGroupByIndex(results.charid) ~= "Neutral";
end

function CharacterUpgradeFactionSelectBlock:OnSkip()
	self.selected = nil;
end

function CharacterUpgradeSelectFactionFrame_OnLoad(self)
	for _, button in ipairs(self.ControlsFrame.FactionButtons) do
		button.FactionIcon:SetTexture(FACTION_LOGO_TEXTURES[button.factionID]);
		button.FactionName:SetText(FACTION_LABELS[button.factionID]);
	end
end

function CharacterUpgradeSelectFactionFrame_ClearChecked()
	for _, button in ipairs(CharacterUpgradeSelectFactionFrame.ControlsFrame.FactionButtons) do
		button:SetChecked(false);
	end

	CharacterUpgradeFactionSelectBlock.selected = nil;
end

function CharacterUpgradeSelectFactionRadioButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	CharacterUpgradeSelectFactionFrame_ClearChecked();
	self:SetChecked(true);
	CharacterUpgradeFactionSelectBlock.selected = self.factionID;
	CharacterServicesMaster_Update();
end

function CharacterUpgradeEndStep:Initialize(results)
	CharacterServicesMaster_Update();
end

function CharacterUpgradeEndStep:IsFinished()
	return true;
end

function CharacterUpgradeEndStep:GetResult()
	return {};
end

function CharacterUpgradeEndStep:OnRewind()
	if (CharacterUpgradeSecondChanceWarningFrame:IsShown()) then
		CharacterUpgradeSecondChanceWarningFrame:Hide();
	end
end

local RPEUPgradeInfoBlock = Mixin(
	{ FrameName = "RPEUPgradeInfoFrame", Back = false, Next = true, Finish = false, AutoAdvance = false, ResultsLabel = SELECT_CHARACTER_RESULTS_LABEL,  ActiveLabel = SELECT_CHARACTER_ACTIVE_LABEL, Popup = "RPE_BOOST_ALLIED_RACE_HERITAGE_ARMOR_WARNING" },
	CharacterSelectBlockBase
);
local RPEUpgradeSpecSelectBlock = Mixin(
	{ FrameName = "RPEUpgradeSelectSpecFrame", Back = true, Next = false, Finish = true, ActiveLabel = "", ResultsLabel = "", Popup = "BOOST_NOT_RECOMMEND_SPEC_WARNING" },
	SpecSelectBlockBase
);

RPEUpgradeFlow = Mixin(
	{
		FinishLabel = CHARACTER_UPGRADE_FINISH_LABEL,

		Steps = {
			[1] = RPEUPgradeInfoBlock,
			[2] = RPEUpgradeSpecSelectBlock
		},

		MinimizedFrame = "RPEUpgradeMinimizedFrame"
	},
	CharacterServicesFlowMixin
);

function RPEUpgradeFlow:Initialize(controller)
	CharacterServicesFlowMixin.Initialize(self, controller);
end

function RPEUpgradeFlow:GetTheme()
	return "RPE";
end

function RPEUpgradeFlow:ShouldDisableButtons()
	return false;
end

function RPEUpgradeFlow:GetFinishLabel()
	return RPE_UPDATE;
end

function RPEUpgradeFlow:UsesSelector()
	return false;
end

local function SetKeepQuestsAndContinue(keepQuests)
	return function()
		GlueDialog.data.keepQuests = keepQuests;
		GlueDialog_Show("RPE_UPGRADE_CONFIRM", nil, GlueDialog.data);
		CharSelectServicesFlowFrame:Hide()
    end
end

GlueDialogTypes["RPE_UPGRADE_QUEST_CLEAR_CONFIRM"] = {
    text = RPE_UPGRADE_QUEST_CLEAR_CONFIRMATION,
    button1 = RPE_CLEAR_QUESTS,
    button2 = RPE_KEEP_QUESTS,
    OnAccept = SetKeepQuestsAndContinue(false),
    OnCancel = SetKeepQuestsAndContinue(true),
}

GlueDialogTypes["RPE_UPGRADE_CONFIRM"] = {
    text = RPE_UPGRADE_CONFIRMATION,
    button1 = RPE_CONFIRM,
    button2 = CANCEL,
    OnAccept = function()
        local results = GlueDialog.data;
		C_CharacterServices.RPEResetCharacter(results.playerguid, results.faction, results.spec, results.keepQuests);
		CharacterSelect_UpdateCharacterMatchingGUID(results.playerguid); --update the character button so it says 'processing'
    end,
    OnCancel = function()
		BeginCharacterServicesFlow(RPEUpgradeFlow, {});
		CharacterServicesMaster.flow:Advance(CharacterServicesMaster); 
	end,
}

function RPEUpgradeFlow:Finish(controller)
	local results = self:BuildResults(self:GetNumSteps());
	if (not results.faction) then
		-- Non neutral character, convert faction group to id.
		results.faction = PLAYER_FACTION_GROUP[C_CharacterServices.GetFactionGroupByIndex(results.charid)];
	end
	local guid = select(15, GetCharacterInfo(results.charid));
	if (guid ~= results.playerguid) then
		-- Bail because guid has changed!
		message(CHARACTER_UPGRADE_CHARACTER_LIST_CHANGED_ERROR);
		self:Restart(controller);
		return false;
	end

	CharacterServicesMaster.pendingGuid = results.playerguid;

	ValidateSpec(results);
	local questClearAvailable = select(37, GetCharacterInfo(results.charid));
	if questClearAvailable then
		GlueDialog_Show("RPE_UPGRADE_QUEST_CLEAR_CONFIRM", nil, results);
		return false; --flow will be closed by the RPE_UPGRADE_QUEST_CLEAR_CONFIRM dialog.
	else
		results.keepQuests = true;
		GlueDialog_Show("RPE_UPGRADE_CONFIRM", nil, results);
		return true;
	end
end


local RPEUPgradeInfoBlockSubFrameText = {
	Line1 = "RPE_INFO_TEXT1", 
	Line2 = "RPE_INFO_TEXT2", 
	Line3 = "RPE_INFO_TEXT3"
};

function RPEUPgradeInfoBlock:Initialize(results)
	self.seenPopup = false;
	CharacterSelect_SetScrollEnabled(true);
	
	--dont clear results
	--self:ClearResultInfo();

	local button = CharacterSelectCharacterFrame.ScrollBox:FindFrameByPredicate(function(frame, elementData)
		return frame.index == CharacterSelect.selectedIndex;
	end);

	if button then
		local serviceInfo = self:GetServiceInfoByCharacterID(button.characterID);
		self:SaveResultInfo(button, serviceInfo.playerguid)
	else
		EndCharacterServicesFlow(); --if there's anything wrong with CharacterSelect.selectedIndex, abort.
	end

	local controlsFrame = self.frame.ControlsFrame
	controlsFrame:Show();

	for k,v in pairs(RPEUPgradeInfoBlockSubFrameText) do
		controlsFrame[k].Text:SetText(_G[v]);
	end
end

function RPEUPgradeInfoBlock:GetServiceInfoByCharacterID(characterID)
	local serviceInfo = { checkAutoSelect = false, checkTrialBoost = false };
	local raceFilename, _, class, _, level, _, _, _, _, _, _, _, playerguid, _, _, _, boostInProgress, _, _, isTrialBoost, _, revokedCharacterUpgrade, vasServiceInProgress, _, _, isExpansionTrialCharacter, _, _, _, _, _, characterServiceRequiresLogin = select(3, GetCharacterInfo(characterID));
	serviceInfo.playerguid = playerguid
	serviceInfo.requiresLogin = characterServiceRequiresLogin
	serviceInfo.isTrialBoost = isTrialBoost
	serviceInfo.isEligible = true;
	serviceInfo.hasBonus = false;
	return serviceInfo;
end

function RPEUPgradeInfoBlock:IsFinished()
	return true;
end

function RPEUPgradeInfoBlock:OnHide()
  --intentionally left blank
end

function RPEUPgradeInfoBlock:ShouldShowPopup()
	return false;
end

function RPEUPgradeInfoBlock:OnAdvance()
	self.frame.ControlsFrame:Hide();
end

function RPEUPgradeInfoBlock:OnRewind()
	--do not clear results
end

NineSliceUtil.AddLayout("CharacterUpdate", {
	TopLeftCorner =	{ atlas = "characterupdate-9slice-topleftcorner", },
	TopRightCorner =	{ atlas = "characterupdate-9slice-toprightcorner", },
	BottomLeftCorner =	{ atlas = "characterupdate-9slice-bottomleftcorner", },
	BottomRightCorner =	{ atlas = "characterupdate-9slice-bottomrightcorner", },
	TopEdge = { atlas = "_characterupdate-9slice-topedge", },
	BottomEdge = { atlas = "_characterupdate-9slice-bottomedge", },
	LeftEdge = { atlas = "!characterupdate-9slice-leftedge", },
	RightEdge = { atlas = "!characterupdate-9slice-rightedge",},
});

NineSliceUtil.AddLayout("CharacterUpdate-Selected", {
	TopLeftCorner =	{ atlas = "characterupdate-9slice-topleftcorner-selected", },
	TopRightCorner =	{ atlas = "characterupdate-9slice-toprightcorner-selected", },
	BottomLeftCorner =	{ atlas = "characterupdate-9slice-bottomleftcorner-selected", },
	BottomRightCorner =	{ atlas = "characterupdate-9slice-bottomrightcorner-selected", },
	TopEdge = { atlas = "_characterupdate-9slice-topedge-selected", },
	BottomEdge = { atlas = "_characterupdate-9slice-bottomedge-selected", },
	LeftEdge = { atlas = "!characterupdate-9slice-leftedge-selected", },
	RightEdge = { atlas = "!characterupdate-9slice-rightedge-selected",},
});

local RPESpecButtonLayoutData = {
	initialAnchor = { point = "TOPLEFT", relativeKey = nil, relativePoint = "TOPLEFT", x = 15, y = -30 },
	subsequentAnchor = { point = "TOP", relativePoint = "BOTTOM", x = 0, y = -35 },
	buttonInsets = nil, -- numerically indexed, ordering matches SetHitInsets API
	specNameWidth = nil,
	specNameFont = nil,
}

function RPEUpgradeSpecSelectBlock:Initialize(results, wasFromRewind)
	local characterBlock = self.frame.ControlsFrame.CharacterBlock;
	local specBlock = self.frame.ControlsFrame.SpecBlock;

	specBlock.layoutData = RPESpecButtonLayoutData;

	specBlock.SpecCheckmark:Hide();

	NineSliceUtil.ApplyLayoutByName(characterBlock, "CharacterUpdate-Selected");
	NineSliceUtil.ApplyLayoutByName(specBlock, "CharacterUpdate");

	local allowAutoSelect = false;
	local numSpecs = self:SpecSelectBlockInitializeHelper(results, wasFromRewind, RPEUpgradeFlow, specBlock, 
		function() 
			specBlock.SpecCheckmark:Show(); 
			NineSliceUtil.ApplyLayoutByName(specBlock, "CharacterUpdate-Selected");
			CharacterServicesMaster_Update();
		end, 
		allowAutoSelect
	); 

	specBlock:SetSize(250, 30 + 50*numSpecs);
	
	local name, _, _, className, _, _, experienceLevel = GetCharacterInfo(results.charid);

	characterBlock.Name:SetText(name);
	characterBlock.Level:SetText(string.format(RPE_CHARACTER_LVL, experienceLevel, className));
end

function RPEUpgradeSpecSelectBlock:GetSpecButtonContainer()
	return self.frame.ControlsFrame.SpecBlock;
end

function RPEUpgradeSpecSelectBlock:SkipIf(results)
	return false; --no skip
end
