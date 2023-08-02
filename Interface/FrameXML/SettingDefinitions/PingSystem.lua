local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(PING_SYSTEM_LABEL);
    category:SetOrder(CUSTOM_GAMEPLAY_SETTINGS_ORDER[PING_SYSTEM_LABEL]);
    Settings.PINGSYSTEM_CATEGORY_ID = category:GetID();

    -- Enable Pings
    local enablePingsSetting, enablePingsInitializer = Settings.SetupCVarCheckBox(category, "enablePings", ENABLE_PINGS, OPTION_TOOLTIP_ENABLE_PINGS);

    local function CanModifyPingSettings()
        return enablePingsSetting:GetValue();
    end

    -- Enable Ping Sounds and Ping Sounds Volume
    do
        local initializer = layout:AddMirroredInitializer(Settings.PingSoundsInitializer);
        initializer:SetParentInitializer(enablePingsInitializer, CanModifyPingSettings);
    end

    -- Show Pings in Chat
    do
        local _, initializer = Settings.SetupCVarCheckBox(category, "showPingsInChat", SHOW_PINGS_IN_CHAT, OPTION_TOOLTIP_SHOW_PINGS_IN_CHAT);
        initializer:SetParentInitializer(enablePingsInitializer, CanModifyPingSettings);
    end

    -- Keybinds Button
	do
		local function onButtonClick()
            local keybindsCategory = SettingsPanel:GetCategory(Settings.KEYBINDINGS_CATEGORY_ID);
            local keybindsLayout = SettingsPanel:GetLayout(keybindsCategory);
            for _, initializer in keybindsLayout:EnumerateInitializers() do
                if initializer.data.name == BINDING_HEADER_PING_SYSTEM then
                    initializer.data.expanded = true;
                    Settings.OpenToCategory(Settings.KEYBINDINGS_CATEGORY_ID, BINDING_HEADER_PING_SYSTEM);
                    return;
                end
            end
		end

		local initializer = CreateSettingsButtonInitializer("", PING_KEYBINDINGS, onButtonClick);
		layout:AddInitializer(initializer);
	end

    Settings.RegisterCategory(category, SETTING_GROUP_GAMEPLAY);
end

SettingsRegistrar:AddRegistrant(Register);