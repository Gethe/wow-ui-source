CombatAudioAlertUtil = {};

function CombatAudioAlertUtil.GetFormattedHealthString(formatInfo, healthPercent)
	if formatInfo then
		local usePercent = formatInfo.short and math.floor(healthPercent / 10) or healthPercent;
		return formatInfo.formatStr:format(usePercent);
	end
end

CombatAudioAlertUtil.PlayerHealthFormatInfo = {
	{formatStr = CAA_SAY_HEALTH_FORMAT_FULL, short = false},
	{formatStr = CAA_SAY_HEALTH_FORMAT_NO_PERCENT, short = false},
	{formatStr = CAA_SAY_HEALTH_FORMAT_NO_PERCENT, short = true},
	{formatStr = CAA_SAY_HEALTH_FORMAT_NO_HEALTH, short = false},
	{formatStr = CAA_SAY_HEALTH_FORMAT_NUM_ONLY, short = false},
	{formatStr = CAA_SAY_HEALTH_FORMAT_NUM_ONLY, short = true},
};

CombatAudioAlertUtil.TargetHealthFormatInfo = {
	{formatStr = CAA_SAY_HEALTH_FORMAT_FULL, short = false},
	{formatStr = CAA_SAY_HEALTH_FORMAT_NO_PERCENT, short = false},
	{formatStr = CAA_SAY_HEALTH_FORMAT_NO_PERCENT, short = true},
	{formatStr = CAA_SAY_HEALTH_FORMAT_NO_HEALTH, short = false},
	{formatStr = CAA_SAY_HEALTH_FORMAT_NUM_ONLY, short = false},
	{formatStr = CAA_SAY_HEALTH_FORMAT_NUM_ONLY, short = true},
	{formatStr = CAA_SAY_TARGET_HEALTH_FORMAT_FULL, short = false},
	{formatStr = CAA_SAY_TARGET_HEALTH_FORMAT_NO_PERCENT, short = false},
	{formatStr = CAA_SAY_TARGET_HEALTH_FORMAT_NO_PERCENT, short = true},
};

function CombatAudioAlertUtil.GetUnitFormattedHealthString(unit, cvarVal, healthPercent)
	if unit == "player" then
		local formatInfo = CombatAudioAlertUtil.PlayerHealthFormatInfo[cvarVal];
		return CombatAudioAlertUtil.GetFormattedHealthString(formatInfo, healthPercent);
	elseif unit == "target" then
		local formatInfo = CombatAudioAlertUtil.TargetHealthFormatInfo[cvarVal];
		return CombatAudioAlertUtil.GetFormattedHealthString(formatInfo, healthPercent);
	end
end

function CombatAudioAlertUtil.EnumerateUnitFormatInfo(unit)
	if unit == "player" then
		return ipairs(CombatAudioAlertUtil.PlayerHealthFormatInfo);
	elseif unit == "target" then
		return ipairs(CombatAudioAlertUtil.TargetHealthFormatInfo);
	end
end

function CombatAudioAlertUtil.GetCAACvarValueNumber(cvarConstant)
	return CVarCallbackRegistry:GetCVarNumberOrDefault(CombatAudioAlertConstants.CVars[cvarConstant].name);
end

function CombatAudioAlertUtil.GetCAACVarValueBool(cvarConstant)
	return CVarCallbackRegistry:GetCVarValueBool(CombatAudioAlertConstants.CVars[cvarConstant].name);
end
