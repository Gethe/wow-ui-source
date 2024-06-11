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