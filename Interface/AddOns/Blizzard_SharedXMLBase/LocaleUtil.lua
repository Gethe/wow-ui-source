LocaleUtil = {};

function LocaleUtil.GetLanguageAtlas(localeName)
	return string.format("Lang-Regions-%s", localeName);
end

function LocaleUtil.GetLanguageRestartAtlas(localeName)
	return string.format("lang-alert-%s", localeName);
end

-- Retrieves the localized display name for a locale
-- Note: We may want to make separate copies from LFG_LIST strings if we ever
-- want the localization to be different than it is in LFG.
function LocaleUtil.GetLocaleDisplayName(localeName)
	local globalKey = "LFG_LIST_LANGUAGE_" .. string.upper(localeName);
	return _G[globalKey] or localeName;
end
