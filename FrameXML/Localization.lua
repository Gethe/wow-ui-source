
-- This is a symbol available for people who need to know the locale (separate from GetLocale())
LOCALE_enUS = true;

function Localize()
	-- Put all locale specific string adjustments here
end

function LocalizeFrames()
	-- Put all locale specific UI adjustments here

	-- Hide billing help option.  If the number of help options changes this will need to change also.
	CATEGORY_TO_NOT_DISPLAY = 9;

end

function Localization_GetShortDate (day, month, year)
	return string.format("%1d/%1d/%02d", month, day, year);
end
