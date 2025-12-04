EncounterWarningsUtil = {};

function EncounterWarningsUtil.GetSeverityFromSystemIndex(systemIndex)
	return EncounterWarningsSystemSeverity[systemIndex];
end

function EncounterWarningsUtil.GetFontObjectForSeverity(severity)
	return GetValueOrCallFunction(EncounterWarningsSeverityFonts, severity);
end

function EncounterWarningsUtil.GetTextColorForSeverity(severity)
	return GetValueOrCallFunction(EncounterWarningsSeverityColors, severity);
end

function EncounterWarningsUtil.GetMaximumTextSizeForSeverity(severity)
	return GetValueOrCallFunction(EncounterWarningsSeverityTextSizeLimits, severity);
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

function EncounterWarningsUtil.GenerateChatMessageIconMarkup(iconFileID)
	local width = EncounterWarningsConstants.ChatMessageIconDisplaySize;
	local height = EncounterWarningsConstants.ChatMessageIconDisplaySize;
	return CreateSimpleTextureMarkup(iconFileID, width, height);
end

function EncounterWarningsUtil.ShowChatMessageForWarning(encounterWarningInfo)
	local iconTextureMarkup = EncounterWarningsUtil.GenerateChatMessageIconMarkup(encounterWarningInfo.iconFileID);
	local formattedMessage = string.join(" ", iconTextureMarkup, encounterWarningInfo.text);
	local chatType = ChatTypeInfo["RAID_BOSS_EMOTE"];

	DEFAULT_CHAT_FRAME:AddMessage(formattedMessage, chatType.r, chatType.g, chatType.b, chatType.id);
end