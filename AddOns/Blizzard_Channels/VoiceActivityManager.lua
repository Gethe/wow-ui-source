VoiceActivityManagerMixin = {};

do
	local templateToFrameLookup =
	{
		VoiceActivityNotificationTemplate = "ContainedAlertFrame",
	};

	function VoiceActivityManagerMixin:OnLoad()
		self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED");
		self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_REMOVED");
		self:RegisterEvent("VOICE_CHAT_CHANNEL_REMOVED");

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
		self:ReleaseNotifications(memberID, channelID);
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
	if self:ShouldShowNotification(memberID, channelID) then
		for i = 1, select("#", ...) do
			local notification = self.notificationPools:Acquire(select(i, ...));
			notification:Setup(memberID, channelID);
			notification:Show();
		end
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
		self.notificationPools:Release(notification);
	end
end
