local PNCNameSelectBlockMainline = CreateFromMixins(
	PNCNameSelectBlock,
    {
	    Next = true,
	    Finish = false
    }
);

function PNCNameSelectBlockMainline:FormatResult()
	local result = self:GetResult();
	return NORMAL_FONT_COLOR:WrapTextInColorCode(result.name);
end


PNCChoiceVerificationBlockMainline = CreateFromMixins(VASChoiceVerificationBlockBase);

function PNCChoiceVerificationBlockMainline:RequestAssignVASForResults(results, isValidationOnly)
	local valid, reason = C_CharacterCreation.IsCharacterNameValid(results.name)
	if not valid then 
		CharSelectServicesFlowFrame:SetErrorMessage(_G[reason]);
		CharacterServicesMaster.flow:RequestRewind();
		return false, 0;
	else
		CharSelectServicesFlowFrame:ClearErrorMessage();
	end
	return RequestAssignPNCForResults(results, isValidationOnly);
end

function PNCChoiceVerificationBlockMainline:OnRewind()
	self.isAssignmentValid = false;
	self:UnregisterHandlers();
end


PaidNameChangeFlowMainline = CreateFromMixins(
	PaidNameChangeFlow,
	{
		Steps = {
			PNCCharacterSelectBlock,
			PNCNameSelectBlockMainline,
			PNCChoiceVerificationBlockMainline,
			CreateFromMixins(VASReviewChoicesBlockBase),
			PNCAssignConfirmationBlock,
			PNCEndStep
		}
	}
);

function DoesClientThinkTheCharacterIsEligibleForPNC(characterID)
	local playerguid = GetCharacterGUID(characterID);
	local errors = {};

	local characterInfo = CharacterSelectUtil.GetCharacterInfoTable(characterID);
	if characterInfo then
		CheckAddVASErrorCode(errors, Enum.VasTransactionPurchaseResult.DbUnderMinLevelReq, characterInfo.experienceLevel >= 10);
		if IsCharacterNPERestricted then
			CheckAddVASErrorCode(errors, Enum.VasTransactionPurchaseResult.DbHasNewPlayerExperienceRestriction, not IsCharacterNPERestricted(playerguid));
		end
		CheckAddVASErrorCode(errors, Enum.VasTransactionPurchaseResult.DbIneligibleMapID, not IsCharacterInTutorialMap(playerguid));
		CheckAddVASErrorString(errors, BLIZZARD_STORE_VAS_ERROR_CHARACTER_INELIGIBLE_FOR_THIS_SERVICE, not IsCharacterVASRestricted(playerguid, Enum.ValueAddedServiceType.PaidNameChange));
		CheckAddVASErrorString(errors, BLIZZARD_STORE_VAS_ERROR_TIMERUNNER_NOT_ALLOWED, not IsCharacterTimerunning(playerguid));

		local canTransfer = #errors == 0;
		return canTransfer, errors, playerguid, characterInfo.characterServiceRequiresLogin;
	end
	return false, errors, playerGuid, false;
end
