local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(ADVANCED_OPTIONS_LABEL);
	Settings.ADVANCED_OPTIONS_CATEGORY_ID = category:GetID();

	-- Order set in GameplaySettingsGroup.lua
	category:SetOrder(CUSTOM_GAMEPLAY_SETTINGS_ORDER[ADVANCED_OPTIONS_LABEL]);

	-- Assisted Highlight
	InterfaceOverrides.RunSettingsCallback(function()
		local tooltipFn = function()
			local isAvailable, failureReason = C_AssistedCombat.IsAssistedCombatHighlightAvailable();
			if isAvailable then
				return OPTION_TOOLTIP_ASSISTED_COMBAT_HIGHLIGHT;
			else
				return format("%s|n|n%s", OPTION_TOOLTIP_ASSISTED_COMBAT_HIGHLIGHT, failureReason);
			end
		end
		local setting, initializer = Settings.SetupCVarCheckbox(category, "assistedCombatHighlight", ASSISTED_COMBAT_HIGHLIGHT_LABEL, tooltipFn);
		initializer:AddModifyPredicate(C_AssistedCombat.IsAssistedCombatHighlightAvailable);

		local onClickFn = function(checked)
			if checked and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ASSISTED_HIGHLIGHT_ENABLED_POPUP) then
				local systemPrefix = "SETTINGS";
				local notificationType = "ASSISTED_HIGHLIGHT";
				StaticPopup_ShowNotification(systemPrefix, notificationType, ASSISTED_COMBAT_HIGHLIGHT_DIALOG_WARNING);
				local OnSettingsPanelHide = function()
					EventRegistry:UnregisterCallback("SettingsPanel.OnHide", notificationType);
					StaticPopup_HideNotification(systemPrefix, notificationType);
				end
				EventRegistry:RegisterCallback("SettingsPanel.OnHide", OnSettingsPanelHide, notificationType);
				SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ASSISTED_HIGHLIGHT_ENABLED_POPUP, true);
			end
			return false;
		end
		initializer:SetSettingIntercept(onClickFn);
	end);

	-- Cooldown Viewer
	InterfaceOverrides.RunSettingsCallback(function()
		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(COOLDOWN_VIEWER_LABEL));
	end);

	InterfaceOverrides.RunSettingsCallback(function()
		local tooltipFn = function()
			local isAvailable, failureReason = C_CooldownViewer.IsCooldownViewerAvailable();
			if isAvailable then
				return ENABLE_COOLDOWN_VIEWER_TOOLTIP;
			else
				return format("%s|n|n%s", ENABLE_COOLDOWN_VIEWER_TOOLTIP, failureReason);
			end
		end

		local _setting, initializer = Settings.SetupCVarCheckbox(category, "cooldownViewerEnabled", ENABLE_COOLDOWN_VIEWER, tooltipFn);
		initializer:AddModifyPredicate(C_CooldownViewer.IsCooldownViewerAvailable);
	end);

	Settings.RegisterCategory(category, SETTING_GROUP_GAMEPLAY);
end

SettingsRegistrar:AddRegistrant(Register);
