KeybindingsOverrides = {}

function KeybindingsOverrides.AddBindingCategories(AddBindingCategory)
	if Settings.IsPlunderstorm() then
		local requiredSettingName = nil;
		local expandedByDefault = true;
		AddBindingCategory(WOWLABS_BINDING_HEADER, requiredSettingName, expandedByDefault);
	end

	AddBindingCategory(BINDING_HEADER_MOVEMENT);
	AddBindingCategory(BINDING_HEADER_INTERFACE);
	AddBindingCategory(BINDING_HEADER_ACTIONBAR);
	AddBindingCategory(BINDING_HEADER_ACTIONBAR2, "PROXY_SHOW_ACTIONBAR_2");
	AddBindingCategory(BINDING_HEADER_ACTIONBAR3, "PROXY_SHOW_ACTIONBAR_3");
	AddBindingCategory(BINDING_HEADER_ACTIONBAR4, "PROXY_SHOW_ACTIONBAR_4");
	AddBindingCategory(BINDING_HEADER_ACTIONBAR5, "PROXY_SHOW_ACTIONBAR_5");
	AddBindingCategory(BINDING_HEADER_ACTIONBAR6, "PROXY_SHOW_ACTIONBAR_6");
	AddBindingCategory(BINDING_HEADER_ACTIONBAR7, "PROXY_SHOW_ACTIONBAR_7");
	AddBindingCategory(BINDING_HEADER_ACTIONBAR8, "PROXY_SHOW_ACTIONBAR_8");
	AddBindingCategory(BINDING_HEADER_MULTIACTIONBAR);
	AddBindingCategory(BINDING_HEADER_CHAT);
	AddBindingCategory(BINDING_HEADER_TARGETING);
	AddBindingCategory(BINDING_HEADER_RAID_TARGET);
	AddBindingCategory(BINDING_HEADER_VEHICLE);
	AddBindingCategory(BINDING_HEADER_CAMERA);
	AddBindingCategory(BINDING_HEADER_PING_SYSTEM);
	AddBindingCategory(BINDING_HEADER_MISC);
	AddBindingCategory(BINDING_HEADER_OTHER);
end

function KeybindingsOverrides.CreateBindingButtonSettings(layout)
	-- Click Cast Bindings
	-- Plunderstorm doesn't have targeted spells.
	if not Settings.IsPlunderstorm() then
		local function OnButtonClick(button, buttonName, down)
			local skipTransitionBackToOpeningPanel = true;
			SettingsPanel:Close(skipTransitionBackToOpeningPanel);
			ToggleClickBindingFrame();
		end

		local addSearchTags = true;
		local initializer = CreateSettingsButtonInitializer("", CLICK_BIND_MODE, OnButtonClick, nil, addSearchTags);
		layout:AddInitializer(initializer);
	end

	-- Quick keybind
	-- Plunderstorm doesn't support quick keybind right now
	if not Settings.IsPlunderstorm() then
		local function OnButtonClick(button, buttonName, down)
			local skipTransitionBackToOpeningPanel = true;
			SettingsPanel:Close(skipTransitionBackToOpeningPanel);
			QuickKeybindFrame:Show();
		end

		local addSearchTags = true;
		local initializer = CreateSettingsButtonInitializer("", SETTINGS_QUICK_KEYBIND_BUTTON, OnButtonClick, nil, addSearchTags);
		layout:AddInitializer(initializer);
	end
end

function KeybindingsOverrides.RunSettingsCallback(callback)
	if not Settings.IsPlunderstorm() then
		callback();
	end
end