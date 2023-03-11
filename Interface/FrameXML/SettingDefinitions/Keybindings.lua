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
			local bindingName = securecallfunction(GetBindingName, action);
			initializer:AddSearchTags(bindingName);
			layout:AddInitializer(initializer);
		end
	end

	fakeCategory.redirectCategory = redirectCategory;
	Settings.RegisterCategory(fakeCategory, SETTING_GROUP_GAMEPLAY);
end

local retained = {};

local function CreateKeybindingInitializers(category, layout)
	-- Keybinding sections
	local bindingsCategories = {};
	local nextOrder = 1;
	local function AddBindingCategory(key)
		if not bindingsCategories[key] then
			bindingsCategories[key] = {order = nextOrder, bindings = {}};
			nextOrder = nextOrder + 1;
		end
	end

	AddBindingCategory(BINDING_HEADER_MOVEMENT);
	AddBindingCategory(BINDING_HEADER_INTERFACE);
	AddBindingCategory(BINDING_HEADER_ACTIONBAR);
	AddBindingCategory(BINDING_HEADER_MULTIACTIONBAR);
	AddBindingCategory(BINDING_HEADER_CHAT);
	AddBindingCategory(BINDING_HEADER_TARGETING);
	AddBindingCategory(BINDING_HEADER_RAID_TARGET);
	AddBindingCategory(BINDING_HEADER_VEHICLE);
	AddBindingCategory(BINDING_HEADER_CAMERA);
	AddBindingCategory(BINDING_HEADER_MISC);
	AddBindingCategory(BINDING_HEADER_OTHER);

	for bindingIndex = 1, GetNumBindings() do
		local action, cat, binding1, binding2 = GetBinding(bindingIndex);
		if not cat then
			tinsert(bindingsCategories[BINDING_HEADER_OTHER].bindings, {bindingIndex, action});
		else
			cat = _G[cat] or cat;
			AddBindingCategory(cat);

			if strsub(action, 1, 6) == "HEADER" then
				tinsert(bindingsCategories[cat].bindings, KeybindingSpacer);
			else
				tinsert(bindingsCategories[cat].bindings, {bindingIndex, action});
			end
		end
	end

	local sortedCategories = {};

	for cat, bindingCategory in pairs(bindingsCategories) do
		sortedCategories[bindingCategory.order] = {cat = cat, bindings = bindingCategory.bindings};
	end

	for _, categoryInfo in ipairs(sortedCategories) do
		if #(categoryInfo.bindings) > 0 then
			layout:AddInitializer(CreateKeybindingSectionInitializer(categoryInfo.cat, categoryInfo.bindings));
		end
	end
	
	-- Keybindings (search + redirectCategory)
	CreateSearchableSettings(category);
end

local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(SETTINGS_KEYBINDINGS_LABEL);
	retained.layout = layout;
	retained.category = category;
	Settings.SetKeybindingsCategory(category);

	-- Order set in GameplaySettingsGroup.lua
	category:SetOrder(CUSTOM_GAMEPLAY_SETTINGS_ORDER[SETTINGS_KEYBINDINGS_LABEL]);

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
		local initializer = Settings.CreateCheckBox(category, setting, CHARACTER_SPECIFIC_KEYBINDING_TOOLTIP);
		
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
	
	retained.initializers = CopyTable(layout:GetInitializers(), true);

	CreateKeybindingInitializers(category, layout);

	Settings.RegisterCategory(category, SETTING_GROUP_GAMEPLAY);
end

SettingsRegistrar:AddRegistrant(Register);

-- Temporary fix to restore access to CG bindings. Will be removed shortly with a proper
-- regeneration technique.
EventUtil.ContinueOnAddOnLoaded("CameraGuy", function()
	-- Flush out every initializer from the layout.
	local initializers = retained.layout:GetInitializers();
	wipe(initializers);

	-- Reassign the initializers we don't need to regenerate.
	for index, initializer in ipairs(retained.initializers) do
		retained.layout:AddInitializer(initializer);
	end

	-- Create new bindings.
	CreateKeybindingInitializers(retained.category, retained.layout);

	retained = nil;
end);