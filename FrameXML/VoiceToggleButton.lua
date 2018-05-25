VoiceToggleButtonMixin = {};

function VoiceToggleButtonMixin:OnLoad()
	PropertyButtonMixin.OnLoad(self);
end

VoiceToggleButtonAlwaysVisibileMixin = CreateFromMixins(VoiceToggleButtonMixin);

function VoiceToggleButtonAlwaysVisibileMixin:OnLoad()
	VoiceToggleButtonMixin.OnLoad(self);
	self:SetVisibilityQueryFunction(function() return true; end);
end

VoiceToggleButtonOnlyVisibleWhenLoggedInMixin = CreateFromMixins(VoiceToggleButtonMixin);

function VoiceToggleButtonOnlyVisibleWhenLoggedInMixin:OnLoad()
	VoiceToggleButtonMixin.OnLoad(self);
	self:RegisterStateUpdateEvent("VOICE_CHAT_LOGIN");
	self:RegisterStateUpdateEvent("VOICE_CHAT_LOGOUT");
	self:SetVisibilityQueryFunction(function() return C_VoiceChat.IsLoggedIn(); end);
end

VoiceToggleMuteMixin = CreateFromMixins(VoiceToggleButtonAlwaysVisibileMixin);

function VoiceToggleMuteMixin:OnLoad()
	VoiceToggleButtonAlwaysVisibileMixin.OnLoad(self);
	self:SetAccessorFunction(C_VoiceChat.IsMuted);
	self:SetMutatorFunction(C_VoiceChat.SetMuted);
	self:AddStateAtlas(false, "chatframe-button-icon-mic-on");
	self:AddStateAtlas(true, "chatframe-button-icon-mic-off");
	self:AddStateAtlasFallback("chatframe-button-icon-mic-on");
	self:AddStateTooltipString(false, VOICE_TOOLTIP_MUTE_MIC);
	self:AddStateTooltipString(true, VOICE_TOOLTIP_UNMUTE_MIC);
	self:RegisterStateUpdateEvent("VOICE_CHAT_MUTED_CHANGED");
	self:UpdateVisibleState();
end

VoiceToggleDeafenMixin = CreateFromMixins(VoiceToggleButtonAlwaysVisibileMixin);

function VoiceToggleDeafenMixin:OnLoad()
	VoiceToggleButtonAlwaysVisibileMixin.OnLoad(self);
	self:SetAccessorFunction(C_VoiceChat.IsDeafened);
	self:SetMutatorFunction(C_VoiceChat.SetDeafened);
	self:AddStateAtlas(false, "chatframe-button-icon-speaker-on");
	self:AddStateAtlas(true, "chatframe-button-icon-speaker-off");
	self:AddStateAtlasFallback("chatframe-button-icon-speaker-on");
	self:AddStateTooltipString(false, VOICE_TOOLTIP_DEAFEN);
	self:AddStateTooltipString(true, VOICE_TOOLTIP_UNDEAFEN);
	self:RegisterStateUpdateEvent("VOICE_CHAT_DEAFENED_CHANGED");
	self:UpdateVisibleState();
end

RosterToggleButtonMixin = CreateFromMixins(VoiceToggleButtonMixin);

function RosterToggleButtonMixin:IsLocalPlayer()
	return self:GetParent():IsLocalPlayer();
end

function RosterToggleButtonMixin:GetVoiceMemberID()
	return self:GetParent():GetVoiceMemberID();
end

function RosterToggleButtonMixin:GetVoiceChannelID()
	return self:GetParent():GetVoiceChannelID();
end

function RosterToggleButtonMixin:GetMemberPlayerLocation()
	return self:GetParent():GetMemberPlayerLocation();
end

function RosterToggleButtonMixin:ShouldShowVoiceActiveOnly()
	return self:GetParent():IsChannelActive() and self:GetParent():IsVoiceActive();
end

function RosterToggleButtonMixin:ShouldShow()
	return self:ShouldShowVoiceActiveOnly() and self:GetVoiceMemberID() ~= nil and self:GetVoiceChannelID() ~= nil;
end

function RosterToggleButtonMixin:ShouldShowLocalPlayerOnly()
	return self:ShouldShow() and self:IsLocalPlayer();
end

function RosterToggleButtonMixin:ShouldShowRemotePlayerOnly()
	return self:ShouldShow() and not self:IsLocalPlayer();
end

RosterSelfDeafenButtonMixin = CreateFromMixins(RosterToggleButtonMixin);

function RosterSelfDeafenButtonMixin:OnLoad()
	RosterToggleButtonMixin.OnLoad(self);

	self:SetVisibilityQueryFunction(self.ShouldShowLocalPlayerOnly);
	self:SetAccessorFunction(C_VoiceChat.IsDeafened);
	self:SetMutatorFunction(C_VoiceChat.SetDeafened);

	self:AddStateAtlas(false, "voicechat-icon-speaker");
	self:AddStateAtlas(true, "voicechat-icon-speaker-mute");
	self:SetUseIconAsHighlight(true);

	self:AddStateTooltipString(false, VOICE_TOOLTIP_DEAFEN);
	self:AddStateTooltipString(true, VOICE_TOOLTIP_UNDEAFEN);

	self:RegisterStateUpdateEvent("VOICE_CHAT_DEAFENED_CHANGED");
	self:UpdateVisibleState();
end

function RosterSelfDeafenButtonMixin:IsDeafened()
	return self:IsLocalPlayer() and C_VoiceChat.IsDeafened();
end

RosterSelfMuteButtonMixin = CreateFromMixins(RosterToggleButtonMixin);

function RosterSelfMuteButtonMixin:OnLoad()
	RosterToggleButtonMixin.OnLoad(self);

	self:SetVisibilityQueryFunction(self.ShouldShowLocalPlayerOnly);
	self:SetAccessorFunctionThroughSelf(self.IsMuted);
	self:SetMutatorFunction(C_VoiceChat.SetMuted);

	self:AddStateAtlas(true, "voicechat-icon-mic-mute");
	self:AddStateAtlas(false, "voicechat-icon-mic");
	self:SetUseIconAsHighlight(true);

	self:AddStateTooltipString(true, VOICE_TOOLTIP_UNMUTE_MIC);
	self:AddStateTooltipString(false, VOICE_TOOLTIP_MUTE_MIC);

	self:RegisterStateUpdateEvent("VOICE_CHAT_MUTED_CHANGED");
	self:UpdateVisibleState();
end

function RosterSelfMuteButtonMixin:IsMuted()
	return self:IsLocalPlayer() and C_VoiceChat.IsMuted();
end

RosterMemberMuteButtonMixin = CreateFromMixins(RosterToggleButtonMixin);

function RosterMemberMuteButtonMixin:OnLoad()
	RosterToggleButtonMixin.OnLoad(self);

	self:SetVisibilityQueryFunction(self.ShouldShowRemotePlayerOnly);
	self:SetAccessorFunctionThroughSelf(self.IsMuted);
	self:SetMutatorFunctionThroughSelf(self.SetMuted);

	self:AddStateAtlas(true, "voicechat-icon-speaker-mute");
	self:AddStateAtlas(false, "voicechat-icon-speaker");
	self:SetUseIconAsHighlight(true);

	self:AddStateTooltipString(true, UNMUTE);
	self:AddStateTooltipString(false, MUTE);

	self:RegisterStateUpdateEvent("VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ME_CHANGED");
	self:RegisterStateUpdateEvent("VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ALL_CHANGED");
	self:UpdateVisibleState();
end

function RosterMemberMuteButtonMixin:IsMuted()
	local playerLocation = self:GetMemberPlayerLocation();
	if playerLocation then
		return C_VoiceChat.IsMemberMuted(self:GetMemberPlayerLocation());
	else
		return false;
	end
end

function RosterMemberMuteButtonMixin:SetMuted(mute)
	local playerLocation = self:GetMemberPlayerLocation();
	if playerLocation then
		return C_VoiceChat.SetMemberMuted(self:GetMemberPlayerLocation(), mute);
	else
		return false;
	end
end
