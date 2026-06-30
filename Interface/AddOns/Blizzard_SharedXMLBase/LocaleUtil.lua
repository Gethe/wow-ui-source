LocaleUtil = {};

function LocaleUtil.GetLanguageAtlas(localeName)
	return string.format("Lang-Regions-%s", localeName);
end

function LocaleUtil.GetLanguageRestartAtlas(localeName)
	return string.format("lang-alert-%s", localeName);
end

-- Retrieves the localized display name for a locale.
function LocaleUtil.GetLocaleDisplayName(localeName)
	localeName = string.upper(localeName);

	-- LOCALE_DISPLAY_NAME_ strings take precedence and allow locale display names to differ from the
	-- LFG_LIST_LANGUAGE_ strings (e.g. to add "Simplified/Traditional" qualifiers for Chinese locales).
	local localeKey = "LOCALE_DISPLAY_NAME_" .. localeName;
	if _G[localeKey] then
		return _G[localeKey];
	end

	local globalKey = "LFG_LIST_LANGUAGE_" .. localeName;
	return _G[globalKey] or localeName;
end
