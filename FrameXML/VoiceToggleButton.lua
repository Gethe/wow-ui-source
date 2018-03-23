VoiceToggleButtonMixin = {};

function VoiceToggleButtonMixin:OnLoad()
	PropertyButtonMixin.OnLoad(self);
end

VoiceToggleButtonOnlyVisibleWhenLoggedInMixin = CreateFromMixins(VoiceToggleButtonMixin);

function VoiceToggleButtonOnlyVisibleWhenLoggedInMixin:OnLoad()
	VoiceToggleButtonMixin.OnLoad(self);
	self:RegisterStateUpdateEvent("VOICE_CHAT_LOGIN");
	self:RegisterStateUpdateEvent("VOICE_CHAT_LOGOUT");
	self:SetVisibilityQueryFunction(function() return C_VoiceChat.IsLoggedIn(); end);
end

VoiceToggleMuteMixin = CreateFromMixins(VoiceToggleButtonOnlyVisibleWhenLoggedInMixin);

function VoiceToggleMuteMixin:OnLoad()
	VoiceToggleButtonOnlyVisibleWhenLoggedInMixin.OnLoad(self);
	self:SetAccessorFunction(C_VoiceChat.IsMuted);
	self:SetMutatorFunction(C_VoiceChat.SetMuted);
	self:AddStateAtlas(false, "voicechat-icon-mic");
	self:AddStateAtlas(true, "voicechat-icon-mic-mute");
	self:AddStateTooltipString(false, VOICE_TOOLTIP_MUTE_MIC);
	self:AddStateTooltipString(true, VOICE_TOOLTIP_UNMUTE_MIC);
	self:RegisterStateUpdateEvent("VOICE_CHAT_MUTED_CHANGED");
	self:UpdateVisibleState();
end

VoiceToggleDeafenMixin = CreateFromMixins(VoiceToggleButtonOnlyVisibleWhenLoggedInMixin);

function VoiceToggleDeafenMixin:OnLoad()
	VoiceToggleButtonOnlyVisibleWhenLoggedInMixin.OnLoad(self);
	self:SetAccessorFunction(C_VoiceChat.IsDeafened);
	self:SetMutatorFunction(C_VoiceChat.SetDeafened);
	self:AddStateAtlas(false, "voicechat-icon-speaker");
	self:AddStateAtlas(true, "voicechat-icon-speaker-mute");
	self:AddStateTooltipString(false, VOICE_TOOLTIP_DEAFEN);
	self:AddStateTooltipString(true, VOICE_TOOLTIP_UNDEAFEN);
	self:RegisterStateUpdateEvent("VOICE_CHAT_DEAFENED_CHANGED");
	self:UpdateVisibleState();
end