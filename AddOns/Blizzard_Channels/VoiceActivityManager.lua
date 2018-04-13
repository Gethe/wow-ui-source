VoiceActivityManagerMixin = {};

do
	local templateToFrameLookup =
	{
		VoiceActivityNotificationTemplate = "ContainedAlertFrame",
	};

	function VoiceActivityManagerMixin:OnLoad()
		self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED");
		self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_ENERGY_CHANGED");
		self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_REMOVED");
		self:RegisterEvent("VOICE_CHAT_CHANNEL_REMOVED");

		self.releaseTimers = {};
		self.notificationList = CreateFromMixins(DoublyLinkedListMixin);

		self.notificationTemplates = { "VoiceActivityNotificationTemplate" }; -- TODO: At some point there will be multiple styles.
		self.notificationPools = CreatePoolCollection();

		for index, templateType in ipairs(self.notificationTemplates) do
			self.notificationPools:CreatePool(templateToFrameLookup[templateType], self, templateType);
		end
	end
end

function VoiceActivityManagerMixin:OnEvent(event, ...)
	if event == "VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED" then
		self:OnVoiceChannelMemberSpeakingStateChanged(...);
	elseif event == "VOICE_CHAT_CHANNEL_MEMBER_ENERGY_CHANGED" then
		self:OnVoiceChatChannelMemberEnergyChanged(...);
	elseif event == "VOICE_CHAT_CHANNEL_MEMBER_REMOVED" then
		self:OnMemberRemoved(...);
	elseif event == "VOICE_CHAT_CHANNEL_REMOVED" then
		self:OnChannelRemoved(...);
	end
end

function VoiceActivityManagerMixin:OnVoiceChannelMemberSpeakingStateChanged(memberID, channelID, isSpeaking)
	if isSpeaking then
		self:ShowNotifications(memberID, channelID, self:GetNotificationTemplates(memberID, channelID));
	else
		self:StartReleaseTimer(memberID, channelID);
	end
end

function VoiceActivityManagerMixin:OnVoiceChatChannelMemberEnergyChanged(memberID, channelID, speakingEnergy)
	for notification in self.notificationPools:EnumerateActive() do
		if notification:MatchesUser(memberID, channelID) then
			notification:SetSpeakingEnergy(speakingEnergy);
		end
	end
end

function VoiceActivityManagerMixin:OnMemberRemoved(memberID, channelID)
	self:ReleaseNotifications(memberID, channelID);
end

function VoiceActivityManagerMixin:OnChannelRemoved(statusCode, channelID)
	self:ReleaseNotifications("*", channelID);
end

function VoiceActivityManagerMixin:ShouldShowNotification(memberID, channelID)
	return true; -- for now, I just want to see all voice notifications
end

function VoiceActivityManagerMixin:GetNotificationTemplates(memberID, channelID)
	-- It's pretty standard right now...all user notifications appear in a single area with a single template
	return unpack(self.notificationTemplates);
end

-- ... all the templates that should be used to show this notification
function VoiceActivityManagerMixin:ShowNotifications(memberID, channelID, ...)
	if self:ClearReleaseTimer(memberID, channelID) then
		-- We already have a notification for this showing, just had to clear the release timer on it
		return;
	end

	local addedSomething = false;
	if self:ShouldShowNotification(memberID, channelID) then
		for i = 1, select("#", ...) do
			local notification = self.notificationPools:Acquire(select(i, ...));
			notification:Setup(memberID, channelID);
			self.notificationList:PushBack(notification);
			addedSomething = true;
		end
	end

	if addedSomething then
		self:UpdateNotificationVisibility();
	end
end

function VoiceActivityManagerMixin:ReleaseNotifications(memberID, channelID)
	self.releaseContainer = self.releaseContainer or {};
	local maxReleaseIndex = 0;

	for notification in self.notificationPools:EnumerateActive() do
		if notification:MatchesUser(memberID, channelID) then
			maxReleaseIndex = maxReleaseIndex + 1;
			self.releaseContainer[maxReleaseIndex] = notification;
		end
	end

	for i = 1, maxReleaseIndex do
		local notification = self.releaseContainer[i];
		self:ClearReleaseTimer(notification:GetMemberID(), notification:GetChannelID());
		self.notificationList:Remove(notification);
		self.notificationPools:Release(notification);
	end

	if maxReleaseIndex > 0 then
		self:UpdateNotificationVisibility();
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

function VoiceActivityManagerMixin:UpdateNotificationVisibility()
	for index, notification in self.notificationList:EnumerateNodes() do
		ChatAlertFrame:SetSubSystemAnchorPriority(notification.alertSystem, STARTING_PRIORITY + index);
		notification:SetShown(index <= MAX_VISIBLE_NOTIFICATIONS);
	end
end
