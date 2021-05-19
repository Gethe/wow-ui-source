VoiceActivityManagerMixin = {};

function VoiceActivityManagerMixin:OnLoad()
	self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED");
	self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_ENERGY_CHANGED");
	self:RegisterEvent("VOICE_CHAT_CHANNEL_TRANSMIT_CHANGED");
	self:RegisterEvent("VOICE_CHAT_COMMUNICATION_MODE_CHANGED");
	self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_REMOVED");
	self:RegisterEvent("VOICE_CHAT_CHANNEL_REMOVED");
	self:RegisterEvent("VOICE_CHAT_CHANNEL_DEACTIVATED");

	self.releaseTimers = {};
	self.notificationMembers = {};
	self.alertNotificationList = CreateFromMixins(DoublyLinkedListMixin);

	self.guidToExternalNotificationInfo = {};
	self.externalNotificationOwnerToGuid = {};
	self.parentFrameNotificationFrames = {};
	self.notificationFrameToParentFrame = {};

	self.notificationTemplates = { "VoiceActivityNotificationTemplate" };
	self.externalNotificationTemplates = {};
	self.notificationPools = CreateFramePoolCollection();

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
	elseif event == "VOICE_CHAT_COMMUNICATION_MODE_CHANGED" then
		self:OnVoiceChatCommunicationModeChanged(...);
	elseif event == "VOICE_CHAT_CHANNEL_MEMBER_REMOVED" then
		self:OnMemberRemoved(...);
	elseif event == "VOICE_CHAT_CHANNEL_REMOVED" then
		self:OnChannelRemoved(...);
	elseif event == "VOICE_CHAT_CHANNEL_DEACTIVATED" then
		self:OnChannelDeactivated(...);
	end
end

function VoiceActivityManagerMixin:OnVoiceChannelMemberSpeakingStateChanged(memberID, channelID, isSpeaking)
	if isSpeaking then
		self:ShowNotifications(memberID, channelID);
	else
		if C_VoiceChat.IsMemberLocalPlayer(memberID, channelID) and (C_VoiceChat.GetCommunicationMode() == Enum.CommunicationMode.PushToTalk) and self.localPlayerTransmittingInfo then
			-- The player is in PTT mode and marked as transmitting, so do nothing
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
		if C_VoiceChat.GetCommunicationMode() == Enum.CommunicationMode.PushToTalk then
			if isTransmitting then
				self:ShowNotifications(localPlayerMemberID, channelID);
			else
				-- Don't wait for a timer...player wants immediate feedback that they stopped transmitting
				self:ReleaseNotifications(localPlayerMemberID, channelID)
			end
		end

		self.localPlayerTransmittingInfo = isTransmitting and {memberID = localPlayerMemberID, channelID = channelID} or nil;
	end
end

function VoiceActivityManagerMixin:OnVoiceChatCommunicationModeChanged(communicationMode)
	if self.localPlayerTransmittingInfo then
		if communicationMode == Enum.CommunicationMode.OpenMic then
			-- Going from PTT to OpenMic and the player was holding the PTT button when they switched to OpenMic, so check if they are currently talking
			local localPlayerActiverMemberInfo = C_VoiceChat.GetLocalPlayerActiveChannelMemberInfo();
			if localPlayerActiverMemberInfo and not localPlayerActiverMemberInfo.isSpeaking then
				-- The player was not talking when they switched, so release
				self:ReleaseNotifications(self.localPlayerTransmittingInfo.memberID, self.localPlayerTransmittingInfo.channelID);
			end
		else
			-- Going from OpenMic to PTT. Check if the PTT button is pushed currently
			local isPTTButtonPressed = C_VoiceChat.GetPTTButtonPressedState();
			if isPTTButtonPressed then
				-- The button is pushed, so show the notification because we won't get a transmitting state update
				self:ShowNotifications(self.localPlayerTransmittingInfo.memberID, self.localPlayerTransmittingInfo.channelID);
			else
				-- The button is not pushed, so hide the notification
				self:ReleaseNotifications(self.localPlayerTransmittingInfo.memberID, self.localPlayerTransmittingInfo.channelID);
			end
		end
	end
end

function VoiceActivityManagerMixin:OnMemberRemoved(memberID, channelID)
	self:ReleaseNotifications(memberID, channelID);
end

function VoiceActivityManagerMixin:OnChannelRemoved(channelID)
	self:ReleaseNotifications("*", channelID);
end

function VoiceActivityManagerMixin:OnChannelDeactivated(channelID)
	self:ReleaseNotifications("*", channelID);
end

-- First return value is the created notification
-- Second return value is true if the notification is an alert
function VoiceActivityManagerMixin:CreateNotification(memberID, channelID, frameTemplate, isLocalPlayer, parentFrame)
	local guid = C_VoiceChat.GetMemberGUID(memberID, channelID);

	local notification = self.notificationPools:Acquire(frameTemplate);
	notification:Setup(memberID, channelID, isLocalPlayer);

	self:LinkFrameNotificationAndGuid(parentFrame, notification, guid);

	return notification, self:CheckForAlertOnAdd(notification);
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
	if self:MemberHasExistingNotification(memberID, channelID) then
		-- We already have a notification for this showing, just clear the release timer on it if there is one
		self:ClearReleaseTimer(memberID, channelID);
		return;
	end

	local isLocalPlayer = C_VoiceChat.IsMemberLocalPlayer(memberID, channelID);

	local addedInternalAlert = self:ShowInternalNotifications(memberID, channelID, isLocalPlayer);
	local addedExternalAlert = self:ShowExternalNotifications(memberID, channelID, isLocalPlayer);

	if addedInternalAlert or addedExternalAlert then
		self:UpdateAlertNotificationVisibility();
	end

	self:SetMemberHasExistingNotification(memberID, channelID);
end

function VoiceActivityManagerMixin:LinkFrameNotificationAndGuid(frame, notification, guid)
	self.notificationFrameToParentFrame[notification] = frame;

	if not self.parentFrameNotificationFrames[frame] then
		self.parentFrameNotificationFrames[frame] = {};
	end

	self.parentFrameNotificationFrames[frame][notification] = guid;
end

function VoiceActivityManagerMixin:GetShowingInternalNotificationForGuid(guid)
	if self.parentFrameNotificationFrames[self] then
		for notification, showingGuid in pairs(self.parentFrameNotificationFrames[self]) do
			if showingGuid == guid then
				return notification;
			end
		end
	end

	return nil;
end

function VoiceActivityManagerMixin:ShowInternalNotifications(memberID, channelID, isLocalPlayer)
	local addedAlert = false;

	for _, frameTemplate in pairs(self.notificationTemplates) do
		local notification, isAlert = self:CreateNotification(memberID, channelID, frameTemplate, isLocalPlayer, self);

		if isAlert then
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
				local notification, isAlert = self:CreateNotification(memberID, channelID, externalNotificationInfo.template, isLocalPlayer, frame);
				externalNotificationInfo.callback(frame, notification);

				if isAlert then
					addedAlert = true;
				end
			end
		end
	end

	return addedAlert;
end

function VoiceActivityManagerMixin:ReleaseNotification(notification)
	local parentFrame = self.notificationFrameToParentFrame[notification];
	if parentFrame then
		self.parentFrameNotificationFrames[parentFrame][notification] = nil;
		self.notificationFrameToParentFrame[notification] = nil;
	end

	self.notificationPools:Release(notification);
end

function VoiceActivityManagerMixin:ReleaseNotifications(memberID, channelID)
	if not self:MemberHasExistingNotification(memberID, channelID) then
		-- We aren't showing a notification for this member. Nothing to do
		return;
	end

	for notification in self.notificationPools:EnumerateActive() do
		if notification:MatchesUser(memberID, channelID) then
			self:ClearReleaseTimer(notification:GetMemberID(), notification:GetChannelID());

			if self:CheckForAlertOnRemove(notification) then
				removedAlert = true;
			end

			self:ReleaseNotification(notification);
		end
	end

	if removedAlert then
		self:UpdateAlertNotificationVisibility();
	end

	if memberID == "*" then
		self:ClearChannelExistingNotifications(channelID);
	else
		self:ClearMemberHasExistingNotification(memberID, channelID);
	end
end

function VoiceActivityManagerMixin:MemberHasExistingNotification(memberID, channelID)
	return self.notificationMembers[channelID] and (self.notificationMembers[channelID][memberID] or memberID == "*");
end

function VoiceActivityManagerMixin:SetMemberHasExistingNotification(memberID, channelID)
	if not self.notificationMembers[channelID] then
		self.notificationMembers[channelID] = {};
	end

	self.notificationMembers[channelID][memberID] = true;
end

function VoiceActivityManagerMixin:ClearMemberHasExistingNotification(memberID, channelID)
	if self.notificationMembers[channelID] then
		self.notificationMembers[channelID][memberID] = nil;
	end
end

function VoiceActivityManagerMixin:ClearChannelExistingNotifications(channelID)
	self.notificationMembers[channelID] = nil;
end

local RELEASE_TIMER_SECONDS = 1;

function VoiceActivityManagerMixin:StartReleaseTimer(memberID, channelID)
	if not self:MemberHasExistingNotification(memberID, channelID) then
		-- We aren't showing a notification for this member. Nothing to do
		return;
	end

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
		if index == 1 then
			notification:SetCushions(0, 14);
		else
			notification:ClearCushions();
		end

		ChatAlertFrame:SetSubSystemAnchorPriority(notification:GetAlertSystem(), STARTING_PRIORITY + index);
		notification:SetShown(index <= MAX_VISIBLE_NOTIFICATIONS);
	end

	ChatAlertFrame:UpdateAnchors();
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
			self:UnregisterFrameForVoiceActivityNotifications(frame);

			if not self.guidToExternalNotificationInfo[guid] then
				self.guidToExternalNotificationInfo[guid] = {};
			end

			self.guidToExternalNotificationInfo[guid][frame] = {channelID = voiceChannelID, template = notificationTemplate, callback = notificationCreatedCallback};
			self.externalNotificationOwnerToGuid[frame] = guid;

			local internalNotification = self:GetShowingInternalNotificationForGuid(guid);
			if internalNotification then
				-- This player is talking right now...add a notofication for them
				local notification = self:CreateNotification(internalNotification:GetMemberID(), internalNotification:GetChannelID(), notificationTemplate, internalNotification:GetIsLocalPlayer(), frame);
				notificationCreatedCallback(frame, notification);
			end
		end
	end
end

function VoiceActivityManagerMixin:UnregisterFrameForVoiceActivityNotifications(frame)
	if frame then
		local guid = self.externalNotificationOwnerToGuid[frame];
		if guid then
			if self.parentFrameNotificationFrames[frame] then
				-- Release the notifications attached to this frame
				for notification in pairs(self.parentFrameNotificationFrames[frame]) do
					self:ReleaseNotification(notification);
				end

				self.parentFrameNotificationFrames[frame] = nil;
			end

			self.guidToExternalNotificationInfo[guid][frame] = nil;

			if not next(self.guidToExternalNotificationInfo[guid]) then
				self.guidToExternalNotificationInfo[guid] = nil;
			end

			self.externalNotificationOwnerToGuid[frame] = nil;
		end
	end
end
