local function CreateOptions(...)
	local exists = {};
	local options = {};
	for index = 1, select("#", ...) do
		local localeName = select(index, ...);
		if not exists[localeName] then
			exists[localeName] = true;
			table.insert(options, {value=localeName});
		end
	end
	return options;
end

local function GetTextLocalesOptions()
	return CreateOptions(GetCVar("textLocale"), GetAvailableLocales());
end

local function GetAudioLocalesOptions()
	return CreateOptions("enUS", GetCVar("audioLocale"), GetCVar("textLocale"));
end

local function SetAudioLocaleSettingToDefault(setting)
	local options = GetAudioLocalesOptions();
	setting:SetValue(options[#options].value);
end

local function SetupLanguageAtlas(texture, localeTbl)
	local atlas = LocaleUtil.GetLanguageAtlas(localeTbl.value);
	texture:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
end

SettingsLanguageDropdownMixin = {};

function SettingsLanguageDropdownMixin:OnLoad()
	WowStyle2DropdownMixin.OnLoad(self);
	
	self:SetDisplacedRegions(2, -1, self.Language);

	self:SetSelectionText(function(selections)
		local selection = selections[1];
		if selection then
			local localeTbl = selection.data;
			SetupLanguageAtlas(self.Language, localeTbl);
		end
		return nil;
	end);

	-- See CreateDropdownButton below.
	self.Text:Hide();
end

local function SetupDropdown(dropdown, setting, options, width, initTooltip)
	local function Inserter(rootDescription, isSelected, setSelected)
		for index, localeTbl in ipairs(options()) do
			local optionDescription = rootDescription:CreateTemplate("SettingsDropdownButtonTemplate");
			Settings.CreateDropdownButton(optionDescription, localeTbl, isSelected, setSelected);
			
			-- Language dropdown requires all the initialization from Settings.CreateDropdownButton,
			-- except it needs to display it's selected value as a texture, not text.
			optionDescription:AddInitializer(function(button, description, menu)
				button.Text:Hide();

				local locTexture = button:AttachTexture();
				locTexture:SetPoint("LEFT", button, "LEFT", 3, -2);
				SetupLanguageAtlas(locTexture, localeTbl);
			end);
		end
	end

	Settings.InitDropdown(dropdown, setting, Inserter, initTooltip);
end

-- SettingsDropdownControlTemplate inherited in XML.
local BaseLanguageDropdownControlMixin = {}; 

function BaseLanguageDropdownControlMixin:SetupDropdownMenu(button, setting, options, initTooltip)
	SetupDropdown(self.Control.Dropdown, setting, options, initTooltip);
end

SettingsLanguageDropdownControlMixin = CreateFromMixins(BaseLanguageDropdownControlMixin);

SettingsAudioLocaleDropdownMixin = CreateFromMixins(BaseLanguageDropdownControlMixin);

function SettingsAudioLocaleDropdownMixin:Init(initializer)
	SettingsDropdownControlMixin.Init(self, initializer);

	-- Changing the text locale changed the audio locale options. Since CBR callbacks are unordered, we need
	-- to ensure the audio locale value is updated prior to updating the dropdown or we won't get the correct
	-- current value.
	local function OnTextLocaleChanged(o, setting, value)
		SetAudioLocaleSettingToDefault(self:GetSetting());

		self:InitDropdown();
	end

	self.cbrHandles:SetOnValueChangedCallback("textLocale", OnTextLocaleChanged);
end

LanguageRestartNeededMixin = CreateFromMixins(SettingsListElementMixin);

function LanguageRestartNeededMixin:EvaluateState()
	local textLocaleCurrent = GetCVar("textLocale");
	self.RestartNeeded:SetShown(textLocaleCurrent ~= self.data.textLocaleOriginal);

	local atlas = LocaleUtil.GetLanguageRestartAtlas(textLocaleCurrent);
	self.RestartNeeded:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
	self.RestartNeeded:SetScale(.5);
end

local function Register()
	if Kiosk.IsEnabled() then
		return;
	end

	local category, layout = Settings.RegisterVerticalLayoutCategory(LANGUAGES_LABEL);

	-- Text
	local textLocaleSetting = Settings.RegisterCVarSetting(category, "textLocale", Settings.VarType.String, LOCALE_TEXT_LABEL);
	local textLocaleInitializer = Settings.CreateControlInitializer("SettingsLanguageTemplate", 
		textLocaleSetting, GetTextLocalesOptions, OPTION_TOOLTIP_LOCALE);
	layout:AddInitializer(textLocaleInitializer);

	-- Audio
	local audioLocaleSetting = Settings.RegisterCVarSetting(category, "audioLocale", Settings.VarType.String, LOCALE_AUDIO_LABEL);
	local audioLocaleInitializer = Settings.CreateControlInitializer("SettingsAudioLocaleTemplate", 
		audioLocaleSetting, GetAudioLocalesOptions, OPTION_TOOLTIP_AUDIO_LOCALE);
	layout:AddInitializer(audioLocaleInitializer);

	-- Restart Needed
	local restartNeededData = { textLocaleOriginal = GetCVar("textLocale") };
	local restartNeededInitializer = Settings.CreateElementInitializer("SettingsLanguageRestartNeededTemplate", restartNeededData);
	restartNeededInitializer:SetParentInitializer(textLocaleInitializer);
	layout:AddInitializer(restartNeededInitializer);
	
	-- Defaulting the audio locale cvar based on a dependent cvar ideally wouldn't be done
	-- on the Lua side at all. Should investigate moving this into the client code. Also
	-- see OnTextLocaleChanged above in SettingsAudioLocaleDropdownMixin!
	local function OnTextLocaleChanged(o, setting, value)
		SetAudioLocaleSettingToDefault(audioLocaleSetting);
	end
	Settings.SetOnValueChangedCallback(textLocaleSetting:GetVariable(), OnTextLocaleChanged);

	Settings.RegisterCategory(category, SETTING_GROUP_SYSTEM);
end

SettingsRegistrar:AddRegistrant(Register);