ChatFrameMixin = {};

function ChatFrameMixin:OnEvent(event, ...)
	if ( self.customEventHandler and self.customEventHandler(self, event, ...) ) then
		return;
	end

	if ( self:ConfigEventHandler(event, ...) ) then
		return;
	end
	if ( self:SystemEventHandler(event, ...) ) then
		return
	end
	if ( self:MessageEventHandler(event, ...) ) then
		return
	end
end

function ChatFrameMixin:OnHyperlinkClick(link, text, button)
	EventRegistry:TriggerEvent("ChatFrame.OnHyperlinkClick", self, link, text, button);

	if not C_Glue.IsOnGlueScreen() then
		SetItemRef(link, text, button, self);
	end
end

function ChatFrameMixin:OnHyperlinkEnter(link, text, region, boundsLeft, boundsBottom, boundsWidth, boundsHeight)
	EventRegistry:TriggerEvent("ChatFrame.OnHyperlinkEnter", self, link, text, region, boundsLeft, boundsBottom, boundsWidth, boundsHeight);
end

function ChatFrameMixin:OnHyperlinkLeave()
	EventRegistry:TriggerEvent("ChatFrame.OnHyperlinkLeave", self);
end

function ChatFrameMixin:AddMessage(...)
	ScrollingMessageFrameSecureMixin.AddMessage(self, ...);

	if ( self.addMessageObserver ) then
		self.addMessageObserver(self, ...);
	end
end

function ChatFrameMixin:RegisterForMessages(...)
	local messageGroup;
	local index = 1;
	for i=1, select("#", ...) do
		messageGroup = ChatTypeGroup[select(i, ...)];
		if ( messageGroup ) then
			self.messageTypeList[index] = select(i, ...);
			for _, value in pairs(messageGroup) do
				self:RegisterEvent(value);
				if ( value == "CHAT_MSG_VOICE_TEXT" ) then
					self:RegisterEvent("VOICE_CHAT_CHANNEL_TRANSCRIBING_CHANGED");
				end
			end
			index = index + 1;
		end
	end
end

function ChatFrameMixin:RegisterForChannels(...)
	local index = 1;
	for i=1, select("#", ...), 2 do
		self.channelList[index], self.zoneChannelList[index] = select(i, ...);
		index = index + 1;
	end
end

function ChatFrameMixin:AddMessageGroup(group)
	local info = ChatTypeGroup[group];
	if ( info ) then
		tinsert(self.messageTypeList, group);
		for index, value in pairs(info) do
			self:RegisterEvent(value);
		end
		AddChatWindowMessages(self:GetID(), group);
	end
end

function ChatFrameMixin:ContainsMessageGroup(group)
	for i, messageType in pairs(self.messageTypeList) do
		if group == messageType then
			return true;
		end
	end

	return false;
end

function ChatFrameMixin:AddSingleMessageType(messageType)
	local group = ChatTypeGroupInverted[messageType];
	local info = ChatTypeGroup[group];
	if ( info ) then
		if (not tContains(self.messageTypeList, group)) then
			tinsert(self.messageTypeList, group);
		end
		for index, value in pairs(info) do
			if (value == messageType) then
				self:RegisterEvent(value);
			end
		end
	end
end

function ChatFrameMixin:RemoveMessageGroup(group)
	local info = ChatTypeGroup[group];
	if ( info ) then
		for index, value in pairs(self.messageTypeList) do
			if ( strupper(value) == strupper(group) ) then
				self.messageTypeList[index] = nil;
			end
		end
		for index, value in pairs(info) do
			self:UnregisterEvent(value);
		end
		RemoveChatWindowMessages(self:GetID(), group);
	end
end

function ChatFrameMixin:UnregisterAllMessageGroups()
	for index, value in pairs(self.messageTypeList) do
		for eventIndex, eventValue in pairs(ChatTypeGroup[value]) do
			self:UnregisterEvent(eventValue);
		end
	end

	self.messageTypeList = {};
end

function ChatFrameMixin:RemoveAllMessageGroups()
	for index, value in pairs(self.messageTypeList) do
		RemoveChatWindowMessages(self:GetID(), value);
	end

	-- Must be after "for" loop because this call clears messageTypeList.
	self:UnregisterAllMessageGroups();
end

function ChatFrameMixin:ContainsChannel(channel)
	for i, channelName in pairs(self.channelList) do
		if channel == channelName then
			return true;
		end
	end

	return false;
end

function ChatFrameMixin:AddChannel(channel)
	if ( not AddChatWindowChannel ) then
		return nil;
	end

	local channelIndex = nil;
	local zoneChannel = AddChatWindowChannel(self:GetID(), channel);
	if ( zoneChannel ) then
		local i = 1;
		while ( self.channelList[i] ) do
			i = i + 1;
		end
		self.channelList[i] = channel;
		self.zoneChannelList[i] = zoneChannel;

		local localId = GetChannelName(channel);
		channelIndex = localId;
	end

	return channelIndex;
end

function ChatFrameMixin:SetChannelEnabled(channel, enabled)
	if enabled then
		self:AddChannel(channel);
	else
		self:RemoveChannel(channel);
	end
end

function ChatFrameMixin:RemoveChannel(channel)
	for index, value in pairs(self.channelList) do
		if ( strupper(channel) == strupper(value) ) then
			self.channelList[index] = nil;
			self.zoneChannelList[index] = nil;
		end
	end

	local localId = GetChannelName(channel);
	RemoveChatWindowChannel(self:GetID(), channel);
	return localId;
end

function ChatFrameMixin:RemoveAllChannels()
	for index, value in pairs(self.channelList) do
		RemoveChatWindowChannel(self:GetID(), value);
	end
	self.channelList = {};
	self.zoneChannelList = {};
end

function ChatFrameMixin:AddPrivateMessageTarget(chatTarget)
	self:RemoveExcludePrivateMessageTarget(chatTarget);
	if ( self.privateMessageList ) then
		self.privateMessageList[strlower(chatTarget)] = true;
	else
		self.privateMessageList = { [strlower(chatTarget)] = true };
	end
end

function ChatFrameMixin:RemovePrivateMessageTarget(chatTarget)
	if ( self.privateMessageList ) then
		self.privateMessageList[strlower(chatTarget)] = nil;
	end
end

function ChatFrameMixin:ExcludePrivateMessageTarget(chatTarget)
	self:RemovePrivateMessageTarget(chatTarget);
	if ( self.excludePrivateMessageList ) then
		self.excludePrivateMessageList[strlower(chatTarget)] = true;
	else
		self.excludePrivateMessageList = { [strlower(chatTarget)] = true };
	end
end

function ChatFrameMixin:RemoveExcludePrivateMessageTarget(chatTarget)
	if ( self.excludePrivateMessageList ) then
		self.excludePrivateMessageList[strlower(chatTarget)] = nil;
	end
end

function ChatFrameMixin:ReceiveAllPrivateMessages()
	self.privateMessageList = nil;
	self.excludePrivateMessageList = nil;
end

function ChatFrameMixin:UpdateColorByID(chatTypeID, r, g, b)
	local function TransformColorByID(text, messageR, messageG, messageB, messageChatTypeID, messageAccessID, lineID)
		if messageChatTypeID == chatTypeID then
			return true, r, g, b;
		end
		return false;
	end
	self:AdjustMessageColors(TransformColorByID);
end

function ChatFrameMixin:GetDefaultChatTarget()
	local newcomerChatType, newcomerChatChannel = ChatFrameUtil.GetNewcomerChatTarget(self);

	if newcomerChatType then
		return newcomerChatType, newcomerChatChannel;
	end

	if #self.messageTypeList == 1 and #self.channelList == 0 then
		return self.messageTypeList[1], nil;
	elseif #self.messageTypeList == 0 and #self.channelList == 1 then
		local channelName = self.channelList[1];
		local localID = GetChannelName(channelName);
		if localID ~= 0 then
			return "CHANNEL", localID;
		else
			return "CHANNEL", channelName;
		end
	end

	return nil;
end

function ChatFrameMixin:UpdateDefaultChatTarget()
	local defaultChatType, defaultChannelTarget = self:GetDefaultChatTarget();
	if defaultChatType then
		local editBox = self.editBox;
		editBox:SetChatType(defaultChatType);
		editBox:SetStickyType(defaultChatType);
		editBox:SetChannelTarget(defaultChannelTarget);
		editBox:UpdateHeader();
	end
end
