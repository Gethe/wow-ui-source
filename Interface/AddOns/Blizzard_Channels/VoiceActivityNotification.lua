VoiceActivityVolumeMixin = {};

function VoiceActivityVolumeMixin:SetVolume(volume)
	self.Level1:SetShown(volume > 0);
	self.Level2:SetShown(volume > 0.5);
	self.Level3:SetShown(volume > 0.8);
end

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

function VoiceActivityNotificationBaseMixin:IsAnAlert()
	return (self.alertSystem ~= nil);
end

function VoiceActivityNotificationBaseMixin:GetAlertSystem()
	return self.alertSystem;
end

function VoiceActivityNotificationBaseMixin:SetSpeakingEnergy(speakingEnergy)
	if self.Volume then
		self.Volume:SetVolume(speakingEnergy);
	end
end

function VoiceActivityNotificationBaseMixin:Setup(memberID, channelID, isLocalPlayer)
	self:SetMemberID(memberID);
	self:SetChannelID(channelID);
	self:SetIsLocalPlayer(isLocalPlayer);
	self:SetSpeakingEnergy(0);
end

function VoiceActivityNotificationBaseMixin:MatchesUser(memberID, channelID)
	return (self:GetChannelID() == channelID) and (memberID == "*" or self:GetMemberID() == memberID);
end

function VoiceActivityNotificationBaseMixin:GetIsLocalPlayer()
	return self.isLocalPlayer;
end

function VoiceActivityNotificationBaseMixin:SetIsLocalPlayer(isLocalPlayer)
	self.isLocalPlayer = isLocalPlayer;
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

-- Chat Frame notification
VoiceActivityNotificationMixin = CreateFromMixins(VoiceActivityNotificationBaseMixin);

function VoiceActivityNotificationMixin:OnLoad()
	VoiceActivityNotificationBaseMixin.OnLoad(self);
	self:EnableMouse(false);
	self.alertSystem = ChatAlertFrame:AddAutoAnchoredSubSystem(self);
end

function VoiceActivityNotificationMixin:Setup(memberID, channelID, isLocalPlayer)
	VoiceActivityNotificationBaseMixin.Setup(self, memberID, channelID, isLocalPlayer);

	self:ClearCushions();

	C_VoiceChat.SetPortraitTexture(self.Portrait, memberID, channelID);

	local memberName = C_VoiceChat.GetMemberName(memberID, channelID);
	local r, g, b = Voice_GetVoiceChannelNotificationColor(channelID);
	self.Name:SetText(VOICE_CHAT_CHAT_NOTIFICATION:format(memberName or ""));
	self.Name:SetVertexColor(r, g, b, 1);
end

function VoiceActivityNotificationMixin:UpdateSize()
	local right = self.Name:GetRight();
	local left = self:GetLeft();
	local width = (right and left) and (right - left) or 120;
	self:SetWidth(width + self.cushionX);

	local height = 29;
	self:SetHeight(height + self.cushionY);
end

function VoiceActivityNotificationMixin:OnAlertAnchorUpdated()
	self:UpdateSize();
end

function VoiceActivityNotificationMixin:SetCushions(cushionX, cushionY)
	self.cushionX = cushionX;
	self.cushionY = cushionY;
end

function VoiceActivityNotificationMixin:ClearCushions()
	self:SetCushions(0, 0);
end
