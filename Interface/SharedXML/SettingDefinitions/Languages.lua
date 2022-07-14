local function CreateOptions(...)
	local options = {};
	for index = 1, select("#", ...) do
		local locale = select(index, ...);
		if LocaleUtil.ContainInstructionForLocale(locale) then
			table.insert(options, {value=locale});
		end
	end
	return options;
end

local function GetTextLocalesOptions()
	return CreateOptions(GetAvailableLocales());
end

local function GetAvailableAudioLocales()
	if GetCVar("textLocale") == "enUS" then
		return "enUS";
	end
	return "enUS", GetCVar("textLocale");
end

local function GetAudioLocalesOptions()
	return CreateOptions(GetAvailableAudioLocales());
end

local function SetAudioLocaleSettingToDefault(setting)
	local options = GetAudioLocalesOptions();
	setting:SetValue(options[#options].value);
end

SettingsAudioLocaleDropDownMixin = CreateFromMixins(SettingsDropDownControlMixin);

function SettingsAudioLocaleDropDownMixin:Init(initializer)
	SettingsDropDownControlMixin.Init(self, initializer);

	-- Changing the text locale changed the audio locale options. Since CBR callback are unordered, we need
	-- to ensure the audio locale value is updated before updating the dropdown.
	local function OnTextLocaleChanged(o, setting, value)
		SetAudioLocaleSettingToDefault(self:GetSetting());

		self:InitDropDown();
	end

	self.cbrHandles:SetOnValueChangedCallback("textLocale", OnTextLocaleChanged);
end

function SettingsAudioLocaleDropDownMixin:Release()
	SettingsDropDownControlMixin.Release(self);
end

SettingsLanguagePopoutEntryMixin = CreateFromMixins(SelectionPopoutEntryMixin);

function SettingsLanguagePopoutEntryMixin:OnLoad()
	SelectionPopoutEntryMixin.OnLoad(self);
end

function SettingsLanguagePopoutEntryMixin:GetTooltipText()
	return self.SelectionDetails:GetTooltipText();
end

function SettingsLanguagePopoutEntryMixin:OnEnter()
	SelectionPopoutEntryMixin.OnEnter(self);

	if not self.isSelected then
		if self.selectionData.disabled == nil then
			self.HighlightBGTex:SetAlpha(0.15);
		end
	end

	self.parentButton:OnEntryMouseEnter(self);
end

function SettingsLanguagePopoutEntryMixin:OnLeave()
	SelectionPopoutEntryMixin.OnLeave(self);

	if not self.isSelected then
		self.HighlightBGTex:SetAlpha(0);
	end

	self.parentButton:OnEntryMouseLeave(self);
end

function SettingsLanguagePopoutEntryMixin:OnClick()
	if self.selectionData.disabled == nil then
		SelectionPopoutEntryMixin.OnClick(self);
	end
end

SettingsLanguagePopoutDetailsMixin = {};

function SettingsLanguagePopoutDetailsMixin:AdjustWidth(multipleColumns, defaultWidth)
	self:SetWidth(Round(defaultWidth));
end

function SettingsLanguagePopoutDetailsMixin:SetupDetails(selectionData, index, isSelected, hasAFailedReq)
	local iconInfo = LocaleUtil.CreateTextureInfoForInstructions(selectionData.value);
	self.Texture:SetTexture(LocaleUtil.GetInstructionTexture());
	self.Texture:SetTexCoord(iconInfo.tCoordLeft, iconInfo.tCoordRight, iconInfo.tCoordTop, iconInfo.tCoordBottom);
	self.Texture:SetWidth(iconInfo.tSizeX);
	self.Texture:SetHeight(iconInfo.tSizeY);
	self.Texture:SetPoint("LEFT", self, "LEFT", 0, 0);
	return true;
end

SettingsLanguagePopoutButtonMixin = CreateFromMixins(SelectionPopoutButtonMixin, DefaultTooltipMixin);

function SettingsLanguagePopoutButtonMixin:OnLoad()
	SelectionPopoutButtonMixin.OnLoad(self);
	DefaultTooltipMixin.OnLoad(self);

	self:SetScript("OnMouseWheel", nil);
end

function SettingsLanguagePopoutButtonMixin:OnEnter()
	SelectionPopoutButtonMixin.OnEnter(self);
	DefaultTooltipMixin.OnEnter(self);
end

function SettingsLanguagePopoutButtonMixin:OnLeave()
	SelectionPopoutButtonMixin.OnLeave(self);
	DefaultTooltipMixin.OnLeave(self);
end

function SettingsLanguagePopoutButtonMixin:SetEnabled_(enabled)
	SelectionPopoutButtonMixin.SetEnabled_(self, enabled);
end

function SettingsLanguagePopoutButtonMixin:IsDataMatch(data1, data2)
	return data1.value == data2.value;
end

function SettingsLanguagePopoutButtonMixin:UpdateButtonDetails()
	local currentSelectedData = self:GetCurrentSelectedData();
	local result = self.SelectionDetails:SetupDetails(currentSelectedData, self.selectedIndex);
	self.SelectionDetails:Layout();
	return result;
end

local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(LANGUAGES_LABEL);

	-- Text
	local textLocaleSetting = Settings.RegisterCVarSetting(category, "textLocale", Settings.VarType.String, LOCALE_TEXT_LABEL);
	local textLocaleInitializer = Settings.CreateControlInitializer("SettingsLanguageDropDownTemplate", 
		textLocaleSetting, GetTextLocalesOptions, OPTION_TOOLTIP_LOCALE);
	layout:AddInitializer(textLocaleInitializer);

	-- Audio
	local audioLocaleSetting = Settings.RegisterCVarSetting(category, "audioLocale", Settings.VarType.String, LOCALE_AUDIO_LABEL);
	local audioLocaleInitializer = Settings.CreateControlInitializer("SettingsAudioLocaleDropDownTemplate", 
		audioLocaleSetting, GetAudioLocalesOptions, OPTION_TOOLTIP_AUDIO_LOCALE);
	layout:AddInitializer(audioLocaleInitializer);

	local function OnTextLocaleChanged(o, setting, value)
		SetAudioLocaleSettingToDefault(audioLocaleSetting);
	end
	Settings.SetOnValueChangedCallback(textLocaleSetting:GetVariable(), OnTextLocaleChanged);

	Settings.RegisterCategory(category, SETTING_GROUP_SYSTEM);
end

SettingsRegistrar:AddRegistrant(Register);