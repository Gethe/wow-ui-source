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

		self.DirtyFlags:MarkDirty(self.DirtyFlags.UpdateAll);

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

		self:AddEvents("PARTY_LEADER_CHANGED", "GROUP_ROSTER_UPDATE", "CHANNEL_UI_UPDATE", "CHANNEL_LEFT", "CHAT_MSG_CHANNEL_NOTICE_USER");

		local promptSubSystem = ChatAlertFrame:AddAutoAnchoredSubSystem(VoiceChatPromptActivateChannel);
		ChatAlertFrame:SetSubSystemAnchorPriority(promptSubSystem, 10);

		local notificationSubSystem = ChatAlertFrame:AddAutoAnchoredSubSystem(VoiceChatChannelActivatedNotification);
		ChatAlertFrame:SetSubSystemAnchorPriority(notificationSubSystem, 11);

		self:CheckDiscoverChannels();
	end
end

function ChannelFrameMixin:OnShow()
	self:SetEventsRegistered(true);
	self.DirtyFlags:MarkDirty(self.DirtyFlags.UpdateAll);
end

function ChannelFrameMixin:OnHide()
	self:SetEventsRegistered(false);
	StaticPopupSpecial_Hide(CreateChannelPopup);
end

function ChannelFrameMixin:OnEvent(event, ...)
	if event == "CHANNEL_UI_UPDATE" then
		self.DirtyFlags:MarkDirty(self.DirtyFlags.UpdateAll);
	elseif event == "CHANNEL_LEFT" then
		self:OnChannelLeft(...);
	elseif event == "PARTY_LEADER_CHANGED" then
		self:UpdatePartyChannelIfSelected();
	elseif event == "GROUP_ROSTER_UPDATE" then
		self:UpdatePartyChannelIfSelected()
	elseif event == "MUTELIST_UPDATE" then
		self.DirtyFlags:MarkDirty(self.DirtyFlags.UpdateRoster);
	elseif event == "IGNORELIST_UPDATE" then
		self.DirtyFlags:MarkDirty(self.DirtyFlags.UpdateRoster);
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
	end

	self:LogEvent(event, ...);
end

function ChannelFrameMixin:OnUpdate()
	self:Update();
end

function ChannelFrameMixin:SetLogEnabled(enabled)
	self.logEnabled = enabled;

	if enabled and not self.logEvents then
		-- Debug log events...these will find alternate homes soon, just want to get notifications going since I have no other way besides
		-- client breakpoints to see what voice is doing.
		self.logEvents = {
			VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED = true, -- VOICE_CHAT_CHANNEL_MEMBER_ENERGY_CHANGED = true,  <--- too spammy
			VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ME_CHANGED = true,
			VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ALL_CHANGED = true,
			VOICE_CHAT_CHANNEL_MEMBER_VOLUME_CHANGED = true,
		};
	end

	if self.logEvents then
		local registrationFn = enabled and self.RegisterEvent or self.UnregisterEvent;

		for k, v in pairs(self.logEvents) do
			registrationFn(self, k);
		end
	end
end

function ChannelFrameMixin:Log(message)
	if self.logEnabled then
		ConsolePrint(message);
	end
end

function ChannelFrameMixin:LogEvent(event, ...)
	if self.logEvents and self.logEvents[event] then
		local eventArgStrings = table.concat({ tostringall(...) }, ", ");
		self:Log(("%s : %s"):format(event, eventArgStrings));
	end
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

function ChannelFrameMixin:OnVoiceChannelJoined(statusCode, channelID)
	if statusCode == Enum.VoiceChatStatusCode.Success then
		self.DirtyFlags:MarkDirty(self.DirtyFlags.UpdateAll);
		self:CheckActivateChannel(channelID);
	end
end

local function GetChannelTypeFromPartyCategory(partyCategory)
	return (partyCategory == LE_PARTY_CATEGORY_HOME) and Enum.ChatChannelType.Party or Enum.ChatChannelType.Instance;
end

function ChannelFrameMixin:CheckActivateChannel(channelID)
	local channel = C_VoiceChat.GetChannel(channelID);
	if channel then
		if not channel.isActive then
			if C_VoiceChat.GetActiveChannelType() == channel.channelType then
				C_VoiceChat.ActivateChannel(channel.channelID);
			elseif C_ChatInfo.IsPartyChannelType(channel.channelType) then
				VoiceChatPromptActivateChannel:ShowPrompt(channel);
			end
		end
	end
end

function ChannelFrameMixin:TryCreateVoiceChannel(channelName)
	self:TryExecuteCommand(function()
		self:CreateVoiceChannel(channelName);
	end);
end

function ChannelFrameMixin:TryJoinVoiceChannelByType(channelType)
	self:TryExecuteCommand(function()
		C_VoiceChat.RequestChannelInfo(channelType);
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

	table.insert(self.queuedVoiceChannelCommands, cmd);
	C_VoiceChat.Login(); -- May already be in-flight, doesn't matter.
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

		self.DirtyFlags:MarkClean();
	end
end

function ChannelFrameMixin:UpdateChannelIfSelected(channelID)
	local channel = self:GetList():GetSelectedChannelButton();
	if channel and channel:IsTextChannel() and channel:GetChannelID() == channelID then
		self.DirtyFlags:MarkDirty(self.DirtyFlags.UpdateRoster);
	end
end

function ChannelFrameMixin:UpdateChannelByNameIfSelected(channelName)
	local channel = self:GetList():GetSelectedChannelButton();
	if channel and channel:IsTextChannel() and channel:GetChannelName() == channelName then
		self.DirtyFlags:MarkDirty(self.DirtyFlags.UpdateRoster);
	end
end

function ChannelFrameMixin:UpdatePartyChannelIfSelected()
	local channel = self:GetList():GetSelectedChannelButton();
	if channel and C_ChatInfo.IsPartyChannelType(channel:GetChannelType()) then
		self.DirtyFlags:MarkDirty(self.DirtyFlags.UpdateRoster);
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
	ShowOptionsPanel(VideoOptionsFrame, self, VOICE_LABEL);
end

-- Channel remains, but appears disabled
function ChannelFrameMixin:OnVoiceChannelRemoved(statusCode, channelID)
	if statusCode == Enum.VoiceChatStatusCode.Success then
		local button = self:GetList():GetButtonForVoiceChannelID(channelID);
		if button then
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
	if errorCode then
		local errorString = Voice_GetGameErrorStringFromStatusCode(statusCode);
		if errorString then
			UIErrorsFrame:TryDisplayMessage(errorCode, errorString, RED_FONT_COLOR:GetRGB());
			ChatFrame_DisplayUsageError(errorString);
		end
	end
end

function ChannelFrameMixin:OnVoiceChatConnectionSuccess()
	self:CheckDiscoverChannels();
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

function ChannelFrameMixin:OnVoiceChannelActivated(channelID)
	self:SetVoiceChannelActiveState(channelID, true);
end

function ChannelFrameMixin:OnVoiceChannelDeactivated(channelID)
	self:SetVoiceChannelActiveState(channelID, false);
end

function ChannelFrameMixin:SetVoiceChannelActiveState(channelID, isActive)
	local channelButton = self:GetList():GetButtonForVoiceChannelID(channelID);

	if channelButton then
		channelButton:SetVoiceActive(isActive);
		channelButton:Update();
	end
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
	self:TryJoinVoiceChannelByType(GetChannelTypeFromPartyCategory(partyCategory));
end

function ChannelFrameMixin:OnGroupLeft(partyCategory, partyGUID)
	-- TODO: This isn't fully correct, needs to check and see if you're still in a party and prompt to switch
	-- back to that party's voice chat (e.g. you just left pug and now you're seeing your private/home party again)
	-- ...need to verify some things related to zoning out of the instance/bg/etc...
	VoiceChatPromptActivateChannel:Hide();
	VoiceChatChannelActivatedNotification:Hide();

	-- TODO: Channel removal now happens as a matter of course on the server. Verify that the channel is being removed properly.
end

function ChannelFrameMixin:UpdateScrolling()
	self:GetRoster():UpdateRosterWidth();
end

function ChannelFrameMixin:OnUserSelectedChannel()
	self:GetRoster():ResetScrollPosition();
	self.DirtyFlags:MarkDirty(self.DirtyFlags.UpdateRoster);
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
	[Enum.ChatChannelType.Party] = VOICE_CHANNEL_NAME_PARTY,
	[Enum.ChatChannelType.Instance] = VOICE_CHANNEL_NAME_INSTANCE,
	[Enum.ChatChannelType.Raid] = VOICE_CHANNEL_NAME_RAID,
	[Enum.ChatChannelType.Battleground] = VOICE_CHANNEL_NAME_RAID,
};

function ChannelFrame_GetIdealChannelName(channel)
	if channel.name == "" then
		return channelTypeToNameLookup[channel.channelType] or "";
	end

	return channel.name or "";
end