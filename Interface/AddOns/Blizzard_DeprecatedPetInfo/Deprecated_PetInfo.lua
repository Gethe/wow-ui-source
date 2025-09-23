-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

do
	PetAssistMode = C_PetInfo.PetAssistMode;
	GetPetTalentTree = C_PetInfo.GetPetTalentTree;
end
