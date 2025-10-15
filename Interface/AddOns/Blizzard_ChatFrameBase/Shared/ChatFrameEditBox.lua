local _, addonTbl = ...;
local hash_SlashCmdList = _G.hash_SlashCmdList;

-- The editbox mixin is split into a base and regular variant, with the base
-- mixin being used by the macro execution manager which doesn't inherit any
-- templates for its internal editbox.

ChatFrameEditBoxBaseMixin = {};

function ChatFrameEditBoxBaseMixin:GetChatType()
	return self:GetAttribute("chatType");
end

function ChatFrameEditBoxBaseMixin:SetChatType(chatType)
	self:SetAttribute("chatType", chatType);
end

function ChatFrameEditBoxBaseMixin:GetStickyType()
	return self:GetAttribute("stickyType");
end

function ChatFrameEditBoxBaseMixin:SetStickyType(stickyType)
	self:SetAttribute("stickyType", stickyType);
end

function ChatFrameEditBoxBaseMixin:GetChannelTarget()
	local channelTarget = self:GetAttribute("channelTarget"); -- may be a name or an index
	if channelTarget == nil then
		return 0;
	end

	local localID = GetChannelName(channelTarget);
	return localID;
end

function ChatFrameEditBoxBaseMixin:SetChannelTarget(channelTarget)
	self:SetAttribute("channelTarget", channelTarget);
end

function ChatFrameEditBoxBaseMixin:GetTellTarget()
	return self:GetAttribute("tellTarget");
end

function ChatFrameEditBoxBaseMixin:SetTellTarget(tellTarget)
	self:SetAttribute("tellTarget", tellTarget);
end

function ChatFrameEditBoxBaseMixin:AddHistory()
	-- No-op; implement in derived mixins.
end

function ChatFrameEditBoxBaseMixin:UpdateHeader()
	-- No-op; implement in derived mixins.
end

function ChatFrameEditBoxBaseMixin:ClearChat()
	-- If making changes here, consider also updating the ClearChat method
	-- in the derived ChatFrameEditBox mixin.

	self:ResetChatTypeToSticky();
	self:SetText("");
	self:Hide();
end

function ChatFrameEditBoxBaseMixin:ResetChatTypeToSticky()
	self:SetChatType(self:GetStickyType());
end

function ChatFrameEditBoxBaseMixin:ExtractTellTarget(msg, chatType)
	local tellTargetExtractionAutoComplete;
	if ( chatType == "WHISPER" ) then
		tellTargetExtractionAutoComplete = AUTOCOMPLETE_LIST.WHISPER_EXTRACT;
	else
		tellTargetExtractionAutoComplete = AUTOCOMPLETE_LIST.SMART_WHISPER_EXTRACT;
	end

	-- Grab the string after the slash command
	local target = strmatch(msg, "%s*(.*)");

	--If we haven't even finished one word, we aren't done.
	if ( not target or not strfind(target, "%s") ) then
		return false;
	end

	if ( strsub(target, 1, 1) == "|" ) then
		return false;
	end

	if ( #GetAutoCompleteResults(target, 1, 0, true, tellTargetExtractionAutoComplete.include, tellTargetExtractionAutoComplete.exclude) > 0 ) then
		--Even if there's a space, we still want to let the person keep typing -- they may be trying to type whatever is in AutoComplete.
		return false;
	end

	--Keep pulling off everything after the last space until we either have something on the AutoComplete list or only a single word is left.
	while ( strfind(target, "%s") ) do
		--Pull off everything after the last space.
		target = strmatch(target, "(.+)%s+[^%s]*");
		if ( #GetAutoCompleteResults(target, 1, 0, true, tellTargetExtractionAutoComplete.include, tellTargetExtractionAutoComplete.exclude) > 0 ) then
			break;
		end
	end
	msg = strsub(msg, strlen(target) + 2);

	if ( chatType ~= "WHISPER" and BNet_GetBNetIDAccount(target) ) then --"WHISPER" forces character whisper
		chatType = "BN_WHISPER";
	else
		chatType = "WHISPER";
	end
	return true, target, chatType, msg;
end

function ChatFrameEditBoxBaseMixin:ExtractChannel(msg)
	local target = strmatch(msg, "%s*([^%s]+)");
	if ( not target ) then
		return;
	end

	local channelNum, channelName = GetChannelName(target);
	if ( channelNum <= 0 ) then
		return;
	end

	msg = strsub(msg, strlen(target) + 2);

	self:SetChannelTarget(channelNum);
	self:SetChatType("CHANNEL");
	self:SetText(msg);
	self:UpdateHeader();
end

function ChatFrameEditBoxBaseMixin:ProcessChatType(msg, index, send)
	local autoCompleteInfo = AUTOCOMPLETE_LIST[index];
	if ( autoCompleteInfo ) then
		AutoCompleteEditBox_SetAutoCompleteSource(self, GetAutoCompleteResults, autoCompleteInfo.include, autoCompleteInfo.exclude);
	else
		AutoCompleteEditBox_SetAutoCompleteSource(self, nil);
	end

	local info = ChatTypeInfo[index];
	if ( info and not info.ignoreChatTypeProcessing ) then
		if ( index == "WHISPER" or index == "SMART_WHISPER" ) then
			local targetFound, target, chatType, parsedMsg = self:ExtractTellTarget(msg, index);
			if ( targetFound ) then
				self:SetTellTarget(target);
				self:SetChatType(chatType);
				self:SetText(parsedMsg);
				self:UpdateHeader();
			elseif ( send == 1 ) then
				self:ClearChat();
			end
		elseif ( index == "REPLY" ) then
			local lastTell, lastTellType = ChatFrameUtil.GetLastTellTarget();
			if ( lastTell ) then
				--BN_WHISPER FIXME
				self:SetChatType(lastTellType);
				self:SetTellTarget(lastTell);
				self:SetText(msg);
				self:UpdateHeader();
			else
				if ( send == 1 ) then
					self:ClearChat();
				end
			end
		elseif (index == "CHANNEL") then
			self:ExtractChannel(msg);
		else
			self:SetChatType(index);
			self:SetText(msg);
			self:UpdateHeader();
		end
		return true;
	end
	return false;
end

function ChatFrameEditBoxBaseMixin:HandleChatType(msg, command, send)
	local channel = strmatch(command, "/([0-9]+)$");
	if( channel ) then
		local chanNum = tonumber(channel);
		if ( chanNum > 0 and chanNum <= Constants.ChatFrameConstants.MaxChatChannels ) then
			local channelNum, channelName = GetChannelName(channel);
			if ( channelNum > 0 ) then
				self:SetChannelTarget(channelNum);
				self:SetChatType("CHANNEL");
				self:SetText(msg);
				self:UpdateHeader();
				return true;
			end
		end
	else
		-- first check the hash table
		ChatFrameUtil.ImportAllListsToHash();
		if ( hash_ChatTypeInfoList[command] ) then
			return self:ProcessChatType(msg, hash_ChatTypeInfoList[command], send);
		end
	end
	--This isn't one we found in our list, so we're not going to autocomplete.
	AutoCompleteEditBox_SetAutoCompleteSource(self, nil);
	return false;
end

function ChatFrameEditBoxBaseMixin:ParseText(send, parseIfNoSpaces)
	local text = self:GetText();
	if ( text == "" ) then
		return;
	end

	if ( strsub(text, 1, 1) ~= "/" ) then
		return;
	end

	--Do not bother parsing if there is no space in the message and we aren't sending.
	if ( send ~= 1 and not parseIfNoSpaces and not strfind(text, "%s") ) then
		return;
	end

	-- If the string is in the format "/cmd blah", command will be "/cmd"
	local command = strmatch(text, "^(/[^%s]+)") or "";
	local msg = "";

	if ( command ~= text ) then
		msg = strsub(text, strlen(command) + 2);
		msg = strmatch(msg, "^%s*(.*)$") or msg;
	end

	command = strupper(command);

	-- Check and see if we've got secure commands to run before we look for chat types or slash commands.
	-- This hash table is prepopulated, unlike the other ones, since nobody can add secure commands. (See line 1205 or thereabouts)
	-- We don't want this code to run unless send is 1, but we need HandleChatType to run when send is 1 as well, which is why we
	-- didn't just move HandleChatType inside the send == 0 conditional, which could have also solved the problem with insecure
	-- code having the ability to affect secure commands.

	if ( send == 1 and addonTbl.hash_SecureCmdList[command] ) then
		addonTbl.hash_SecureCmdList[command](strtrim(msg));
		self:AddHistoryLine(text);
		self:ClearChat();
		return;
	end

	ChatFrameUtil.ImportAllListsToHash();

	-- Handle chat types. No need for a securecall here, since we should be done with anything secure.
	if ( self:HandleChatType(msg, command, send) ) then
		return;
	end

	if ( send == 0 ) then
		return;
	end

	-- Check the hash tables for slash commands and emotes to see if we've run this before.
	if ( hash_SlashCmdList[command] ) then
		-- if the code in here changes - change the corresponding code below
		hash_SlashCmdList[command](strtrim(msg), self);
		self:AddHistoryLine(text);
		self:ClearChat();
		return;
	elseif ( hash_EmoteTokenList[command] ) then
		-- if the code in here changes - change the corresponding code below
		local restricted = C_ChatInfo.PerformEmote(hash_EmoteTokenList[command], msg);
		-- If the emote is restricted, we want to treat it as if the player entered an unrecognized chat command.
		if ( not restricted ) then
			self:AddHistoryLine(text);
			self:ClearChat();
			return;
		end
	end

	-- Unrecognized chat command, show simple help text
	if ( self.chatFrame ) then
		ChatFrameUtil.DisplayHelpTextSimple(self.chatFrame);
	end

	-- Reset the chat type and clear the edit box's contents
	self:ClearChat();
end

function ChatFrameEditBoxBaseMixin:SendText(addHistory)
	self:ParseText(1);
	local type = self:GetChatType();
	local text = self:GetText();
	if ( strfind(text, "%s*[^%s]+") ) then
		text = ChatFrameUtil.SubstituteChatMessageBeforeSend(text);
		--BN_WHISPER FIXME
		if ( type == "WHISPER") then
			local target = self:GetTellTarget();
			ChatFrameUtil.SetLastToldTarget(target, type);
			C_ChatInfo.SendChatMessage(text, type, self.languageID, target);
		elseif ( type == "BN_WHISPER" ) then
			local target = self:GetTellTarget();
			local bnetIDAccount = BNet_GetBNetIDAccount(target);
			if ( bnetIDAccount ) then
				ChatFrameUtil.SetLastToldTarget(target, type);
				C_BattleNet.SendWhisper(bnetIDAccount, text);
			else
				ChatFrameUtil.DisplaySystemMessageInPrimary(format(BN_UNABLE_TO_RESOLVE_NAME, target));
			end
		elseif ( type == "CHANNEL") then
			C_ChatInfo.SendChatMessage(text, type, self.languageID, self:GetChannelTarget());
		else
			C_ChatInfo.SendChatMessage(text, type, self.languageID);
		end
		if ( addHistory ) then
			self:AddHistory();
		end
	end
end

ChatFrameEditBoxMixin = CreateFromMixins(ChatFrameEditBoxBaseMixin);

function ChatFrameEditBoxMixin:OnLoad()
	self:SetFrameLevel(self.chatFrame:GetFrameLevel()+1);
	self:SetChatType("SAY");
	self:SetStickyType("SAY");
	self.chatLanguage = GetDefaultLanguage();
	self:RegisterEvent("UPDATE_CHAT_COLOR");

	self.addSpaceToAutoComplete = true;
	self.addHighlightedText = true;

	local function ChatEditAutoComplete(editBox, fullText, nameInfo, ambiguatedName)
		if hash_ChatTypeInfoList[string.upper(editBox.command)] == "SMART_WHISPER" then
			if nameInfo.bnetID ~= nil and nameInfo.bnetID ~= 0 then
				editBox:SetTellTarget(nameInfo.name);
				editBox:SetChatType("BN_WHISPER");
			else
				editBox:SetTellTarget(ambiguatedName);
				editBox:SetChatType("WHISPER");
			end
			editBox:SetText("");
			editBox:UpdateHeader();
			return true;
		end

		return false;
	end

	AutoCompleteEditBox_SetCustomAutoCompleteFunction(self, ChatEditAutoComplete);

	self:SetParent(UIParent);
end

function ChatFrameEditBoxMixin:OnEvent(event, ...)
	if ( event == "UPDATE_CHAT_COLOR" ) then
		local chatType = ...;
		if ( self:IsShown() ) then
			self:UpdateHeader();
		end
	end
end

function ChatFrameEditBoxMixin:OnUpdate(elapsedSec)
	if ( self.setText == 1) then
		self:SetText(self.text);
		self.setText = 0;
		self:ParseText(0, true);

		if self.desiredCursorPosition then
			self:SetCursorPosition(self.desiredCursorPosition);
			self.desiredCursorPosition = nil;
		end
	end
end

function ChatFrameEditBoxMixin:OnShow()
	self:ResetChatType();
end

function ChatFrameEditBoxMixin:OnHide()
	if ( ACTIVE_CHAT_EDIT_BOX == self ) then
		ChatFrameUtil.DeactivateChat(self);
	end

	if ( LAST_ACTIVE_CHAT_EDIT_BOX == self and ( self.disableActivate or self:IsShown() ) ) then	--Our parent was hidden. Let's find a new default frame.
		--We'll go with the active dock frame since people think of that as the primary chat.
		ChatFrameUtil.SetLastActiveWindow(FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK).editBox);
	end
end

function ChatFrameEditBoxMixin:OnEditFocusGained()
	ChatFrameUtil.ActivateChat(self);
end

function ChatFrameEditBoxMixin:OnEditFocusLost()
	AutoCompleteEditBox_OnEditFocusLost(self);

	if self:ShouldDeactivateChatOnEditFocusLost() then
		ChatFrameUtil.DeactivateChat(self);
	end
end

function ChatFrameEditBoxMixin:OnEnterPressed()
	if(AutoCompleteEditBox_OnEnterPressed(self)) then
		return;
	end
	self:SendText(1);

	local type = self:GetChatType();
	local chatFrame = self:GetParent();
	if ( chatFrame.isTemporary and chatFrame.chatType ~= "PET_BATTLE_COMBAT_LOG" ) then --Temporary window sticky types never change.
		self:SetStickyType(chatFrame.chatType);
		--BN_WHISPER FIXME
		if ( chatFrame.chatType == "WHISPER" or chatFrame.chatType == "BN_WHISPER" ) then
			self:SetTellTarget(chatFrame.chatTarget);
		end
	elseif ( ChatTypeInfo[type].sticky == 1 ) then
		self:SetStickyType(type);
	end

	self:ClearChat();
end

function ChatFrameEditBoxMixin:OnEscapePressed()
	if ( not AutoCompleteEditBox_OnEscapePressed(self) ) then
		self:ClearChat();
	end
end

function ChatFrameEditBoxMixin:OnSpacePressed()
	self:ParseText(0);
end

function ChatEdit_CustomTabPressed(editBox)
	-- This function is left intentionally global as it is used to enable
	-- secure tab completion hooks in addons.
end

function ChatFrameEditBoxMixin:OnTabPressed()
	if ( not AutoCompleteEditBox_OnTabPressed(self) ) then
		if ( securecall("ChatEdit_CustomTabPressed", self) ) then
			return;
		end
		self:SecureTabPressed();
	end
end

function ChatFrameEditBoxMixin:OnTextChanged(userInput)
	self:ParseText(0);
	if ( not self.ignoreTextChange ) then
		self.lastTabComplete = nil;
		self.tabCompleteText = nil;
		self.tabCompleteTableIndex = 1;
	end
	self.ignoreTextChange = nil;
	local regex = "^((/[^%s]+)%s+(.+))"
	local full, command, target = strmatch(self:GetText(), regex);
	if ( not target or (strsub(target, 1, 1) == "|") or self.disallowAutoComplete) then
		AutoComplete_HideIfAttachedTo(self);
		return;
	end

	if ( userInput ) then
		self.autoCompleteXOffset = 35;
		AutoComplete_Update(self, target, self:GetUTF8CursorPosition() - strlenutf8(command) - 1);
	end
end

local symbols = {"%%", "%*", "%+", "%-", "%?", "%(", "%)", "%[", "%]", "%$", "%^"} --% has to be escaped first or everything is ruined
local replacements = {"%%%%", "%%%*", "%%%+", "%%%-", "%%%?", "%%%(", "%%%)", "%%%[", "%%%]", "%%%$", "%%%^"}
local function escapePatternSymbols(text)
	for i=1, #symbols do
		text = text:gsub(symbols[i], replacements[i])
	end
	return text
end

function ChatFrameEditBoxMixin:OnChar()
	local regex = "^((/[^%s]+)(%s+)(.+))$"
	local text, command, whitespace, target = strmatch(self:GetText(), regex);
	if (command) then
		self.command = command
	else
		self.command = nil;
	end
	if (command and target and self.autoCompleteSource and self.autoCompleteParams) then --if they typed a command with a autocompletable target
		local utf8Position = self:GetUTF8CursorPosition();
		local allowFullMatch = false;
		local nameToShow = self.autoCompleteSource(target, 1, utf8Position, allowFullMatch, unpack(self.autoCompleteParams))[1];
		if (nameToShow and nameToShow.name) then
			local name = Ambiguate and Ambiguate(nameToShow.name, "all") or nameToShow.name;
			--We're going to be setting the text programatically which will clear the userInput flag on the editBox.
			--So we want to manually update the dropdown before we change the text.
			AutoComplete_Update(self, target, utf8Position - strlenutf8(command) - strlen(whitespace));
			if strsub(name, 1, 1) ~= "|" then
				target = escapePatternSymbols(target);

				local newTarget = name;
				self:SetText(string.format("%s%s%s", command, whitespace, newTarget));
				self:HighlightText(strlen(text), strlen(command) + strlen(whitespace) + strlen(newTarget));
			end
		end
	end
end

function ChatFrameEditBoxMixin:OnTextSet()
	self:ParseText(0);
end

function ChatFrameEditBoxMixin:OnInputLanguageChanged()
	local button = _G[self:GetName().."Language"];
	local variable = _G["INPUT_"..self:GetInputLanguage()];
	button:SetText(variable);
end

function ChatFrameEditBoxMixin:ClearChat()
	self:ResetChatTypeToSticky();
	if ( not self.isGM and ((not IsVoiceTranscription(self.chatFrame) and GetCVar("chatStyle") ~= "im")) ) then
		self:SetText("");
		self:Hide();
	else
		ChatFrameUtil.DeactivateChat(self);
	end
end

function ChatFrameEditBoxMixin:Deactivate()
	self:SetFrameStrata("LOW");
	if ( self.disableActivate or (GetCVar("chatStyle") == "classic" and not IsVoiceTranscription(self.chatFrame)) and not self.isGM ) then
		self:Hide();
	else
		self:SetText("");
		self.header:Hide();
		if ( not self.isGM ) then
			self:SetAlpha(0.35);
		end
		self:UpdateNewcomerEditBoxHint();
		self:ClearFocus();

		self:SetFocusRegionsShown(false);
		self:ResetChatTypeToSticky();
		self:ResetChatType();
	end
	_G[self:GetName().."Language"]:Hide();
end

function ChatFrameEditBoxMixin:ResetChatType()
	if ( self:GetChatType() == "PARTY" and (not IsInGroup(LE_PARTY_CATEGORY_HOME)) ) then
		self:SetChatType("SAY");
	end
	if ( self:GetChatType() == "RAID" and (not IsInRaid(LE_PARTY_CATEGORY_HOME)) ) then
		self:SetChatType("SAY");
	end
	if ( (self:GetChatType() == "GUILD" or self:GetChatType() == "OFFICER") and not IsInGuild() ) then
		self:SetChatType("SAY");
	end
	if ( self:GetChatType() == "INSTANCE_CHAT" and (not IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) ) then
		self:SetChatType("SAY");
	end

	-- GAME RULES TODO:: The game modes portion here should be an explicit game rule.
	if ( C_Glue.IsOnGlueScreen() and (C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm) and IsInGroup(LE_PARTY_CATEGORY_HOME) ) then
		self:SetChatType("PARTY");
	end

	self.lastTabComplete = nil;
	self.tabCompleteText = nil;
	self.tabCompleteTableIndex = 1;
	self:UpdateHeader();
	self:OnInputLanguageChanged();
end

local chatTypesThatRequireTellTarget =
{
	BN_WHISPER = true,
	WHISPER = true,
	SMART_WHISPER = true,
};

function ChatFrameEditBoxMixin:UpdateHeader()
	ChatFrameEditBoxBaseMixin.UpdateHeader(self);

	local type = self:GetChatType();
	if ( not type ) then
		return;
	end

	local tellTarget  = self:GetTellTarget();
	if not tellTarget and chatTypesThatRequireTellTarget[type] then
		return;
	end

	local info;
	if ( type == "VOICE_TEXT" and VoiceTranscription_GetChatTypeAndInfo ) then
		-- This can occur after loading ChatFrame.lua and before loading VoiceChatTranscriptionFrame.lua due to loading screen event signals, so nil check is required before calling the function.
		type, info = VoiceTranscription_GetChatTypeAndInfo();
	else
		info = ChatTypeInfo[type];
	end

	local header = _G[self:GetName().."Header"];
	local headerSuffix = _G[self:GetName().."HeaderSuffix"];
	if ( not header ) then
		return;
	end

	header:SetWidth(0);
	--BN_WHISPER FIXME
	if ( type == "SMART_WHISPER" ) then
		--If we have a bnetIDAccount or this name, it's a BN whisper.
		if ( BNet_GetBNetIDAccount(tellTarget) ) then
			self:SetChatType("BN_WHISPER");
		else
			self:SetChatType("WHISPER");
		end
		self:UpdateHeader();
		return;
	elseif ( type == "WHISPER" ) then
		header:SetFormattedText(CHAT_WHISPER_SEND, tellTarget);
	elseif ( type == "BN_WHISPER" ) then
		header:SetFormattedText(CHAT_BN_WHISPER_SEND, tellTarget);
	elseif ( type == "EMOTE" ) then
		header:SetFormattedText(CHAT_EMOTE_SEND, UnitName("player"));
	elseif ( type == "CHANNEL" ) then
		local localID, channelName, instanceID, isCommunitiesChannel = GetChannelName(self:GetChannelTarget());
		if ( channelName ) then
			if ( isCommunitiesChannel ) then
				channelName = ChatFrameUtil.ResolveChannelName(channelName);
			elseif ( instanceID > 0 ) then
				channelName = channelName.." "..instanceID;
			end
			info = ChatTypeInfo["CHANNEL"..localID];
			self:SetChannelTarget(localID);
			header:SetFormattedText(CHAT_CHANNEL_SEND, localID, channelName);
		end
	elseif ( (type == "PARTY") and
		 (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) ) then
		 --Smartly switch to instance chat
		self:SetChatType("INSTANCE_CHAT");
		self:UpdateHeader();
		return;
	elseif ( (type == "RAID") and
		 (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) ) then
		 --Smartly switch to instance chat
		self:SetChatType("INSTANCE_CHAT");
		self:UpdateHeader();
		return;
	elseif ( (type == "INSTANCE_CHAT") and
		(IsInGroup(LE_PARTY_CATEGORY_HOME) and not IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) )then
		if ( IsInRaid(LE_PARTY_CATEGORY_HOME) ) then
			self:SetChatType("RAID");
		else
			self:SetChatType("PARTY");
		end
		self:UpdateHeader();
		return;
	elseif ( type == "COMMUNITIES_CHANNEL" and info.channelName ) then
		header:SetFormattedText(CHAT_CHANNEL_SEND_NO_ID, info.channelName);
	else
		header:SetText(_G["CHAT_"..type.."_SEND"]);
	end

	local headerWidth = (header:GetRight() or 0) - (header:GetLeft() or 0);
	local editBoxWidth = (self:GetRight() or 0) - (self:GetLeft() or 0);

	if ( headerWidth > editBoxWidth / 2 ) then
		header:SetWidth(editBoxWidth / 2);
		headerSuffix:Show();
	else
		headerSuffix:Hide();
	end

	header:SetTextColor(info.r, info.g, info.b);
	headerSuffix:SetTextColor(info.r, info.g, info.b);

	local languageHeaderWidth = self:UpdateLanguageHeader();
	self:SetTextInsets(15 + header:GetWidth() + (headerSuffix:IsShown() and headerSuffix:GetWidth() or 0) + languageHeaderWidth, 13, 0, 0);
	self:SetTextColor(info.r, info.g, info.b);
	self:SetFocusRegionVertexColors(info);
end

function ChatFrameEditBoxMixin:UpdateLanguageHeader()
	-- Overridden in flavor-specific files.
	local languageHeaderWidth = 0;
	return languageHeaderWidth;
end

function ChatFrameEditBoxMixin:SetFocusRegionVertexColors(color)
	-- Overridden in flavor-specific files.
end

function ChatFrameEditBoxMixin:SetFocusRegionsShown(shown)
	-- Overridden in flavor-specific files.
end

function ChatFrameEditBoxMixin:DoesCurrentChannelTargetMatch(localID)
	local type = self:GetChatType();
	if type == "CHANNEL" then
		return self:GetChannelTarget() == localID;
	end

	return false;
end

function ChatFrameEditBoxMixin:AddHistory()
	local text = "";
	local type = self:GetChatType();
	local header = _G["SLASH_"..type.."1"];
	if ( header ) then
		text = header;
	end

	if ( type == "WHISPER" ) then
		text = text.." "..self:GetTellTarget();
	elseif ( type == "CHANNEL" ) then
		text = "/"..self:GetChannelTarget();
	end

	local editBoxText = self:GetText();
	if ( editBoxText ~= "" ) then
		text = text.." "..self:GetText();
	end

	if ( text ~= "" ) then
		self:AddHistoryLine(text);
	end
end

local tabCompleteTables = { hash_ChatTypeInfoList, hash_EmoteTokenList };

local function SearchTabCompleteTable(tableCompleteTable, command, cmdString)
	repeat	--Loop through this table to find matching items.
		cmdString = next(tableCompleteTable, cmdString);
	until ( not cmdString or strfind(cmdString, strupper(command), 1, 1) );	--Either we finished going through this table or we found a match.
	return cmdString;
end

function ChatFrameEditBoxMixin:SecureTabPressed()
	local chatType = self:GetChatType();
	if ( chatType == "WHISPER" or chatType == "BN_WHISPER" ) then
		local newTarget, newTargetType = ChatFrameUtil.GetNextTellTarget(self:GetTellTarget(), chatType);
		if ( newTarget and newTarget ~= "" ) then
			self:SetChatType(newTargetType);
			self:SetTellTarget(newTarget);
			self:UpdateHeader();
		end
		return;
	end

	local text = self.tabCompleteText;
	if ( not text ) then
		text = self:GetText();
		self.tabCompleteText = text;
	end

	if ( strsub(text, 1, 1) ~= "/" ) then
		return;
	end

	ChatFrameUtil.ImportAllListsToHash();

	local lastTabComplete = self.lastTabComplete;

	-- If the string is in the format "/cmd blah", command will be "/cmd"
	local command = strmatch(text, "^(/[^%s]+)") or "";

	local cmdString = lastTabComplete;
	repeat	--The outer loop lets us go through multiple hash tables of commands.
		cmdString = securecallfunction(SearchTabCompleteTable, tabCompleteTables[self.tabCompleteTableIndex], command, cmdString);
		if ( not cmdString ) then	--Nothing else in the current table, move to the next one.
			self.tabCompleteTableIndex = self.tabCompleteTableIndex + 1;
		end
	until ( cmdString or self.tabCompleteTableIndex > #tabCompleteTables );

	self.lastTabComplete = cmdString;
	if ( cmdString ) then
		self.ignoreTextChange = 1;
		self:SetText(strlower(cmdString));
	else
		self.tabCompleteTableIndex = 1;
		self:SetText(self.tabCompleteText);
	end
end

function ChatFrameEditBoxMixin:SetGameLanguage(language, languageId)
	self.language = language;
	self.languageID = languageId;
	self:UpdateHeader();
end

function ChatFrameEditBoxMixin:HasStickyFocus()
	return ChatFrameUtil.HasStickyFocus();
end
