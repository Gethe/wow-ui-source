-- These are values that were deprecated and will be removed in the future.
-- Please upgrade to the updated values as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

do
	LE_WORLD_ELAPSED_TIMER_TYPE_NONE = Enum.WorldElapsedTimerTypes.None;
	LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE = Enum.WorldElapsedTimerTypes.ChallengeMode;
	LE_WORLD_ELAPSED_TIMER_TYPE_PROVING_GROUND = Enum.WorldElapsedTimerTypes.ProvingGround;
end
