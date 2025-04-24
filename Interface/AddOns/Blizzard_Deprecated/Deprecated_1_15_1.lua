-- These are functions that were deprecated in 1.15.1 and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

do
	Enum.SeasonID.Placeholder = Enum.SeasonID.SeasonOfDiscovery;
end