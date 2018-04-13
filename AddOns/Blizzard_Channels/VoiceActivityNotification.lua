VoiceActivityNotificationBaseMixin = {};

function VoiceActivityNotificationBaseMixin:OnLoad()

end

function VoiceActivityNotificationBaseMixin:OnEvent(event, ...)

end

function VoiceActivityNotificationBaseMixin:OnClick(button)

end

function VoiceActivityNotificationBaseMixin:OnEnter()

end

function VoiceActivityNotificationBaseMixin:OnLeave()

end

function VoiceActivityNotificationBaseMixin:Setup(memberID, channelID)
	self:SetMemberID(memberID);
	self:SetChannelID(channelID);
end

function VoiceActivityNotificationBaseMixin:MatchesUser(memberID, channelID)
	return (self:GetChannelID() == channelID) and (memberID == "*" or self:GetMemberID() == memberID);
end

function VoiceActivityNotificationBaseMixin:GetMemberID()
	return self.memberID;
end

function VoiceActivityNotificationBaseMixin:SetMemberID(memberID)
	self.memberID = memberID;
end

function VoiceActivityNotificationBaseMixin:GetChannelID()
	return self.channelID;
end

function VoiceActivityNotificationBaseMixin:SetChannelID(channelID)
	self.channelID = channelID;
end

VoiceActivityNotificationMixin = CreateFromMixins(VoiceActivityNotificationBaseMixin);

function VoiceActivityNotificationMixin:OnLoad()
	VoiceActivityNotificationBaseMixin.OnLoad(self);
	self.alertSystem = ChatAlertFrame:AddAutoAnchoredSubSystem(self);
end

function VoiceActivityNotificationMixin:SetSpeakingEnergy(speakingEnergy)
	self.VoiceLoudness1:SetShown(speakingEnergy > 0);
	self.VoiceLoudness2:SetShown(speakingEnergy > 0.5);
	self.VoiceLoudness3:SetShown(speakingEnergy > 0.8);
end

function VoiceActivityNotificationMixin:SetPortrait(memberID, channelID)

end

function VoiceActivityNotificationMixin:Setup(memberID, channelID)
	VoiceActivityNotificationBaseMixin.Setup(self, memberID, channelID);

	C_VoiceChat.SetPortraitTexture(self.Portrait, memberID, channelID);

	local member = C_VoiceChat.GetMemberInfo(memberID, channelID);
	local r, g, b = Voice_GetVoiceChannelNotificationColor(channelID);
	self.Name:SetText(VOICE_CHAT_CHAT_NOTIFICATION:format(member.name));
	self.Name:SetVertexColor(r, g, b, 1);

	self:SetSpeakingEnergy(0);
end

function VoiceActivityNotificationMixin:UpdateSize()
	local right = self.Name:GetRight();
	local left = self:GetLeft();
	local width = (right and left) and (right - left) or 120;
	self:SetWidth(width);
end

function VoiceActivityNotificationMixin:OnAlertAnchorUpdated()
	self:UpdateSize();
end