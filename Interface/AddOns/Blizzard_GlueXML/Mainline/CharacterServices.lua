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

StaticPopupDialogs["PRODUCT_ASSIGN_TO_TARGET_FAILED"] = {
	text = BLIZZARD_STORE_INTERNAL_ERROR,
	button1 = OKAY,
	escapeHides = true,
};

StaticPopupDialogs["BOOST_FACTION_CHANGE_IN_PROGRESS"] = {
	text = CHARACTER_BOOST_ERROR_PENDING_FACTION_CHANGE,
	button1 = OKAY,
	escapeHides = true,
};

StaticPopupDialogs["MUST_LOG_IN_FIRST"] = {
	text = MUST_LOG_IN_FIRST,
	button1 = OKAY,
	escapeHides = true,
};

local function IsCharacterEligibleForVeteranBonus(level, isTrialBoost, revokedCharacterUpgrade)
	return false;
end

local function IsBoostFlowValidForCharacter(flowData, level, boostInProgress, isTrialBoost, revokedCharacterUpgrade, vasServiceInProgress, isExpansionTrialCharacter, raceFilename, hasWowToken, playerGUID)
	if (boostInProgress or vasServiceInProgress or hasWowToken) then
		return false;
	end

	local timerunningSeasonID = playerGUID and GetCharacterTimerunningSeasonID(playerGUID);
	if timerunningSeasonID then
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

local function CanBoostCharacter(level, boostInProgress, isTrialBoost, revokedCharacterUpgrade, vasServiceInProgress, isExpansionTrialCharacter, raceFilename, hasWowToken, playerGUID)
	return IsBoostFlowValidForCharacter(CharacterUpgradeFlow.data, level, boostInProgress, isTrialBoost, revokedCharacterUpgrade, vasServiceInProgress, isExpansionTrialCharacter, raceFilename, hasWowToken, playerGUID);
end

local function clearButtonScripts(frame)
	frame:SetScript("OnClick", nil);
	frame:SetScript("OnDoubleClick", nil);
	frame:SetScript("OnDragStart", nil);
	frame:SetScript("OnDragStop", nil);
	frame:SetScript("OnMouseDown", nil);
	frame:SetScript("OnMouseUp", nil);
	frame:SetScript("OnEnter", nil);
	frame:SetScript("OnLeave", nil);
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
				point = "LEFT", relativeFrame = self.frame.StepNumber, relativePoint ="RIGHT", offsetX = 30, offsetY = 2,
				offsetXConjunction = 2, offsetYConjunction = -24,
			},

			[self.OPTION_INDEX_CREATE_NEW_CHARACTER] = {
				frame = self.frame.ControlsFrame.CreateCharacterButton,
				needsConjunction = true,
				point = "LEFT", relativeFrame = self.frame.StepNumber, relativePoint ="RIGHT", offsetX = 30, offsetY = 2,
				offsetXConjunction = 0, offsetYConjunction = -10,
			},

			[self.OPTION_INDEX_CREATE_TRIAL_CHARACTER] = {
				frame = self.frame.ControlsFrame.CreateCharacterClassTrialButton,
				needsConjunction = true,
				point = "TOPLEFT", relativeFrame = self.frame.StepNumber, relativePoint ="TOPRIGHT", offsetX = 30, offsetY = 2,
				offsetXConjunction = 0, offsetYConjunction = -10,
			},

			[self.OPTION_INDEX_CREATE_TRIAL_CHARACTER_HINT] = {
				frame = self.frame.ControlsFrame.ClassTrialButtonHintText,
				offsetXConjunction = 2, offsetYConjunction = -5,
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
				conjunctionFrame:SetPoint("TOPLEFT", previousFrameData.frame, "BOTTOMLEFT", previousFrameData.offsetXConjunction, previousFrameData.offsetYConjunction);
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
	self.charid = characterSelectButton:GetElementData().characterID;
	self.index = CharacterSelectListUtil.GetIndexFromCharID(self.charid);
	self.playerguid = playerguid;
end

function CharacterSelectBlockBase:ClearResultInfo()
	self.charid = nil;
	self.index = nil;
	self.playerguid = nil;
end

function CharacterSelectBlockBase:OnRewind()
	self:ClearResultInfo();
end

function CharacterSelectBlockBase:GetServiceInfoByCharacterID(characterID)
	local serviceInfo = { checkAutoSelect = true, checkTrialBoost = true };

	local characterInfo = CharacterSelectUtil.GetCharacterInfoTable(characterID);
	if characterInfo then
		serviceInfo.playerguid = characterInfo.guid;
		serviceInfo.requiresLogin = characterInfo.characterServiceRequiresLogin;
		serviceInfo.isTrialBoost = characterInfo.isTrialBoost;
		serviceInfo.isEligible = CanBoostCharacter(characterInfo.experienceLevel, characterInfo.boostInProgress, characterInfo.isTrialBoost, characterInfo.isRevokedCharacterUpgrade, characterInfo.vasServiceInProgress, characterInfo.isExpansionTrialCharacter, characterInfo.raceFilename, characterInfo.hasWowToken, characterInfo.guid);
		serviceInfo.hasBonus = IsCharacterEligibleForVeteranBonus(characterInfo.experienceLevel, characterInfo.isTrialBoost, characterInfo.isRevokedCharacterUpgrade);
	end
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
	CharacterSelectListUtil.SetScrollListInteractiveState(true);

	self:ClearResultInfo();
	self.lastSelectedIndex = CharacterSelect.selectedIndex;

	if (CharacterUpgrade_IsCreatedCharacterUpgrade()) then
		CharacterSelect_UpdateButtonState();

		if (self.createNum < GetNumCharacters()) then
			local scrollBox = CharacterSelectCharacterFrame.ScrollBox;
			scrollBox:ScrollToEnd();

			local last = true;
			CharacterSelect.selectedIndex = CharacterSelectListUtil.GetFirstOrLastCharacterIndex(last);
			CharacterSelectCharacterFrame:UpdateCharacterSelection();

			self.index = CharacterSelect.selectedIndex;
			self.charid = CharacterSelectListUtil.GetCharIDFromIndex(CharacterSelect.selectedIndex);
			self.playerguid = GetCharacterGUID(self.charid);

			local frame = scrollBox:FindFrameByPredicate(function(frame, elementData)
				return CharacterSelectListUtil.GetCharacterPositionData(self.playerguid, elementData) ~= nil;
			end);

			if frame then
				local frameElementData = frame:GetElementData();
				if frameElementData.isGroup then
					for _, character in ipairs(frame.groupButtons) do
						if character:GetCharacterID() == self.charid then
							clearButtonScripts(character);
							break;
						end
					end
				else
					clearButtonScripts(frame);
				end
			end

			CharacterServicesMaster_Update();

			return;
		end
	end

	CharacterServicesCharacterSelector:Show();
	CharacterServicesCharacterSelector:UpdateDisplay(self);

	self.frame.ControlsFrame.BonusLabel:SetHeight(self.frame.ControlsFrame.BonusLabel.BonusText:GetHeight());
	self.frame.ControlsFrame.BonusLabel:SetPoint("BOTTOM", CharSelectServicesFlowFrame, "BOTTOM", 0, 28);
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
	-- Heritage armor restriction has been removed.
	-- Re-enable this if needed
	--[[
	local characterInfo = CharacterSelectUtil.GetCharacterInfoTable(self.charid);
	if characterInfo then
		local raceData = C_CharacterCreation.GetRaceDataByID(C_CharacterCreation.GetRaceIDFromName(characterInfo.raceFilename));
		local seenPopupBefore = self.seenPopup;
		self.seenPopup = true;
		return characterInfo.isTrialBoost == false and raceData.isAlliedRace and not raceData.hasHeritageArmor and not seenPopupBefore;
	end
	--]]
	return false;
end

function CharacterSelectBlockBase:GetPopupText()
	local characterGuid = GetCharacterGUID(self.charid);
	if not characterGuid then
		return "";
	end

	local basicInfo = GetBasicCharacterInfo(characterGuid);
	local raceData = C_CharacterCreation.GetRaceDataByID(C_CharacterCreation.GetRaceIDFromName(basicInfo.raceFilename));

	if GetCurrentRegionName() == "CN" then
		return ReplaceGenderTokens(BOOST_ALLIED_RACE_HERITAGE_ARMOR_WARNING_CN:format(raceData.name), basicInfo.genderID+1);
	else
		return ReplaceGenderTokens(BOOST_ALLIED_RACE_HERITAGE_ARMOR_WARNING:format(raceData.name), basicInfo.genderID+1);
	end
end

function CharacterSelectBlockBase:IsFinished()
	return self.charid ~= nil;
end

function CharacterSelectBlockBase:GetResult()
	return { charid = self.charid; playerguid = self.playerguid }
end

function CharacterSelectBlockBase:FormatResult()
	local characterGuid = GetCharacterGUID(self.charid);
	if not characterGuid then
		return "";
	end

	local basicInfo = GetBasicCharacterInfo(characterGuid);
	if basicInfo.classFilename then
		local coloredName = NORMAL_FONT_COLOR:WrapTextInColorCode(basicInfo.name);

		local color = CreateColor(GetClassColor(basicInfo.classFilename));
		local coloredClassName = color:WrapTextInColorCode(basicInfo.className);

		return SELECT_CHARACTER_RESULTS_FORMAT:format(coloredName, basicInfo.experienceLevel, coloredClassName);
	else
		return "";
	end
end

function CharacterSelectBlockBase:OnHide()
	local index = self.lastSelectedIndex;
	if (self:IsFinished()) then
		index = self.index;
	end

	CharacterServicesCharacterSelector:ResetState(index);
end

function CharacterSelectBlockBase:OnAdvance()
	CharacterSelectListUtil.SetScrollListInteractiveState(false);
	CharacterServicesCharacterSelector:Hide();

	CharacterSelectListUtil.ForEachCharacterDo(function(frame)
		local enable = frame.characterID == self.charid;
		frame.InnerContent:SetEnabledState(enable);
		frame:SetSelectedState(enable);
		frame:SetArrowButtonShown(enable);
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
	initialAnchor = { point = "TOPLEFT", relativeKey = nil, relativePoint = "TOPLEFT", x = 89, y = -115 },
	subsequentAnchor = { point = "TOP", relativePoint = "BOTTOM", x = 0, y = -48 },
	buttonInsets = nil, -- numerically indexed, ordering matches SetHitInsets API
	specNameWidth = nil,
	specNameFont = nil,
	selectionGlowOffset = -53
}

local function CreateSpecButton(parent, buttonIndex, layoutData)
	local frame = CreateFrame("CheckButton", nil, parent, "CharacterUpgradeSelectSpecRadioButtonTemplate");
	local relativeFrame, anchorData;

	if buttonIndex == 1 then
		anchorData = layoutData.initialAnchor;
		relativeFrame = parent;
	else
		anchorData = layoutData.subsequentAnchor;
		relativeFrame = parent.SpecButtons[buttonIndex - 1];
	end

	if anchorData.relativeKey then
		relativeFrame = relativeFrame[anchorData.relativeKey];
	end

	frame:SetPoint(anchorData.point, relativeFrame, anchorData.relativePoint, anchorData.x, anchorData.y);

	if layoutData.buttonInsets then
		frame:SetHitRectInsets(unpack(layoutData.buttonInsets));
	end

	if layoutData.specNameWidth then
		frame.SpecName:SetWidth(layoutData.specNameWidth);
	end

	if layoutData.specNameFont then
		frame.SpecName:SetFontObject(layoutData.specNameFont);
	end

	if layoutData.selectionGlowOffset then
		frame.HoverGlow:ClearAllPoints();
		frame.HoverGlow:SetPoint("Left", layoutData.selectionGlowOffset, 0);

		frame.SelectGlow:ClearAllPoints();
		frame.SelectGlow:SetPoint("Left", layoutData.selectionGlowOffset, 0);
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
			button.SpecOverlay:SetDesaturated(not allowed);
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
				button.SpecName:SetPoint("TOPLEFT", button.SpecOverlay, "TOPRIGHT", 7, 1);
			else
				button.SpecName:SetPoint("TOPLEFT", button.SpecOverlay, "TOPRIGHT", 6, -8);
			end

			button:SetChecked(false);
			button.SelectGlow:Hide();
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

	local characterGuid = GetCharacterGUID(results.charid);
	if not characterGuid then
		return;
	end

	local basicInfo = GetBasicCharacterInfo(characterGuid);
	self.classID = basicInfo.classID;
	self.frame.ControlsFrame.classFilename = basicInfo.classFilename;

	local isNewCharacter = basicInfo.experienceLevel < 10;
	if isNewCharacter then
		self.currentSpecID = nil;
	else
		self.currentSpecID = basicInfo.specID;
	end

	-- When boosting to level 100, prevent the selection of non-recommended specs, but still auto-select from
	-- the limited number of specs that the user can choose from
	local flags = flow.data.flags or 0;
	local restrictToRecommendedSpecs = bit.band(flags, Enum.CharacterServiceInfoFlag.RestrictToRecommendedSpecs) == Enum.CharacterServiceInfoFlag.RestrictToRecommendedSpecs;

	return CharacterServices_UpdateSpecializationButtons(basicInfo.classID, basicInfo.genderID+1, parent, self, not restrictToRecommendedSpecs, nil, self.currentSpecID, allowAutoSelectSpec);
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

	local characterGuid = GetCharacterGUID(results.charid);
	if not characterGuid then
		return nil;
	end

	return GetServiceCharacterInfo(characterGuid).isRevokedCharacterUpgrade;
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

	local characterGuid = GetCharacterGUID(results.charid);
	if not characterGuid then
		return nil;
	end

	local experienceLevel = GetBasicCharacterInfo(characterGuid).experienceLevel;
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
		local factionGroup = C_CharacterServices.GetFactionGroupByIndex(results.charid);
		self.Steps[3].SkipOnRewind = (factionGroup ~= "Neutral");
	end
end

local function ValidateSpec(results)
	if not results.spec and CharacterUpgradeFlow:ShouldSkipSpecSelect() then
		local characterGuid = GetCharacterGUID(results.charid);
		if characterGuid then
			local basicInfo = GetBasicCharacterInfo(characterGuid);
			results.spec = basicInfo.specID;
			results.classId = basicInfo.classID;
		end
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

		CharSelectServicesFlowFrame.FinishButton:Hide();
		CharSelectServicesFlowFrame.BackButton:Hide();
		CharSelectServicesFlowFrame.CloseButton:Hide();
		CharacterUpgradeSecondChanceWarningFrame:Show();
		return false;
	end

	local results = self:BuildResults(self:GetNumSteps());
	local guid = GetCharacterGUID(results.charid);
	if self:IsUnrevoke() then
		C_CharacterServices.RequestManualUnrevoke(guid);
	else

		if (not results.faction) then
			-- Non neutral character, convert faction group to id.
			results.faction = PLAYER_FACTION_GROUP[C_CharacterServices.GetFactionGroupByIndex(results.charid)];
		end
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

function DoesClientThinkTheCharacterIsEligibleForCharacterUpgrade(characterID)
	local characterInfo = CharacterSelectUtil.GetCharacterInfoTable(characterID);
	local errors = {};

	if characterInfo then
		local isSameRealm = CharacterSelectUtil.IsSameRealmAsCurrent(characterInfo.realmAddress);
		CheckAddVASErrorString(errors, BLIZZARD_STORE_VAS_ERROR_CHARACTER_ON_DIFFERENT_REALM_1, isSameRealm);
		CheckAddVASErrorString(errors, BLIZZARD_STORE_VAS_ERROR_CHARACTER_ON_DIFFERENT_REALM_2, isSameRealm);

		-- CanBoostCharacter could be broken down into individual VAS error checks to match other flows.  At the moment they just return false with no associated error.
		local canTransfer = #errors == 0 and CanBoostCharacter(characterInfo.experienceLevel, characterInfo.boostInProgress, characterInfo.isTrialBoost, characterInfo.isRevokedCharacterUpgrade, characterInfo.vasServiceInProgress, characterInfo.isExpansionTrialCharacter, characterInfo.raceFilename, characterInfo.hasWowToken, characterInfo.guid);
		return canTransfer, errors, characterInfo.guid, characterInfo.characterServiceRequiresLogin, characterInfo.isTrialBoost, IsCharacterEligibleForVeteranBonus(characterInfo.experienceLevel, characterInfo.isTrialBoost, characterInfo.isRevokedCharacterUpgrade);
	end
	return false, errors, nil, false, false, false;
end

function CharacterUpgradeCharacterSelectBlock:GetServiceInfoByCharacterID(characterID)
	local serviceInfo = { checkAutoSelect = true, checkTrialBoost = true, checkErrors = true };
	local canUpgradeCharacter, errors, playerguid, characterServiceRequiresLogin, isTrialBoost, hasBonus = DoesClientThinkTheCharacterIsEligibleForCharacterUpgrade(characterID);
	serviceInfo.isEligible = canUpgradeCharacter;
	serviceInfo.errors = errors;
	serviceInfo.playerguid = playerguid;
	serviceInfo.requiresLogin = characterServiceRequiresLogin;
	serviceInfo.isTrialBoost = isTrialBoost;
	serviceInfo.hasBonus = hasBonus;
	return serviceInfo;
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
	local serviceInfo = GetServiceCharacterInfo(characterGUID);
	return serviceInfo.isExpansionTrialCharacter;
end

function GetAvailableBoostTypesForCharacterByGUID(characterGUID)
	local availableBoosts = {};
	local upgradeDistributions = C_SharedCharacterServices.GetUpgradeDistributions();
	if upgradeDistributions then
		local basicInfo = GetBasicCharacterInfo(characterGUID);
		local serviceInfo = GetServiceCharacterInfo(characterGUID);
		for boostType, data in pairs(upgradeDistributions) do
			if IsBoostFlowValidForCharacter(C_CharacterServices.GetCharacterServiceDisplayData(boostType), basicInfo.experienceLevel, serviceInfo.boostInProgress, serviceInfo.isTrialBoost, serviceInfo.isRevokedCharacterUpgrade, serviceInfo.vasServiceInProgress, basicInfo.raceFilename) then
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

function CharacterUpgradeCharacterSelectBlock_IsCharacterBoostable(characterID)
	local characterInfo = CharacterSelectUtil.GetCharacterInfoTable(characterID);
	if not characterInfo then
		return false;
	end

	local canBoostCharacter = CanBoostCharacter(characterInfo.experienceLevel, characterInfo.boostInProgress, characterInfo.isTrialBoost, characterInfo.isRevokedCharacterUpgrade, characterInfo.vasServiceInProgress, characterInfo.isExpansionTrialCharacter, characterInfo.raceFilename, characterInfo.hasWowToken);
	return canBoostCharacter;
end

function CharacterUpgradeSelectCharacterFrame_OnLoad(self)
	local controls = self.ControlsFrame;
	local buttonWidth = max(controls.CreateCharacterButton:GetTextWidth(), controls.CreateCharacterClassTrialButton:GetTextWidth()) + 73;
	controls.CreateCharacterButton:SetWidth(buttonWidth);
	controls.CreateCharacterClassTrialButton:SetWidth(buttonWidth);
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
	CharacterSelectUtil.CreateNewCharacter(characterType);
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
	self:SpecSelectBlockInitializeHelper(results, wasFromRewind, CharacterUpgradeFlow, self.frame.ControlsFrame, CharacterServicesMaster_Update, allowAutoSelect);
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
			self.SelectGlow:Show();
			return;
		else
			owner.selected = self:GetID();
			self:SetChecked(true);
			self.SelectGlow:Show();
		end

		if owner.specButtonClickedCallback then
			owner.specButtonClickedCallback();
		end
	end

	for _, specButton in ipairs(self:GetParent().SpecButtons) do
		if specButton:GetID() ~= self:GetID() then
			specButton:SetChecked(false);
			specButton.SelectGlow:Hide();
		end
	end
end

function CharacterUpgradeFactionSelectBlock:Initialize(results, wasFromRewind)
	if not wasFromRewind then
		self.selected = nil;
	end
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
		button.SelectGlow:Hide();
	end

	CharacterUpgradeFactionSelectBlock.selected = nil;
end

function CharacterUpgradeSelectFactionRadioButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	CharacterUpgradeSelectFactionFrame_ClearChecked();
	self:SetChecked(true);
	self.SelectGlow:Show();
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
	{ FrameName = "RPEUpgradeSelectSpecFrame", Back = true, Next = true, Finish = false, ActiveLabel = "", ResultsLabel = "", Popup = "BOOST_NOT_RECOMMEND_SPEC_WARNING" },
	SpecSelectBlockBase
);
local RPEUpgradeReviewBlock = { FrameName = "RPEUpgradeReviewFrame", Back = true, Next = false, Finish = true, ActiveLabel = "", ResultsLabel = "" };

RPEUpgradeFlow = Mixin(
	{
		FinishLabel = CHARACTER_UPGRADE_FINISH_LABEL,

		Steps = {
			[1] = RPEUPgradeInfoBlock,
			[2] = RPEUpgradeSpecSelectBlock,
			[3] = RPEUpgradeReviewBlock
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

function RPEUpgradeFlow:AllowCharacterReordering()
	return true;
end

function RPEUpgradeFlow:CanInitialize()
	return CharacterSelectListUtil.GetSelectedCharacterFrame() ~= nil;
end

local function SetKeepQuestsAndContinue(keepQuests)
	return function()
		GlueDialog.data.keepQuests = keepQuests;

		local specName = GetSpecializationNameForSpecID(GlueDialog.data.spec);
		local formattedText = string.format(StaticPopupDialogs["RPE_UPGRADE_CONFIRM"].text, specName);
		GlueDialog_Show("RPE_UPGRADE_CONFIRM", formattedText, GlueDialog.data);
		CharSelectServicesFlowFrame:Hide();
    end
end

StaticPopupDialogs["RPE_UPGRADE_QUEST_CLEAR_CONFIRM"] = {
    text = RPE_UPGRADE_QUEST_CLEAR_CONFIRMATION,
    button1 = RPE_CLEAR_QUESTS,
    button2 = RPE_KEEP_QUESTS,
    OnAccept = SetKeepQuestsAndContinue(false),
    OnCancel = SetKeepQuestsAndContinue(true),
}

StaticPopupDialogs["RPE_UPGRADE_CONFIRM"] = {
    text = RPE_UPGRADE_CONFIRMATION,
    button1 = RPE_CONFIRM,
    button2 = CANCEL,
    OnAccept = function()
        local results = GlueDialog.data;
		C_CharacterServices.RPEResetCharacter(results.playerguid, results.faction, results.spec, results.keepQuests);
		CharacterSelectCharacterFrame:UpdateCharacterMatchingGUID(results.playerguid); --update the character button so it says 'processing'
		GlueDialog_Show("RPE_UPGRADE_COMPLETE_WARNING");
    end,
    OnCancel = function()
		BeginCharacterServicesFlow(RPEUpgradeFlow, {});
		CharacterServicesMaster.flow:Advance(CharacterServicesMaster);
	end,
}

StaticPopupDialogs["RPE_UPGRADE_COMPLETE_WARNING"] = {
    text = RPE_UPGRADE_COMPLETE_WARNING,
    button1 = OKAY,
}

function RPEUpgradeFlow:Finish(controller)
	local results = self:BuildResults(self:GetNumSteps());
	if (not results.faction) then
		-- Non neutral character, convert faction group to id.
		results.faction = PLAYER_FACTION_GROUP[C_CharacterServices.GetFactionGroupByIndex(results.charid)];
	end
	local guid = GetCharacterGUID(results.charid);
	if (guid ~= results.playerguid) then
		-- Bail because guid has changed!
		message(CHARACTER_UPGRADE_CHARACTER_LIST_CHANGED_ERROR);
		self:Restart(controller);
		return false;
	end

	CharacterServicesMaster.pendingGuid = results.playerguid;

	ValidateSpec(results);
	local serviceInfo = GetServiceCharacterInfo(guid);
	if serviceInfo.rpeResetQuestClearAvailable then
		GlueDialog_Show("RPE_UPGRADE_QUEST_CLEAR_CONFIRM", nil, results);
		return false; --flow will be closed by the RPE_UPGRADE_QUEST_CLEAR_CONFIRM dialog.
	else
		results.keepQuests = true;

		local specName = GetSpecializationNameForSpecID(results.spec);
		local formattedText = string.format(StaticPopupDialogs["RPE_UPGRADE_CONFIRM"].text, specName);
		GlueDialog_Show("RPE_UPGRADE_CONFIRM", formattedText, results);
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
	CharacterSelectCharacterFrame:SetScrollEnabled(true);
	CharacterSelectUI:SetCharacterListToggleEnabled(true);

	--dont clear results
	--self:ClearResultInfo();

	local frame = CharacterSelectListUtil.GetSelectedCharacterFrame();
	if frame then
		local characterID = CharacterSelectListUtil.GetCharIDFromIndex(CharacterSelect.selectedIndex);
		local characterSelectButton = frame;
		local frameElementData = frame:GetElementData();
		if frameElementData.isGroup then
			for _, character in ipairs(frame.groupButtons) do
				if character:GetCharacterID() == characterID then
					characterSelectButton = character;
					break;
				end
			end
		end

		local serviceInfo = self:GetServiceInfoByCharacterID(characterID);
		self:SaveResultInfo(characterSelectButton, serviceInfo.playerguid);
	end

	local controlsFrame = self.frame.ControlsFrame;
	controlsFrame:Show();

	for k,v in pairs(RPEUPgradeInfoBlockSubFrameText) do
		controlsFrame[k].Text:SetText(_G[v]);
	end
end

function RPEUPgradeInfoBlock:GetServiceInfoByCharacterID(characterID)
	local serviceInfo = { checkAutoSelect = true, checkTrialBoost = true };
	local guid = GetCharacterGUID(characterID);
	if guid then
		local serviceCharacterInfo = GetServiceCharacterInfo(guid);
		serviceInfo.playerguid = guid;
		serviceInfo.requiresLogin = serviceCharacterInfo.characterServiceRequiresLogin;
		serviceInfo.isTrialBoost = serviceCharacterInfo.isTrialBoost;
		serviceInfo.isEligible = true;
		serviceInfo.hasBonus = false;
	end
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

local RPESpecButtonLayoutData = {
	initialAnchor = { point = "TOPLEFT", relativeKey = nil, relativePoint = "TOPLEFT", x = 24, y = -34 },
	subsequentAnchor = { point = "TOP", relativePoint = "BOTTOM", x = 0, y = -50 },
	buttonInsets = nil, -- numerically indexed, ordering matches SetHitInsets API
	specNameWidth = nil,
	specNameFont = nil,
	selectionGlowOffset = -17
}

function RPEUpgradeSpecSelectBlock:Initialize(results, wasFromRewind)
	local characterGuid = GetCharacterGUID(results.charid);
	if not characterGuid then
		return;
	end

	-- Force expand character list if collapsed.
	CharacterSelectUI:ExpandCharacterList();
	CharacterSelectUI:SetCharacterListToggleEnabled(false);

	local basicInfo = GetBasicCharacterInfo(characterGuid);
	if basicInfo.classFilename then
		local characterBlock = self.frame.ControlsFrame.CharacterBlock;
		characterBlock.Name:SetText(basicInfo.name);

		local color = CreateColor(GetClassColor(basicInfo.classFilename));
		local coloredClassName = color:WrapTextInColorCode(basicInfo.className);
		characterBlock.Level:SetText(string.format(RPE_CHARACTER_LVL, basicInfo.experienceLevel, coloredClassName));
	end

	local specBlock = self.frame.ControlsFrame.SpecBlock;
	specBlock.layoutData = RPESpecButtonLayoutData;

	local allowAutoSelect = wasFromRewind;
	local numSpecs = self:SpecSelectBlockInitializeHelper(results, wasFromRewind, RPEUpgradeFlow, specBlock, CharacterServicesMaster_Update, allowAutoSelect);

	local specBlockHeight = 68 + (18*numSpecs) + (50*(numSpecs-1));
	specBlock:SetSize(296, specBlockHeight);
end

function RPEUpgradeSpecSelectBlock:GetSpecButtonContainer()
	return self.frame.ControlsFrame.SpecBlock;
end

function RPEUpgradeSpecSelectBlock:SkipIf(results)
	return false; --no skip
end

function RPEUpgradeReviewBlock:Initialize(results, wasFromRewind)
	local characterGuid = GetCharacterGUID(results.charid);
	if not characterGuid then
		return;
	end

	local basicInfo = GetBasicCharacterInfo(characterGuid);
	if basicInfo.classFilename then
		local characterBlock = self.frame.ControlsFrame.CharacterBlock;
		characterBlock.Name:SetText(basicInfo.name);

		local color = CreateColor(GetClassColor(basicInfo.classFilename));
		local coloredClassName = color:WrapTextInColorCode(basicInfo.className);
		characterBlock.Level:SetText(string.format(RPE_CHARACTER_LVL, basicInfo.experienceLevel, coloredClassName));
	end

	local specName = GetSpecializationNameForSpecID(results.spec);
	local specBlock = self.frame.ControlsFrame.SpecBlock;
	specBlock.SpecName:SetText(specName);
end

function RPEUpgradeReviewBlock:SkipIf(results)
	return false; --no skip
end

function RPEUpgradeReviewBlock:IsFinished(wasFromRewind)
	return not wasFromRewind;
end

function RPEUpgradeReviewBlock:GetResult()
	return {};
end


CharacterUpgradeSelectSpecRadioButtonMixin = {};

function CharacterUpgradeSelectSpecRadioButtonMixin:OnEnter()
	if (self.tooltip) then
		GlueTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 48, -4);
		GlueTooltip:SetText(self.tooltipTitle);
		GlueTooltip:AddLine(self.tooltip, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1, true);
		GlueTooltip:Show();
	end
	self.HoverGlow:Show();
end

function CharacterUpgradeSelectSpecRadioButtonMixin:OnLeave()
	if (self.tooltip) then
		GlueTooltip:Hide();
	end
	self.HoverGlow:Hide();
end


CharacterUpgradeSelectFactionRadioButtonMixin = {};

function CharacterUpgradeSelectFactionRadioButtonMixin:OnEnter()
	self.HoverGlow:Show();
end

function CharacterUpgradeSelectFactionRadioButtonMixin:OnLeave()
	self.HoverGlow:Hide();
end


RPEUpgradeMinimizedFrameMixin = {};

function RPEUpgradeMinimizedFrameMixin:OnLoad()
	self.ExpandButton:SetScript("OnClick", function()
		self:OnClick();
	end);
end

function RPEUpgradeMinimizedFrameMixin:OnShow()
	AccountUpgradePanel_UpdateExpandState();
end

function RPEUpgradeMinimizedFrameMixin:OnHide()
	AccountUpgradePanel_UpdateExpandState();
end

function RPEUpgradeMinimizedFrameMixin:OnEnter()
	self.ExpandButton:LockHighlight();
end

function RPEUpgradeMinimizedFrameMixin:OnLeave()
	self.ExpandButton:UnlockHighlight();
end

function RPEUpgradeMinimizedFrameMixin:OnClick()
	CharSelectServicesFlow_Maximize();
end