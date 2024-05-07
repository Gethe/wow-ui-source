-- These are functions that were deprecated in 10.0.0 and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

do
	-- Recommend using C_PaperDollInfo.CanCursorCanGoInSlot to correctly
	-- determine if the item is relevant to Profession 1 or Profession 2 which
	-- have different slot IDs for each profession.
	CursorCanGoInSlot = C_PaperDollInfo.CanCursorCanGoInSlot;
end

do
	-- Use C_TradeSkillUI.GetRemainingRecasts to return the number of casts
	-- remaining, which excludes the current cast in progress.
	C_TradeSkillUI.GetRecipeRepeatCount = function()
		return C_TradeSkillUI.GetRemainingRecasts() + 1;
	end;
end