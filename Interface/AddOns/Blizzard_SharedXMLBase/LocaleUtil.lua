LocaleUtil = {};

function LocaleUtil.GetLanguageAtlas(localeName)
	return string.format("Lang-Regions-%s", localeName);
end

function LocaleUtil.GetLanguageRestartAtlas(localeName)
	return string.format("lang-alert-%s", localeName);
end