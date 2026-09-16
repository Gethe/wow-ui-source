-- These are aura filter values that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

-- "NOT_CANCELABLE" was replaced by negating the CANCELABLE filter ("!CANCELABLE")
AuraUtil.AuraFilters.NotCancelable = AuraUtil.AuraFilterNegationPrefix .. AuraUtil.AuraFilters.Cancelable;
