Settings.GetOrCreateSettingsGroup(SETTING_GROUP_GAMEPLAY, 1);
Settings.GetOrCreateSettingsGroup(SETTING_GROUP_ACCESSIBILITY, 2);
Settings.GetOrCreateSettingsGroup(SETTING_GROUP_SYSTEM, 3);

SETTING_GROUP_DEBUG = "Debug";
if IsGMClient() then
	Settings.GetOrCreateSettingsGroup(SETTING_GROUP_DEBUG, 4);
end
