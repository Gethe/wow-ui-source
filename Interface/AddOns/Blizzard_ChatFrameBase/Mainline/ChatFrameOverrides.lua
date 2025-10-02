function ChatFrameMixin:OnLoad()
	self:SetTimeVisible(120.0);
	self:SetMaxLines(128);
	self:SetFontObject(ChatFontNormal);
	self:SetIndentedWordWrap(true);
	self:SetJustifyH("LEFT");

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("SETTINGS_LOADED");
	self:RegisterEvent("UPDATE_CHAT_COLOR");
	self:RegisterEvent("UPDATE_CHAT_WINDOWS");
	self:RegisterEvent("CHAT_MSG_CHANNEL");
	self:RegisterEvent("CHAT_MSG_COMMUNITIES_CHANNEL");
	self:RegisterEvent("CLUB_REMOVED");
	self:RegisterEvent("UPDATE_INSTANCE_INFO");
	self:RegisterEvent("UPDATE_CHAT_COLOR_NAME_BY_CLASS");
	self:RegisterEvent("CHAT_SERVER_DISCONNECTED");
	self:RegisterEvent("CHAT_SERVER_RECONNECTED");
	self:RegisterEvent("BN_CONNECTED");
	self:RegisterEvent("BN_DISCONNECTED");
	self:RegisterEvent("PLAYER_REPORT_SUBMITTED");
	self:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT");
	self:RegisterEvent("ALTERNATIVE_DEFAULT_LANGUAGE_CHANGED");
	self:RegisterEvent("NEWCOMER_GRADUATION");
	self:RegisterEvent("CHAT_REGIONAL_STATUS_CHANGED");
	self:RegisterEvent("CHAT_REGIONAL_SEND_FAILED");
	self:RegisterEvent("NOTIFY_CHAT_SUPPRESSED");
	self:RegisterEvent("CAUTIONARY_CHAT_MESSAGE");

	self.channelList = {};
	self.zoneChannelList = {};
	self.messageTypeList = {};

	local function OnValueChanged(o, setting, value)
		ChatFrameUtil.UpdateChatFrames();
	end
	Settings.SetOnValueChangedCallback("chatStyle", OnValueChanged);

	local noMouseWheel = not GetCVarBool("chatMouseScroll");
	ScrollUtil.InitScrollingMessageFrameWithScrollBar(self, self.ScrollBar, noMouseWheel);

	-- Scroll bar alpha is managed by a cursor test over the chat frame. Set the initial alpha to 0
	-- so this doesn't appear before the cursor test ever passes. See FCF_FadeInScrollbar and
	-- FCF_FadeOutScrollbar.
	self.ScrollBar:SetAlpha(0);
end


local function ChatFrame_CheckAddChannel(chatFrame, eventType, channelID)
	-- This is called in the event that a user receives chat events for a channel that isn't enabled for any chat frames.
	-- Minor hack, because chat channel filtering is backed by the client, but driven entirely from Lua.
	-- This solves the issue of Guides abdicating their status, and then re-applying in the same game session, unless ChatFrame_AddChannel
	-- is called, the channel filter will be off even though it's still enabled in the client, since abdication removes the chat channel and its config.

	-- Only add to default (since multiple chat frames receive the event and we don't want to add to others)
	if chatFrame ~= DEFAULT_CHAT_FRAME then
		return false;
	end

	-- Only add if the user is joining a channel
	if eventType ~= "YOU_CHANGED" then
		return false;
	end

	-- Only add regional channels
	if not C_ChatInfo.IsChannelRegionalForChannelID(channelID) then
		return false;
	end

	return chatFrame:AddChannel(C_ChatInfo.GetChannelShortcutForChannelID(channelID)) ~= nil;
end

local function ShouldAddRecentAllyIconToName(frameChatType, senderGUID)
	local isWhisper = (frameChatType == "WHISPER");
	-- Don't add the icon if the chat frame is a whisper window
	if not senderGUID or isWhisper then
		return false;
	end 

	return C_RecentAllies.IsRecentAllyByGUID(senderGUID);
end

function ChatFrameMixin:ConfigEventHandler(event, ...)
	if C_Glue.IsOnGlueScreen() and not C_GameRules.IsGameRuleActive(Enum.GameRule.FrontEndChat) then
		return;
	end

	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self.defaultLanguage = GetDefaultLanguage();
		self.alternativeDefaultLanguage = GetAlternativeDefaultLanguage();

		if self == DEFAULT_CHAT_FRAME then
			self.editBox:UpdateNewcomerEditBoxHint();

			local isInitialLogin, isUIReload = ...;
			if isInitialLogin then
				C_Timer.After(3, ChatFrameUtil.CheckShowNewcomerGraduation);
			end
		end
		return true;
	elseif ( event == "SETTINGS_LOADED" ) then
		ChatFrameUtil.UpdateChatFrames();
	elseif ( event == "NEUTRAL_FACTION_SELECT_RESULT" ) then
		self.defaultLanguage = GetDefaultLanguage();
		self.alternativeDefaultLanguage = GetAlternativeDefaultLanguage();
		return true;
	elseif ( event == "ALTERNATIVE_DEFAULT_LANGUAGE_CHANGED" ) then
		self.alternativeDefaultLanguage = GetAlternativeDefaultLanguage();
		return true;
	elseif ( event == "NEWCOMER_GRADUATION" ) then
		local isFromEvent = true;
		ChatFrameUtil.CheckShowNewcomerGraduation(isFromEvent);
		return true;
	elseif ( event == "UPDATE_CHAT_WINDOWS" ) then
		local name, fontSize, r, g, b, a, shown, locked = FCF_GetChatWindowInfo(self:GetID());
		if ( fontSize > 0 ) then
			local fontFile, unused, fontFlags = self:GetFont();
			self:SetFont(fontFile, fontSize, fontFlags);
		end
		if ( shown and not self.minimized ) then
			self:Show();
		end
		-- UPDATE_CHAT_WINDOWS can be received before settings have been downloaded, so reset current state.
		self:UnregisterAllMessageGroups();
		self:RegisterForMessages(GetChatWindowMessages(self:GetID()));
		self:RegisterForChannels(GetChatWindowChannels(self:GetID()));

		self:UpdateDefaultChatTarget();

		if not C_Glue.IsOnGlueScreen() then
			-- GMOTD may have arrived before this frame registered for the event
			if ( not self.checkedGMOTD and self:IsEventRegistered("GUILD_MOTD") ) then
				self.checkedGMOTD = true;
				ChatFrameUtil.DisplayGMOTD(self, GetGuildRosterMOTD());
			end
		end
		return true;
	end

	local arg1, arg2, arg3, arg4 = ...;
	if ( event == "UPDATE_CHAT_COLOR" ) then
		local info = ChatTypeInfo[strupper(arg1)];
		if ( info ) then
			info.r = arg2;
			info.g = arg3;
			info.b = arg4;
			self:UpdateColorByID(info.id, info.r, info.g, info.b);

			if ( strupper(arg1) == "WHISPER" ) then
				info = ChatTypeInfo["REPLY"];
				if ( info ) then
					info.r = arg2;
					info.g = arg3;
					info.b = arg4;
					self:UpdateColorByID(info.id, info.r, info.g, info.b);
				end
			end
		end
		return true;
	elseif ( event == "UPDATE_CHAT_COLOR_NAME_BY_CLASS" ) then
		local info = ChatTypeInfo[strupper(arg1)];
		if ( info ) then
			info.colorNameByClass = arg2;
			if ( strupper(arg1) == "WHISPER" ) then
				info = ChatTypeInfo["REPLY"];
				if ( info ) then
					info.colorNameByClass = arg2;
				end
			end
		end
		return true;
	end
end

local function GetRegionalChatAvailableString()
	return DoesActivePlayerHaveMentorStatus() and NPEV2_CHAT_AVAILABLE or NPEV2_REGIONAL_CHAT_AVAILABLE;
end

local function GetRegionalChatUnavailableString()
	return DoesActivePlayerHaveMentorStatus() and NPEV2_CHAT_UNAVAILABLE or NPEV2_REGIONAL_CHAT_UNAVAILABLE;
end

function ChatFrameMixin:SystemEventHandler(event, ...)
	if ( event == "TIME_PLAYED_MSG" ) then
		local arg1, arg2 = ...;
		ChatFrameUtil.DisplayTimePlayed(self, arg1, arg2);
		return true;
	elseif ( event == "PLAYER_LEVEL_CHANGED" ) then
		local oldLevel, newLevel, real = ...;
		ChatFrameUtil.DisplayLevelUp(self, oldLevel, newLevel, real);
		return true;
	elseif ( event == "GUILD_MOTD" ) then
		ChatFrameUtil.DisplayGMOTD(self, ...);
		return true;
	elseif ( event == "UPDATE_INSTANCE_INFO" ) then
		if ( RaidFrame.hasRaidInfo ) then
			local info = ChatTypeInfo["SYSTEM"];
			if ( RaidFrame.slashCommand and GetNumSavedInstances() + GetNumSavedWorldBosses() == 0 and self == DEFAULT_CHAT_FRAME) then
				self:AddMessage(NO_RAID_INSTANCES_SAVED, info.r, info.g, info.b, info.id);
				RaidFrame.slashCommand = nil;
			end
		end
		return true;
	elseif ( event == "CHAT_SERVER_DISCONNECTED" ) then
		local info = ChatTypeInfo["SYSTEM"];
		local isInitialMessage = ...;
		self:AddMessage(CHAT_SERVER_DISCONNECTED_MESSAGE, info.r, info.g, info.b, info.id);
		return true;
	elseif ( event == "CHAT_SERVER_RECONNECTED" ) then
		local info = ChatTypeInfo["SYSTEM"];
		self:AddMessage(CHAT_SERVER_RECONNECTED_MESSAGE, info.r, info.g, info.b, info.id);
		return true;
	elseif ( event == "BN_CONNECTED" ) then
		local suppressNotification = ...;
		local info = ChatTypeInfo["SYSTEM"];
		if not suppressNotification then
			self:AddMessage(BN_CHAT_CONNECTED, info.r, info.g, info.b, info.id);
		end
	elseif ( event == "BN_DISCONNECTED" ) then
		local _, suppressNotification = ...;
		local info = ChatTypeInfo["SYSTEM"];
		if not suppressNotification then
			self:AddMessage(BN_CHAT_DISCONNECTED, info.r, info.g, info.b, info.id);
		end
	elseif event == "CHAT_REGIONAL_STATUS_CHANGED" then
		local isServiceAvailable = ...;
		local info = ChatTypeInfo["SYSTEM"];
		if isServiceAvailable then
			self:AddMessage(GetRegionalChatAvailableString(), info.r, info.g, info.b, info.id);
		else
			self:AddMessage(GetRegionalChatUnavailableString(), info.r, info.g, info.b, info.id);
		end
		return true;
	elseif event == "CHAT_REGIONAL_SEND_FAILED" then
		local info = ChatTypeInfo["SYSTEM"];
		self:AddMessage(GetRegionalChatUnavailableString(), info.r, info.g, info.b, info.id);
		return true;
	elseif event == "NOTIFY_CHAT_SUPPRESSED" then
		local hyperlink = string.format("|Haadcopenconfig|h[%s]", RESTRICT_CHAT_CONFIG_HYPERLINK);
		local message = string.format(RESTRICT_CHAT_CHATFRAME_FORMAT, RESTRICT_CHAT_MESSAGE_SUPPRESSED, LIGHTBLUE_FONT_COLOR:WrapTextInColorCode(hyperlink));
		local info = ChatTypeInfo["SYSTEM"];
		self:AddMessage(message, info.r, info.g, info.b, info.id);
		return true;
	elseif ( event == "PLAYER_REPORT_SUBMITTED" ) then
		local guid = ...;
		FCF_RemoveAllMessagesFromChanSender(self, guid);
		return true;
	elseif ( event == "CLUB_REMOVED" ) then
		local clubId = ...;
		local streamIDs = C_ChatInfo.GetClubStreamIDs(clubId);
		for k, streamID in pairs(streamIDs) do
			local channelName = ChatFrameUtil.GetCommunitiesChannelName(clubId, streamID);

			local function RemoveClubChannelFromChatWindow(chatWindow, chatWindowIndex)
				if chatWindow:ContainsChannel(channelName) then
					local omitMessage = true;
					ChatFrameUtil.RemoveCommunitiesChannel(chatWindow, clubId, streamID, omitMessage);
				end
			end

			FCF_IterateActiveChatWindows(RemoveClubChannelFromChatWindow);
		end
	elseif(event == "DISPLAY_EVENT_TOAST_LINK") then
		EventToastManagerFrame:DisplayToastLink(self, ...);
	end
end

function ChatFrameMixin:MessageEventHandler(event, ...)
	if ( TextToSpeechFrame_MessageEventHandler ~= nil ) then
		TextToSpeechFrame_MessageEventHandler(self, event, ...)
	end

	if event == "CAUTIONARY_CHAT_MESSAGE" then
		local hyperlinkLineID, confirmNumber = ...;
		ChatFrameUtil.HandleCautionaryChatMessage(hyperlinkLineID, confirmNumber);
	elseif ( strsub(event, 1, 8) == "CHAT_MSG" ) then
		local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = ...;
		if (arg16) then
			-- hiding sender in letterbox: do NOT even show in chat window (only shows in cinematic frame)
			return true;
		end

		local type = strsub(event, 10);
		local info = ChatTypeInfo[type];

		--If it was a GM whisper, dispatch it to the GMChat addon.
		if arg6 == "GM" and type == "WHISPER" then
			return;
		end

		local shouldDiscardMessage = false;
		shouldDiscardMessage, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14
			= ChatFrameUtil.ProcessMessageEventFilters(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14);

		if shouldDiscardMessage then
			return true;
		end

		local coloredName = ChatFrameUtil.GetDecoratedSenderName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14);

		local channelLength = strlen(arg4);
		local infoType = type;

		if type == "VOICE_TEXT" and not GetCVarBool("speechToText") then
			return;

		elseif ( (type == "COMMUNITIES_CHANNEL") or ((strsub(type, 1, 7) == "CHANNEL") and (type ~= "CHANNEL_LIST") and ((arg1 ~= "INVITE") or (type ~= "CHANNEL_NOTICE_USER"))) ) then
			if ( arg1 == "WRONG_PASSWORD" ) then
				local staticPopup = _G[StaticPopup_Visible("CHAT_CHANNEL_PASSWORD") or ""];
				if ( staticPopup and strupper(staticPopup.data) == strupper(arg9) ) then
					-- Don't display invalid password messages if we're going to prompt for a password (bug 102312)
					return;
				end
			end

			local found = false;
			for index, value in pairs(self.channelList) do
				if ( channelLength > strlen(value) ) then
					-- arg9 is the channel name without the number in front...
					if ( ((arg7 > 0) and (self.zoneChannelList[index] == arg7)) or (strupper(value) == strupper(arg9)) ) then
						found = true;
						infoType = "CHANNEL"..arg8;
						info = ChatTypeInfo[infoType];
						if ( (type == "CHANNEL_NOTICE") and (arg1 == "YOU_LEFT") ) then
							self.channelList[index] = nil;
							self.zoneChannelList[index] = nil;
						end
						break;
					end
				end
			end
			if not found or not info then
				local eventType, channelID = arg1, arg7;
				if not ChatFrame_CheckAddChannel(self, eventType, channelID) then
					return true;
				end
			end
		end

		local chatGroup = ChatFrameUtil.GetChatCategory(type);
		local chatTarget = FCFManager_GetChatTarget(chatGroup, arg2, arg8);

		if ( FCFManager_ShouldSuppressMessage(self, chatGroup, chatTarget) ) then
			return true;
		end

		if ( chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" ) then
			if ( self.privateMessageList and not self.privateMessageList[strlower(arg2)] ) then
				return true;
			elseif ( self.excludePrivateMessageList and self.excludePrivateMessageList[strlower(arg2)]
				and ( (chatGroup == "WHISPER" and GetCVar("whisperMode") ~= "popout_and_inline") or (chatGroup == "BN_WHISPER" and GetCVar("whisperMode") ~= "popout_and_inline") ) ) then
				return true;
			end
		end

		if (self.privateMessageList) then
			-- Dedicated BN whisper windows need online/offline messages for only that player
			if ( (chatGroup == "BN_INLINE_TOAST_ALERT" or chatGroup == "BN_WHISPER_PLAYER_OFFLINE") and not self.privateMessageList[strlower(arg2)] ) then
				return true;
			end

			-- HACK to put certain system messages into dedicated whisper windows
			if ( chatGroup == "SYSTEM") then
				local matchFound = false;
				local message = strlower(arg1);
				for playerName, _ in pairs(self.privateMessageList) do
					local playerNotFoundMsg = strlower(format(ERR_CHAT_PLAYER_NOT_FOUND_S, playerName));
					local charOnlineMsg = strlower(format(ERR_FRIEND_ONLINE_SS, playerName, playerName));
					local charOfflineMsg = strlower(format(ERR_FRIEND_OFFLINE_S, playerName));
					if ( message == playerNotFoundMsg or message == charOnlineMsg or message == charOfflineMsg) then
						matchFound = true;
						break;
					end
				end

				if (not matchFound) then
					return true;
				end
			end
		end

		if ( type == "SYSTEM" or type == "SKILL" or type == "CURRENCY" or type == "MONEY" or
			 type == "OPENING" or type == "TRADESKILLS" or type == "PET_INFO" or type == "TARGETICONS" or type == "BN_WHISPER_PLAYER_OFFLINE") then
			self:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif (type == "LOOT") then
			self:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,7) == "COMBAT_" ) then
			self:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,6) == "SPELL_" ) then
			self:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,10) == "BG_SYSTEM_" ) then
			self:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,11) == "ACHIEVEMENT" ) then
			self:AddMessage(arg1:format(GetPlayerLink(arg2, ("[%s]"):format(coloredName))), info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,18) == "GUILD_ACHIEVEMENT" ) then
			local message = arg1:format(GetPlayerLink(arg2, ("[%s]"):format(coloredName)));
			self:AddMessage(message, info.r, info.g, info.b, info.id);
		elseif (type == "PING") then
			--Add Timestamps
			local chatTimestampFmt = ChatFrameUtil.GetTimestampFormat();
			local outMsg = arg1;
			if ( chatTimestampFmt ) then
				outMsg = BetterDate(chatTimestampFmt, time())..outMsg;
			end

			self:AddMessage(outMsg, info.r, info.g, info.b, info.id);
		elseif ( type == "IGNORED" ) then
			self:AddMessage(format(CHAT_IGNORED, arg2), info.r, info.g, info.b, info.id);
		elseif ( type == "FILTERED" ) then
			self:AddMessage(format(CHAT_FILTERED, arg2), info.r, info.g, info.b, info.id);
		elseif ( type == "RESTRICTED" ) then
			self:AddMessage(CHAT_RESTRICTED_TRIAL, info.r, info.g, info.b, info.id);
		elseif ( type == "CHANNEL_LIST") then
			if(channelLength > 0) then
				self:AddMessage(format(ChatFrameUtil.GetOutMessageFormatKey(type)..arg1, tonumber(arg8), arg4), info.r, info.g, info.b, info.id);
			else
				self:AddMessage(arg1, info.r, info.g, info.b, info.id);
			end
		elseif (type == "CHANNEL_NOTICE_USER") then
			local globalstring = _G["CHAT_"..arg1.."_NOTICE_BN"];
			if ( not globalstring ) then
				globalstring = _G["CHAT_"..arg1.."_NOTICE"];
			end
			if not globalstring then
				GMError(("Missing global string for %q"):format("CHAT_"..arg1.."_NOTICE_BN"));
				return;
			end
			if(arg5 ~= "") then
				-- TWO users in this notice (E.G. x kicked y)
				self:AddMessage(format(globalstring, arg8, arg4, arg2, arg5), info.r, info.g, info.b, info.id);
			elseif ( arg1 == "INVITE" ) then
				local playerLink = GetPlayerLink(arg2, ("[%s]"):format(arg2), arg11);
				local accessID = ChatHistory_GetAccessID(chatGroup, chatTarget);
				local typeID = ChatHistory_GetAccessID(infoType, chatTarget, arg12);
				self:AddMessage(format(globalstring, arg4, playerLink), info.r, info.g, info.b, info.id, accessID, typeID);
			else
				self:AddMessage(format(globalstring, arg8, arg4, arg2), info.r, info.g, info.b, info.id);
			end
			if ( arg1 == "INVITE" and GetCVarBool("blockChannelInvites") ) then
				self:AddMessage(CHAT_MSG_BLOCK_CHAT_CHANNEL_INVITE, info.r, info.g, info.b, info.id);
			end
		elseif (type == "CHANNEL_NOTICE") then
			local accessID = ChatHistory_GetAccessID(ChatFrameUtil.GetChatCategory(type), arg8);
			local typeID = ChatHistory_GetAccessID(infoType, arg8, arg12);

			if arg1 == "YOU_CHANGED" and C_ChatInfo.GetChannelRuleset(arg8) == Enum.ChatChannelRuleset.Mentor then
				self:UpdateDefaultChatTarget();
				self.editBox:UpdateNewcomerEditBoxHint();
			else
				if arg1 == "YOU_LEFT" then
					self.editBox:UpdateNewcomerEditBoxHint(arg8);
				end

				local globalstring;
				if ( arg1 == "TRIAL_RESTRICTED" ) then
					globalstring = CHAT_TRIAL_RESTRICTED_NOTICE_TRIAL;
				else
					globalstring = _G["CHAT_"..arg1.."_NOTICE_BN"];
					if ( not globalstring ) then
						globalstring = _G["CHAT_"..arg1.."_NOTICE"];
						if not globalstring then
							GMError(("Missing global string for %q"):format("CHAT_"..arg1.."_NOTICE"));
							return;
						end
					end
				end

				self:AddMessage(format(globalstring, arg8, ChatFrameUtil.ResolvePrefixedChannelName(arg4)), info.r, info.g, info.b, info.id, accessID, typeID);
			end
		elseif ( type == "BN_INLINE_TOAST_ALERT" ) then
			local globalstring = _G["BN_INLINE_TOAST_"..arg1];
			if not globalstring then
				GMError(("Missing global string for %q"):format("BN_INLINE_TOAST_"..arg1));
				return;
			end
			local message;
			if ( arg1 == "FRIEND_REQUEST" ) then
				message = globalstring;
			elseif ( arg1 == "FRIEND_PENDING" ) then
				message = format(BN_INLINE_TOAST_FRIEND_PENDING, BNGetNumFriendInvites());
			elseif ( arg1 == "FRIEND_REMOVED" or arg1 == "BATTLETAG_FRIEND_REMOVED" ) then
				message = format(globalstring, arg2);
			elseif ( arg1 == "FRIEND_ONLINE" or arg1 == "FRIEND_OFFLINE") then
				local accountInfo = C_BattleNet.GetAccountInfoByID(arg13);
				if accountInfo and accountInfo.gameAccountInfo.clientProgram ~= "" then
					C_Texture.GetTitleIconTexture(accountInfo.gameAccountInfo.clientProgram, Enum.TitleIconVersion.Small, function(success, texture)
						if success then
							local characterName = BNet_GetValidatedCharacterNameWithClientEmbeddedTexture(accountInfo.gameAccountInfo.characterName, accountInfo.battleTag, texture, 32, 32, 10);
							local linkDisplayText = ("[%s] (%s)"):format(arg2, characterName);
							local playerLink = GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, ChatFrameUtil.GetChatCategory(type), 0);
							local message = format(globalstring, playerLink);
							self:AddMessage(message, info.r, info.g, info.b, info.id);
							ChatFrameUtil.FlashTabIfNotShown(self, info, type, chatGroup, chatTarget);
						end
					end);
					return;
				else
					local linkDisplayText = ("[%s]"):format(arg2);
					local playerLink = GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, ChatFrameUtil.GetChatCategory(type), 0);
					message = format(globalstring, playerLink);
				end
			else
				local linkDisplayText = ("[%s]"):format(arg2);
				local playerLink = GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, ChatFrameUtil.GetChatCategory(type), 0);
				message = format(globalstring, playerLink);
			end
			self:AddMessage(message, info.r, info.g, info.b, info.id);
		elseif ( type == "BN_INLINE_TOAST_BROADCAST" ) then
			if ( arg1 ~= "" ) then
				arg1 = RemoveNewlines(RemoveExtraSpaces(arg1));
				local linkDisplayText = ("[%s]"):format(arg2);
				local playerLink = GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, ChatFrameUtil.GetChatCategory(type), 0);
				self:AddMessage(format(BN_INLINE_TOAST_BROADCAST, playerLink, arg1), info.r, info.g, info.b, info.id);
			end
		elseif ( type == "BN_INLINE_TOAST_BROADCAST_INFORM" ) then
			if ( arg1 ~= "" ) then
				arg1 = RemoveExtraSpaces(arg1);
				self:AddMessage(BN_INLINE_TOAST_BROADCAST_INFORM, info.r, info.g, info.b, info.id);
			end
		else
			local msgTime = time();
			local playerName, lineID, bnetIDAccount = arg2, arg11, arg13;

			local function MessageFormatter(msg)
				local fontHeight = select(2, FCF_GetChatWindowInfo(self:GetID()));
				if ( fontHeight == 0 ) then
					--fontHeight will be 0 if it's still at the default (14)
					fontHeight = 14;
				end

				-- Add AFK/DND flags
				local pflag = ChatFrameUtil.GetPFlag(arg6, arg7, arg8);

				if ( type == "WHISPER_INFORM" and GMChatFrame_IsGM and GMChatFrame_IsGM(arg2) ) then
					return;
				end

				local showLink = 1;
				if ( strsub(type, 1, 7) == "MONSTER" or strsub(type, 1, 9) == "RAID_BOSS") then
					showLink = nil;
				else
					msg = gsub(msg, "%%", "%%%%");
				end

				-- Search for icon links and replace them with texture links.
				msg = C_ChatInfo.ReplaceIconAndGroupExpressions(msg, arg17, not ChatFrameUtil.CanChatGroupPerformExpressionExpansion(chatGroup)); -- If arg17 is true, don't convert to raid icons

				--Remove groups of many spaces
				msg = RemoveExtraSpaces(msg);

				local playerLink;
				local playerLinkDisplayText = coloredName;
				local relevantDefaultLanguage = self.defaultLanguage;
				if ( (type == "SAY") or (type == "YELL") ) then
					relevantDefaultLanguage = self.alternativeDefaultLanguage;
				end
				local usingDifferentLanguage = (arg3 ~= "") and (arg3 ~= relevantDefaultLanguage);
				local usingEmote = (type == "EMOTE") or (type == "TEXT_EMOTE");

				if ( usingDifferentLanguage or not usingEmote ) then
					playerLinkDisplayText = ("[%s]"):format(coloredName);
				end

				local isCommunityType = type == "COMMUNITIES_CHANNEL";
				if ( isCommunityType ) then
					local isBattleNetCommunity = bnetIDAccount ~= nil and bnetIDAccount ~= 0;
					local messageInfo, clubId, streamId, clubType = C_Club.GetInfoFromLastCommunityChatLine();
					if (messageInfo ~= nil) then
						if ( isBattleNetCommunity ) then
							playerLink = GetBNPlayerCommunityLink(playerName, playerLinkDisplayText, bnetIDAccount, clubId, streamId, messageInfo.messageId.epoch, messageInfo.messageId.position);
						else
							playerLink = GetPlayerCommunityLink(playerName, playerLinkDisplayText, clubId, streamId, messageInfo.messageId.epoch, messageInfo.messageId.position);
						end
					else
						playerLink = playerLinkDisplayText;
					end
				else
					if ( type == "BN_WHISPER" or type == "BN_WHISPER_INFORM" ) then
						playerLink = GetBNPlayerLink(playerName, playerLinkDisplayText, bnetIDAccount, lineID, chatGroup, chatTarget);
					else
						playerLink = GetPlayerLink(playerName, playerLinkDisplayText, lineID, chatGroup, chatTarget);
						local senderGUID = arg12;
						if not usingEmote and ShouldAddRecentAllyIconToName(self.chatType, senderGUID) then
							playerLink = playerLink .. " " .. CreateAtlasMarkup("friendslist-recentallies-yellow", 11, 11);
						end
					end
				end

				local message = msg;
				-- isMobile
				if arg14 then
					message = ChatFrameUtil.GetMobileEmbeddedTexture(info.r, info.g, info.b)..message;
				end

				local outMsg;
				if ( usingDifferentLanguage ) then
					local languageHeader = "["..arg3.."] ";
					if ( showLink and (arg2 ~= "") ) then
						outMsg = format(ChatFrameUtil.GetOutMessageFormatKey(type)..languageHeader..message, pflag..playerLink);
					else
						outMsg = format(ChatFrameUtil.GetOutMessageFormatKey(type)..languageHeader..message, pflag..arg2);
					end
				else
					if ( not showLink or arg2 == "" ) then
						if ( type == "TEXT_EMOTE" ) then
							outMsg = message;
						else
							outMsg = format(ChatFrameUtil.GetOutMessageFormatKey(type)..message, pflag..arg2, arg2);
						end
					else
						if ( type == "EMOTE" ) then
							outMsg = format(ChatFrameUtil.GetOutMessageFormatKey(type)..message, pflag..playerLink);
						elseif ( type == "TEXT_EMOTE") then
							outMsg = string.gsub(message, arg2, pflag..playerLink, 1);
						elseif (type == "GUILD_ITEM_LOOTED") then
							outMsg = string.gsub(message, "$s", GetPlayerLink(arg2, playerLinkDisplayText));
						else
							outMsg = format(ChatFrameUtil.GetOutMessageFormatKey(type)..message, pflag..playerLink);
						end
					end
				end

				-- Add Channel
				if (channelLength > 0) then
					outMsg = "|Hchannel:channel:"..arg8.."|h["..ChatFrameUtil.ResolvePrefixedChannelName(arg4).."]|h "..outMsg;
				end

				--Add Timestamps
				local chatTimestampFmt = ChatFrameUtil.GetTimestampFormat();
				if ( chatTimestampFmt ) then
					outMsg = BetterDate(chatTimestampFmt, msgTime)..outMsg;
				end

				return outMsg;
			end

			local isChatLineCensored = C_ChatInfo.IsChatLineCensored(lineID);
			local msg = isChatLineCensored and arg1 or MessageFormatter(arg1);
			local accessID = ChatHistory_GetAccessID(chatGroup, chatTarget);
			local typeID = ChatHistory_GetAccessID(infoType, chatTarget, arg12 or arg13);

			-- The message formatter is captured so that the original message can be reformatted when a censored message
			-- is approved to be shown.
			local eventArgs = SafePack(...);
			self:AddMessage(msg, info.r, info.g, info.b, info.id, accessID, typeID, event, eventArgs, MessageFormatter);
		end

		if ( type == "WHISPER" or type == "BN_WHISPER" ) then
			--BN_WHISPER FIXME
			ChatFrameUtil.SetLastTellTarget(arg2, type);

			if ( not self.tellTimer or (GetTime() > self.tellTimer) ) then
				PlaySound(SOUNDKIT.TELL_MESSAGE);
			end
			self.tellTimer = GetTime() + ChatFrameConstants.WhisperSoundAlertCooldown;
			--FCF_FlashTab(self);

			-- We don't flash the app icon for front end chat for now.
			if FlashClientIcon then
				FlashClientIcon();
			end
		end

		ChatFrameUtil.FlashTabIfNotShown(self, info, type, chatGroup, chatTarget);

		return true;
	elseif ( event == "VOICE_CHAT_CHANNEL_TRANSCRIBING_CHANGED" ) then
		local _, isNowTranscribing = ...
		if ( not self.isTranscribing and isNowTranscribing ) then
			ChatFrameUtil.DisplaySystemMessage(self, SPEECH_TO_TEXT_STARTED);
		end
		self.isTranscribing = isNowTranscribing;
	end
end

function ChatFrameMixin:OnUpdate(elapsedSec)
	local flash = self.ScrollToBottomButton.Flash;
	if flash then
		local shouldFlash = not self:AtBottom();

		if shouldFlash ~= UIFrameIsFlashing(flash) then
			if shouldFlash then
				UIFrameFlash(flash, .1, .1, -1, false, ChatFrameConstants.ScrollToBottomFlashInterval, ChatFrameConstants.ScrollToBottomFlashInterval);
				FCF_FadeInScrollbar(self);
			else
				UIFrameFlashStop(flash);
			end
		end
	end
end
