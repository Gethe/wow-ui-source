do
	if StaticPopupDialogs then
		StaticPopupDialogs["CONFIRM_DELETING_CHARACTER_SPECIFIC_BINDINGS"] = {
			text = CONFIRM_DELETING_CHARACTER_SPECIFIC_BINDINGS,
			button1 = OKAY,
			button2 = CANCEL,
			OnAccept = function()
				Settings.SetValue("PROXY_CHARACTER_SPECIFIC_BINDINGS", false);
			end,
			OnCancel = function() end,
			timeout = 0,
			whileDead = 1,
			showAlert = 1,
		};
	end
end

local KeybindingSpacer = {};

AutoLootDropDownControlMixin = CreateFromMixins(SettingsDropDownControlMixin);

function AutoLootDropDownControlMixin:Init(initializer)
	SettingsDropDownControlMixin.Init(self, initializer);
	
	self.autoLootSetting = Settings.GetSetting("autoLootDefault");
	self:UpdateLabel();

	self.cbrHandles:SetOnValueChangedCallback("autoLootDefault", self.OnAutoLootChanged, self);
end

function AutoLootDropDownControlMixin:Release()
	SettingsDropDownControlMixin.Release(self);
end

function AutoLootDropDownControlMixin:OnAutoLootChanged(setting, value)
	self:UpdateLabel();
end

function AutoLootDropDownControlMixin:UpdateLabel()
	local text = self.autoLootSetting:GetValue() and LOOT_KEY_TEXT or AUTO_LOOT_KEY_TEXT;
	self.Text:SetText(text);
end

function CreateAutoLootInitializer(setting)
	local options = Settings.CreateModifiedClickOptions({
		OPTION_TOOLTIP_AUTO_LOOT_ALT_KEY,
		OPTION_TOOLTIP_AUTO_LOOT_CTRL_KEY,
		OPTION_TOOLTIP_AUTO_LOOT_SHIFT_KEY,
		OPTION_TOOLTIP_AUTO_LOOT_NONE_KEY,
	});

	local data = Settings.CreateSettingInitializerData(setting, options, OPTION_TOOLTIP_AUTO_LOOT_KEY);
	local initializer = Settings.CreateSettingInitializer("AutoLootDropDownControlTemplate", data);
	initializer:AddSearchTags(LOOT_KEY_TEXT);
	return initializer;
end

SettingsKeybindingSectionMixin = CreateFromMixins(SettingsExpandableSectionMixin);

function SettingsKeybindingSectionMixin:OnLoad()
	SettingsExpandableSectionMixin.OnLoad(self);

	self.bindingsPool = CreateFramePool("Frame", nil, "KeyBindingFrameBindingTemplate");
	self.spacerPool = CreateFramePool("Frame", nil, "SettingsKeybindingSpacerTemplate");
end

function SettingsKeybindingSectionMixin:Init(initializer)
	SettingsExpandableSectionMixin.Init(self, initializer);
	
	local data = initializer.data;
	local bindingsCategories = data.bindingsCategories;
	
	self.Controls = {};
	for _, data in ipairs(bindingsCategories) do
		if data == KeybindingSpacer then
			local frame = self.spacerPool:Acquire();
			table.insert(self.Controls, frame);
		else
			local frame = self.bindingsPool:Acquire();
			local bindingIndex, action = unpack(data);
			local initializer = {data={}};
			initializer.data.bindingIndex = bindingIndex;
			frame:Init(initializer);
			table.insert(self.Controls, frame);
		end
	end

	local total = 0;
	local rt = nil;
	for index, frame in ipairs(self.Controls) do
		frame:SetParent(self);
		frame:ClearAllPoints();
		if rt then
			frame:SetPoint("TOPLEFT", rt, "BOTTOMLEFT", 0, 0);
			frame:SetPoint("TOPRIGHT", rt, "BOTTOMRIGHT", 0, 0);
		else
			local offset = -45;
			frame:SetPoint("TOPLEFT", 0, offset);
			frame:SetPoint("TOPRIGHT", 0, offset);
		end
		rt = frame;
	end

	self:EvaluateVisibility(data.expanded);
end

function SettingsKeybindingSectionMixin:Release(initializer)
	-- Bindings can include a custom binding button that needs to be released.
	for frame in self.bindingsPool:EnumerateActive() do
		frame:Release();
	end

	self.bindingsPool:ReleaseAll();
	self.spacerPool:ReleaseAll();
end

function SettingsKeybindingSectionMixin:CalculateHeight()
	local initializer = self:GetElementData();
	return initializer:GetExtent();
end

function SettingsKeybindingSectionMixin:OnExpandedChanged(expanded)
	self:EvaluateVisibility(expanded);
end

function SettingsKeybindingSectionMixin:EvaluateVisibility(expanded)
	for index, frame in ipairs(self.Controls) do
		frame:SetShown(expanded);
	end

	if expanded then
		self.Button.Right:SetAtlas("Options_ListExpand_Right_Expanded", TextureKitConstants.UseAtlasSize);
	else
		self.Button.Right:SetAtlas("Options_ListExpand_Right", TextureKitConstants.UseAtlasSize);
	end

	local initializer = self:GetElementData();
	self:SetHeight(initializer:GetExtent());
end

local SettingsKeybindingSectionInitializer = CreateFromMixins(SettingsExpandableSectionInitializer);

function SettingsKeybindingSectionInitializer:GetExtent()
	local bindingHeight = 25;
	if self.data.expanded then
		local bottomPad = 20;
		return (bindingHeight * #self.data.bindingsCategories) + bindingHeight + bottomPad;
	end
	return bindingHeight;
end

function CreateKeybindingSectionInitializer(name, bindingsCategories)
	local initializer = CreateFromMixins(SettingsKeybindingSectionInitializer);
	initializer:Init("SettingsKeybindingSectionTemplate");
	initializer.data = {name=name, bindingsCategories=bindingsCategories};
	return initializer;
end

local function CreateSearchableSettings(redirectCategory)
	local fakeCategory, layout = Settings.RegisterVerticalLayoutCategory("NoDisplayKB");

	local bindingsCategories = {
		[BINDING_HEADER_OTHER] = {},
	};

	for bindingIndex = 1, GetNumBindings() do
		local action, cat, binding1, binding2 = GetBinding(bindingIndex);
		
		if not cat then
			tinsert(bindingsCategories[BINDING_HEADER_OTHER], {bindingIndex, action});
		else
			cat = _G[cat] or cat;
			if not bindingsCategories[cat] then
				bindingsCategories[cat] = {};
			end

			if strsub(action, 1, 6) ~= "HEADER" then
				tinsert(bindingsCategories[cat], {bindingIndex, action});
			end
		end
	end

	for categoryName, bindingCategory in pairs(bindingsCategories) do
		for _, bindingData in ipairs(bindingCategory) do
			local bindingIndex, action = unpack(bindingData);
			local initializer = CreateKeybindingEntryInitializer(bindingIndex, true);
			initializer:AddSearchTags(GetBindingName(action));
			layout:AddInitializer(initializer);
		end
	end

	fakeCategory.redirectCategory = redirectCategory;
	Settings.RegisterCategory(fakeCategory, SETTING_GROUP_GAMEPLAY);
end

local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(SETTINGS_KEYBINDINGS_LABEL);
	Settings.SetKeybindingsCategory(category);

	-- Binding set
	do
		local function GetValue()
			return GetCurrentBindingSet() == Enum.BindingSet.Character;
		end
		
		local function SetValue(value)
			if value then
				Settings.SelectCharacterBindings();
			else
				Settings.SelectAccountBindings();
			end
		end

		local defaultValue = Settings.CannotDefault;
		local setting = Settings.RegisterProxySetting(category, "PROXY_CHARACTER_SPECIFIC_BINDINGS", Settings.DefaultVarLocation,
			Settings.VarType.Boolean, CHARACTER_SPECIFIC_KEYBINDINGS, defaultValue, GetValue, SetValue);
		local initializer = Settings.CreateCheckBox(category, setting, OPTION_TOOLTIP_CHARACTER_SPECIFIC_KEYBINDINGS);
		
		-- Changing from character to account bindings requires confirmation since it overwrites
		-- character with account bindings.
		local function CanChangeSetting(value)
			if value then
				return false;
			end
			StaticPopup_Show("CONFIRM_DELETING_CHARACTER_SPECIFIC_BINDINGS");
			return true;
		end
		
		initializer:SetSettingIntercept(CanChangeSetting);
	end

	-- Click Cast Bindings
	do
		local function OnButtonClick(button, buttonName, down)
			local skipTransitionBackToOpeningPanel = true;
			SettingsPanel:Close(skipTransitionBackToOpeningPanel);
			ToggleClickBindingFrame();
		end

		local initializer = CreateSettingsButtonInitializer("", CLICK_BIND_MODE, OnButtonClick);
		layout:AddInitializer(initializer);
	end

	-- Quick keybind
	do
		local function OnButtonClick(button, buttonName, down)
			local skipTransitionBackToOpeningPanel = true;
			SettingsPanel:Close(skipTransitionBackToOpeningPanel);
			QuickKeybindFrame:Show();
		end

		local initializer = CreateSettingsButtonInitializer("", SETTINGS_QUICK_KEYBIND_BUTTON, OnButtonClick);
		layout:AddInitializer(initializer);
	end

	-- Self Cast Key
	do
		local tooltips = {
			OPTION_TOOLTIP_AUTO_SELF_CAST_ALT_KEY,
			OPTION_TOOLTIP_AUTO_SELF_CAST_CTRL_KEY,
			OPTION_TOOLTIP_AUTO_SELF_CAST_SHIFT_KEY,
			OPTION_TOOLTIP_AUTO_SELF_CAST_NONE_KEY,
		};
		Settings.SetupModifiedClickDropDown(category, "SELFCAST", "ALT", AUTO_SELF_CAST_KEY_TEXT, tooltips, OPTION_TOOLTIP_AUTO_SELF_CAST_KEY_TEXT);
	end

	-- Focus Cast Key
	do
		local tooltips = {
			OPTION_TOOLTIP_FOCUS_CAST_ALT_KEY,
			OPTION_TOOLTIP_FOCUS_CAST_CTRL_KEY,
			OPTION_TOOLTIP_FOCUS_CAST_SHIFT_KEY,
			OPTION_TOOLTIP_FOCUS_CAST_NONE_KEY,
		};
		Settings.SetupModifiedClickDropDown(category, "FOCUSCAST", "ALT", FOCUS_CAST_KEY_TEXT, tooltips, OPTION_TOOLTIP_FOCUS_CAST_KEY_TEXT);
	end

	-- Auto Loot
	Settings.SetupCVarCheckBox(category, "autoLootDefault", AUTO_LOOT_DEFAULT_TEXT, OPTION_TOOLTIP_AUTO_LOOT_DEFAULT);

	-- Auto Loot Key
	do
		local setting = Settings.RegisterModifiedClickSetting(category, "AUTOLOOTTOGGLE", AUTO_LOOT_KEY_TEXT, "SHIFT");
		local initializer = CreateAutoLootInitializer(setting);
		layout:AddInitializer(initializer);
	end
	

	-- Keybinding sections
	local bindingsCategories = {
		[BINDING_HEADER_OTHER] = {},
	};

	for bindingIndex = 1, GetNumBindings() do
		local action, cat, binding1, binding2 = GetBinding(bindingIndex);
		
		if not cat then
			tinsert(bindingsCategories[BINDING_HEADER_OTHER], {bindingIndex, action});
		else
			cat = _G[cat] or cat;
			if not bindingsCategories[cat] then
				bindingsCategories[cat] = {};
			end

			if strsub(action, 1, 6) == "HEADER" then
				tinsert(bindingsCategories[cat], KeybindingSpacer);
			else
				tinsert(bindingsCategories[cat], {bindingIndex, action});
			end
		end
	end

	for categoryName, bindingCategory in pairs(bindingsCategories) do
		layout:AddInitializer(CreateKeybindingSectionInitializer(categoryName, bindingCategory));
	end
	
	-- Keybindings (search + redirectCategory)
	CreateSearchableSettings(category);

	Settings.RegisterCategory(category, SETTING_GROUP_GAMEPLAY);
end

SettingsRegistrar:AddRegistrant(Register);