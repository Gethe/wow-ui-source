-- Overrides the shared version, loaded only by wowlabs
function IconIntroTrackerMixin:RegisterEvents()
	if C_GameModeManager and C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.ActionBarIconIntro) then
		self:RegisterEvent("SPELL_PUSHED_TO_ACTIONBAR");
	end
end