function RegisterMacSettings()
	local category, layout = Settings.RegisterVerticalLayoutCategory(MAC_SETTINGS_LABEL);
	Settings.MAC_CATEGORY_ID = category:GetID();

	local setting = Settings.SetupCVarCheckBox(category, "MacDisableOsShortcuts", MAC_DISABLE_OS_SHORTCUTS, MAC_DISABLE_OS_SHORTCUTS_TOOLTIP);
	
	local function OnDisableOsShortcutsChanged(o, setting, value)
		if value and not C_MacOptions.IsUniversalAccessEnabled() then
			ShowAppropriateDialog("MAC_OPEN_UNIVERSAL_ACCESS");
			setting:SetValue(false);
		end
	end
	Settings.SetOnValueChangedCallback(setting:GetVariable(), OnDisableOsShortcutsChanged);
	
	Settings.SetupCVarCheckBox(category, "MacUseCommandLeftClickAsRightClick", MAC_USE_COMMAND_LEFT_CLICK_AS_RIGHT_CLICK, MAC_USE_COMMAND_LEFT_CLICK_AS_RIGHT_CLICK_TOOLTIP);
	
	Settings.RegisterCategory(category, SETTING_GROUP_SYSTEM);
end


function DefineGameSettingsMacOpenUniversalAccessDialog(dialogTable)
	dialogTable["MAC_OPEN_UNIVERSAL_ACCESS"] = {
		text = MAC_OPEN_UNIVERSAL_ACCESS,
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			C_MacOptions.OpenUniversalAccess();
			Settings.OpenToCategory(Settings.MAC_CATEGORY_ID);
		end,
		OnCancel = function()
			Settings.OpenToCategory(Settings.MAC_CATEGORY_ID);
		end,
		OnShow = function(self)
			self.text:SetFormattedText(MAC_OPEN_UNIVERSAL_ACCESS1090, C_MacOptions.GetGameBundleName());
		end,
		showAlert = 1,
		timeout = 0,
		exclusive = 0,
		hideOnEscape = false,
		whileDead = 1,
	};
end

function DefineGameSettingsMacOpenInputMonitoringDialog(dialogTable)
	dialogTable["MAC_OPEN_INPUT_MONITORING"] = {
		text = MAC_OPEN_UNIVERSAL_ACCESS,
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			C_MacOptions.OpenInputMonitoring();
		end,
		OnShow = function(self)
			if (C_MacOptions.HasNewStyleInputMonitoring()) then
				self.text:SetFormattedText(MAC_INPUT_MONITORING1015, C_MacOptions.GetGameBundleName());
			else
				self.text:SetFormattedText(MAC_INPUT_MONITORING1014, C_MacOptions.GetGameBundleName());
			end
		end,
		showAlert = 1,
		timeout = 0,
		exclusive = 0,
		hideOnEscape = false,
		whileDead = 1,
	};
end
