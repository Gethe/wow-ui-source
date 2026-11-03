-- We want to only show highlighting on spells that are not on your bar but the highest rank.
function ActionButtonUtil.OverrideStatusForUnplacedSpell(status, spellID, notOnBar)
	if notOnBar then
		-- check if spellID is the highest rank, if it isn't then just give it ActionButtonUtil.ActionBarActionStatus.NotMissing
		if C_ActionBar.IsHighestSpellRank(spellID) then
			status = ActionButtonUtil.ActionBarActionStatus.MissingFromAllBars;
		else
			status = ActionButtonUtil.ActionBarActionStatus.NotMissing;
		end
	end
	return status;
end
