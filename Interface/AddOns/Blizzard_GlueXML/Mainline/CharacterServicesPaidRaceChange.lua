local function RequestAssignPRCForResults(results, isValidationOnly)
	local currentRealmAddress = select(5, GetServerName());
	return C_CharacterServices.AssignRaceOrFactionChangeDistribution(
		results.selectedCharacterGUID,
		"",
		isValidationOnly,
		Enum.ValueAddedServiceType.PaidRaceChange
	);
end

local PRCCharacterSelectBlock = CreateFromMixins(VASCharacterSelectBlockBase);
do
	PRCCharacterSelectBlock.FrameName = "PRCCharacterSelect";
	PRCCharacterSelectBlock.ActiveLabel = SELECT_CHARACTER_ACTIVE_LABEL;
	PRCCharacterSelectBlock.ResultsLabel = SELECT_CHARACTER_RESULTS_LABEL;
end

function PRCCharacterSelectBlock:SetResultsShown(shown)
	self.frame.ResultsFrame:SetShown(shown);

	if shown then
		local result = self:GetResult();
		if result.selectedCharacterGUID then
			local basicCharacterInfo = GetBasicCharacterInfo(result.selectedCharacterGUID);
			self.frame.ResultsFrame.CurrentRaceLabel:SetText(basicCharacterInfo.raceName);
		end
	end
end

function DoesClientThinkTheCharacterIsEligibleForPRC(characterID)
	local characterInfo = CharacterSelectUtil.GetCharacterInfoTable(characterID);
	local sameFaction, _ = CharacterHasAlternativeRaceOptions(characterID);
	local errors = {};

	if characterInfo then
		local isSameRealm = CharacterSelectUtil.IsSameRealmAsCurrent(characterInfo.realmAddress);
		CheckAddVASErrorString(errors, BLIZZARD_STORE_VAS_ERROR_CHARACTER_ON_DIFFERENT_REALM_1, isSameRealm);
		CheckAddVASErrorString(errors, BLIZZARD_STORE_VAS_ERROR_CHARACTER_ON_DIFFERENT_REALM_2, isSameRealm);

		CheckAddVASErrorCode(errors, Enum.VasError.UnderMinLevelReq, characterInfo.experienceLevel >= 10);
		CheckAddVASErrorCode(errors, Enum.VasError.IsNpeRestricted, not IsCharacterNPERestricted(characterInfo.guid));
		CheckAddVASErrorCode(errors, Enum.VasError.RaceClassComboIneligible, sameFaction);
		CheckAddVASErrorCode(errors, Enum.VasError.IneligibleMapID, not IsCharacterInTutorialMap(characterInfo.guid));
		CheckAddVASErrorString(errors, BLIZZARD_STORE_VAS_ERROR_CHARACTER_INELIGIBLE_FOR_THIS_SERVICE, not IsCharacterVASRestricted(characterInfo.guid, Enum.ValueAddedServiceType.PaidRaceChange));

		local canTransfer = #errors == 0;
		return canTransfer, errors, characterInfo.guid, characterInfo.characterServiceRequiresLogin;
	end
	return false, errors, nil, false;
end

function PRCCharacterSelectBlock:GetServiceInfoByCharacterID(characterID)
	local serviceInfo = { checkErrors = true };
	local canTransferCharacter, errors, playerguid, characterServiceRequiresLogin = DoesClientThinkTheCharacterIsEligibleForPRC(characterID);
	serviceInfo.isEligible = canTransferCharacter;
	serviceInfo.errors = errors;
	serviceInfo.playerguid = playerguid;
	serviceInfo.requiresLogin = characterServiceRequiresLogin;
	return serviceInfo;
end

local PRCChoiceVerificationBlock = CreateFromMixins(VASChoiceVerificationBlockBase);

function PRCChoiceVerificationBlock:RequestAssignVASForResults(results, isValidationOnly)
	return RequestAssignPRCForResults(results, isValidationOnly);
end

local PRCAssignConfirmationBlock = CreateFromMixins(VASAssignConfirmationBlockBase)
do
	PRCAssignConfirmationBlock.dialogText = PRC_CUSTOMIZE_DIALOG_TEXT;
	PRCAssignConfirmationBlock.dialogAcceptLabel = CUSTOMIZE;
	PRCAssignConfirmationBlock.dialogCancelLabel = CANCEL;
end

PRCEndStep =
{
	AutoAdvance = true,
	Back = true,
	Next = false,
	Finish = false,
	HiddenStep = true,
	SkipOnRewind = true,
};

function PRCEndStep:Initialize(results, wasFromRewind)
	CharacterSelect_StartCustomizeForVAS(Enum.ValueAddedServiceType.PaidRaceChange, results);
end

function PRCEndStep:IsFinished()
	return true;
end

function PRCEndStep:GetResult()
	return { };
end

PaidRaceChangeFlow = Mixin(
	{
		FinishLabel = PRC_FLOW_FINISH_LABEL,
		AutoCloseAfterFinish = true,

		Steps = {
			PRCCharacterSelectBlock,
			CreateFromMixins(VASReviewChoicesBlockBase),
			PRCChoiceVerificationBlock,
			PRCAssignConfirmationBlock,
			PRCEndStep,
		},
	},
	CharacterServicesFlowMixin
);

function PaidRaceChangeFlow:Initialize(controller)
	CharacterServicesFlowMixin.Initialize(self, controller);

	CharacterServicesCharacterSelector:Hide();

	EventRegistry:RegisterFrameEvent("STORE_CHARACTER_LIST_RECEIVED");
	EventRegistry:RegisterCallback("STORE_CHARACTER_LIST_RECEIVED", self.OnStoreCharacterListReceived, self);

	C_StoreGlue.RequestStoreCharacterListForVasType(Enum.ValueAddedServiceType.PaidRaceChange);
end

function PaidRaceChangeFlow:OnStoreCharacterListReceived()
	self:GetStep(1):CheckEnable();
	EventRegistry:UnregisterFrameEvent("STORE_CHARACTER_LIST_RECEIVED");
	EventRegistry:UnregisterCallback("STORE_CHARACTER_LIST_RECEIVED", self);
end

function PaidRaceChangeFlow:ShouldFinishBehaveLikeNext()
	return true;
end

function PaidRaceChangeFlow:Finish(controller)
	local isFinished = self:IsAllFinished();
	return isFinished;
end