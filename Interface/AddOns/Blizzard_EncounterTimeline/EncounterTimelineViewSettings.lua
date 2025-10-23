-- Timeline settings are split into a family of accessor and mutator mixins.
--
-- The base variants of these mixins define a key/value based Get/Set
-- interface that is expected to be implemented by derived mixins to provide
-- access to settings.
--
-- The full accessor and mutator mixins provide a more standard Get/Set API
-- for each individual setting.
--
-- This split is to simplify management of settings across the various parts
-- of the timeline, since three distinct components (edit mode shell, timeline
-- view, and view elements) all need access to configuration data.

EncounterTimelineViewSettingsAccessorBaseMixin = {};

function EncounterTimelineViewSettingsAccessorBaseMixin:GetViewSetting(key)
	-- Ideally override in a derived mixin so that this doesn't read defaults :)
	return EncounterTimelineUtil.GetDefaultViewSetting(key);
end

EncounterTimelineViewSettingsAccessorMixin = CreateFromMixins(EncounterTimelineViewSettingsAccessorBaseMixin);

local function ReflectViewSettingAccessors(target)
	for settingEnumName, settingKey in pairs(EncounterTimelineViewSetting) do
		target["Get" .. settingEnumName] = function(self) return self:GetViewSetting(settingKey); end;
	end
end

ReflectViewSettingAccessors(EncounterTimelineViewSettingsAccessorMixin);

EncounterTimelineViewSettingsMutatorBaseMixin = {};

function EncounterTimelineViewSettingsMutatorBaseMixin:SetViewSetting(_key, _value)
	-- No-op; implement in a derived mixin.
end

EncounterTimelineViewSettingsMutatorMixin = CreateFromMixins(EncounterTimelineViewSettingsMutatorBaseMixin);

local function ReflectViewSettingMutators(target)
	for settingEnumName, settingKey in pairs(EncounterTimelineViewSetting) do
		target["Set" .. settingEnumName] = function(self, value) self:SetViewSetting(settingKey, value); end;
	end
end

ReflectViewSettingMutators(EncounterTimelineViewSettingsMutatorMixin);

function EncounterTimelineUtil.CreateViewSettings()
	local settingsMap = CreateFromMixins(EncounterTimelineUtil.GetDefaultViewSettingsMap());
	local settings = CreateFromMixins(EncounterTimelineViewSettingsAccessorMixin, EncounterTimelineViewSettingsMutatorMixin);

	function settings:GetViewSetting(key)
		return settingsMap[key];
	end

	function settings:SetViewSetting(key, value)
		settingsMap[key] = value;
	end

	return settings;
end

function EncounterTimelineUtil.ApplyViewSettings(target, source)
	for key in EncounterTimelineUtil.EnumerateDefaultViewSettings() do
		target:SetViewSetting(key, source:GetViewSetting(key));
	end
end

function EncounterTimelineUtil.CloneViewSettings(source)
	local target = EncounterTimelineUtil.CreateViewSettings();
	EncounterTimelineUtil.ApplyViewSettings(target, source);
	return target;
end

function EncounterTimelineUtil.ResetViewSettings(target)
	local source = EncounterTimelineUtil.GetDefaultViewSettings();
	EncounterTimelineUtil.ApplyViewSettings(target, source);
end

function EncounterTimelineUtil.GetDefaultViewSetting(key)
	local defaultSettings = EncounterTimelineUtil.GetDefaultViewSettingsMap();
	return defaultSettings[key];
end

function EncounterTimelineUtil.GetDefaultViewSettings()
	return EncounterTimelineViewSettingsAccessorMixin;
end

function EncounterTimelineUtil.GetDefaultViewSettingsMap()
	return EncounterTimelineDefaultViewSettings;
end

function EncounterTimelineUtil.EnumerateDefaultViewSettings()
	return pairs(EncounterTimelineUtil.GetDefaultViewSettingsMap());
end
