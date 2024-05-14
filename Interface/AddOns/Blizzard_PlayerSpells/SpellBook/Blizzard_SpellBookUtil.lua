SpellBookUtil = {};

function SpellBookUtil.GetOrStartSyncedAnimationOffset(animDuration)
	if not SpellBookUtil.firstSyncedAnimStartTime then
		SpellBookUtil.firstSyncedAnimStartTime = GetTime();
		return 0;
	end

	local timeSinceStart = GetTime() - SpellBookUtil.firstSyncedAnimStartTime;
	return timeSinceStart % animDuration;
end