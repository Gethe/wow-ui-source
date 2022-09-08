if IsMacClient() then
	DefineGameSettingsMacOpenUniversalAccessDialog(GlueDialogTypes);
	DefineGameSettingsMacOpenInputMonitoringDialog(GlueDialogTypes);

	SettingsRegistrar:AddRegistrant(RegisterMacSettings);
end