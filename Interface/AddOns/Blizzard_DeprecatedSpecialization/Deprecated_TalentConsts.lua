-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

MAX_TALENT_TIERS = Constants.TalentTierConstants.MAX_TALENT_TIERS;
NUM_TALENT_COLUMNS = Constants.TalentConsts.NumTalentColumns;
