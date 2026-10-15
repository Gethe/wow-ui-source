-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

do
	C_TransmogOutfitInfo.GetWeaponOptionsForSlot = C_TransmogOutfitInfo.GetOptionsForSlot;
	C_TransmogOutfitInfo.SetViewedWeaponOptionForSlot = C_TransmogOutfitInfo.SetViewedOptionForSlot;
end
