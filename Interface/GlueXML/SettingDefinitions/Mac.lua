if IsMacClient() then
	DefineGameSettingsMacOpenUniversalAccessDialog(GlueDialogTypes);
	DefineGameSettingsMacOpenInputMonitoringDialog(GlueDialogTypes);

	RegisterMacSettings();
end