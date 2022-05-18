function CheckAddVASErrorString(errorTable, errorString, requirementPassed)
	if not requirementPassed then
		table.insert(errorTable, errorString);
	end
end

function CheckAddVASErrorCode(errorTable, errorCode, requirementPassed)
	CheckAddVASErrorString(errorTable, VASErrorData_GetMessage(errorCode), requirementPassed);
end

function IsVASAssignmentValid(storeError, vasPurchaseResult, characterGUID)
	if storeError == 0 and vasPurchaseResult == 0 then
		return true;
	end

	local msgTable = {};

	if vasPurchaseResult ~= 0 then
		local character = C_StoreSecure.GetCharacterInfoByGUID(characterGUID);
		local msg = VASErrorData_GetMessage(vasPurchaseResult, character);
		table.insert(msgTable, msg);
	end

	if storeError ~= 0 then
		local _, msg = StoreErrorData_GetMessage(storeError);
		table.insert(msgTable, msg);
	end

	return false, table.concat(msgTable, "\n");
end

VASReviewChoicesBlockBase = {
	AutoAdvance = false,
	Back = true,
	Next = false,
	Finish = true,
	HiddenStep = true,
	SkipOnRewind = true,
};

function VASReviewChoicesBlockBase:Initialize(results, wasFromRewind)

end

function VASReviewChoicesBlockBase:GetResult()
	return {};
end

function VASReviewChoicesBlockBase:IsFinished()
	return true;
end

VASAssignConfirmationBlockBase = { 
	AutoAdvance = true,
	Back = true,
	Next = false,
	Finish = false,
	HiddenStep = true,
	SkipOnRewind = true,
};

function VASAssignConfirmationBlockBase:Initialize(results, wasFromRewind)
	self.results = results;
	self:ClearWarningState();
	self.isInitialized = true;
end

-- Override
function VASAssignConfirmationBlockBase:RequestForResults(results, isValidationOnly)
end

function VASAssignConfirmationBlockBase:IsFinished()
	if not self.isInitialized then
		return false;
	end
	
	local warningState = self:CheckFinishConfirmation();
	if warningState == "accepted" then
		local isValidationOnly = false;
		self:RequestForResults(self.results, isValidationOnly);
		self:ClearWarningState();
		self.isInitialized = false;

		return true;
	elseif warningState == "declined" then
		CharacterServicesMaster.flow:RequestRewind();
		self.warningState = "rewind";
	end

	return false;
end

function VASAssignConfirmationBlockBase:GetResult()
	return {};
end

function VASAssignConfirmationBlockBase:SetWarningAccepted(accepted)
	if accepted == true then
		self.warningState = "accepted";
	elseif accepted == false then
		self.warningState = "declined";
	else
		self.warningState = nil;
	end

	if accepted ~= nil then
		CharacterServicesMaster_Update();
	end
end

function VASAssignConfirmationBlockBase:ClearWarningState()
	self:SetWarningAccepted(nil);
end

function VASAssignConfirmationBlockBase:GetWarningState()
	return self.warningState or "unseen";
end

function VASAssignConfirmationBlockBase:CheckFinishConfirmation()
	local warningState = self:GetWarningState();
	if warningState == "unseen" then
		CharacterServicesFlow_ShowFinishConfirmation(self, self.dialogText, self.dialogAcceptLabel, self.dialogCancelLabel);
	end

	return warningState;
end

VASCharacterSelectBlockBase = {
	Back = false,
	Next = false,
	Finish = false,
	AutoAdvance = true,
};

function VASCharacterSelectBlockBase:Initialize(results, wasFromRewind)
	self.results = nil;
	self:SetResultsShown(false);

	self:CheckEnable();
end

function VASCharacterSelectBlockBase:CheckEnable()
	-- This is called by the event handler for getting the valid characters for a VAS product.
	local currentRealmAddress = select(5, GetServerName());
	local isGuildVAS = false;
	local characters = C_StoreSecure.GetCharactersForRealm(currentRealmAddress, isGuildVAS);

	-- This is only valid if something doesn't end up changing which characters can be selected during this process (this is potentially subject to issues from rewinding the flow)
	if #characters > 0 then
		self:ShowCharacterSelector();
	end
end

-- Override
function VASCharacterSelectBlockBase:GetServiceInfoByCharacterID(characterID)
	--[[
	Should return a table with:
		isEligible 			bool : enable the character button (this will show the arrow indicator next to the character)
		playerguid			guid
		requiresLogin		bool, optional : display dialog error that character must be logged in
		hasBonus			bool, optional : enable the bonus icon, the bonus icon communicates some custom state
		checkAutoSelect		bool, optional : save block result if playerguid matches CharacterUpgradeFlow:GetAutoSelectGuid
		checkErrors			bool, optional : set up handlers for the tooltip to handle errors
		errors				table, optional: errors for the tooltip
		checkTrialBoost		bool, optional : evaluate isTrialBoost
		isTrialBoost		bool, optional : sets CharacterUpgradeFlow:SetTrialBoostGuid with the playerguid
	--]]
end

function VASCharacterSelectBlockBase:ShowCharacterSelector()
	CharacterServicesCharacterSelector:Show();
	CharacterServicesCharacterSelector:UpdateDisplay(self);
end

function VASCharacterSelectBlockBase:OnHide()
	CharacterServicesCharacterSelector:ResetState(self:GetSelectedCharacterIndex());
end

-- Override
function VASCharacterSelectBlockBase:SetResultsShown(shown)

end

function VASCharacterSelectBlockBase:OnAdvance()
	CharacterSelect_SetScrollEnabled(false);
	CharacterServicesCharacterSelector:Hide();
	self:SetResultsShown(true);

	local selectedButtonIndex = math.min(self:GetSelectedCharacterIndex(), MAX_CHARACTERS_DISPLAYED);
	local numDisplayedCharacters = math.min(GetNumCharacters(), MAX_CHARACTERS_DISPLAYED);

	for buttonIndex = 1, numDisplayedCharacters do
		if (buttonIndex ~= selectedButtonIndex) then
			CharacterSelect_SetCharacterButtonEnabled(buttonIndex, false);
		end
	end
end

function VASCharacterSelectBlockBase:IsFinished(wasFromRewind)
	return self:GetResult().selectedCharacterGUID ~= nil;
end

function VASCharacterSelectBlockBase:SaveResultInfo(characterButton, guid)
	self.results = { selectedCharacterGUID = guid, characterButtonID = characterButton:GetID(), characterIndex = characterButton.index };
end

function VASCharacterSelectBlockBase:GetResult()
	return self.results or {};
end

function VASCharacterSelectBlockBase:GetSelectedCharacterIndex()
	return self:GetResult().characterButtonID or CharacterSelect.selectedIndex;
end

function VASCharacterSelectBlockBase:FormatResult()
	local result = self:GetResult();
	if result.selectedCharacterGUID then
		local name, raceName, raceFilename, className, classFilename, classID, experienceLevel, areaName, genderEnum, isGhost, hasCustomize, hasRaceChange,
		hasFactionChange, raceChangeDisabled, guid, profession0, profession1, genderID, boostInProgress, hasNameChange, isLocked, isTrialBoost, isTrialBoostCompleted,
		isRevokedCharacterUpgrade, vasServiceInProgress, lastLoginBuild, specID, isExpansionTrialCharacter, faction, isLockedByExpansion, mailSenders, customizeDisabled,
		factionChangeDisabled, characterServiceRequiresLogin, eraChoiceState, lastActiveDay, lastActiveMonth, lastActiveYear = GetCharacterInfoByGUID(result.selectedCharacterGUID);

		return SELECT_CHARACTER_RESULTS_FORMAT:format(RAID_CLASS_COLORS[classFilename].colorStr, name, experienceLevel, className);
	end

	return "";
end

VASChoiceVerificationBlockBase =
{
	Back = true,
	Next = false,
	Finish = false,
	HiddenStep = true,
	SkipOnRewind = true,
};

function VASChoiceVerificationBlockBase:Initialize(results, wasFromRewind)
	self.results = results; -- Store the results so we can use them when we get a response to the validation request.
	self.isAssignmentValid = false;

	if not wasFromRewind then
		EventRegistry:RegisterFrameEvent("ASSIGN_VAS_RESPONSE");
		EventRegistry:RegisterCallback("ASSIGN_VAS_RESPONSE", self.OnAssignVASResponse, self);

		local isValidationOnly = true;
		local hadError = self:RequestAssignVASForResults(results, isValidationOnly);
		if hadError then
			local msg = select(2, StoreErrorData_GetMessage(Enum.StoreError.Other));
			CharSelectServicesFlowFrame:SetErrorMessage(msg);
		end
	end
end

function VASChoiceVerificationBlockBase:OnAssignVASResponse(token, storeError, vasPurchaseResult)
	self:UnregisterHandlers();

	local errorMsg;
	self.isAssignmentValid, errorMsg = IsVASAssignmentValid(storeError, vasPurchaseResult, self.results.selectedCharacterGUID);

	if self.isAssignmentValid then
		CharacterServicesMaster_Advance();
	else
		CharSelectServicesFlowFrame:SetErrorMessage(errorMsg);
		CharacterServicesMaster_Update();
	end
end

function VASChoiceVerificationBlockBase:IsFinished()
	return self.isAssignmentValid;
end

function VASChoiceVerificationBlockBase:GetResult()
	-- Needs to return all results thus far? Or can this just return its own little block of sucess/failure?
	return { isAssignmentValid = self.isAssignmentValid };
end

function VASChoiceVerificationBlockBase:UnregisterHandlers()
	EventRegistry:UnregisterFrameEvent("ASSIGN_VAS_RESPONSE");
	EventRegistry:UnregisterCallback("ASSIGN_VAS_RESPONSE", self);
end

function VASChoiceVerificationBlockBase:OnRewind()
	self.isAssignmentValid = false;
	CharSelectServicesFlowFrame:ClearErrorMessage();
	self:UnregisterHandlers();
end

function VASChoiceVerificationBlockBase:OnHide()
	self:UnregisterHandlers();
end

function VASChoiceVerificationBlockBase:OnAdvance()
	self:UnregisterHandlers();
end

-- Override
function VASChoiceVerificationBlockBase:RequestAssignVASForResults(results, isValidationOnly)

end