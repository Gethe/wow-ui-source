
-- These are functions that were deprecated in 9.2.5, and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not IsPublicBuild() then
	return;
end

-- LFG flags
do
	LFG_LIST_FILTER_RECOMMENDED = Enum.LFGListFilter.Recommended;
	LFG_LIST_FILTER_NOT_RECOMMENDED = Enum.LFGListFilter.NotRecommended;
	LFG_LIST_FILTER_PVE = Enum.LFGListFilter.PvE;
	LFG_LIST_FILTER_PVP = Enum.LFGListFilter.PvP;
end

-- LFG renaming cleanup
do
	Enum.CurrencySource.LfgReward = Enum.CurrencySource.LFGReward;

	Enum.LfgEntryPlaystyle = Enum.LFGEntryPlaystyle;
	Enum.LfgListDisplayType = Enum.LFGListDisplayType;

	Enum.BrawlType.Lfg = Enum.BrawlType.LFG;
end

-- The GetPlayerAuraBySpellID API no longer returns information about hidden auras