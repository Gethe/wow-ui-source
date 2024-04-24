local function DefineNewSettings()
	local version = GetBuildInfo();

	local currentNewSettings = NewSettings[version];
	if currentNewSettings then
		for _, settingName in ipairs(currentNewSettings) do
			local setting = Settings.GetSetting(settingName);
			if setting then
				setting:SetNewTagShown(true);
			end
		end
	end
end

SettingsRegistrar:AddRegistrant(DefineNewSettings);