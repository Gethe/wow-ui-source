local function RequestAssignPFCForResults(results, isValidationOnly)
	local currentRealmAddress = select(5, GetServerName());
	return C_CharacterServices.AssignRaceOrFactionChangeDistribution(
		results.selectedCharacterGUID,
		"",
		isValidationOnly,
		Enum.ValueAddedServiceType.PaidFactionChange
	);
end

local factionInfoTable = {
 	Alliance = { color = CreateColor(0, 0.439, 0.867), name = FACTION_ALLIANCE },
	Horde = { color = CreateColor(1, 0, 0), name = FACTION_HORDE },
}

local PFCCharacterSelectBlock = CreateFromMixins(VASCharacterSelectBlockBase);
do
	PFCCharacterSelectBlock.FrameName = "PFCCharacterSelect";
	PFCCharacterSelectBlock.ActiveLabel = SELECT_CHARACTER_ACTIVE_LABEL;
	PFCCharacterSelectBlock.ResultsLabel = SELECT_CHARACTER_RESULTS_LABEL;
end

function PFCCharacterSelectBlock:SetResultsShown(shown)
	self.frame.ResultsFrame:SetShown(shown);

	if shown then
		local result = self:GetResult();
		if result.selectedCharacterGUID then
			local name, raceName, raceFilename, className, classFilename, classID, experienceLevel, areaName, genderEnum, isGhost, hasCustomize, hasRaceChange,
			hasFactionChange, raceChangeDisabled, guid, profession0, profession1, genderID, boostInProgress, hasNameChange, isLocked, isTrialBoost, isTrialBoostCompleted,
			isRevokedCharacterUpgrade, vasServiceInProgress, lastLoginBuild, specID, isExpansionTrialCharacter, faction, isLockedByExpansion, mailSenders, customizeDisabled,
			factionChangeDisabled, characterServiceRequiresLogin, eraChoiceState, lastActiveDay, lastActiveMonth, lastActiveYear = GetCharacterInfoByGUID(result.selectedCharacterGUID);

			-- factions
			for factionTag, factionInfo in pairs(factionInfoTable) do
				local fontString;
				if factionTag == faction then
					fontString = self.frame.ResultsFrame.CurrentFactionLabel;
				else
					fontString = self.frame.ResultsFrame.NewFactionLabel;
				end
				fontString:SetText(factionInfo.name);
				fontString:SetTextColor(factionInfo.color:GetRGB());
			end
		end
	end
end

function DoesClientThinkTheCharacterIsEligibleForPFC(characterID)
	local level, _, _, _, _, _, _, _, playerguid, _, _, _, _, _, _, _, _, _, _, _, _, _, faction, mailSenders = select(7, GetCharacterInfo(characterID));
	local _, otherFaction = CharacterHasAlternativeRaceOptions(characterID);
	local errors = {};

	CheckAddVASErrorCode(errors, Enum.VasError.UnderMinLevelReq, level >= 10);
	CheckAddVASErrorCode(errors, Enum.VasError.HasMail, #mailSenders == 0);
	CheckAddVASErrorCode(errors, Enum.VasError.RaceClassComboIneligible, otherFaction);
	CheckAddVASErrorCode(errors, Enum.VasError.IneligibleMapID, not IsCharacterInTutorialMap(playerguid));
	CheckAddVASErrorString(errors, BLIZZARD_STORE_VAS_ERROR_CHARACTER_INELIGIBLE_FOR_THIS_SERVICE, not IsCharacterVASRestricted(playerguid, Enum.ValueAddedServiceType.PaidFactionChange));

	local canTransfer = #errors == 0;
	return canTransfer, errors, playerguid, false;
end

function PFCCharacterSelectBlock:GetServiceInfoByCharacterID(characterID)
	local serviceInfo = { checkErrors = true };
	local canTransferCharacter, errors, playerguid, characterServiceRequiresLogin = DoesClientThinkTheCharacterIsEligibleForPFC(characterID);
	serviceInfo.isEligible = canTransferCharacter;
	serviceInfo.errors = errors;
	serviceInfo.playerguid = playerguid;
	serviceInfo.requiresLogin = characterServiceRequiresLogin;
	return serviceInfo;
end

local PFCReviewChoicesBlock = CreateFromMixins(VASReviewChoicesBlockBase);

function PFCReviewChoicesBlock:Initialize(results, wasFromRewind)
	VASReviewChoicesBlockBase.Initialize(results, wasFromRewind);
	CharacterServicesCharacterSelector:UpdateDisplay(self);
end

local PFCChoiceVerificationBlock = CreateFromMixins(VASChoiceVerificationBlockBase);

function PFCChoiceVerificationBlock:RequestAssignVASForResults(results, isValidationOnly)
	return RequestAssignPFCForResults(results, isValidationOnly);
end

local PFCAssignConfirmationBlock = CreateFromMixins(VASAssignConfirmationBlockBase)
do
	PFCAssignConfirmationBlock.dialogText = PFC_CUSTOMIZE_DIALOG_TEXT;
	PFCAssignConfirmationBlock.dialogAcceptLabel = CUSTOMIZE;
	PFCAssignConfirmationBlock.dialogCancelLabel = CANCEL;
end

PFCEndStep =
{
	AutoAdvance = true,
	Back = true,
	Next = false,
	Finish = false,
	HiddenStep = true,
	SkipOnRewind = true,
};

function PFCEndStep:Initialize(results, wasFromRewind)
	CharacterSelect_StartCustomizeForVAS(Enum.ValueAddedServiceType.PaidFactionChange, results);
end

function PFCEndStep:IsFinished()
	return true;
end

function PFCEndStep:GetResult()
	return { };
end

PaidFactionChangeFlow = Mixin(
	{
		FinishLabel = PFC_FLOW_FINISH_LABEL,
		AutoCloseAfterFinish = true,

		Steps = {
			PFCCharacterSelectBlock,
			PFCReviewChoicesBlock,
			PFCChoiceVerificationBlock,
			PFCAssignConfirmationBlock,
			PFCEndStep,
		},
	},
	CharacterServicesFlowMixin
);

function PaidFactionChangeFlow:Initialize(controller)
	CharacterServicesFlowMixin.Initialize(self, controller);

	CharacterServicesCharacterSelector:Hide();

	EventRegistry:RegisterFrameEvent("STORE_CHARACTER_LIST_RECEIVED");
	EventRegistry:RegisterCallback("STORE_CHARACTER_LIST_RECEIVED", self.OnStoreCharacterListReceived, self);

	C_StoreGlue.RequestStoreCharacterListForVasType(Enum.ValueAddedServiceType.PaidFactionChange);
end

function PaidFactionChangeFlow:OnStoreCharacterListReceived()
	self:GetStep(1):CheckEnable();
	EventRegistry:UnregisterFrameEvent("STORE_CHARACTER_LIST_RECEIVED");
	EventRegistry:UnregisterCallback("STORE_CHARACTER_LIST_RECEIVED", self);
end

function PaidFactionChangeFlow:ShouldFinishBehaveLikeNext()
	return true;
end

function PaidFactionChangeFlow:Finish(controller)
	local isFinished = self:IsAllFinished();
	return isFinished;
end