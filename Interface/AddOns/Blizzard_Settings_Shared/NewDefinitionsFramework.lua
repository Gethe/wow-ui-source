NewSettings = {};

local version = GetBuildInfo();

function IsNewSettingInCurrentVersion(variable)
	local currentNewSettings = NewSettings[version];
	if currentNewSettings then
		for _, var in ipairs(currentNewSettings) do
			if variable == var then
				return true;
			end
		end
	end

	return false;
end