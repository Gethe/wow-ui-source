EncounterWarningsUtil = {};

function EncounterWarningsUtil.GetSeverityFromSystemIndex(systemIndex)
	return EncounterWarningsSystemSeverity[systemIndex];
end

function EncounterWarningsUtil.GetDefaultFontObject(severity)
	return GetValueOrCallFunction(EncounterWarningsSeverityFonts, severity);
end

function EncounterWarningsUtil.GetDefaultTextColor(severity)
	return GetValueOrCallFunction(EncounterWarningsSeverityColors, severity);
end

function EncounterWarningsUtil.GetDefaultMaximumTextHeight(severity)
	local textSizeLimits = GetValueOrCallFunction(EncounterWarningsSeverityTextSizeLimits, severity);
	return textSizeLimits and textSizeLimits.height or nil;
end

function EncounterWarningsUtil.GetDefaultMaximumTextWidth(severity)
	local textSizeLimits = GetValueOrCallFunction(EncounterWarningsSeverityTextSizeLimits, severity);
	return textSizeLimits and textSizeLimits.width or nil;
end

function EncounterWarningsUtil.GetClassColoredTargetName(encounterWarningInfo)
	local formattedTargetName = encounterWarningInfo.targetName;

	if encounterWarningInfo.targetGUID ~= nil then
		local className = GetPlayerInfoByGUID(encounterWarningInfo.targetGUID);
		local classColor = GetClassColorObj(className);

		if classColor ~= nil then
			formattedTargetName = classColor:WrapTextInColorCode(formattedTargetName);
		end
	end

	return formattedTargetName;
end

function EncounterWarningsUtil.ShouldShowFrameForSystem(systemIndex)
	if not CVarCallbackRegistry:GetCVarValueBool("encounterWarningsEnabled") then
		return false;
	end

	local minimumSeverity = CVarCallbackRegistry:GetCVarNumberOrDefault("encounterWarningsLevel");
	local systemSeverity = EncounterWarningsUtil.GetSeverityFromSystemIndex(systemIndex);

	return systemSeverity >= minimumSeverity;
end

function EncounterWarningsUtil.ShowChatMessageForWarning(encounterWarningInfo)
	-- EETODO: Clean this up; should also be a globalstring rather than a basic join.
	local iconTextureMarkup = CreateTextureMarkup(encounterWarningInfo.iconFileID, 64, 64, 20, 20, 0, 1, 0, 1, 0, 0);
	local formattedMessage = string.join(" ", iconTextureMarkup, encounterWarningInfo.text);

	ChatFrameUtil.DisplaySystemMessageInPrimary(formattedMessage);
end
