NewSettings = {};

NewSettings["10.1.0"] = {
	"PROXY_CENSOR_MESSAGES",
};
NewSettings["10.1.5"] = {
	"ReplaceOtherPlayerPortraits",
	"ReplaceMyPlayerPortrait",
};

NewSettings["10.1.7"] = {
	"restrictCalendarInvites",
	"enablePings",
};

function IsNewSettingInCurrentVersion(variable)
	local version = GetBuildInfo();
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