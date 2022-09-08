do
	local category, layout = Settings.RegisterCanvasLayoutCategory(CompactUnitFrameProfiles, COMPACT_UNIT_FRAME_PROFILES_LABEL)
	-- Order set in GameplaySettingsGroup.lua
	category:SetOrder(CUSTOM_GAMEPLAY_SETTINGS_ORDER[COMPACT_UNIT_FRAME_PROFILES_LABEL]);
	
	Settings.RegisterCategory(category, "Gameplay");
end