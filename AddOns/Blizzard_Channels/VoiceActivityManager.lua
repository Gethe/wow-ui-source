VoiceActivityManagerMixin = {};

function VoiceActivityManagerMixin:OnLoad()
	self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED");
	self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_ENERGY_CHANGED");
	self:RegisterEvent("VOICE_CHAT_CHANNEL_TRANSMIT_CHANGED");
	self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_REMOVED");
	self:RegisterEvent("VOICE_CHAT_CHANNEL_REMOVED");

	self.releaseTimers = {};
	self.alertNotificationList = CreateFromMixins(DoublyLinkedListMixin);

	self.guidToExternalNotificationInfo = {};
	self.externalNotificationOwnerToGuid = {};

	self.notificationTemplates = { "VoiceActivityNotificationTemplate" };
	self.externalNotificationTemplates = {};
	self.notificationPools = CreatePoolCollection();

	for index, templateType in ipairs(self.notificationTemplates) do
		self.notificationPools:CreatePool("ContainedAlertFrame", self, templateType);
	end
end

function VoiceActivityManagerMixin:OnEvent(event, ...)
	if event == "VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED" then
		self:OnVoiceChannelMemberSpeakingStateChanged(...);
	elseif event == "VOICE_CHAT_CHANNEL_MEMBER_ENERGY_CHANGED" then
		self:OnVoiceChatChannelMemberEnergyChanged(...);
	elseif event == "VOICE_CHAT_CHANNEL_TRANSMIT_CHANGED" then
		self:OnVoiceChatChannelTransmitChanged(...);
	elseif event == "VOICE_CHAT_CHANNEL_MEMBER_REMOVED" then
		self:OnMemberRemoved(...);
	elseif event == "VOICE_CHAT_CHANNEL_REMOVED" then
		self:OnChannelRemoved(...);
	end
end

function VoiceActivityManagerMixin:OnVoiceChannelMemberSpeakingStateChanged(memberID, channelID, isSpeaking)
	if C_VoiceChat.IsMemberLocalPlayer(memberID, channelID) and self.localPlayerTransmitting then
		-- Do nothing...the player is already marked as transmitting
		return;
	else
		if isSpeaking then
			self:ShowNotifications(memberID, channelID);
		else
			self:StartReleaseTimer(memberID, channelID);
		end
	end
end

function VoiceActivityManagerMixin:OnVoiceChatChannelMemberEnergyChanged(memberID, channelID, speakingEnergy)
	for notification in self.notificationPools:EnumerateActive() do
		if notification:MatchesUser(memberID, channelID) then
			notification:SetSpeakingEnergy(speakingEnergy);
		end
	end
end

function VoiceActivityManagerMixin:OnVoiceChatChannelTransmitChanged(channelID, isTransmitting)
	local localPlayerMemberID = C_VoiceChat.GetLocalPlayerMemberID(channelID);

	if localPlayerMemberID then
		if isTransmitting then
			self:ShowNotifications(localPlayerMemberID, channelID);
		else
			-- Don't wait for a timer...player wants immediate feedback that they stopped transmitting
			self:ReleaseNotifications(localPlayerMemberID, channelID)
		end

		self.localPlayerTransmitting = isTransmitting;
	end
end

function VoiceActivityManagerMixin:OnMemberRemoved(memberID, channelID)
	self:ReleaseNotifications(memberID, channelID);
end

function VoiceActivityManagerMixin:OnChannelRemoved(statusCode, channelID)
	self:ReleaseNotifications("*", channelID);
end

function VoiceActivityManagerMixin:CreateNotification(memberID, channelID, frameTemplate, isLocalPlayer)
	local notification = self.notificationPools:Acquire(frameTemplate);
	notification:Setup(memberID, channelID, isLocalPlayer);
	return notification;
end

function VoiceActivityManagerMixin:CheckForAlertOnAdd(notification)
	if notification:IsAnAlert() then
		if notification:GetIsLocalPlayer() then
			self.alertNotificationList:PushFront(notification);
		else
			self.alertNotificationList:PushBack(notification);
		end
		return true;
	else
		return false;
	end
end

function VoiceActivityManagerMixin:CheckForAlertOnRemove(notification)
	if notification:IsAnAlert() then
		self.alertNotificationList:Remove(notification);
		return true;
	else
		return false;
	end
end

function VoiceActivityManagerMixin:ShowNotifications(memberID, channelID)
	if self:ClearReleaseTimer(memberID, channelID) then
		-- We already have a notification for this showing, just had to clear the release timer on it
		return;
	end

	local isLocalPlayer = C_VoiceChat.IsMemberLocalPlayer(memberID, channelID);

	local addedInternalAlert = self:ShowInternalNotifications(memberID, channelID, isLocalPlayer);
	local addedExternalAlert = self:ShowExternalNotifications(memberID, channelID, isLocalPlayer);

	if addedInternalAlert or addedExternalAlert then
		self:UpdateAlertNotificationVisibility();
	end
end

function VoiceActivityManagerMixin:ShowInternalNotifications(memberID, channelID, isLocalPlayer)
	local addedAlert = false;

	for _, frameTemplate in pairs(self.notificationTemplates) do
		local notification = self:CreateNotification(memberID, channelID, frameTemplate, isLocalPlayer);

		if self:CheckForAlertOnAdd(notification) then
			addedAlert = true;
		end
	end

	return addedAlert;
end

function VoiceActivityManagerMixin:ShowExternalNotifications(memberID, channelID, isLocalPlayer)
	local guid = C_VoiceChat.GetMemberGUID(memberID, channelID);
	local addedAlert = false;

	local externalNotificationList = self.guidToExternalNotificationInfo[guid];
	if externalNotificationList then
		-- ok something has registered for this guid
		-- go through all of the registrations and create notifications for each
		for frame, externalNotificationInfo in pairs(externalNotificationList) do
			if not externalNotificationInfo.channelID or externalNotificationInfo.channelID == channelID then
				-- either they registered for all channels or the channel matches, so show the notification
				local notification = self:CreateNotification(memberID, channelID, externalNotificationInfo.template, isLocalPlayer);
				externalNotificationInfo.callback(frame, notification);

				if self:CheckForAlertOnAdd(notification) then
					addedAlert = true;
				end
			end
		end
	end

	return addedAlert;
end

function VoiceActivityManagerMixin:ReleaseNotifications(memberID, channelID)
	local removedAlert = false;

	for notification in self.notificationPools:EnumerateActive() do
		if notification:MatchesUser(memberID, channelID) then
			self:ClearReleaseTimer(notification:GetMemberID(), notification:GetChannelID());

			if self:CheckForAlertOnRemove(notification) then
				removedAlert = true;
			end

			self.notificationPools:Release(notification);
		end
	end

	if removedAlert then
		self:UpdateAlertNotificationVisibility();
	end
end

local RELEASE_TIMER_SECONDS = 1;

function VoiceActivityManagerMixin:StartReleaseTimer(memberID, channelID)
	if not self.releaseTimers[channelID] then
		self.releaseTimers[channelID] = {};
	else
		self:ClearReleaseTimer(memberID, channelID);
	end

	self.releaseTimers[channelID][memberID] = C_Timer.NewTimer(RELEASE_TIMER_SECONDS, function()
		self:ClearReleaseTimer(memberID, channelID);
		self:ReleaseNotifications(memberID, channelID);
	end)
end

function VoiceActivityManagerMixin:ClearReleaseTimer(memberID, channelID)
	if self.releaseTimers[channelID] and self.releaseTimers[channelID][memberID] then
		self.releaseTimers[channelID][memberID]:Cancel();
		self.releaseTimers[channelID][memberID] = nil;
		return true;
	end

	return false;
end

local MAX_VISIBLE_NOTIFICATIONS = 3;
local STARTING_PRIORITY= 19;

function VoiceActivityManagerMixin:UpdateAlertNotificationVisibility()
	for index, notification in self.alertNotificationList:EnumerateNodes() do
		ChatAlertFrame:SetSubSystemAnchorPriority(notification:GetAlertSystem(), STARTING_PRIORITY + index);
		notification:SetShown(index <= MAX_VISIBLE_NOTIFICATIONS);
	end
end

function VoiceActivityManagerMixin:RegisterExternalNotificationTemplate(notificationTemplate, frameType)
	if notificationTemplate then
		if not self.externalNotificationTemplates[notificationTemplate] then
			-- Create a pool for it
			self.notificationPools:CreatePool(frameType, self, notificationTemplate);
		end
		self.externalNotificationTemplates[notificationTemplate] = true;
		return true;
	end

	return false;
end

function VoiceActivityManagerMixin:RegisterFrameForVoiceActivityNotifications(frame, guid, voiceChannelID, notificationTemplate, frameType, notificationCreatedCallback)
	if frame and guid and notificationTemplate and notificationCreatedCallback then
		if self:RegisterExternalNotificationTemplate(notificationTemplate, frameType) then
			if not self.guidToExternalNotificationInfo[guid] then
				self.guidToExternalNotificationInfo[guid] = {};
			end

			self.guidToExternalNotificationInfo[guid][frame] = {channelID = voiceChannelID, template = notificationTemplate, callback = notificationCreatedCallback};
			self.externalNotificationOwnerToGuid[frame] = guid;
		end
	end
end

function VoiceActivityManagerMixin:UnregisterFrameForVoiceActivityNotifications(frame)
	if frame then
		local guid = self.externalNotificationOwnerToGuid[frame];
		if guid then
			self.guidToExternalNotificationInfo[guid][frame] = nil;

			if not next(self.guidToExternalNotificationInfo[guid]) then
				self.guidToExternalNotificationInfo[guid] = nil;
			end

			self.externalNotificationOwnerToGuid[frame] = nil;
		end
	end
end
