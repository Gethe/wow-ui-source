local function DefineGameSettingsApplyDefaultsDialog()
	StaticPopupDialogs["GAME_SETTINGS_APPLY_DEFAULTS"] = {
		text = CONFIRM_RESET_INTERFACE_SETTINGS,
		button1 = ALL_SETTINGS,
		button3 = CURRENT_SETTINGS,
		button2 = CANCEL,
		OnAccept = function(dialog, data)
			SettingsPanel:SetAllSettingsToDefaults();
		end,
		OnAlt = function(dialog, data)
			SettingsPanel:SetCurrentCategorySettingsToDefaults();
		end,
		OnCancel = function(dialog, data) end,
		hideOnEscape = 1,
		whileDead = 1,
		fullScreenCover = true,
	}
end

local function DefineGameSettingsConfirmDiscardDialog()
	StaticPopupDialogs["GAME_SETTINGS_CONFIRM_DISCARD"] = {
		text = SETTINGS_CONFIRM_DISCARD,
		button1 = SETTINGS_UNAPPLIED_EXIT,
		button2 = SETTINGS_UNAPPLIED_APPLY_AND_EXIT,
		button3 = SETTINGS_UNAPPLIED_CANCEL,
		OnButton1 = function(dialog, data)
			SettingsPanel:ExitWithoutCommit();
		end,
		OnButton2 = function(dialog, data)
			SettingsPanel:ExitWithCommit();
		end,
		OnButton3 = function(dialog, data)
		end,
		selectCallbackByIndex = true,
		hideOnEscape = 1,
		whileDead = 1,
		fullScreenCover = true,
	}
end

local function DefineGameSettingsTimedRevertDialog()
	StaticPopupDialogs["GAME_SETTINGS_TIMED_CONFIRMATION"] = {
		text = "",
		button1 = SETTINGS_CONFIRM_TIMEOUT_BUTTON,
		button2 = SETTINGS_CANCEL_TIMEOUT_BUTTON,
		OnAccept = function(dialog, data)
			SettingsPanel:DiscardRevertableSettings();
		end,
		OnCancel = function(dialog, data)
			SettingsPanel:RevertSettings();
		end,
		OnShow = function(dialog, duration)
			dialog.duration = duration;
		end,
		OnHide = function(dialog, data)
			dialog.duration = nil;
		end,
		OnUpdate = function(dialog, elapsed)
			dialog.duration = dialog.duration - elapsed;
			local time = math.max(dialog.duration + 1, 1);
			dialog:SetText(SETTINGS_TIMED_CONFIRMATION:format(time));
			dialog:Resize("GAME_SETTINGS_TIMED_CONFIRMATION");
		end,
		whileDead = 1,
		fullScreenCover = true,
	};
end

local function DefineGameSettingsDefaultKeybindings()
	StaticPopupDialogs["CONFIRM_RESET_TO_DEFAULT_KEYBINDINGS"] = {
		text = CONFIRM_RESET_KEYBINDINGS,
		button1 = OKAY,
		button2 = CANCEL,
		OnAccept = function(dialog, data)
			KeybindListener:ResetBindingsToDefault();
		end,
		timeout = 0,
		whileDead = 1,
		showAlert = 1,
		fullScreenCover = true,
	};
end

DefineGameSettingsApplyDefaultsDialog();
DefineGameSettingsConfirmDiscardDialog();
DefineGameSettingsTimedRevertDialog();
DefineGameSettingsDefaultKeybindings();