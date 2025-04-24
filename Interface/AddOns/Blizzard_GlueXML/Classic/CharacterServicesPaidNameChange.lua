local PNCNameSelectBlockClassic = CreateFromMixins(
	PNCNameSelectBlock,
	{
		Next = false,
		Finish = true
	}
);

function PNCNameSelectBlockClassic:FormatResult()
	local result = self:GetResult();
	return result.name;
end


PNCChoiceVerificationBlockClassic = CreateFromMixins(VASChoiceVerificationBlockBase);

function PNCChoiceVerificationBlockClassic:RequestAssignVASForResults(results, isValidationOnly)
	local valid, reason = C_CharacterCreation.IsCharacterNameValid(results.name)
	if not valid then
		self.errorSet = true; --This flag is so when we rewind due to invalid name, the error messages wont be cleared. 
		CharSelectServicesFlowFrame:SetErrorMessage(_G[reason]);
		CharacterServicesMaster.flow:RequestRewind();
		return false, 0;
	else
		self.errorSet = false;
	end
	return RequestAssignPNCForResults(results, isValidationOnly);
end

function PNCChoiceVerificationBlockClassic:OnRewind()
	self.isAssignmentValid = false;
	if not self.errorSet then
		CharSelectServicesFlowFrame:ClearErrorMessage();
	end
	self:UnregisterHandlers();
end


PaidNameChangeFlowClassic = CreateFromMixins(
	PaidNameChangeFlow,
	{
		Steps = {
			PNCCharacterSelectBlock,
			PNCNameSelectBlockClassic,
			PNCChoiceVerificationBlockClassic,
			CreateFromMixins(VASReviewChoicesBlockBase),
			PNCAssignConfirmationBlock,
			PNCEndStep
		}
	}
);

function DoesClientThinkTheCharacterIsEligibleForPNC(characterID)
	local playerguid = GetCharacterGUID(characterID);
	local basicInfo = GetBasicCharacterInfo(playerguid);
	local serviceInfo = GetServiceCharacterInfo(playerguid);
	local errors = {};

	if not basicInfo or not serviceInfo then
		return false, errors, playerGuid, false;
	end

	CheckAddVASErrorCode(errors, Enum.VasError.UnderMinLevelReq, basicInfo.experienceLevel >= 10);
	if IsCharacterNPERestricted then
		CheckAddVASErrorCode(errors, Enum.VasError.IsNpeRestricted, not IsCharacterNPERestricted(playerguid));
	end
	CheckAddVASErrorCode(errors, Enum.VasError.IneligibleMapID, not IsCharacterInTutorialMap(playerguid));
	CheckAddVASErrorString(errors, BLIZZARD_STORE_VAS_ERROR_CHARACTER_INELIGIBLE_FOR_THIS_SERVICE, not IsCharacterVASRestricted(playerguid, Enum.ValueAddedServiceType.PaidNameChange));

	local canTransfer = #errors == 0;
	return canTransfer, errors, playerguid, serviceInfo.characterServiceRequiresLogin;
end