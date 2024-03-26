-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not IsPublicBuild() then
	return;
end

do
	PlayVocalErrorSoundID = C_Sound.PlayVocalErrorSound;
end