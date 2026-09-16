function DoesClientThinkTheCharacterIsEligibleForFCM(characterID)
	local characterInfo = CharacterSelectUtil.GetCharacterInfoTable(characterID);
	local errors = {};
	
	if characterInfo then
		if characterInfo.mailSenders then
			CheckAddVASErrorCode(errors, Enum.VasTransactionPurchaseResult.DbHasMail, #characterInfo.mailSenders == 0);
		end

		CheckAddVASErrorCode(errors, Enum.VasTransactionPurchaseResult.DbCharLocked, not characterInfo.hasVasRevoked)
		CheckAddVASErrorCode(errors, Enum.VasTransactionPurchaseResult.DbUnderMinLevelReq, characterInfo.experienceLevel >= 10);
		CheckAddVASErrorCode(errors, Enum.VasTransactionPurchaseResult.DbHasNewPlayerExperienceRestriction, not IsCharacterNPERestricted(characterInfo.guid));
		CheckAddVASErrorString(errors, BLIZZARD_STORE_VAS_ERROR_CHARACTER_INELIGIBLE_FOR_THIS_SERVICE, not IsCharacterVASRestricted(characterInfo.guid, Enum.ValueAddedServiceType.PaidCharacterTransfer));
		CheckAddVASErrorString(errors, BLIZZARD_STORE_VAS_ERROR_TIMERUNNER_NOT_ALLOWED, not IsCharacterTimerunning(characterInfo.guid));

		local canTransfer = #errors == 0;
		return canTransfer, errors, characterInfo.guid, characterInfo.characterServiceRequiresLogin;
	end
	return false, errors, nil, false;
end

