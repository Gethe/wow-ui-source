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
	Alliance = { color = CreateColor(0, 0.439, 0.867), name = FACTION_ALLIANCE, icon = "glues-characterSelect-icon-faction-alliance" },
	Horde = { color = CreateColor(1, 0, 0), name = FACTION_HORDE, icon = "glues-characterselect-icon-faction-horde" },
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
			local basicCharacterInfo = GetBasicCharacterInfo(result.selectedCharacterGUID);
			for factionTag, factionInfo in pairs(factionInfoTable) do
				local fontString;
				local icon;
				if factionTag == basicCharacterInfo.faction then
					fontString = self.frame.ResultsFrame.CurrentFactionLabel;
					icon = self.frame.ResultsFrame.CurrentFactionEmblem;
				else
					fontString = self.frame.ResultsFrame.NewFactionLabel;
					icon = self.frame.ResultsFrame.NewFactionEmblem;
				end
				fontString:SetText(factionInfo.name);
				fontString:SetTextColor(factionInfo.color:GetRGB());
				icon:SetAtlas(factionInfo.icon, TextureKitConstants.UseAtlasSize);
			end
		end
	end
end

function DoesClientThinkTheCharacterIsEligibleForPFC(characterID)
	local characterInfo = CharacterSelectUtil.GetCharacterInfoTable(characterID);
	local _, otherFaction = CharacterHasAlternativeRaceOptions(characterID);
	local errors = {};

	if characterInfo then
		local isSameRealm = CharacterSelectUtil.IsSameRealmAsCurrent(characterInfo.realmAddress);
		CheckAddVASErrorString(errors, BLIZZARD_STORE_VAS_ERROR_CHARACTER_ON_DIFFERENT_REALM_1, isSameRealm);
		CheckAddVASErrorString(errors, BLIZZARD_STORE_VAS_ERROR_CHARACTER_ON_DIFFERENT_REALM_2, isSameRealm);

		if characterInfo.mailSenders then
			CheckAddVASErrorCode(errors, Enum.VasError.HasMail, #characterInfo.mailSenders == 0);
		end

		CheckAddVASErrorCode(errors, Enum.VasError.UnderMinLevelReq, characterInfo.experienceLevel >= 10);
		CheckAddVASErrorCode(errors, Enum.VasError.IsNpeRestricted, not IsCharacterNPERestricted(characterInfo.guid));
		CheckAddVASErrorCode(errors, Enum.VasError.RaceClassComboIneligible, otherFaction);
		CheckAddVASErrorCode(errors, Enum.VasError.IneligibleMapID, not IsCharacterInTutorialMap(characterInfo.guid));
		CheckAddVASErrorString(errors, BLIZZARD_STORE_VAS_ERROR_CHARACTER_INELIGIBLE_FOR_THIS_SERVICE, not IsCharacterVASRestricted(characterInfo.guid, Enum.ValueAddedServiceType.PaidFactionChange));

		local canTransfer = #errors == 0;
		return canTransfer, errors, characterInfo.guid, characterInfo.characterServiceRequiresLogin;
	end
	return false, errors, nil, false;
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
			CreateFromMixins(VASReviewChoicesBlockBase),
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