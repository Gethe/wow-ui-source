function ShouldShowTargetFrame(targetFrame)
	-- Target frames should always show if the unit being displayed is the
	-- player, a party or raid member (including if they're on another map),
	-- or any other other unit that the client can "see" even if they aren't
	-- interactive.
	--
	-- If updating this logic, please mirror changes to the SecureStateDriver
	-- unitExistsCache.

	if C_GameRules.IsGameRuleActive(Enum.GameRule.TargetFrameDisabled) then
		return false;
	end

	return UnitExists(targetFrame.unit) or UnitIsVisible(targetFrame.unit);
end
