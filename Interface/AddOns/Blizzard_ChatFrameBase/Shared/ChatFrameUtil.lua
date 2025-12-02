local _, addonTbl = ...;

local chatEditLastTell = {};
local chatEditLastTellType = {};
local chatEditLastTold;
local chatEditLastToldType;
local hasInitializedDefaultChatChannel = false;
local stickyFocusFrames = {};

for i = 1, ChatFrameConstants.MaxRememberedWhisperTargets, 1 do
	chatEditLastTell[i] = "";
	chatEditLastTellType[i] = "";
end

-- The following variables are mutated by various aspects of the chat frame
-- code. As they're also used externally by user addons the global-ness and
-- awkward SHOUT_CASING has been kept intact for now.

DEFAULT_CHAT_FRAME = ChatFrame1;
CHAT_FOCUS_OVERRIDE = nil;
ACTIVE_CHAT_EDIT_BOX = nil;
LAST_ACTIVE_CHAT_EDIT_BOX = nil;
CHAT_SHOW_IME = false;

ChatFrameUtil = {};

function ChatFrameUtil.ForEachChatFrame(func)
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName];
		func(frame);
	end
end

function ChatFrameUtil.DisplayGMOTD(chatFrame, gmotd)
	if ( gmotd and (gmotd ~= "") ) then
		local info = ChatTypeInfo["GUILD"];
		local string = format(GUILD_MOTD_TEMPLATE, gmotd);
		chatFrame:AddMessage(string, info.r, info.g, info.b, info.id);
	end
end

function ChatFrameUtil.TruncateToMaxLength(text, maxLength)
	local length = strlenutf8(text);
	if ( length > maxLength ) then
		return text:sub(1, maxLength - 2).."...";
	end

	return text;
end

function ChatFrameUtil.ResolvePrefixedChannelName(communityChannelArg)
	local prefix, communityChannel = communityChannelArg:match("(%d+. )(.*)");
	return prefix..ChatFrameUtil.ResolveChannelName(communityChannel);
end

function ChatFrameUtil.GetCommunityAndStreamFromChannel(communityChannel)
	local clubId, streamId = communityChannel:match("(%d+)%:(%d+)");
	return tonumber(clubId), tonumber(streamId);
end

function ChatFrameUtil.GetChatFrame(chatFrameIndex)
	return _G["ChatFrame"..chatFrameIndex];
end

function ChatFrameUtil.GetChatCategory(chatType)
	return CHAT_INVERTED_CATEGORY_LIST[chatType] or chatType;
end

function ChatFrameUtil.GetChannelColor(chatInfo)
	return chatInfo.r, chatInfo.g, chatInfo.b;
end

function ChatFrameUtil.GetCommunitiesChannelName(clubId, streamId)
	return ("Community:%s:%s"):format(tostring(clubId), tostring(streamId));
end

function ChatFrameUtil.GetCommunitiesChannel(clubId, streamId)
	local communitiesChannelName = ChatFrameUtil.GetCommunitiesChannelName(clubId, streamId);
	for i = 1, Constants.ChatFrameConstants.MaxChatChannels do
		local channelID, channelName = GetChannelName(i);
		if channelName and channelName == communitiesChannelName then
			return "CHANNEL"..i, i;
		end
	end
end

function ChatFrameUtil.GetMobileEmbeddedTexture(r, g, b)
	r, g, b = floor(r * 255), floor(g * 255), floor(b * 255);
	return format("|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat:14:14:0:0:16:16:0:16:0:16:%d:%d:%d|t", r, g, b);
end

function ChatFrameUtil.CanChatGroupPerformExpressionExpansion(chatGroup)
	if chatGroup == "RAID" then
		return true;
	end

	if chatGroup == "INSTANCE_CHAT" then
		return IsInRaid(LE_PARTY_CATEGORY_INSTANCE);
	end

	return false;
end

function ChatFrameUtil.SetChatFocusOverride(editBoxOverride)
	CHAT_FOCUS_OVERRIDE = editBoxOverride;
end

function ChatFrameUtil.GetChatFocusOverride()
	return CHAT_FOCUS_OVERRIDE;
end

function ChatFrameUtil.ClearChatFocusOverride()
	CHAT_FOCUS_OVERRIDE = nil;
end

function ChatFrameUtil.ScrollToBottom()
	SELECTED_DOCK_FRAME:ScrollToBottom();
end

function ChatFrameUtil.ScrollUp()
	SELECTED_DOCK_FRAME:ScrollUp();
end

function ChatFrameUtil.ScrollDown()
	SELECTED_DOCK_FRAME:ScrollDown();
end

function ChatFrameUtil.DisplayHelpTextSimple(frame)
	if ( not frame ) then
		return;
	end

	local info = ChatTypeInfo["SYSTEM"];
	frame:AddMessage(HELP_TEXT_SIMPLE, info.r, info.g, info.b, info.id);
end

function ChatFrameUtil.DisplayHelpText(frame)
	if ( not frame ) then
		return;
	end

	local info = ChatTypeInfo["SYSTEM"];
	local i = 1;
	local text = _G["HELP_TEXT_LINE"..i];
	while text do
		frame:AddMessage(text, info.r, info.g, info.b, info.id);
		i = i + 1;
		text = _G["HELP_TEXT_LINE"..i];
	end
end

function ChatFrameUtil.DisplayMacroHelpText(frame)
	if ( not frame ) then
		return;
	end

	local info = ChatTypeInfo["SYSTEM"];
	local i = 1;
	local text = _G["MACRO_HELP_TEXT_LINE"..i];
	while text do
		frame:AddMessage(text, info.r, info.g, info.b, info.id);
		i = i + 1;
		text = _G["MACRO_HELP_TEXT_LINE"..i];
	end
end

function ChatFrameUtil.DisplayGameTime(frame)
	if ( not frame ) then
		return;
	end

	local info = ChatTypeInfo["SYSTEM"];
	frame:AddMessage(GameTime_GetGameTime(true), info.r, info.g, info.b, info.id);
end

function ChatFrameUtil.TimeBreakDown(time)
	local days = floor(time / (60 * 60 * 24));
	local hours = floor((time - (days * (60 * 60 * 24))) / (60 * 60));
	local minutes = floor((time - (days * (60 * 60 * 24)) - (hours * (60 * 60))) / 60);
	local seconds = mod(time, 60);
	return days, hours, minutes, seconds;
end

function ChatFrameUtil.DisplayTimePlayed(chatFrame, totalTime, levelTime)
	local info = ChatTypeInfo["SYSTEM"];
	local d;
	local h;
	local m;
	local s;
	d, h, m, s = ChatFrameUtil.TimeBreakDown(totalTime);
	local string = format(TIME_PLAYED_TOTAL, format(TIME_DAYHOURMINUTESECOND, d, h, m, s));
	chatFrame:AddMessage(string, info.r, info.g, info.b, info.id);

	d, h, m, s = ChatFrameUtil.TimeBreakDown(levelTime);
	string = format(TIME_PLAYED_LEVEL, format(TIME_DAYHOURMINUTESECOND, d, h, m, s));
	chatFrame:AddMessage(string, info.r, info.g, info.b, info.id);
end

function ChatFrameUtil.DisplayChatHelp(frame)
	if ( not frame ) then
		return;
	end

	local info = ChatTypeInfo["SYSTEM"];
	local i = 1;
	local text = _G["CHAT_HELP_TEXT_LINE"..i];
	while text do
		-- Some strings are intentionally empty as they previously referenced
		-- commands which no longer exist. Skip these when iterating.
		if text ~= "" then
			frame:AddMessage(text, info.r, info.g, info.b, info.id);
		end
		i = i + 1;
		text = _G["CHAT_HELP_TEXT_LINE"..i];
	end
end

function ChatFrameUtil.ChatPageUp()
	SELECTED_CHAT_FRAME:PageUp();
end

function ChatFrameUtil.ChatPageDown()
	SELECTED_CHAT_FRAME:PageDown();
end

function ChatFrameUtil.DisplayUsageError(messageTag)
	ChatFrameUtil.DisplaySystemMessageInPrimary(messageTag);
end

function ChatFrameUtil.DisplaySystemMessageInPrimary(messageTag)
	local info = ChatTypeInfo["SYSTEM"];
	DEFAULT_CHAT_FRAME:AddMessage(messageTag, info.r, info.g, info.b, info.id);
end

function ChatFrameUtil.DisplaySystemMessageInCurrent(messageTag)
	local info = ChatTypeInfo["SYSTEM"];
	SELECTED_CHAT_FRAME:AddMessage(messageTag, info.r, info.g, info.b, info.id);
end

function ChatFrameUtil.DisplaySystemMessage(frame, messageTag)
	local info = ChatTypeInfo["SYSTEM"];
	frame:AddMessage(messageTag, info.r, info.g, info.b, info.id);
end

function ChatFrameUtil.AddSystemMessage(messageText)
	local info = ChatTypeInfo["SYSTEM"];
	DEFAULT_CHAT_FRAME:AddMessage(messageText, info.r, info.g, info.b, info.id);
end

function ChatFrameUtil.CanAddChannel()
	return C_ChatInfo.GetNumActiveChannels() < Constants.ChatFrameConstants.MaxChatChannels;
end

function ChatFrameUtil.GetPFlag(specialFlag, zoneChannelID, localChannelID)
	if specialFlag ~= "" then
		if specialFlag == "GM" or specialFlag == "DEV" then
			-- Add Blizzard Icon if  this was sent by a GM/DEV
			return "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16|t ";
		elseif specialFlag == "GUIDE" then
			if ChatFrameUtil.GetMentorChannelStatus(Enum.PlayerMentorshipStatus.Mentor, C_ChatInfo.GetChannelRulesetForChannelID(zoneChannelID)) == Enum.PlayerMentorshipStatus.Mentor then
				return NPEV2_CHAT_USER_TAG_GUIDE .. " "; -- possibly unable to save global string with trailing whitespace...
			end
		elseif specialFlag == "NEWCOMER" then
			if ChatFrameUtil.GetMentorChannelStatus(Enum.PlayerMentorshipStatus.Newcomer, C_ChatInfo.GetChannelRulesetForChannelID(zoneChannelID)) == Enum.PlayerMentorshipStatus.Newcomer then
				return NPEV2_CHAT_USER_TAG_NEWCOMER;
			end
		else
			local pflag = _G["CHAT_FLAG_"..specialFlag];
			assertsafe(pflag ~= nil, "'pflag' at _G[CHAT_FLAG_%s] doesn't exist.", specialFlag);
			return pflag or "";
		end
	end

	return "";
end

function ChatFrameUtil.GetOutMessageFormatKey(chatEventSubtype)
	local formatKey = _G["CHAT_"..chatEventSubtype.."_GET"];
	assertsafe(formatKey ~= nil, "'formatKey' at _G[CHAT_%s_GET] doesn't exist.", chatEventSubtype);
	return formatKey or "";
end

function ChatFrameUtil.GetFullChannelInfo(channelIdentifier)
	local channelInfo = C_ChatInfo.GetChannelInfoFromIdentifier(channelIdentifier);
	if channelInfo then
		channelInfo.humanReadableName = ChatFrameUtil.ResolveChannelName(channelInfo.name);
	end

	return channelInfo;
end

function ChatFrameUtil.SendTellWithMessage(name, text, chatFrame)
	local editBox = ChatFrameUtil.ChooseBoxForSend(chatFrame);

	--DEBUG FIXME - for now, we're not going to remove spaces from names. We need to make sure X-server still works.
	-- Remove spaces from the server name for slash command parsing
	--name = gsub(name, " ", "");

	local formattedText = string.format("%s %s %s", SLASH_WHISPER1, name, text);
	if ( editBox ~= ChatFrameUtil.GetActiveWindow() ) then
		ChatFrameUtil.OpenChat(formattedText, chatFrame);
	else
		editBox:SetText(formattedText);
	end
	editBox:ParseText(0);
end

function ChatFrameUtil.SendTell(name, chatFrame)
	local message = "";
	ChatFrameUtil.SendTellWithMessage(name, message, chatFrame);
end

function ChatFrameUtil.SendBNetTell(tokenizedName)
	local editBox = ChatFrameUtil.ChooseBoxForSend();
	editBox:SetAttribute("tellTarget", tokenizedName);
	editBox:SetAttribute("chatType", "BN_WHISPER");
	if ( editBox ~= ChatFrameUtil.GetActiveWindow() ) then
		ChatFrameUtil.OpenChat("");
	else
		editBox:UpdateHeader();
	end
end

function ChatFrameUtil.ReplyTell(chatFrame)
	local editBox = ChatFrameUtil.ChooseBoxForSend(chatFrame);

	local lastTell, lastTellType = ChatFrameUtil.GetLastTellTarget();
	if ( lastTell ) then
		--BN_WHISPER FIXME
		editBox:SetAttribute("chatType", lastTellType);
		editBox:SetAttribute("tellTarget", lastTell);
		editBox:UpdateHeader();
		if ( editBox ~= ChatFrameUtil.GetActiveWindow() ) then
			ChatFrameUtil.OpenChat("", chatFrame);
		end
	else
		-- Error message
	end
end

function ChatFrameUtil.ReplyTell2(chatFrame)
	local editBox = ChatFrameUtil.ChooseBoxForSend(chatFrame);

	local lastTold, lastToldType = ChatFrameUtil.GetLastToldTarget();
	if ( lastTold ) then
		--BN_WHISPER FIXME
		editBox:SetAttribute("chatType", lastToldType);
		editBox:SetAttribute("tellTarget", lastTold);
		editBox:UpdateHeader();
		if ( editBox ~= ChatFrameUtil.GetActiveWindow() ) then
			ChatFrameUtil.OpenChat("", chatFrame);
		end
	else
		-- Error message
	end
end

function ChatFrameUtil.OpenChat(text, chatFrame, desiredCursorPosition)
	if chatFrame == nil and CHAT_FOCUS_OVERRIDE ~= nil then
		if CHAT_FOCUS_OVERRIDE.supportsSlashCommands or not text or strsub(text, 0, 1) ~= "/" then
			CHAT_FOCUS_OVERRIDE:SetFocus();
			if text then
				CHAT_FOCUS_OVERRIDE:SetText(text);
			end
			return;
		end
	end

	local editBox = ChatFrameUtil.ChooseBoxForSend(chatFrame);

	-- GAME RULES TODO:: This should be an explicit game rule.
	if C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm then
		if not hasInitializedDefaultChatChannel then
			hasInitializedDefaultChatChannel = true;

			-- Don't default chat type if we already have a specific type (i.e. BN_WHISPER)
			if editBox:GetAttribute("chatType") == "SAY" then
				local isInGroup;
				if IsInGroup(LE_PARTY_CATEGORY_HOME) then
					local groupCount = GetNumGroupMembers();
					if groupCount > 1 then
						isInGroup = true;
					end
				end

				local chatType = "SAY";
				if C_Glue.IsOnGlueScreen() then
					chatType = "PARTY";
				elseif isInGroup then
					chatType = "INSTANCE_CHAT";
				end

				editBox:SetAttribute("chatType", chatType);
				editBox:SetAttribute("stickyType", chatType);
			end
		end
	end

	ChatFrameUtil.ActivateChat(editBox);
	editBox.desiredCursorPosition = desiredCursorPosition;

	if text then
		editBox.text = text;
		editBox.setText = 1;
	end

	if ( editBox:GetAttribute("chatType") == editBox:GetAttribute("stickyType") ) then
		if ( (editBox:GetAttribute("stickyType") == "PARTY") and (not IsInGroup(LE_PARTY_CATEGORY_HOME)) or
		(editBox:GetAttribute("stickyType") == "RAID") and (not IsInRaid(LE_PARTY_CATEGORY_HOME)) or
		(editBox:GetAttribute("stickyType") == "INSTANCE_CHAT") and (not IsInGroup(LE_PARTY_CATEGORY_INSTANCE))) then
			editBox:SetAttribute("chatType", "SAY");
		end
	end

	editBox:UpdateHeader();
	return editBox;
end

function ChatFrameUtil.GetActiveWindow()
	return ACTIVE_CHAT_EDIT_BOX;
end

function ChatFrameUtil.GetLastActiveWindow()
	return LAST_ACTIVE_CHAT_EDIT_BOX;
end

function ChatFrameUtil.GetActiveChatType()
	local editBox = ChatFrameUtil.GetActiveWindow();
	return editBox and editBox:GetAttribute("chatType") or nil;
end

function ChatFrameUtil.FocusActiveWindow()
	local active = ChatFrameUtil.GetActiveWindow()
	if ( active ) then
		ChatFrameUtil.ActivateChat(active);
	end
end

function ChatFrameUtil.ActivateChat(editBox)
	if ( editBox.disableActivate ) then
		return;
	end

	ChatFrameUtil.ClearChatFocusOverride();
	if ( ACTIVE_CHAT_EDIT_BOX and ACTIVE_CHAT_EDIT_BOX ~= editBox ) then
		ChatFrameUtil.DeactivateChat(ACTIVE_CHAT_EDIT_BOX);
	end
	ACTIVE_CHAT_EDIT_BOX = editBox;

	ChatFrameUtil.SetLastActiveWindow(editBox);

	--Stop any sort of fading
	UIFrameFadeRemoveFrame(editBox);

	editBox:Show();
	editBox:SetFocus();
	editBox:SetFrameStrata("DIALOG");
	editBox:Raise();

	editBox.header:Show();
	editBox:UpdateNewcomerEditBoxHint();
	editBox:SetFocusRegionsShown(true);
	editBox:SetAlpha(1.0);

	editBox:UpdateHeader();

	if ( CHAT_SHOW_IME ) then
		_G[editBox:GetName().."Language"]:Show();
	end
end

function ChatFrameUtil.DeactivateChat(editBox)
	if ( ACTIVE_CHAT_EDIT_BOX == editBox ) then
		_G.ACTIVE_CHAT_EDIT_BOX = nil;
	end

	editBox:Deactivate();
end

function ChatFrameUtil.ChooseBoxForSend(preferredChatFrame)
	local lastActiveWindow = ChatFrameUtil.GetLastActiveWindow();
	if ( (not (lastActiveWindow and IsVoiceTranscription(lastActiveWindow.chatFrame))) and GetCVar("chatStyle") == "classic" ) then
		return DEFAULT_CHAT_FRAME.editBox;
	elseif ( preferredChatFrame and preferredChatFrame:IsShown() ) then
		return preferredChatFrame.editBox;
	elseif ( lastActiveWindow  and lastActiveWindow:GetParent():IsShown() ) then
		return lastActiveWindow;
	else
		return FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK).editBox;
	end
end

function ChatFrameUtil.SetLastActiveWindow(editBox)
	if ( editBox ~= nil and editBox.disableActivate ) then
		return;
	end

	local previousValue = LAST_ACTIVE_CHAT_EDIT_BOX;
	if ( previousValue and not previousValue.isGM and previousValue ~= editBox ) then
		if ( IsVoiceTranscription(previousValue.chatFrame) or GetCVar("chatStyle") == "im" ) then
			previousValue:Hide();
		end
	end

	LAST_ACTIVE_CHAT_EDIT_BOX = editBox;
	if ( editBox and (IsVoiceTranscription(editBox.chatFrame) or GetCVar("chatStyle") == "im") and ACTIVE_CHAT_EDIT_BOX ~= editBox ) then
		editBox:Show();
		editBox:Deactivate();
	end

	if ( previousValue ) then
		FCFClickAnywhereButton_UpdateState(previousValue.chatFrame.clickAnywhereButton);
	end

	if ( editBox ) then
		FCFClickAnywhereButton_UpdateState(editBox.chatFrame.clickAnywhereButton);
	end
end

function ChatFrameUtil.LinkItem(itemID, itemLink)
	if ( not itemLink ) then
		itemLink = select(2, C_Item.GetItemInfo(itemID));
	end
	if ( itemLink ) then
		if ( ChatFrameUtil.GetActiveWindow() ) then
			ChatFrameUtil.InsertLink(itemLink);
		else
			ChatFrameUtil.OpenChat(itemLink);
		end
	end
end

function ChatFrameUtil.TryInsertChatLink(link)
	if ( IsModifiedClick("CHATLINK") and link ) then
		return ChatFrameUtil.InsertLink(link);
	end
end

function ChatFrameUtil.TryInsertQuestLinkForQuestID(questID)
	return ChatFrameUtil.TryInsertChatLink(GetQuestLink(questID));
end

function ChatFrameUtil.GetLastTellTarget()
	for i=1, #chatEditLastTell do
		local value = chatEditLastTell[i];
		if ( value ~= "" ) then
			return value, chatEditLastTellType[i];
		end
	end
	return nil;
end

function ChatFrameUtil.SetLastTellTarget(target, chatType)
	local found = #chatEditLastTell;
	for i=1, #chatEditLastTell do
		local tellTarget, tellChatType = chatEditLastTell[i], chatEditLastTellType[i];
		if ( strupper(target) == strupper(tellTarget) and strupper(chatType) == strupper(tellChatType) ) then
			found = i;
			break;
		end
	end

	for i = found, 2, -1 do
		chatEditLastTell[i] = chatEditLastTell[i-1];
		chatEditLastTellType[i] = chatEditLastTellType[i-1];
	end
	chatEditLastTell[1] = target;
	chatEditLastTellType[1] = chatType;
end

function ChatFrameUtil.GetNextTellTarget(target, chatType)
	if ( not target or target == "" ) then
		return chatEditLastTell[1], chatEditLastTellType[1];
	end

	for i = 1, #chatEditLastTell - 1, 1 do
		if ( chatEditLastTell[i] == "" ) then
			break;
		elseif ( strupper(target) == strupper(chatEditLastTell[i]) and
			strupper(chatType) == strupper(chatEditLastTellType[i]) ) then
			if ( chatEditLastTell[i+1] ~= "" ) then
				return chatEditLastTell[i+1], chatEditLastTellType[i+1];
			else
				break;
			end
		end
	end

	return chatEditLastTell[1], chatEditLastTellType[1];
end

function ChatFrameUtil.GetLastToldTarget()
	return chatEditLastTold, chatEditLastToldType;
end

function ChatFrameUtil.SetLastToldTarget(name, chatType)
	chatEditLastTold = name;
	chatEditLastToldType = chatType;
end

function ChatFrameUtil.CheckUpdateNewcomerEditBoxHint()
	local editBox = ChatFrameUtil.GetActiveWindow() or ChatFrameUtil.GetLastActiveWindow();
	if editBox then
		-- No need for an exlcude channel, this should not be called when leaving a channel.
		editBox:UpdateNewcomerEditBoxHint();
	end
end

function ChatFrameUtil.SubstituteChatMessageBeforeSend(msg)
	for tag in string.gmatch(msg, "%b{}") do
		local term = strlower(string.gsub(tag, "[{}]", ""));
		if ( GROUP_TAG_LIST[term] ) then
			local groupIndex = GROUP_TAG_LIST[term];
			msg = string.gsub(msg, tag, "{"..GROUP_LANGUAGE_INDEPENDENT_STRINGS[groupIndex].."}");
		end
	end
	return msg;
end

function ChatFrameUtil.ShowChatChannelContextMenu(chatFrame, chatType, chatTarget, chatName)
	MenuUtil.CreateContextMenu(chatFrame, function(owner, rootDescription)
		rootDescription:SetTag("MENU_CHAT_FRAME_CHANNEL");

		rootDescription:CreateTitle(ChatFrameUtil.ResolveChannelName(chatName));

		local clubId, streamId = ChatFrameUtil.GetCommunityAndStreamFromChannel(chatName);
		if clubId and streamId and C_Club.IsEnabled() then
			rootDescription:CreateButton(CHAT_CHANNEL_DROP_DOWN_OPEN_COMMUNITIES_FRAME, function()
				if not CommunitiesFrame or not CommunitiesFrame:IsShown() then
					ToggleCommunitiesFrame();
				end

				CommunitiesFrame:SelectStream(clubId, streamId);
				CommunitiesFrame:SelectClub(clubId);
			end);
		end

		local button = rootDescription:CreateButton(MOVE_TO_NEW_WINDOW, function()
			ChatFrameUtil.PopOutChat(chatFrame, chatType, chatTarget);
		end);

		if not FCF_CanOpenNewWindow() then
			button:SetEnabled(false);
		end
	end);
end

function ChatFrameUtil.PopOutChat(sourceChatFrame, chatType, chatTarget)
	local windowName;
	if ( chatType == "CHANNEL" ) then
		windowName = ChatFrameUtil.GetChannelShortcutName(chatTarget);
	else
		windowName = _G[chatType];
	end
	local frame = FCF_OpenNewWindow(windowName);
	FCF_CopyChatSettings(frame, sourceChatFrame);

	frame:RemoveAllMessageGroups();
	frame:RemoveAllChannels();
	frame:ReceiveAllPrivateMessages();

	frame:AddMessageGroup(chatType);

	if ( CHAT_CATEGORY_LIST[chatType] ) then
		for _, chat in pairs(CHAT_CATEGORY_LIST[chatType]) do
			frame:AddMessageGroup(chat);
		end
	end

	frame.editBox:SetAttribute("chatType", chatType);
	frame.editBox:SetAttribute("stickyType", chatType);

	if ( chatType == "CHANNEL" ) then
		frame.editBox:SetAttribute("channelTarget", chatTarget);
		frame:AddChannel(ChatFrameUtil.GetChannelShortcutName(chatTarget));
	end

	if ( chatType == "PET_BATTLE_COMBAT_LOG" or chatType == "PET_BATTLE_INFO" ) then
		frame.editBox:SetAttribute("chatType", "SAY");
		frame.editBox:SetAttribute("stickyType", "SAY");
	end

	--Remove the things popped out from the source chat frame.
	if ( chatType == "CHANNEL" ) then
		sourceChatFrame:RemoveChannel(ChatFrameUtil.GetChannelShortcutName(chatTarget));
	else
		sourceChatFrame:RemoveMessageGroup(chatType);
		if ( CHAT_CATEGORY_LIST[chatType] ) then
			for _, chat in pairs(CHAT_CATEGORY_LIST[chatType]) do
				sourceChatFrame:RemoveMessageGroup(chat);
			end
		end
	end

	--Copy over messages
	local accessID = ChatHistory_GetAccessID(chatType, chatTarget);
	for i = 1, sourceChatFrame:GetNumMessages() do
		local text, r, g, b, chatTypeID, messageAccessID, lineID = sourceChatFrame:GetMessageInfo(i);
		if messageAccessID == accessID then
			frame:AddMessage(text, r, g, b, chatTypeID, messageAccessID, lineID);
		end
	end
	--Remove the messages from the old frame.
	sourceChatFrame:RemoveMessagesByPredicate(function(text, r, g, b, chatTypeID, messageAccessID, lineID) return messageAccessID == accessID; end);
end

-- This function is kept local for security reasons, as it's passed a
-- reference to the secure command list tables.

local getmetatable = getmetatable;
local securecallfunction = securecallfunction;
local secureexecuterange = secureexecuterange;
local tWipe = table.wipe;

local function ImportListToHash(list, hash)
	local function ImportHash(k, v, hash)
		local i = 1;
		local tag = _G["SLASH_"..k..i];
		while(tag) do
			tag = strupper(tag);
			if ( hash ) then
				hash[tag] = v;
			end
			hash_ChatTypeInfoList[tag] = k;	--Also need to import it here for all types.
			i = i + 1;
			tag = _G["SLASH_"..k..i];
		end
		--Add the item we removed to the proxy table.
		local proxyTable = getmetatable(list).__index;
		proxyTable[k] = v;
	end
	secureexecuterange(list, ImportHash, hash);
	securecallfunction(tWipe, list);
end

function ChatFrameUtil.ImportAllListsToHash()
	ImportListToHash(addonTbl.SecureCmdList, addonTbl.hash_SecureCmdList);
	ImportListToHash(SlashCmdList, hash_SlashCmdList);
	ImportListToHash(ChatTypeInfo);
end

function ChatFrameUtil.ImportEmoteTokensToHash()
	local i = 1;
	local j = 1;
	local cmdString = _G["EMOTE"..i.."_CMD"..j];
	while ( i <= MAXEMOTEINDEX ) do
		local token = _G["EMOTE"..i.."_TOKEN"];
		-- if the code in here changes - change the corresponding code above
		if ( token and cmdString) then
			hash_EmoteTokenList[strupper(cmdString)] = token;	-- add to hash
		end
		j = j + 1;
		cmdString = _G["EMOTE"..i.."_CMD"..j];
		if ( not cmdString ) then
			i = i + 1;
			j = 1;
			cmdString = _G["EMOTE"..i.."_CMD"..j];
		end
	end
end

function ChatFrameUtil.SetIMEShown(shown)
	CHAT_SHOW_IME = shown;
end

function ChatFrameUtil.GetTimestampFormat()
	local value = Settings.GetValue("showTimestamps");
	if value ~= "none" then
		return value;
	end
	return nil;
end

function ChatFrameUtil.HandleCautionaryChatMessage(hyperlinkLineID, confirmNumber)
	local function DoesMessageLineIDMatch(message, r, g, b, infoID, accessID, typeID, event, eventArgs, MessageFormatter, ...)
		if not eventArgs then
			return false;
		end

		local lineID = eventArgs[11];
		return lineID == hyperlinkLineID and type(eventArgs[2]) == "string";
	end

	local function SetMessage(message, r, g, b, infoID, accessID, typeID, event, eventArgs, MessageFormatter, ...)
		local lineID = eventArgs[11];
		local sendTo = eventArgs[2];

		local text = C_ChatInfo.GetChatLineText(lineID);
		local formatArg = MessageFormatter(text);
		local formattedText = CENSORED_MESSAGE_SENDER:format(formatArg, sendTo, lineID, confirmNumber, sendTo, lineID, confirmNumber, sendTo);
		return formattedText, r, g, b, infoID, accessID, typeID, event, eventArgs, MessageFormatter, ...;
	end

	-- The line may be present in multiple chat windows, particularly if chat settings are configured to
	-- send the line to both the default chat window and a whisper tab.
	ChatFrameUtil.ForEachChatFrame(function(chatFrame)
		chatFrame:TransformMessages(DoesMessageLineIDMatch, SetMessage);
	end);
end

local function ChatClassColorOverrideShown()
	local value = GetCVar("chatClassColorOverride");
	if value == "0" then
		return true;
	elseif value == "1" then
		return false;
	else
		return nil;
	end
end

function ChatFrameUtil.ShouldColorChatByClass(chatTypeInfo)
	local override = ChatClassColorOverrideShown();
	local colorByClass = chatTypeInfo and chatTypeInfo.colorNameByClass;
	return override or (override == nil and colorByClass);
end

function ChatFrameUtil.GetColoredChatName(chatType, chatTarget)
	if ( chatType == "CHANNEL" ) then
		local info = ChatTypeInfo["CHANNEL"..chatTarget];
		local colorString = format("|cff%02x%02x%02x", info.r * 255, info.g * 255, info.b * 255);
		local chanNum, channelName = GetChannelName(chatTarget);
		return format("%s|Hchannel:channel:%d|h[%d. %s]|h|r", colorString, chanNum, chanNum, gsub(channelName, "%s%-%s.*", ""));	--The gsub removes zone-specific markings (e.g. "General - Ironforge" to "General")
	elseif ( chatType == "WHISPER" ) then
		local info = ChatTypeInfo["WHISPER"];
		local colorString = format("|cff%02x%02x%02x", info.r * 255, info.g * 255, info.b * 255);
		return format("%s[%s] |Hplayer:%3$s|h[%3$s]|h|r", colorString, _G[chatType], chatTarget);
	else
		local info = ChatTypeInfo[chatType];
		local colorString = format("|cff%02x%02x%02x", info.r * 255, info.g * 255, info.b * 255);
		return format("%s|Hchannel:%s|h[%s]|h|r", colorString, chatType, _G[chatType]);
	end
end

function ChatFrameUtil.UpdateChatFrames()
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName];
		ChatFrameUtil.DeactivateChat(frame.editBox);
	end
	ChatFrameUtil.ActivateChat(FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK).editBox);
	ChatFrameUtil.DeactivateChat(FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK).editBox);
end

function ChatFrameUtil.GetCommunitiesChannelColor(clubId, streamId)
	local channel = ChatFrameUtil.GetCommunitiesChannel(clubId, streamId);
	if channel then
		local chatInfo = ChatTypeInfo[channel];
		if chatInfo then
			return ChatFrameUtil.GetChannelColor(chatInfo);
		end
	end

	local clubInfo = C_Club.GetClubInfo(clubId);
	if clubInfo then
		if clubInfo.clubType == Enum.ClubType.Guild then
			local streamInfo = C_Club.GetStreamInfo(clubId, streamId);
			local chatInfoType = (streamInfo and streamInfo.streamType == Enum.ClubStreamType.Officer) and "OFFICER" or "GUILD";
			return ChatFrameUtil.GetChannelColor(ChatTypeInfo[chatInfoType]);
		elseif clubInfo.clubType == Enum.ClubType.BattleNet then
			return BATTLENET_FONT_COLOR:GetRGB();
		end
	end

	return DEFAULT_CHAT_CHANNEL_COLOR:GetRGB();
end

function ChatFrameUtil.GetCommunityAndStreamName(clubId, streamId)
	local streamInfo = C_Club.GetStreamInfo(clubId, streamId);

	if streamInfo and (streamInfo.streamType == Enum.ClubStreamType.Guild or streamInfo.streamType == Enum.ClubStreamType.Officer) then
		return streamInfo.name;
	end

	local streamName = streamInfo and ChatFrameUtil.TruncateToMaxLength(streamInfo.name, ChatFrameConstants.TruncatedCommunityNameLength) or "";

	local clubInfo = C_Club.GetClubInfo(clubId);
	if streamInfo and streamInfo.streamType == Enum.ClubStreamType.General then
		local communityName = clubInfo and ChatFrameUtil.TruncateToMaxLength(clubInfo.shortName or clubInfo.name, ChatFrameConstants.TruncatedCommunityNameWithoutChannelLength) or "";
		return communityName;
	else
		local communityName = clubInfo and ChatFrameUtil.TruncateToMaxLength(clubInfo.shortName or clubInfo.name, ChatFrameConstants.TruncatedCommunityNameLength) or "";
		return communityName.." - "..streamName;
	end
end

function ChatFrameUtil.ResolveChannelName(communityChannel)
	local clubId, streamId = ChatFrameUtil.GetCommunityAndStreamFromChannel(communityChannel);
	if not clubId or not streamId then
		return communityChannel;
	end

	return ChatFrameUtil.GetCommunityAndStreamName(clubId, streamId);
end

function ChatFrameUtil.GetCommunitiesChannelLocalID(clubId, streamId)
	local channelName = ChatFrameUtil.GetCommunitiesChannelName(clubId, streamId);
	local localID = GetChannelName(channelName);
	return localID;
end

function ChatFrameUtil.AddCommunitiesChannel(chatFrame, channelName, channelColor, setEditBoxToChannel)
	local channelIndex = chatFrame:AddChannel(channelName);
	chatFrame:AddMessage(COMMUNITIES_CHANNEL_ADDED_TO_CHAT_WINDOW:format(channelIndex, ChatFrameUtil.ResolveChannelName(channelName)), channelColor:GetRGB());

	if setEditBoxToChannel then
		chatFrame.editBox:SetAttribute("channelTarget", channelIndex);
		chatFrame.editBox:SetAttribute("chatType", "CHANNEL");
		chatFrame.editBox:SetAttribute("stickyType", "CHANNEL");
		chatFrame.editBox:UpdateHeader();
	end
end

function ChatFrameUtil.AddNewCommunitiesChannel(chatFrameIndex, clubId, streamId, setEditBoxToChannel)
	local clubInfo = C_Club.GetClubInfo(clubId);
	if clubInfo then
		C_Club.AddClubStreamChatChannel(clubId, streamId);

		local channelColor = DEFAULT_CHAT_CHANNEL_COLOR;
		local channelName = ChatFrameUtil.GetCommunitiesChannelName(clubId, streamId);
		if clubInfo.clubType == Enum.ClubType.BattleNet then
			channelColor = BATTLENET_FONT_COLOR;

			local channel = ChatFrameUtil.GetCommunitiesChannel(clubId, streamId);
			ChangeChatColor(channel, channelColor:GetRGB());
		end

		local chatFrame = _G["ChatFrame"..chatFrameIndex];
		ChatFrameUtil.AddCommunitiesChannel(chatFrame, channelName, channelColor, setEditBoxToChannel);
	end
end

function ChatFrameUtil.RemoveCommunitiesChannel(chatFrame, clubId, streamId, omitMessage)
	local channelName = ChatFrameUtil.GetCommunitiesChannelName(clubId, streamId);
	local channelIndex = chatFrame:RemoveChannel(channelName);

	if not omitMessage then
		local r, g, b = ChatFrameUtil.GetCommunitiesChannelColor(clubId, streamId);
		chatFrame:AddMessage(COMMUNITIES_CHANNEL_REMOVED_FROM_CHAT_WINDOW:format(channelIndex, ChatFrameUtil.ResolveChannelName(channelName)), r, g, b);
	end
end

function ChatFrameUtil.GetSlashCommandForChannelOpenChat(localID)
	return "/" .. localID;
end

function ChatFrameUtil.RegisterForStickyFocus(frame)
	stickyFocusFrames[frame] = true;
end

function ChatFrameUtil.UnregisterForStickyFocus(frame)
	stickyFocusFrames[frame] = nil;
end

function ChatFrameUtil.HasStickyFocus()
	for frame in pairs(stickyFocusFrames) do
		if frame:HasStickyFocus() then
			return true;
		end
	end
	return false;
end

function ChatFrameUtil.FlashTabIfNotShown(chatFrame, info, type, chatGroup, chatTarget)
	if ( not chatFrame:IsShown() ) then
		if ( (chatFrame == DEFAULT_CHAT_FRAME and info.flashTabOnGeneral) or (chatFrame ~= DEFAULT_CHAT_FRAME and info.flashTab) ) then
			if ( type == "WHISPER" or type == "BN_WHISPER" ) then	--BN_WHISPER FIXME
				if (not FCFManager_ShouldSuppressMessageFlash(chatFrame, chatGroup, chatTarget) ) then
					FCF_StartAlertFlash(chatFrame);
				end
			end
		end
	end
end

function ChatFrameUtil.GetDecoratedSenderName(event, ...)
	local text, senderName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, languageID, lineID, senderGUID, bnSenderID, isMobile = ...;
	local chatType = string.sub(event, 10);

	if string.find(chatType, "^WHISPER") then
		chatType = "WHISPER";
	end

	if string.find(chatType, "^CHANNEL") then
		chatType = "CHANNEL" .. channelIndex;
	end

	local chatTypeInfo = ChatTypeInfo[chatType];
	local decoratedPlayerName = senderName;

	-- Ambiguate guild chat names
	if Ambiguate then
		if chatType == "GUILD" then
			decoratedPlayerName = Ambiguate(decoratedPlayerName, "guild");
		else
			decoratedPlayerName = Ambiguate(decoratedPlayerName, "none");
		end
	end

	-- Add timerunning icon when necessary based on player guid
	if senderGUID and C_ChatInfo.IsTimerunningPlayer(senderGUID) then
		decoratedPlayerName = TimerunningUtil.AddSmallIcon(decoratedPlayerName);
	end

	if senderGUID and chatTypeInfo and ChatFrameUtil.ShouldColorChatByClass(chatTypeInfo) and GetPlayerInfoByGUID ~= nil then
		local localizedClass, englishClass, localizedRace, englishRace, sex = GetPlayerInfoByGUID(senderGUID);

		if englishClass then
			local classColor = RAID_CLASS_COLORS[englishClass];

			if classColor then
				decoratedPlayerName = classColor:WrapTextInColorCode(decoratedPlayerName);
			end
		end
	end

	decoratedPlayerName = ChatFrameUtil.ProcessSenderNameFilters(event, decoratedPlayerName, ...);
	return decoratedPlayerName;
end

function GetRandomArgument(...)
	return (select(random(select("#", ...)), ...));
end

function RemoveExtraSpaces(str)
	return string.gsub(str, "     +", "    ");	--Replace all instances of 5+ spaces with only 4 spaces.
end

function RemoveNewlines(str)
	return string.gsub(str, "\n", "");
end

function SecureCmdItemParse(item)
	if ( not item ) then
		return nil, nil, nil;
	end
	local bag, slot = strmatch(item, "^(%d+)%s+(%d+)$");
	if ( not bag ) then
		slot = strmatch(item, "^(%d+)$");
	end
	if ( bag ) then
		item = C_Container.GetContainerItemLink(bag, slot);
	elseif ( slot ) then
		item = GetInventoryItemLink("player", slot);
	end
	return item, bag, slot;
end

function SecureCmdUseItem(name, bag, slot, target)
	if ( bag ) then
		C_Container.UseContainerItem(bag, slot, target);
	elseif ( slot ) then
		UseInventoryItem(slot, target);
	else
		C_Item.UseItemByName(name, target);
	end
end
