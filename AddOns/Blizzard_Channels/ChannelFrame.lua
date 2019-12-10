UIPanelWindows["ChannelFrame"] = { area = "left", pushable = 1, whileDead = 1 };

ChannelFrameMixin = CreateFromMixins(EventRegistrationHelper);

do
	local dirtyFlags = {
		UpdateChannelList = 1,
		UpdateRoster = 2,
	};

	function ChannelFrameMixin:OnLoad()
		self.DirtyFlags = CreateFromMixins(DirtyFlagsMixin);
		self.DirtyFlags:OnLoad();
		self.DirtyFlags:AddNamedFlagsFromTable(dirtyFlags);
		self.DirtyFlags:AddNamedMask("UpdateAll", Flags_CreateMaskFromTable(dirtyFlags));
		self.DirtyFlags:AddNamedMask("CheckShowTutorial", 4);

		self:MarkDirty("UpdateAll");

		self:RegisterEvent("MUTELIST_UPDATE");
		self:RegisterEvent("IGNORELIST_UPDATE");
		self:RegisterEvent("CHANNEL_FLAGS_UPDATED");
		self:RegisterEvent("CHANNEL_COUNT_UPDATE");
		self:RegisterEvent("CHANNEL_ROSTER_UPDATE");
		self:RegisterEvent("VOICE_CHAT_LOGIN");
		self:RegisterEvent("VOICE_CHAT_LOGOUT");
		self:RegisterEvent("VOICE_CHAT_CHANNEL_JOINED");
		self:RegisterEvent("VOICE_CHAT_CHANNEL_ACTIVATED");
		self:RegisterEvent("VOICE_CHAT_CHANNEL_DEACTIVATED");
		self:RegisterEvent("VOICE_CHAT_CHANNEL_REMOVED");
		self:RegisterEvent("VOICE_CHAT_CHANNEL_DISPLAY_NAME_CHANGED");
		self:RegisterEvent("VOICE_CHAT_CONNECTION_SUCCESS");
		self:RegisterEvent("VOICE_CHAT_ERROR");
		self:RegisterEvent("GROUP_FORMED");
		self:RegisterEvent("GROUP_LEFT");
		self:RegisterEvent("CLUB_ADDED");
		self:RegisterEvent("CLUB_REMOVED");
		self:RegisterEvent("CLUB_STREAMS_LOADED");
		self:RegisterEvent("CLUB_STREAM_ADDED");
		self:RegisterEvent("CLUB_STREAM_REMOVED");
		self:RegisterEvent("CLUB_MEMBER_UPDATED");
		self:RegisterEvent("CLUB_MEMBER_PRESENCE_UPDATED");
		self:RegisterEvent("CLUB_MEMBER_ROLE_UPDATED");
		self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_ACTIVE_STATE_CHANGED");
		self:RegisterEvent("VOICE_CHAT_CHANNEL_TRANSMIT_CHANGED");
		self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ME_CHANGED");
		self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_ADDED");
		self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_GUID_UPDATED");

		self:AddEvents("PARTY_LEADER_CHANGED", "GROUP_ROSTER_UPDATE", "CHANNEL_UI_UPDATE", "CHANNEL_LEFT", "CHAT_MSG_CHANNEL_NOTICE_USER");

		local promptSubSystem = ChatAlertFrame:AddAutoAnchoredSubSystem(VoiceChatPromptActivateChannel);
		ChatAlertFrame:SetSubSystemAnchorPriority(promptSubSystem, 10);

		local notificationSubSystem = ChatAlertFrame:AddAutoAnchoredSubSystem(VoiceChatChannelActivatedNotification);
		ChatAlertFrame:SetSubSystemAnchorPriority(notificationSubSystem, 11);
	end
end

function ChannelFrameMixin:OnShow()
	-- Don't allow ChannelFrame and CommunitiesFrame to show at the same time, because they share one presence subscription
	if CommunitiesFrame and CommunitiesFrame:IsShown() then
		HideUIPanel(CommunitiesFrame);
	end

	ChatFrameChannelButton:HideTutorial();

	local channel = self:GetList():GetSelectedChannelButton();
	if channel and channel:ChannelIsCommunity() then
		C_Club.SetClubPresenceSubscription(channel.clubId);
	end

	self:SetEventsRegistered(true);
	self:MarkDirty("UpdateAll");
end

function ChannelFrameMixin:OnHide()
	C_Club.ClearClubPresenceSubscription();

	self:SetEventsRegistered(false);
	StaticPopupSpecial_Hide(CreateChannelPopup);
end

function ChannelFrameMixin:OnEvent(event, ...)
	if event == "CHANNEL_UI_UPDATE" then
		self:MarkDirty("UpdateAll");
	elseif event == "CHANNEL_LEFT" then
		self:OnChannelLeft(...);
	elseif event == "PARTY_LEADER_CHANGED" then
		self:UpdatePartyChannelIfSelected();
	elseif event == "GROUP_ROSTER_UPDATE" then
		self:UpdatePartyChannelIfSelected()
	elseif event == "MUTELIST_UPDATE" then
		self:MarkDirty("UpdateRoster");
	elseif event == "IGNORELIST_UPDATE" then
		self:MarkDirty("UpdateRoster");
	elseif event == "CHANNEL_FLAGS_UPDATED" then
		self:GetList():UpdateDropdownForChannel(self:GetDropdown(), ...);
	elseif event == "CHAT_MSG_CHANNEL_NOTICE_USER" then
		local channelName = select(9, ...);
		self:UpdateChannelByNameIfSelected(channelName);
	elseif event == "CHANNEL_COUNT_UPDATE" then
		self:OnCountUpdate(...);
	elseif event == "CHANNEL_ROSTER_UPDATE" then
		self:UpdateChannelIfSelected(...);
	elseif event == "VOICE_CHAT_LOGIN" then
		self:OnVoiceChatLogin(...);
	elseif event == "VOICE_CHAT_LOGOUT" then
		self:OnVoiceChatLogout();
	elseif event == "VOICE_CHAT_CHANNEL_JOINED" then
		self:OnVoiceChannelJoined(...);
	elseif event == "VOICE_CHAT_CHANNEL_ACTIVATED" then
		self:OnVoiceChannelActivated(...);
	elseif event == "VOICE_CHAT_CHANNEL_DEACTIVATED" then
		self:OnVoiceChannelDeactivated(...);
	elseif event == "VOICE_CHAT_CHANNEL_REMOVED" then
		self:OnVoiceChannelRemoved(...);
	elseif event == "VOICE_CHAT_CHANNEL_DISPLAY_NAME_CHANGED" then
		self:OnVoiceChannelDisplayNameChanged(...);
	elseif event == "VOICE_CHAT_CONNECTION_SUCCESS" then
		self:OnVoiceChatConnectionSuccess();
	elseif event == "VOICE_CHAT_ERROR" then
		self:OnVoiceChatError(...);
	elseif event == "GROUP_FORMED" then
		self:OnGroupFormed(...);
	elseif event == "GROUP_LEFT" then
		self:OnGroupLeft(...);
	elseif event == "CLUB_ADDED" then
		self:OnClubAdded(...);
	elseif event == "CLUB_REMOVED" then
		self:OnClubRemoved(...);
	elseif event == "CLUB_STREAMS_LOADED" then
		self:OnClubStreamsLoaded(...);
	elseif event == "CLUB_STREAM_ADDED" then
		self:OnClubStreamAdded(...);
	elseif event == "CLUB_STREAM_REMOVED" then
		self:OnClubStreamRemoved(...);
	elseif event == "CLUB_MEMBER_UPDATED" then
		self:UpdateCommunityChannelIfSelected(...);
	elseif event == "CLUB_MEMBER_PRESENCE_UPDATED" then
		self:UpdateCommunityChannelIfSelected(...);
	elseif event == "CLUB_MEMBER_ROLE_UPDATED" then
		self:UpdateCommunityChannelIfSelected(...);
	elseif event == "VOICE_CHAT_CHANNEL_MEMBER_ACTIVE_STATE_CHANGED" then
		self:OnMemberActiveStateChanged(...);
	elseif event == "VOICE_CHAT_CHANNEL_TRANSMIT_CHANGED" then
		self:OnChatChannelTransmitChanged(...);
	elseif event == "VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ME_CHANGED" then
		self:OnMemberMuted(...);
	elseif event == "VOICE_CHAT_CHANNEL_MEMBER_ADDED" then
		self:UpdateVoiceChannelIfSelected(select(2,...));
	elseif event == "VOICE_CHAT_CHANNEL_MEMBER_GUID_UPDATED" then
		self:UpdateVoiceChannelIfSelected(select(2,...));
	end
end

function ChannelFrameMixin:OnUpdate()
	self:Update();
end

function ChannelFrameMixin:GetList()
	return self.ChannelList;
end

function ChannelFrameMixin:GetRoster()
	return self.ChannelRoster;
end

function ChannelFrameMixin:GetDropdown()
	return self.Dropdown;
end

function ChannelFrameMixin:OnVoiceChannelJoined(statusCode, voiceChannelID, channelType, clubId, streamId)
	if statusCode == Enum.VoiceChatStatusCode.Success then
		if channelType == Enum.ChatChannelType.Communities then
			-- For community channels, just set the voice channel on the channel button
			local channelButton = self:GetList():GetButtonForCommunityStream(clubId, streamId);
			if channelButton then
				channelButton:SetVoiceChannel(C_VoiceChat.GetChannel(voiceChannelID));
			end
		else
			-- For other channels, set the voice channel on the channel button and then check if we want to show the activate prompts, etc.
			local channelButton = self:GetList():GetButtonForChannelType(channelType)
			if channelButton then
				channelButton:SetVoiceChannel(C_VoiceChat.GetChannel(voiceChannelID));
			end
			self:CheckActivateChannel(voiceChannelID);
			self:CheckChannelAnnounceState(voiceChannelID, "joined");
		end
	end
end

function ChannelFrameMixin:CheckActivateChannel(channelID)
	local channel = C_VoiceChat.GetChannel(channelID);
	if channel then
		if not channel.isActive then
			if C_VoiceChat.GetActiveChannelType() == channel.channelType then
				C_VoiceChat.ActivateChannel(channel.channelID);
			else
				VoiceChatPromptActivateChannel:CheckActivateChannel(channel);
			end
		end
	end
end

function ChannelFrameMixin:CheckShowTutorial()
	if self:ShouldShowTutorial() then
		local channels = self:GetList();
		local channelButton = channels:GetButtonForAnyVoiceChannel();
		if channelButton then
			self.Tutorial:ClearAllPoints();
			self.Tutorial:SetPoint("LEFT", channelButton, "RIGHT", 20, -1);
			self.Tutorial:Show();
		end
	end
end

function ChannelFrameMixin:HideTutorial()
	self.Tutorial:Hide();
end

function ChannelFrameMixin:ShouldShowTutorial()
	return false; -- Disabling this modern-style tutorial for Classic.
	--return UnitLevel("player") >= 10 and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_CHAT_CHANNELS);
end

function ChannelFrameMixin:TryCreateVoiceChannel(channelName)
	self:TryExecuteCommand(function()
		self:CreateVoiceChannel(channelName);
	end);
end

function ChannelFrameMixin:TryJoinVoiceChannelByType(channelType, autoActivate)
	self:TryExecuteCommand(function()
		C_VoiceChat.RequestJoinChannelByChannelType(channelType, autoActivate);
	end);
end

function ChannelFrameMixin:TryJoinCommunityStreamChannel(clubId, streamId)
	self:TryExecuteCommand(function()
		C_VoiceChat.RequestJoinAndActivateCommunityStreamChannel(clubId, streamId);
	end);
end

function ChannelFrameMixin:CreateVoiceChannel(channelName)
	local customChannelVoiceEnabled = false;
	if customChannelVoiceEnabled then
		C_VoiceChat.CreateChannel(channelName);
	end
end

function ChannelFrameMixin:OnVoiceChatLogin(loginStatusCode)
	if loginStatusCode == Enum.VoiceChatStatusCode.Success then
		if self.queuedVoiceChannelCommands then
			for index, cmd in ipairs(self.queuedVoiceChannelCommands) do
				cmd();
			end
		end
	end

	self.queuedVoiceChannelCommands = nil;
end

function ChannelFrameMixin:OnVoiceChatLogout()
	self.queuedVoiceChannelCommands = nil;
end

function ChannelFrameMixin:QueueVoiceChannelCommand(cmd)
	if not self.queuedVoiceChannelCommands then
		self.queuedVoiceChannelCommands = {};
	end

	local statusCode = C_VoiceChat.Login();
	if statusCode == Enum.VoiceChatStatusCode.OperationPending then
		table.insert(self.queuedVoiceChannelCommands, cmd);
	end
end

function ChannelFrameMixin:TryExecuteCommand(cmd)
	if C_VoiceChat.IsLoggedIn() then
		cmd();
	else
		self:QueueVoiceChannelCommand(cmd);
	end
end

function ChannelFrameMixin:Toggle()
	ToggleFrame(self);
end

function ChannelFrameMixin:Update()
	if self.DirtyFlags:IsDirty() then
		if self.DirtyFlags:IsDirty(self.DirtyFlags.UpdateChannelList) then
			self:GetList():Update();
		end

		if self.DirtyFlags:IsDirty(self.DirtyFlags.UpdateRoster) then
			self:GetRoster():Update();
		end

		if self.DirtyFlags:IsDirty(self.DirtyFlags.CheckShowTutorial) then
			self:CheckShowTutorial();
		end

		self.DirtyFlags:MarkClean();
	end
end

function ChannelFrameMixin:MarkDirty(maskName)
	self.DirtyFlags:MarkDirty(self.DirtyFlags[maskName]);
end

function ChannelFrameMixin:UpdateChannelIfSelected(channelID)
	local channel = self:GetList():GetSelectedChannelButton();
	if channel and channel:ChannelSupportsText() and channel:GetChannelID() == channelID then
		self:MarkDirty("UpdateRoster");
	end
end

function ChannelFrameMixin:UpdateChannelByNameIfSelected(channelName)
	local channel = self:GetList():GetSelectedChannelButton();
	if channel and channel:ChannelSupportsText() and channel:GetChannelName() == channelName then
		self:MarkDirty("UpdateRoster");
	end
end

function ChannelFrameMixin:UpdateVoiceChannelIfSelected(voiceChannelID)
	local channel = self:GetList():GetSelectedChannelButton();
	if channel and channel:ChannelSupportsVoice() and channel:GetVoiceChannelID() == voiceChannelID then
		self:MarkDirty("UpdateRoster");
	end
end

function ChannelFrameMixin:UpdatePartyChannelIfSelected()
	local channel = self:GetList():GetSelectedChannelButton();
	if channel and C_ChatInfo.IsPartyChannelType(channel:GetChannelType()) then
		self:MarkDirty("UpdateRoster");
	end
end

function ChannelFrameMixin:UpdateCommunityChannelIfSelected(clubId)
	local channel = self:GetList():GetSelectedChannelButton();
	if channel and channel:ChannelIsCommunity() and channel.clubId == clubId then
		self:MarkDirty("UpdateRoster");
	end
end

function ChannelFrameMixin:OnChannelLeft(channelID, channelName)
	self:GetList():OnChannelLeft(channelID, channelName);
end

function ChannelFrameMixin:TryCreateChannelFromPopup(name, password)
	local zoneChannel, channelName = JoinPermanentChannel(name, password, DEFAULT_CHAT_FRAME:GetID(), 1);
	if not zoneChannel then
		local info = ChatTypeInfo["CHANNEL"];
		DEFAULT_CHAT_FRAME:AddMessage(CHAT_INVALID_NAME_NOTICE, info.r, info.g, info.b, info.id);
	else
		if channelName then
			name = channelName;
		end

		-- TODO: Add API for this?
		local i = 1;
		while ( DEFAULT_CHAT_FRAME.channelList[i] ) do
			i = i + 1;
		end
		DEFAULT_CHAT_FRAME.channelList[i] = name;
		DEFAULT_CHAT_FRAME.zoneChannelList[i] = zoneChannel;
	end
end

function ChannelFrameMixin:ToggleCreateChannel()
	CreateChannelPopup:SetCallback(self, self.TryCreateChannelFromPopup)
	StaticPopupSpecial_Toggle(CreateChannelPopup);
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end

function ChannelFrameMixin:ToggleVoiceSettings()
	ShowOptionsPanel(VideoOptionsFrame, self, VOICE_CHAT);
end

-- Channel remains, but appears disabled
function ChannelFrameMixin:OnVoiceChannelRemoved(channelID)
	local button = self:GetList():GetButtonForVoiceChannelID(channelID);
	if button then
		if button:ChannelIsCommunity() then
			-- This is a community stream, so just remove the attached voice channel...we will try to re-join when they activate next
			button:ClearVoiceChannel();
		else
			button:SetActive(false);
			button:SetRemoved(true);
			button:Update();
		end
	end
end

function ChannelFrameMixin:OnVoiceChannelDisplayNameChanged(channelID, channelName)
	local button = self:GetList():GetButtonForVoiceChannelID(channelID);
	if button then
		-- TODO: Need to check if this is selected in the roster or dropdown menus and update those as well.
		button:SetChannelName(channelName);
		button:Update();
	end
end

function ChannelFrameMixin:OnVoiceChatError(platformCode, statusCode)
	local errorCode = Voice_GetGameErrorFromStatusCode(statusCode);
	local errorString = Voice_GetGameAlertStringFromStatusCode(statusCode);
	if errorString then
		UIErrorsFrame:TryDisplayMessage(errorCode, errorString, RED_FONT_COLOR:GetRGB());
		ChatFrame_DisplayUsageError(errorString);
		self.lastError = statusCode;
	end
end

function ChannelFrameMixin:OnVoiceChatConnectionSuccess()
	if self.lastError then
		ChatFrame_DisplayUsageError(VOICE_CHAT_SERVICE_CONNECTION_RESTORED);
		self.lastError = nil;
	end
end

function ChannelFrameMixin:CheckDiscoverChannels()
	if C_VoiceChat.ShouldDiscoverChannels() then
		local partyCategories = C_PartyInfo.GetActiveCategories();
		if partyCategories then
			for _, partyCategory in ipairs(partyCategories) do
				self:TryJoinVoiceChannelByType(GetChannelTypeFromPartyCategory(partyCategory));
			end
		end

		C_VoiceChat.MarkChannelsDiscovered();
	end
end

function ChannelFrameMixin:CheckChannelAnnounceState(channelID, state)
	if not self.channelStates then
		self.channelStates = {};
	end

	local previousState = self.channelStates[channelID];
	if state == "joined" then
		self:ShowChannelManagementTip(channelID);
	elseif state == "active" then
		self:ShowChannelAnnounce(channelID);
	end

	self.channelStates[channelID] = state;
end

local function CountActiveChannelMembers(channel)
	local count = 0;
	for index, member in pairs(channel.members) do
		if member.isActive then
			count = count + 1;
		end
	end

	-- TODO FIX: bug work-around, member active status not updated for local player when channel is initially activated.
	-- If the channel is marked active, then the local player must be active in it:
	if channel.isActive then
		return count + 1;
	else
		return count;
	end
end

function ChannelFrameMixin:ShowChannelAnnounce(channelID)
	local channel = C_VoiceChat.GetChannel(channelID);
	if channel then
		local notification = Voice_GetChannelActivatedNotification(channel);
		if notification then
			local atlas = CreateAtlasMarkup("voicechat-icon-headphone-on");
			local announce = Voice_FormatChannelNotification(channel, notification)
			local communicationMode = Voice_GetCommunicationModeNotification(channel);
			local memberCountMessage = VOICE_CHAT_CHANNEL_MEMBER_COUNT_ACTIVE:format(CountActiveChannelMembers(channel));
			ChatFrame_DisplaySystemMessageInPrimary(VOICE_CHAT_CHANNEL_ANNOUNCE:format(atlas..announce, communicationMode, memberCountMessage));
		end
	end
end

function ChannelFrameMixin:ShowChannelManagementTip(channelID)
	local channel = C_VoiceChat.GetChannel(channelID);
	if channel and GetPartyCategoryFromChannelType(channel.channelType) ~= nil then
		local atlas = CreateAtlasMarkup("voicechat-channellist-icon-headphone-off");
		local useNotBound = false;
		local useParentheses = true;
		local bindingText = GetBindingKeyForAction("TOGGLECHATTAB", useNotBound, useParentheses);
		if bindingText and bindingText ~= "" then
			local announceText = VOICE_CHAT_CHANNEL_MANAGEMENT_TIP:format(atlas, bindingText);
			ChatFrame_DisplaySystemMessageInPrimary(announceText);
		end
	end
end

function ChannelFrameMixin:OnVoiceChannelActivated(voiceChannelID)
	self:SetVoiceChannelActiveState(voiceChannelID, true);
	self:CheckChannelAnnounceState(voiceChannelID, "active");
	PlaySound(SOUNDKIT.UI_VOICECHAT_JOINCHANNEL);
end

function ChannelFrameMixin:OnVoiceChannelDeactivated(voiceChannelID)
	ChatFrame_DisplaySystemMessageInPrimary(VOICE_CHAT_CHANNEL_ANNOUNCE_PLAYER_LEFT);
	self:SetVoiceChannelActiveState(voiceChannelID, false);
	self:CheckChannelAnnounceState(voiceChannelID, "inactive");
	PlaySound(SOUNDKIT.UI_VOICECHAT_LEAVECHANNEL);
end

function ChannelFrameMixin:SetVoiceChannelActiveState(voiceChannelID, isActive)
	local channelButton = self:GetList():GetButtonForVoiceChannelID(voiceChannelID);

	if channelButton then
		channelButton:SetVoiceActive(isActive);
		channelButton:Update();
	end

	self:UpdateVoiceChannelIfSelected(voiceChannelID);
end

function ChannelFrameMixin:OnCountUpdate(id, count)
	local name, header, collapsed, channelNumber, count, active, category, channelType = GetChannelDisplayInfo(id);
	if self:IsCategoryGroup(category) and count then
		local channelButton = self:GetList():GetButtonForTextChannelID(id);
		if channelButton then
			channelButton:SetMemberCount(count);
			channelButton:Update();
		end
	end

	self:UpdateChannelIfSelected(id);
end

function ChannelFrameMixin:OnGroupFormed(partyCategory, partyGUID)
end

function ChannelFrameMixin:OnGroupLeft(partyCategory, partyGUID)
	-- TODO: This isn't fully correct, needs to check and see if you're still in a party and prompt to switch
	-- back to that party's voice chat (e.g. you just left pug and now you're seeing your private/home party again)
	-- ...need to verify some things related to zoning out of the instance/bg/etc...
	VoiceChatPromptActivateChannel:Hide();
	VoiceChatChannelActivatedNotification:Hide();
end

function ChannelFrameMixin:OnClubAdded(clubId)
	self:MarkDirty("UpdateChannelList");
end

function ChannelFrameMixin:OnClubRemoved(clubId)
	self:MarkDirty("UpdateChannelList");
end

function ChannelFrameMixin:OnClubStreamsLoaded(clubId)
	self:MarkDirty("UpdateChannelList");
end

function ChannelFrameMixin:OnClubStreamAdded(clubId, streamId)
	self:MarkDirty("UpdateChannelList");
end

function ChannelFrameMixin:OnClubStreamRemoved(clubId, streamId)
	self:MarkDirty("UpdateChannelList");
end

function ChannelFrameMixin:OnCommunityFavoriteChanged(clubId)
	self:MarkDirty("UpdateChannelList");
end

function ChannelFrameMixin:OnMemberActiveStateChanged(memberID, channelID, isActive)
	if not C_VoiceChat.IsMemberLocalPlayer(memberID, channelID) then
		local channel = C_VoiceChat.GetChannel(channelID);
		if channel and channel.isActive then
			local memberName = C_VoiceChat.GetMemberName(memberID, channelID) or "";
			if isActive then
				ChatFrame_DisplaySystemMessageInPrimary(VOICE_CHAT_CHANNEL_ANNOUNCE_MEMBER_ACTIVE:format(memberName));
				PlaySound(SOUNDKIT.UI_VOICECHAT_MEMBERJOINCHANNEL);
			else
				ChatFrame_DisplaySystemMessageInPrimary(VOICE_CHAT_CHANNEL_ANNOUNCE_MEMBER_LEFT:format(memberName));
				PlaySound(SOUNDKIT.UI_VOICECHAT_MEMBERLEAVECHANNEL);
			end
		end
	end
end

function ChannelFrameMixin:OnMemberMuted(memberID, channelID, isMuted)
	if isMuted then
		PlaySound(SOUNDKIT.UI_VOICECHAT_MUTEOTHERON);
	else
		PlaySound(SOUNDKIT.UI_VOICECHAT_MUTEOTHEROFF);
	end
end

function ChannelFrameMixin:OnChatChannelTransmitChanged(channelID, isTransmitting)
	if isTransmitting then
		PlaySound(SOUNDKIT.UI_VOICECHAT_TALKSTART);
	else
		PlaySound(SOUNDKIT.UI_VOICECHAT_STOPTALK);
	end
end

function ChannelFrameMixin:UpdateScrolling()
	self:GetRoster():UpdateRosterWidth();
end

function ChannelFrameMixin:OnUserSelectedChannel()
	self:GetRoster():ResetScrollPosition();
	self:MarkDirty("UpdateRoster");
end

function ChannelFrameMixin:IsCategoryGlobal(category)
	return category == "CHANNEL_CATEGORY_WORLD";
end

function ChannelFrameMixin:IsCategoryGroup(category)
	return category == "CHANNEL_CATEGORY_GROUP";
end

function ChannelFrameMixin:IsCategoryCustom(category)
	return category == "CHANNEL_CATEGORY_CUSTOM";
end

--[ Utility Functions ]--
function ChannelFrame_Desaturate(texture, desaturate, a)
	texture:SetDesaturated(desaturate);
	if ( a ) then
		texture:SetAlpha(a);
	end
end

local channelTypeToNameLookup =
{
	[Enum.ChatChannelType.Private_Party] = VOICE_CHANNEL_NAME_PARTY,
	[Enum.ChatChannelType.Public_Party] = VOICE_CHANNEL_NAME_INSTANCE,
};

function ChannelFrame_GetIdealChannelName(channel)
	if channel.name == "" then
		return channelTypeToNameLookup[channel.channelType] or "";
	end

	return channel.name or "";
end