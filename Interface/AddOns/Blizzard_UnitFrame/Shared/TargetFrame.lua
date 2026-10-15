local function ShouldShowUnitInternal(targetFrame)
	-- Target frames should always show if the unit being displayed is the
	-- player, a party or raid member (including if they're on another map),
	-- or any other other unit that the client can "see" even if they aren't
	-- interactive.
	--
	-- If updating this logic, please mirror changes to the SecureStateDriver
	-- unitExistsCache.

	return UnitExists(targetFrame.unit) or UnitIsVisible(targetFrame.unit);
end

local function ShouldShowTargetFrameInternal(targetFrame)
	-- If the game rule is active, only show the target frame for other players, 
	-- not for the player themselves, npcs, or enemies. This is purely for visually
	-- disabling the target frame and the initial use case is for WoWHack.
	if C_GameRules.IsGameRuleActive(Enum.GameRule.ShowTargetFrameForOtherPlayersOnly) then
		if UnitIsPlayer(targetFrame.unit) and not UnitIsUnit(targetFrame.unit, "player") then
			return true;
		end

		return false;
	end

	return ShouldShowUnitInternal(targetFrame);
end

local function ShouldShowBossFrameInternal(targetFrame)
	return ShouldShowUnitInternal(targetFrame);
end

function ShouldShowTargetFrame(targetFrame)
	if C_GameRules.IsGameRuleActive(Enum.GameRule.TargetFrameDisabled) then
		return false;
	end

	if targetFrame.frameType == "Target-Boss-Small" then
		return ShouldShowBossFrameInternal(targetFrame);
	end

	return ShouldShowTargetFrameInternal(targetFrame);
end
