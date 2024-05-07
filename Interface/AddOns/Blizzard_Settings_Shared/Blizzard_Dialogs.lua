local function DefineGameSettingsApplyDefaultsDialog()
	StaticPopupDialogs["GAME_SETTINGS_APPLY_DEFAULTS"] = {
		text = CONFIRM_RESET_INTERFACE_SETTINGS,
		button1 = ALL_SETTINGS,
		button3 = CURRENT_SETTINGS,
		button2 = CANCEL,
		OnAccept = function(self)
			SettingsPanel:SetAllSettingsToDefaults();
		end,
		OnAlt = function(self)
			SettingsPanel:SetCurrentCategorySettingsToDefaults();
		end,
		OnCancel = function() end,
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
		OnButton1 = function(self)
			SettingsPanel:ExitWithoutCommit();
		end,
		OnButton2 = function(self)
			SettingsPanel:ExitWithCommit();
		end,
		OnButton3 = function(self)
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
		OnAccept = function(self)
			SettingsPanel:DiscardRevertableSettings();
		end,
		OnCancel = function(self)
			SettingsPanel:RevertSettings();
		end,
		OnShow = function(self, duration)
			self.duration = duration;
		end,
		OnHide = function(self)
			self.duration = nil;
		end,
		OnUpdate = function(self, elapsed)
			self.duration = self.duration - elapsed;
			local time = math.max(self.duration + 1, 1);
			self.text:SetText(SETTINGS_TIMED_CONFIRMATION:format(time));
			StaticPopup_Resize(self, "GAME_SETTINGS_TIMED_CONFIRMATION");
		end,
		whileDead = 1,
		fullScreenCover = true,
	};

	if IsOnGlueScreen() then
		StaticPopupDialogs["GAME_SETTINGS_TIMED_CONFIRMATION"].OnUpdate = function(self, elapsed)
			self.duration = self.duration - elapsed;
			local time = math.max(self.duration + 1, 1);
			GlueDialogText:SetText(SETTINGS_TIMED_CONFIRMATION:format(time));
			GlueDialog_Resize(StaticPopupDialogs["GAME_SETTINGS_TIMED_CONFIRMATION"], "GAME_SETTINGS_TIMED_CONFIRMATION");
		end;
	end
end

local function DefineGameSettingsDefaultKeybindings()
	StaticPopupDialogs["CONFIRM_RESET_TO_DEFAULT_KEYBINDINGS"] = {
		text = CONFIRM_RESET_KEYBINDINGS,
		button1 = OKAY,
		button2 = CANCEL,
		OnAccept = function(self)
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