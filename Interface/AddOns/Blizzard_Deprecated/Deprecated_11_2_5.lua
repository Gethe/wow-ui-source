-- These are functions that were deprecated in 11.2.5 and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

IsArtifactRelicItem = C_ItemSocketInfo.IsArtifactRelicItem;
