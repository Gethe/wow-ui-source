do
	local function CheckExperienceReadiness(experience)
		local templateSetID = Kiosk.GetCharacterTemplateSetID(experience) or 0;
		local sessionDuration = Kiosk.GetSessionDuration(experience) or 0;

		if templateSetID <= 0 then
			C_Log.LogErrorMessage("Kiosk readiness check failed: template set ID is not configured.");
			return false;
		end

		if sessionDuration <= 0 then
			C_Log.LogErrorMessage("Kiosk readiness check failed: session duration is not configured.");
			return false;
		end

		return true;
	end

	local experienceOneReady = CheckExperienceReadiness(Enum.KioskExperience.One);
	local experienceTwoReady = CheckExperienceReadiness(Enum.KioskExperience.Two);

	if experienceOneReady and experienceTwoReady then
		C_Log.LogMessage("Kiosk readiness check passed.");
	end
end
