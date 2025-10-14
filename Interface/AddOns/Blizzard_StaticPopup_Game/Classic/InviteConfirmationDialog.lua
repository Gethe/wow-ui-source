-- Shared invitation confirmation behavior

function UpdateInviteConfirmationDialogs()
	if ( StaticPopup_FindVisible("GROUP_INVITE_CONFIRMATION") ) then
		return;
	end

	local firstInvite = GetNextPendingInviteConfirmation();
	if ( not firstInvite ) then
		return;
	end

	local confirmationType, name, guid, roles, willConvertToRaid = GetInviteConfirmationInfo(firstInvite);
	local text = "";
	if ( confirmationType == LE_INVITE_CONFIRMATION_REQUEST ) then
		local suggesterGuid, suggesterName, relationship, isQuickJoin = GetInviteReferralInfo(firstInvite);

		local playerLink = GetPlayerLink(name, name);
		local safeLink = playerLink and "["..playerLink.."]" or name;

		if ( isQuickJoin ) then
			text = text..string.format(INVITE_CONFIRMATION_REQUEST_GROUPFINDER, FRIENDS_WOW_NAME_COLOR_CODE..safeLink..FONT_COLOR_CODE_CLOSE);
		else
			text = text..string.format(INVITE_CONFIRMATION_REQUEST, name);
		end
	elseif ( confirmationType == LE_INVITE_CONFIRMATION_SUGGEST ) then
		local suggesterGuid, suggesterName, relationship, isQuickJoin = GetInviteReferralInfo(firstInvite);
		text = text..string.format(INVITE_CONFIRMATION_SUGGEST, suggesterName, name);
	elseif ( confirmationType == LE_INVITE_CONFIRMATION_QUEUE_WARNING ) then
		local warnings = CreatePendingInviteConfirmationText_GetWarnings(firstInvite, name, guid);
		if warnings ~= "" then
			if text ~= "" then
				text = text.."\n\n"..warnings;
			else
				text = warnings;
			end
		end
	end

	if ( willConvertToRaid ) then
		text = text.."\n\n"..RED_FONT_COLOR_CODE..LFG_LIST_CONVERT_TO_RAID_WARNING..FONT_COLOR_CODE_CLOSE;
	end

	StaticPopup_Show("GROUP_INVITE_CONFIRMATION", text, nil, firstInvite);
end

function CreatePendingInviteConfirmationText_GetWarnings(invite, name, guid)
	local warnings = {};
	local invalidQueues = C_PartyInfo.GetInviteConfirmationInvalidQueues(invite);
	if invalidQueues and #invalidQueues > 0 then
		table.insert(warnings, INVITE_CONFIRMATION_QUEUE_WARNING:format(name));

		for i=1, #invalidQueues do
			local queueName = SocialQueueUtil_GetQueueName(invalidQueues[i]);
			table.insert(warnings, NORMAL_FONT_COLOR:WrapTextInColorCode(queueName));
		end
	end

	return table.concat(warnings, "\n");
end
