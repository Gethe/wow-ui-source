
HousingControlsUtil = {};

function HousingControlsUtil.CanActivateHousingControls(availabilityResult)
	local canActivate = availabilityResult == Enum.HousingResult.Success;
	if not canActivate then
		return canActivate, HousingResultToErrorText[availabilityResult];
	end

	return canActivate, nil;
end