NewSettings = {};
NewSettingsSeen = {};
NewSettingsPredicates = {};

local version = GetBuildInfo();

local function InvokeSettingPredicate(predicate)
	assertsafe(predicate);
	local returnValue = predicate();
	assertsafe(type(returnValue) == "boolean");
	return returnValue;
end

function IsNewSettingInCurrentVersion(variable)
	local currentNewSettings = NewSettings[version];
	if currentNewSettings then
		for _, var in ipairs(currentNewSettings) do
			if variable == var then
				local newSettingPredicate = NewSettingsPredicates[var];
				if not newSettingPredicate or InvokeSettingPredicate(newSettingPredicate) == true then
					return true;
				end
				break;
			end
		end
	end

	return false;
end

function CurrentVersionHasNewUnseenSettings()
	local currentNewSettings = NewSettings[version];
	if not currentNewSettings then
		return false;
	end

	for _, newSetting in ipairs(currentNewSettings) do
		local newSettingPredicate = NewSettingsPredicates[newSetting];
		if NewSettingsSeen[newSetting] ~= true and (not newSettingPredicate or InvokeSettingPredicate(newSettingPredicate) == true) then
			return true;
		end
	end

	return false;
end

function MarkNewSettingAsSeen(setting)
	local currentNewSettings = NewSettings[version];
	if not currentNewSettings then
		return;
	end

	for _, newSetting in ipairs(currentNewSettings) do
		if setting == newSetting then
			-- A setting cannot be marked as seen if it has a predicate that returns false.
			local newSettingPredicate = NewSettingsPredicates[newSetting];
			if not newSettingPredicate or InvokeSettingPredicate(newSettingPredicate) == true then
				NewSettingsSeen[setting] = true;
			end
			return;
		end
	end
end
