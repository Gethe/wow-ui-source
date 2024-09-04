local function CallLocalizationFunction(l10nTable, key)
	-- It's ok if things are missing, it just means that locale doesn't require any specific localization
	local localeTable = l10nTable[UI_LOCALE];
	if localeTable then
		local localizeFn = localeTable[key];
		if localizeFn then
			localizeFn();
		end
	end
end

local localizeFramesCallbacks = {};
local function AddLocalizeFramesCallback(l10nTable)
	table.insert(localizeFramesCallbacks, function()
		CallLocalizationFunction(l10nTable, "localizeFrames");
	end);
end

-- Intentionally global, this is called later when all of the UI that needs l10n is loaded.
function LocalizeFrames()
	for index, callback in ipairs(localizeFramesCallbacks) do
		-- If an error occurs (e.g. a frame in the original file was renamed) report the problem but don't stop execution so the loc teams aren't blocked.
		local ok, err = pcall(callback);
		if not ok then
			ConsolePrint("Error in localization callback " .. err);
			HandleLuaWarning(LUA_WARNING_TREAT_AS_ERROR, "Error in localization callback " .. err);
		end
	end

	localizeFramesCallbacks = {};
end

function SetupLocalization(l10nTable)
	-- This is called immediately when l10n is set up to adjust strings and other constants that the rest of the UI setup depends on.
	CallLocalizationFunction(l10nTable, "localize");

	-- NOTE: The typical hook for this is VARIABLES_LOADED, so for LoadOnDemand addons, use the "localize" section.
	AddLocalizeFramesCallback(l10nTable);
end