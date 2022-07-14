if IsMacClient() then
	DefineGameSettingsMacOpenUniversalAccessDialog(StaticPopupDialogs);
	DefineGameSettingsMacOpenInputMonitoringDialog(StaticPopupDialogs);

	RegisterMacSettings();
end