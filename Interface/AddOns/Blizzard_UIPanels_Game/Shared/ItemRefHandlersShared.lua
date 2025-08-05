local function HandleBNPlayerLink(link, text, linkData, contextData)
	local name, bnetIDAccount, lineID, chatType, chatTarget, communityClubID, communityStreamID, communityEpoch, communityPosition;
	if ( linkData.type == LinkTypes.BNPlayerCommunity ) then
		name, bnetIDAccount, communityClubID, communityStreamID, communityEpoch, communityPosition = string.split(":", linkData.options);
	else
		name, bnetIDAccount, lineID, chatType, chatTarget = string.split(":", linkData.options);
	end
	if ( name and (string.len(name) > 0) ) then
		if ( IsModifiedClick("CHATLINK") ) then
			-- Disable SHIFT-CLICK for battlenet friends, so we don't put an encoded bnetIDAccount in chat
		elseif ( contextData.button == "RightButton" ) then
			if ( isCommunityLink or not BNIsSelf(bnetIDAccount) ) then
				FriendsFrame_ShowBNDropdown(name, 1, nil, chatType, contextData.frame, nil, bnetIDAccount, communityClubID, communityStreamID, communityEpoch, communityPosition);
			end
		else
			if ( BNIsFriend(bnetIDAccount)) then
				ChatFrame_SendBNetTell(name);
			else
				local displayName = BNGetDisplayName(bnetIDAccount);
				ChatFrame_SendBNetTell(displayName)
			end
		end
	end
end

LinkUtil.RegisterLinkHandler(LinkTypes.BNPlayer, HandleBNPlayerLink);
LinkUtil.RegisterLinkHandler(LinkTypes.BNPlayerCommunity, HandleBNPlayerLink);

LinkUtil.RegisterLinkHandler(LinkTypes.Channel, function(link, text, linkData, contextData)
	if ( IsModifiedClick("CHATLINK") ) then
		ChannelFrame:Toggle();
	elseif ( contextData.button == "LeftButton" ) then
		local chatType, chatTarget = string.split(":", linkData.options);

		if ( string.upper(chatType) == "CHANNEL" ) then
			if ( GetChannelName(tonumber(chatTarget))~=0 ) then
				ChatFrame_OpenChat("/"..chatTarget, contextData.frame);
			end
		elseif ( string.upper(chatType) == "PET_BATTLE_COMBAT_LOG" or string.upper(chatType) == "PET_BATTLE_INFO" ) then
			--Don't do anything
		else
			ChatFrame_OpenChat("/"..chatType, contextData.frame);
		end
	elseif ( contextData.button == "RightButton" ) then
		local chatType, chatTarget = string.split(":", linkData.options);
		if not ( (string.upper(chatType) == "CHANNEL" and GetChannelName(tonumber(chatTarget)) == 0) ) then	--Don't show the dropdown if this is a channel we are no longer in.
			ChatChannelDropdown_Show(contextData.frame, string.upper(chatType), chatTarget, Chat_GetColoredChatName(string.upper(chatType), chatTarget));
		end
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.GMChat, function(link, text, linkData, contextData)
	GMChatStatusFrame_OnClick();
end);

LinkUtil.RegisterLinkHandler(LinkTypes.PvPUI, function(link, text, linkData, contextData)
	TogglePVPUI();
end);

LinkUtil.RegisterLinkHandler(LinkTypes.GroupFinderUI, function(link, text, linkData, contextData)
	ToggleLFDParentFrame();
end);

LinkUtil.RegisterLinkHandler(LinkTypes.WorldQuest, function(link, text, linkData, contextData)
	OpenWorldMap();
end);

LinkUtil.RegisterLinkHandler(LinkTypes.BattlePetAbility, function(link, text, linkData, contextData)
	local abilityID, maxHealth, power, speed = string.split(":", linkData.options);
	if ( IsModifiedClick() ) then
		local fixedLink = GetFixedLink(text);
		HandleModifiedItemClick(fixedLink);
	else
		FloatingPetBattleAbility_Show(tonumber(abilityID), tonumber(maxHealth), tonumber(power), tonumber(speed));
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.GarrisonFollowerAbility, function(link, text, linkData, contextData)
	local garrFollowerAbilityID = string.split(":", linkData.options);

	if ( IsModifiedClick("CHATLINK") ) then
		local _, abilityID = strsplit(":", link);
		local abilLink = C_Garrison.GetFollowerAbilityLink(abilityID);
		ChatEdit_InsertLink (abilLink);
	elseif ( IsModifiedClick() ) then
		local fixedLink = GetFixedLink(text);
		HandleModifiedItemClick(fixedLink);
	else
		FloatingGarrisonFollowerAbility_Toggle(tonumber(garrFollowerAbilityID));
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.GarrisonFollower, function(link, text, linkData, contextData)
	local garrisonFollowerID, quality, level, itemLevel, ability1, ability2, ability3, ability4, trait1, trait2, trait3, trait4, spec1 = string.split(":", linkData.options);
	if ( IsModifiedClick() ) then
		local fixedLink = GetFixedLink(text, tonumber(quality));
		HandleModifiedItemClick(fixedLink);
	else
		FloatingGarrisonFollower_Toggle(tonumber(garrisonFollowerID), tonumber(quality), tonumber(level), tonumber(itemLevel), tonumber(spec1), tonumber(ability1), tonumber(ability2), tonumber(ability3), tonumber(ability4), tonumber(trait1), tonumber(trait2), tonumber(trait3), tonumber(trait4));
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.GarrisonMission, function(link, text, linkData, contextData)
	local garrMissionID, garrMissionDBID = link:match("garrmission:(%d+):([0-9a-fA-F]+)")
	if (garrMissionID and garrMissionDBID and string.len(garrMissionDBID) == 16) then
		if ( IsModifiedClick() ) then
			local fixedLink = GetFixedLink(text);
			HandleModifiedItemClick(fixedLink);
		else
			FloatingGarrisonMission_Toggle(tonumber(garrMissionID), "0x"..(garrMissionDBID:upper()));
		end
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.DeathRecap, function(link, text, linkData, contextData)
	local id = string.split(":", linkData.options);
	OpenDeathRecapUI(id);
end);

LinkUtil.RegisterLinkHandler(LinkTypes.TransmogIllusion, function(link, text, linkData, contextData)
	local fixedLink = GetFixedLink(text);
	if ( not HandleModifiedItemClick(fixedLink) ) then
		DressUpTransmogLink(link);
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.APIDocumentation, function(link, text, linkData, contextData)
	APIDocumentation_LoadUI();

	local command = APIDocumentation.Commands.Default;
	if contextData.button == "RightButton" then
		command = APIDocumentation.Commands.CopyAPI;
	elseif IsModifiedClick("CHATLINK") then
		command = APIDocumentation.Commands.OpenDump;
	end

	APIDocumentation:HandleAPILink(link, command);
end);

LinkUtil.RegisterLinkHandler(LinkTypes.Item, function(link, text, linkData, contextData)
	if ( IsModifiedClick("CHATLINK") and contextData.button == "LeftButton" ) then
		local name, itemLink = C_Item.GetItemInfo(text);
		if ChatEdit_InsertLink(itemLink) then
			return;
		end
	end

	return LinkProcessorResponse.Unhandled;
end);

LinkUtil.RegisterLinkHandler(LinkTypes.ClubTicket, function(link, text, linkData, contextData)
	if ( IsModifiedClick("CHATLINK") and contextData.button == "LeftButton" ) then
		if ChatEdit_InsertLink(text) then
			return;
		end
	end
	local ticketId = string.split(":", linkData.options);
	if ( CommunitiesFrame_IsEnabled() ) then
		CommunitiesHyperlink.OnClickLink(ticketId);
	end
end);

local function GetLineIDFromChatMsgEventArgs(eventArgs)
	return eventArgs and eventArgs[11];
end

local function DoesEventArgsMatchLineID(eventArgs, hyperlinkLineID)
	local lineID = GetLineIDFromChatMsgEventArgs(eventArgs);
	return lineID == hyperlinkLineID;
end

LinkUtil.RegisterLinkHandler(LinkTypes.CensoredMessage, function(link, text, linkData, contextData)
	local hyperlinkLineID = tonumber(LinkUtil.SplitLinkOptions(linkData.options));

	-- Uncensor this line so that the original text can be retrieved from C_ChatInfo.GetChatLineText.
	C_ChatInfo.UncensorChatLine(hyperlinkLineID);

	local function DoesMessageLineIDMatch(message, r, g, b, infoID, accessID, typeID, event, eventArgs)
		return DoesEventArgsMatchLineID(eventArgs, hyperlinkLineID);
	end

	local _event = nil;
	local _eventArgs = nil;
	local function SetMessage(message, r, g, b, infoID, accessID, typeID, event, eventArgs, MessageFormatter, ...)
		local lineID = eventArgs[11];

		-- Original text is routed through the tts system, which prepends the message with "<player whispers> text.
		local text = C_ChatInfo.GetChatLineText(lineID);
		local formatArg = MessageFormatter(text);
		local formattedText = CENSORED_MESSAGE_REPORT:format(formatArg, lineID);

		_event = event;
		_eventArgs = eventArgs;
		-- The tts handler should only include the original text, not the formatted text; what is displayed is not the
		-- same as what is spoken.
		_eventArgs[1] = text;
		return formattedText, r, g, b, infoID, accessID, typeID, event, eventArgs, MessageFormatter, ...;
	end

	-- The line may be present in multiple chat windows, particularly if chat settings are configured to
	-- send the line to both the default chat window and a whisper tab.
	ChatFrameUtil.ForEachChatFrame(function(chatFrame)
		chatFrame:TransformMessages(DoesMessageLineIDMatch, SetMessage);
	end);

	-- If we captured event and eventArgs in SetMessage, then we successfully replaced the message and need to route it
	-- through tts.
	if _event and _eventArgs then
		TextToSpeechFrame_MessageEventHandler(chatFrame, _event, SafeUnpack(_eventArgs));
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.CensoredMessageRewrite, function(link, text, linkData, contextData)
	-- Expected hyperlink: censoredmessagerewrite:%d:%d:%s
	local hyperlinkLineID, confirmNumber, sendTo = LinkUtil.SplitLinkOptions(linkData.options);
	hyperlinkLineID = tonumber(hyperlinkLineID);
	confirmNumber = tonumber(confirmNumber);

	C_ChatInfo.DropCautionaryChatMessage(confirmNumber);

	local function DoesMessageLineIDMatch(message, r, g, b, infoID, accessID, typeID, event, eventArgs)
		return DoesEventArgsMatchLineID(eventArgs, hyperlinkLineID);
	end

	-- The line may be present in multiple chat windows, particularly if chat settings are configured to
	-- send the line to both the default chat window and a whisper tab.
	ChatFrameUtil.ForEachChatFrame(function(chatFrame)
		chatFrame:RemoveMessagesByPredicate(DoesMessageLineIDMatch);
	end);

	local chatFrame = contextData.frame;
	if chatFrame then
		local originalText = C_ChatInfo.GetChatLineText(hyperlinkLineID);
		ChatFrame_SendTellWithMessage(sendTo, originalText, chatFrame);
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.CensoredMessageConfirmSend, function(link, text, linkData, contextData)
	-- Expected hyperlink: censoredmessageconfirmsend:%d:%d:%s
	local hyperlinkLineID, confirmNumber, sendTo = LinkUtil.SplitLinkOptions(linkData.options);
	hyperlinkLineID = tonumber(hyperlinkLineID);
	confirmNumber = tonumber(confirmNumber);

	C_ChatInfo.SendCautionaryChatMessage(confirmNumber);

	local function DoesMessageLineIDMatch(message, r, g, b, infoID, accessID, typeID, event, eventArgs)
		return DoesEventArgsMatchLineID(eventArgs, hyperlinkLineID);
	end

	local function SetMessage(message, r, g, b, infoID, accessID, typeID, event, eventArgs, MessageFormatter, ...)
		local lineID = GetLineIDFromChatMsgEventArgs(eventArgs);
		local text = C_ChatInfo.GetChatLineText(lineID);
		local formatArg = MessageFormatter(text);
		local formattedText = CENSORED_MESSAGE_SENT:format(formatArg);
		return formattedText, r, g, b, infoID, accessID, typeID, event, eventArgs, MessageFormatter, ...;
	end

	-- The line may be present in multiple chat windows, particularly if chat settings are configured to
	-- send the line to both the default chat window and a whisper tab.
	ChatFrameUtil.ForEachChatFrame(function(chatFrame)
		chatFrame:TransformMessages(DoesMessageLineIDMatch, SetMessage);
	end);
end);

LinkUtil.RegisterLinkHandler(LinkTypes.AddOn, function(link, text, linkData, contextData)
	-- local links only
	EventRegistry:TriggerEvent("SetItemRef", link, text, contextData.button, contextData.frame);
end);
