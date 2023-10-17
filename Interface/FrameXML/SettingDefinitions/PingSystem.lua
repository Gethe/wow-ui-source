local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(PING_SYSTEM_LABEL);
    category:SetOrder(CUSTOM_GAMEPLAY_SETTINGS_ORDER[PING_SYSTEM_LABEL]);
    Settings.PINGSYSTEM_CATEGORY_ID = category:GetID();

    -- Tutorial
    local tooltip = PING_SYSTEM_TUTORIAL_TOOLTIP;
    local function PingSystemTutorialCallback()
        PingSystemTutorial:SetShown(not PingSystemTutorial:IsShown());
    end

    Settings.AssignTutorialToCategory(category, tooltip, PingSystemTutorialCallback);

    -- Enable Pings
    local enablePingsSetting, enablePingsInitializer = Settings.SetupCVarCheckBox(category, "enablePings", ENABLE_PINGS, OPTION_TOOLTIP_ENABLE_PINGS);

    local function CanModifyPingSettings()
        return enablePingsSetting:GetValue();
    end

    -- Ping Modes
	do
		local function GetOptions()
            local container = Settings.CreateControlTextContainer();
            container:Add(Enum.PingMode.KeyDown, PING_MODE_KEY_DOWN, OPTION_TOOLTIP_PING_MODE_KEY_DOWN);
            container:Add(Enum.PingMode.ClickDrag, PING_MODE_CLICK_DRAG, OPTION_TOOLTIP_PING_MODE_CLICK_DRAG);
            return container:GetData();
        end

        local setting = Settings.RegisterCVarSetting(category, "pingMode", Settings.VarType.Number, PING_MODE);
        local initializer = Settings.CreateDropDown(category, setting, GetOptions, OPTION_TOOLTIP_PING_MODE);
        initializer:SetParentInitializer(enablePingsInitializer, CanModifyPingSettings);
	end

    -- Enable Ping Sounds and Ping Sounds Volume
    if not Kiosk.IsEnabled() then
        do
            local initializer = layout:AddMirroredInitializer(Settings.PingSoundsInitializer);
            initializer:SetParentInitializer(enablePingsInitializer, CanModifyPingSettings);
        end
    end

    -- Show Pings in Chat
    do
        local setting = Settings.RegisterCVarSetting(category, "showPingsInChat", Settings.VarType.Boolean, SHOW_PINGS_IN_CHAT);
        local function OnButtonClick()
            ShowUIPanel(ChatConfigFrame);
            ChatConfigFrameChatTabManager:UpdateSelection(DEFAULT_CHAT_FRAME:GetID());
		end;
		local initializer = CreateSettingsCheckBoxWithButtonInitializer(setting, PING_CHAT_SETTINGS, OnButtonClick, true, OPTION_TOOLTIP_SHOW_PINGS_IN_CHAT);
		layout:AddInitializer(initializer);
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

        local addSearchTags = false;
		local initializer = CreateSettingsButtonInitializer("", PING_KEYBINDINGS, onButtonClick, nil, addSearchTags);
		layout:AddInitializer(initializer);
	end

    PingSystemInitializer(category);

    Settings.RegisterCategory(category, SETTING_GROUP_GAMEPLAY);
end

SettingsRegistrar:AddRegistrant(Register);

PingSystemMixin = {
    TutorialCutoffVersion = {
        Major = 10;
        Minor = 2;
        Revision = 5;
    };
};

do
    local function CreateVersionInt(major, minor, revision)
        return (major * 10000) + (minor * 100) + revision;
    end

    local threshold = CreateVersionInt(
        PingSystemMixin.TutorialCutoffVersion.Major,
        PingSystemMixin.TutorialCutoffVersion.Minor,
        PingSystemMixin.TutorialCutoffVersion.Revision);

    local currentVersion = GetBuildInfo();
    local major, minor, revision = strsplit(".", currentVersion);
    local lastVersion = CreateVersionInt(tonumber(major), tonumber(minor), tonumber(revision));
    local shouldShowTutorial = lastVersion <= threshold;

    function PingSystemMixin:TutorialCutoffVersionCheck()
        return shouldShowTutorial;
    end
end

function PingSystemMixin:Init(category)
    self.category = category;
    EventRegistry:RegisterCallback("Settings.CategoryChanged", self.OnCategoryChanged, self);
end

function PingSystemMixin:OnCategoryChanged(category)
    if category == self.category then
        if GetCVar("pingCategoryTutorialShown") == "0" and self:TutorialCutoffVersionCheck() then
            PingSystemTutorial:Show();
            SetCVar("pingCategoryTutorialShown", "1");
        end
    end
end

function PingSystemInitializer(category)
	local initializer = CreateFromMixins(PingSystemMixin);
	initializer:Init(category);
end

PingSystemTutorialMixin = {};

function PingSystemTutorialMixin:OnLoad()
    self:SetParent(UIParent);

    ButtonFrameTemplate_HidePortrait(self);
    ButtonFrameTemplate_HideAttic(self);
    ButtonFrameTemplate_HideButtonBar(self);

    self:SetTitle(PING_SYSTEM_TUTORIAL_LABEL);
    self.DragBar:Init(self);
end

function PingSystemTutorialMixin:OnHide()
    SettingsPanel.activeCategoryTutorial = false;
end

function PingSystemTutorialMixin:OnShow()
    SettingsPanel.activeCategoryTutorial = true;
end
