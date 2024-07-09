KeybindingsOverrides = {}

function KeybindingsOverrides.AddBindingCategories(AddBindingCategory)
	AddBindingCategory(BINDING_HEADER_MOVEMENT);
	AddBindingCategory(BINDING_HEADER_INTERFACE);
	AddBindingCategory(BINDING_HEADER_ACTIONBAR);
	AddBindingCategory(BINDING_HEADER_ACTIONBAR2, "PROXY_SHOW_ACTIONBAR_2");
	AddBindingCategory(BINDING_HEADER_ACTIONBAR3, "PROXY_SHOW_ACTIONBAR_3");
	AddBindingCategory(BINDING_HEADER_ACTIONBAR4, "PROXY_SHOW_ACTIONBAR_4");
	AddBindingCategory(BINDING_HEADER_ACTIONBAR5, "PROXY_SHOW_ACTIONBAR_5");
	AddBindingCategory(BINDING_HEADER_CHAT);
	AddBindingCategory(BINDING_HEADER_TARGETING);
	AddBindingCategory(BINDING_HEADER_RAID_TARGET);
	AddBindingCategory(BINDING_HEADER_VEHICLE);
	AddBindingCategory(BINDING_HEADER_CAMERA);
	AddBindingCategory(BINDING_HEADER_MISC);
	AddBindingCategory(BINDING_HEADER_OTHER);
end

function KeybindingsOverrides.CreateBindingButtonSettings(layout)
	-- No settings for Classic
end

function KeybindingsOverrides.RunSettingsCallback(callback)
	callback();
end