local function GetShouldShowDebugTooltipInfo()
	return GetCVarBool("debugTargetInfo");
end
local showDebugTooltipInfo = GetShouldShowDebugTooltipInfo();

CustomizationUtil = {};

function CustomizationUtil.UpdateShowDebugTooltipInfo()
	showDebugTooltipInfo = GetShouldShowDebugTooltipInfo();
end

function CustomizationUtil.ShouldShowDebugTooltipInfo()
	return showDebugTooltipInfo;
end