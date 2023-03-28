function DefineNewSettings()
	local newSettings = {};

	newSettings["10.1.0"] = {
		"PROXY_CENSOR_MESSAGES",
	};

	local version = GetBuildInfo();

	local currentNewSettings = newSettings[version];
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
