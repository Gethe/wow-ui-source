do
	local category, layout = Settings.RegisterCanvasLayoutCategory(CompactUnitFrameProfiles, COMPACT_UNIT_FRAME_PROFILES_LABEL)
	
	Settings.RegisterCVarSetting(category, "useCompactPartyFrames", "boolean", RAID_SETTINGS_ENABLED);

	Settings.RegisterCategory(category, "Gameplay");
end