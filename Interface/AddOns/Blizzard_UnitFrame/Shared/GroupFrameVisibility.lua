function ShouldShowArenaParty()
	return IsActiveBattlefieldArena() and not C_PvP.IsInBrawl();
end

function ShouldShowPartyFrames()
	return ShouldShowArenaParty() or (IsInGroup() and not IsInRaid()) or EditModeManagerFrame:ArePartyFramesForcedShown();
end

function ShouldShowRaidFrames()
	return not ShouldShowArenaParty() and IsInRaid() or EditModeManagerFrame:AreRaidFramesForcedShown();
end
