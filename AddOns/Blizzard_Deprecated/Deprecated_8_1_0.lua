
-- These are functions that were deprecated in 8.1.0, and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not IsPublicBuild() then
	--return;
end

-- Summons API update

do 
	-- Use C_SummonInfo.GetSummonConfirmTimeLeft() instead.
	GetSummonConfirmTimeLeft = C_SummonInfo.GetSummonConfirmTimeLeft;

	-- Use C_SummonInfo.GetSummonConfirmSummoner() instead.
	GetSummonConfirmSummoner = C_SummonInfo.GetSummonConfirmSummoner;

	-- Use C_SummonInfo.GetSummonConfirmAreaName() instead.
	GetSummonConfirmAreaName = C_SummonInfo.GetSummonConfirmAreaName;

	-- Use C_SummonInfo.ConfirmSummon() instead.
	ConfirmSummon = C_SummonInfo.ConfirmSummon;

	-- Use C_SummonInfo.CancelSummon() instead.
	CancelSummon = C_SummonInfo.CancelSummon;
end
