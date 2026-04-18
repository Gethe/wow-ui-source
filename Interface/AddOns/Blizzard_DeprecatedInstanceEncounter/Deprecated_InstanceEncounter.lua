-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

IsEncounterInProgress = function()
	return C_InstanceEncounter.IsEncounterInProgress();
end

IsEncounterSuppressingRelease = function()
	return C_InstanceEncounter.IsEncounterSuppressingRelease();
end

IsEncounterLimitingResurrections = function()
	return C_InstanceEncounter.IsEncounterLimitingResurrections();
end
