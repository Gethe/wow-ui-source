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