CombatAudioAlertUtil = {};

function CombatAudioAlertUtil.GetFormattedString(formatInfo, stringVal, numberVal)
	if formatInfo then
		if formatInfo.noValue then
			return formatInfo.formatStr;
		else
			local useNumberVal = formatInfo.divideByTen and math.floor(numberVal / 10) or numberVal;
			if stringVal and not formatInfo.noStringValue then
				return formatInfo.formatStr:format(stringVal, useNumberVal);
			else
				return formatInfo.formatStr:format(useNumberVal);
			end
		end
	end
end

local function GetPercentOptionString(percent)
	return EVERY_X_PERCENT:format(percent);
end

local percentInfo = {
	{str = LOC_OPTION_OFF},
	{str = GetPercentOptionString(10)},
	{str = GetPercentOptionString(20)},
	{str = GetPercentOptionString(30)},
	{str = GetPercentOptionString(40)},
	{str = GetPercentOptionString(50)},
};

local function GetUnderPercentOptionString(percent)
	return UNDER_X_PERCENT:format(percent);
end

local partyHealthPercentInfo = {
	{percentVal = 0, str = LOC_OPTION_OFF},
	{percentVal = 100, str = GetUnderPercentOptionString(100)},
	{percentVal = 90, str = GetUnderPercentOptionString(90)},
	{percentVal = 80, str = GetUnderPercentOptionString(80)},
	{percentVal = 70, str = GetUnderPercentOptionString(70)},
	{percentVal = 60, str = GetUnderPercentOptionString(60)},
	{percentVal = 50, str = GetUnderPercentOptionString(50)},
	{percentVal = 40, str = GetUnderPercentOptionString(40)},
	{percentVal = 30, str = GetUnderPercentOptionString(30)},
	{percentVal = 20, str = GetUnderPercentOptionString(20)},
	{percentVal = 10, str = GetUnderPercentOptionString(10)},
};

local sayIfTargetedInfo = {
	{str = LOC_OPTION_OFF},
	{str = CAA_SAY_IF_TARGETED_FORMAT_AGGRO},
	{str = CAA_SAY_IF_TARGETED_FORMAT_TARGETED_NO_NAME},
	{str = CAA_SAY_IF_TARGETED_FORMAT_TARGETED},
};

local sayCastInfo = {
	{str = LOC_OPTION_OFF},
	{str = CAA_SAY_CASTS_START_OF_CAST},
	{str = CAA_SAY_CASTS_END_OF_CAST},
};

local playerHealthFormatInfo = {
	{formatStr = CAA_SAY_HEALTH_FORMAT_FULL},
	{formatStr = CAA_SAY_HEALTH_FORMAT_NO_PERCENT},
	{formatStr = CAA_SAY_HEALTH_FORMAT_NO_PERCENT, divideByTen = true},
	{formatStr = CAA_SAY_HEALTH_FORMAT_NO_HEALTH},
	{formatStr = CAA_SAY_HEALTH_FORMAT_NUM_ONLY},
	{formatStr = CAA_SAY_HEALTH_FORMAT_NUM_ONLY, divideByTen = true},
};

local targetHealthFormatInfo = {
	{formatStr = CAA_SAY_HEALTH_FORMAT_FULL},
	{formatStr = CAA_SAY_HEALTH_FORMAT_NO_PERCENT},
	{formatStr = CAA_SAY_HEALTH_FORMAT_NO_PERCENT, divideByTen = true},
	{formatStr = CAA_SAY_HEALTH_FORMAT_NO_HEALTH},
	{formatStr = CAA_SAY_HEALTH_FORMAT_NUM_ONLY},
	{formatStr = CAA_SAY_HEALTH_FORMAT_NUM_ONLY, divideByTen = true},
	{formatStr = CAA_SAY_TARGET_HEALTH_FORMAT_FULL},
	{formatStr = CAA_SAY_TARGET_HEALTH_FORMAT_NO_PERCENT},
	{formatStr = CAA_SAY_TARGET_HEALTH_FORMAT_NO_PERCENT, divideByTen = true},
};

local playerCastFormatInfo = {
	{formatStr = CAA_SAY_CASTS_FORMAT_FULL},
	{formatStr = CAA_SAY_CASTS_FORMAT_SHORT},
	{formatStr = CAA_SAY_CASTS_FORMAT_NO_SPELLNAME, noValue = true},
	{formatStr = CAA_SAY_CASTS_FORMAT_SHORT_NO_SPELLNAME, noValue = true},
	{formatStr = CAA_SAY_CASTS_FORMAT_SPELLNAME_ONLY},
};

local targetCastFormatInfo = {
	{formatStr = CAA_SAY_TARGET_CASTS_FORMAT_FULL},
	{formatStr = CAA_SAY_TARGET_CASTS_FORMAT_SHORT},
	{formatStr = CAA_SAY_CASTS_FORMAT_FULL},
	{formatStr = CAA_SAY_CASTS_FORMAT_SHORT},
	{formatStr = CAA_SAY_CASTS_FORMAT_NO_SPELLNAME, noValue = true},
	{formatStr = CAA_SAY_CASTS_FORMAT_SHORT_NO_SPELLNAME, noValue = true},
	{formatStr = CAA_SAY_CASTS_FORMAT_SPELLNAME_ONLY},
};

local unitFormatInfo = {
	["player"] = {
		[Enum.CombatAudioAlertType.Health] = playerHealthFormatInfo,
		[Enum.CombatAudioAlertType.Cast] = playerCastFormatInfo,
	},

	["target"] = {
		[Enum.CombatAudioAlertType.Health] = targetHealthFormatInfo,
		[Enum.CombatAudioAlertType.Cast] = targetCastFormatInfo,
	},
};

local unitThrottleInfo = {
	["player"] = {
		[Enum.CombatAudioAlertType.Health] = Enum.CombatAudioAlertThrottle.PlayerHealth,
		[Enum.CombatAudioAlertType.Cast] = Enum.CombatAudioAlertThrottle.PlayerCast,
	},

	["target"] = {
		[Enum.CombatAudioAlertType.Health] = Enum.CombatAudioAlertThrottle.TargetHealth,
		[Enum.CombatAudioAlertType.Cast] = Enum.CombatAudioAlertThrottle.TargetCast,
	},
};

local playerResourceFormatInfo = {
	{formatStr = CAA_SAY_RESOURCE_FORMAT_FULL},
	{formatStr = CAA_SAY_RESOURCE_FORMAT_NO_PERCENT,},
	{formatStr = CAA_SAY_RESOURCE_FORMAT_NO_PERCENT, divideByTen = true},
	{formatStr = CAA_SAY_RESOURCE_FORMAT_NO_RESOURCE, noStringValue = true},
	{formatStr = CAA_SAY_RESOURCE_FORMAT_NUM_ONLY, noStringValue = true},
	{formatStr = CAA_SAY_RESOURCE_FORMAT_NUM_ONLY, noStringValue = true, divideByTen = true},
};

local playerResourceThrottleInfo = {
	[Enum.CombatAudioAlertType.Health] = Enum.CombatAudioAlertThrottle.PlayerHealth,
	[Enum.CombatAudioAlertType.Cast] = Enum.CombatAudioAlertThrottle.PlayerCast,
};

function CombatAudioAlertUtil.GetPercentInfo(cvarVal)
	return percentInfo[cvarVal + 1];
end

function CombatAudioAlertUtil.EnumeratePercentInfo()
	return ipairs(percentInfo);
end

function CombatAudioAlertUtil.GetPartyHealthPercentInfo(cvarVal)
	return partyHealthPercentInfo[cvarVal + 1];
end

function CombatAudioAlertUtil.GetCurrentPartyHealthPercentInfo()
	local cvarVal = CombatAudioAlertUtil.GetCAACvarValueNumber("PARTY_HEALTH_PCT_CVAR");
	return CombatAudioAlertUtil.GetPartyHealthPercentInfo(cvarVal);
end

function CombatAudioAlertUtil.EnumeratePartyHealthPercentInfo()
	return ipairs(partyHealthPercentInfo);
end

function CombatAudioAlertUtil.GetSayIfTargetedInfo(cvarVal)
	return sayIfTargetedInfo[cvarVal + 1];
end

function CombatAudioAlertUtil.EnumerateSayIfTargetedInfo()
	return ipairs(sayIfTargetedInfo);
end

function CombatAudioAlertUtil.GetSayCastInfo(cvarVal)
	return sayCastInfo[cvarVal + 1];
end

function CombatAudioAlertUtil.EnumerateSayCastInfo()
	return ipairs(sayCastInfo);
end

function CombatAudioAlertUtil.EnumerateUnitFormatInfo(unit, alertType)
	local formatInfoTbl = unitFormatInfo[unit][alertType];
	return ipairs(formatInfoTbl);
end

function CombatAudioAlertUtil.EnumeratePlayerResourceFormatInfo()
	return ipairs(playerResourceFormatInfo);
end

function CombatAudioAlertUtil.GetUnitThrottleType(unit, alertType)
	return unitThrottleInfo[unit][alertType];
end

function CombatAudioAlertUtil.ConvertToAlertUnitEnum(unit)
	if type(unit) == "number" then
		return unit;
	else
		if unit == "player" then
			return Enum.CombatAudioAlertUnit.Player;
		elseif unit == "target" then
			return Enum.CombatAudioAlertUnit.Target;
		else
			error("Invalid unit passed to ConvertUnitToAlertUnit");
		end
	end
end

function CombatAudioAlertUtil.GetUnitFormatCVarVal(unit, alertType)
	local unitEnum = CombatAudioAlertUtil.ConvertToAlertUnitEnum(unit);
	return C_CombatAudioAlert.GetFormatSetting(unitEnum, alertType);
end

function CombatAudioAlertUtil.GetUnitFormatInfo(unit, alertType)
	local formatInfoTbl = unitFormatInfo[unit][alertType];
	local cvarVal = CombatAudioAlertUtil.GetUnitFormatCVarVal(unit, alertType);
	return formatInfoTbl[cvarVal + 1];
end

function CombatAudioAlertUtil.GetUnitFormattedString(unit, alertType, stringVal, numberVal)
	local formatInfo = CombatAudioAlertUtil.GetUnitFormatInfo(unit, alertType);
	return CombatAudioAlertUtil.GetFormattedString(formatInfo, stringVal, numberVal);
end

function CombatAudioAlertUtil.IsPlayerResource1(powerTypeOrToken)
	local resource1PowerType, resource1PowerToken = UnitPowerType("player");
	if type(powerTypeOrToken) == "number" then
		return (powerTypeOrToken == resource1PowerType);
	else
		return (powerTypeOrToken == resource1PowerToken);
	end
end

function CombatAudioAlertUtil.GetResourceThrottleType(powerTypeOrToken)
	if CombatAudioAlertUtil.IsPlayerResource1(powerTypeOrToken) then
		return Enum.CombatAudioAlertThrottle.PlayerResource1;
	else
		return Enum.CombatAudioAlertThrottle.PlayerResource2;
	end
end

function CombatAudioAlertUtil.ConvertToResourceSettingEnum(powerTypeOrToken, isPercent)
	if CombatAudioAlertUtil.IsPlayerResource1(powerTypeOrToken) then
		return isPercent and Enum.CombatAudioAlertSpecSetting.Resource1Percent or Enum.CombatAudioAlertSpecSetting.Resource1Format;
	else
		return isPercent and Enum.CombatAudioAlertSpecSetting.Resource2Percent or Enum.CombatAudioAlertSpecSetting.Resource2Format;
	end
end

function CombatAudioAlertUtil.GetResourcePercentCVarVal(powerTypeOrToken)
	local isPercentYes = true;
	local settingEnum = CombatAudioAlertUtil.ConvertToResourceSettingEnum(powerTypeOrToken, isPercentYes);
	return C_CombatAudioAlert.GetSpecSetting(settingEnum);
end

function CombatAudioAlertUtil.GetResourceFormatCVarVal(powerTypeOrToken)
	local isPercentNo = false;
	local settingEnum = CombatAudioAlertUtil.ConvertToResourceSettingEnum(powerTypeOrToken, isPercentNo);
	return C_CombatAudioAlert.GetSpecSetting(settingEnum);
end

function CombatAudioAlertUtil.GetPlayerResourceFormatInfoFromCVarVal(cvarVal)
	return playerResourceFormatInfo[cvarVal + 1];
end

function CombatAudioAlertUtil.GetPlayerResourceFormatInfo(powerTypeOrToken)
	local cvarVal = CombatAudioAlertUtil.GetResourceFormatCVarVal(powerTypeOrToken);
	return playerResourceFormatInfo[cvarVal + 1];
end

function CombatAudioAlertUtil.GetPlayerResourceFormattedString(powerTypeOrToken, stringVal, numberVal)
	local formatInfo = CombatAudioAlertUtil.GetPlayerResourceFormatInfo(powerTypeOrToken);
	return CombatAudioAlertUtil.GetFormattedString(formatInfo, stringVal, numberVal);
end

function CombatAudioAlertUtil.GetCAACvarValueNumber(cvarConstant)
	return CVarCallbackRegistry:GetCVarNumberOrDefault(CombatAudioAlertConstants.CVars[cvarConstant].name);
end

function CombatAudioAlertUtil.GetCAACVarValueBool(cvarConstant)
	return CVarCallbackRegistry:GetCVarValueBool(CombatAudioAlertConstants.CVars[cvarConstant].name);
end

