-- Note that the concept of a "view" setting refers to tweakables that we
-- support within EncounterWarningsViewTemplate/Mixin and the child element
-- templates respectively.
--
-- This differs from an edit mode setting; edit mode settings are handled by
-- the encounter warnings system frame which acts as a container around a
-- view. Some edit mode settings are handled directly by the container (eg.
-- overall scale and transparency), whereas others are remapped to view
-- settings (eg. icon scale and tooltips) and are passed down the frame
-- hierarchy to the locations that need them.

EncounterWarningsViewSetting = {
	ChatAlertsEnabled = "chatAlertsEnabled",
	ClassColorEnabled = "classColorEnabled",
	IconScale = "iconScale",
	MaximumTextHeight = "maximumTextHeight",
	MaximumTextWidth = "maximumTextWidth",
	SoundAlertsEnabled = "soundAlertsEnabled",
	TextFontObject = "textFontObject",
	TextColor = "textColor",
	TooltipsEnabled = "tooltipsEnabled",
};

EncounterWarningsViewSettingDefaults = {
	[EncounterWarningsViewSetting.ChatAlertsEnabled] = true,
	[EncounterWarningsViewSetting.ClassColorEnabled] = true,
	[EncounterWarningsViewSetting.IconScale] = 1,
	[EncounterWarningsViewSetting.MaximumTextHeight] = nil,  -- If nil, use severity-specific defaults.
	[EncounterWarningsViewSetting.MaximumTextWidth] = nil,  -- If nil, use severity-specific defaults.
	[EncounterWarningsViewSetting.SoundAlertsEnabled] = true,
	[EncounterWarningsViewSetting.TextFontObject] = nil,  -- If nil, use severity-specific defaults.
	[EncounterWarningsViewSetting.TextColor] = nil,  -- If nil, use severity-specific defaults.
	[EncounterWarningsViewSetting.TooltipsEnabled] = true,
};

function EncounterWarningsUtil.GetDefaultViewSetting(setting)
	return GetValueOrCallFunction(EncounterWarningsViewSettingDefaults, setting);
end

-- Storage of settings is abstracted to a pair of accessor and mutator mixins
-- that provide a key/value based interface for queries or writes.

EncounterWarningsViewSettingsAccessorMixin = {};

function EncounterWarningsViewSettingsAccessorMixin:GetViewSetting(setting)
	-- Implement in a derived mixin to provide read access to settings.
	return EncounterWarningsUtil.GetDefaultViewSetting(setting);
end

EncounterWarningsViewSettingsMutatorMixin = {};

function EncounterWarningsViewSettingsMutatorMixin:SetViewSetting(_setting, _value)
	-- Implement in a derived mixin to provide write access to settings.
end

EncounterWarningsViewSettingsMixin = CreateFromMixins(EncounterWarningsViewSettingsAccessorMixin, EncounterWarningsViewSettingsMutatorMixin);

-- The following namespace should be used when reading or writing individual
-- view settings.

EncounterWarningsViewSettings = {};

function EncounterWarningsViewSettings.AreChatAlertsEnabled(accessor)
	return accessor:GetViewSetting(EncounterWarningsViewSetting.ChatAlertsEnabled);
end

function EncounterWarningsViewSettings.SetChatAlertsEnabled(mutator, chatAlertsEnabled)
	mutator:SetViewSetting(EncounterWarningsViewSetting.ChatAlertsEnabled, chatAlertsEnabled);
end

function EncounterWarningsViewSettings.AreSoundAlertsEnabled(accessor)
	return accessor:GetViewSetting(EncounterWarningsViewSetting.SoundAlertsEnabled);
end

function EncounterWarningsViewSettings.SetSoundAlertsEnabled(mutator, soundAlertsEnabled)
	mutator:SetViewSetting(EncounterWarningsViewSetting.SoundAlertsEnabled, soundAlertsEnabled);
end

function EncounterWarningsViewSettings.AreTooltipsEnabled(accessor)
	return accessor:GetViewSetting(EncounterWarningsViewSetting.TooltipsEnabled);
end

function EncounterWarningsViewSettings.SetTooltipsEnabled(mutator, tooltipsEnabled)
	mutator:SetViewSetting(EncounterWarningsViewSetting.TooltipsEnabled, tooltipsEnabled);
end

function EncounterWarningsViewSettings.GetIconScale(accessor)
	return accessor:GetViewSetting(EncounterWarningsViewSetting.IconScale);
end

function EncounterWarningsViewSettings.SetIconScale(mutator, iconScale)
	mutator:SetViewSetting(EncounterWarningsViewSetting.IconScale, iconScale);
end

function EncounterWarningsViewSettings.GetMaximumTextHeight(accessor, severity)
	local maximumTextHeight = accessor:GetViewSetting(EncounterWarningsViewSetting.MaximumTextHeight);

	if maximumTextHeight == nil and severity ~= nil then
		maximumTextHeight = EncounterWarningsUtil.GetDefaultMaximumTextHeight(severity);
	end

	return maximumTextHeight;
end

function EncounterWarningsViewSettings.SetMaximumTextHeight(mutator, maximumTextHeight)
	mutator:SetViewSetting(EncounterWarningsViewSetting.MaximumTextHeight, maximumTextHeight);
end

function EncounterWarningsViewSettings.GetMaximumTextWidth(accessor, severity)
	local maximumTextWidth = accessor:GetViewSetting(EncounterWarningsViewSetting.MaximumTextWidth);

	if maximumTextWidth == nil and severity ~= nil then
		maximumTextWidth = EncounterWarningsUtil.GetDefaultMaximumTextWidth(severity);
	end

	return maximumTextWidth;
end

function EncounterWarningsViewSettings.SetMaximumTextWidth(mutator, maximumTextWidth)
	mutator:SetViewSetting(EncounterWarningsViewSetting.MaximumTextWidth, maximumTextWidth);
end

function EncounterWarningsViewSettings.GetTextColor(accessor, severity)
	local textColor = accessor:GetViewSetting(EncounterWarningsViewSetting.TextColor);

	if textColor == nil and severity ~= nil then
		textColor = EncounterWarningsUtil.GetDefaultTextColor(severity);
	end

	return textColor;
end

function EncounterWarningsViewSettings.SetTextColor(mutator, textColor)
	mutator:SetViewSetting(EncounterWarningsViewSetting.TextColor, textColor);
end

function EncounterWarningsViewSettings.GetTextFontObject(accessor, severity)
	local textFontObject = accessor:GetViewSetting(EncounterWarningsViewSetting.TextFontObject);

	if textFontObject == nil and severity ~= nil then
		textFontObject = EncounterWarningsUtil.GetDefaultFontObject(severity);
	end

	return textFontObject;
end

function EncounterWarningsViewSettings.SetTextFontObject(mutator, textFontObject)
	mutator:SetViewSetting(EncounterWarningsViewSetting.TextFontObject, textFontObject);
end

function EncounterWarningsViewSettings.ShouldClassColorTargetNames(accessor)
	return accessor:GetViewSetting(EncounterWarningsViewSetting.ClassColorEnabled);
end

function EncounterWarningsViewSettings.SetClassColorTargetNames(mutator, classColorTargetNames)
	return mutator:SetViewSetting(EncounterWarningsViewSetting.ClassColorEnabled, classColorTargetNames);
end
