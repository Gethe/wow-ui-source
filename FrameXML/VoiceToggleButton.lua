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

MUTE_SILENCE_STATE_NONE		= 0
MUTE_SILENCE_STATE_MUTE		= 1
MUTE_SILENCE_STATE_SILENCE	= 2
MUTE_SILENCE_STATE_BOTH		= 3

function VoiceToggleMuteMixin:IsForPublicChannel()
	return true;	-- default to showing public channel silence state
end

function VoiceToggleMuteMixin:SetupMuteButton()
	local function GetSelfMuteAndSilenceState()
		local isMuted = C_VoiceChat.IsMuted();
		local isSilenced = C_VoiceChat.IsSilenced();

		local stateVal = MUTE_SILENCE_STATE_NONE;
		if isMuted then
			stateVal = stateVal + MUTE_SILENCE_STATE_MUTE;
		end

		local isForPublicChannel = self:IsForPublicChannel();

		if isForPublicChannel and isSilenced then
			stateVal = stateVal + MUTE_SILENCE_STATE_SILENCE;
		end

		return stateVal;
	end

	self:SetAccessorFunction(GetSelfMuteAndSilenceState);
	self:SetMutatorFunction(C_VoiceChat.ToggleMuted);
	self:AddStateTooltipString(MUTE_SILENCE_STATE_NONE, VOICE_TOOLTIP_MUTE_MIC);
	self:AddStateTooltipString(MUTE_SILENCE_STATE_MUTE, VOICE_TOOLTIP_UNMUTE_MIC);
	self:AddStateTooltipString(MUTE_SILENCE_STATE_SILENCE, VOICE_TOOLTIP_SILENCED_MUTE_MIC);
	self:AddStateTooltipString(MUTE_SILENCE_STATE_BOTH, VOICE_TOOLTIP_SILENCED_UNMUTE_MIC);
end

function VoiceToggleMuteMixin:OnLoad()
	VoiceToggleButtonAlwaysVisibileMixin.OnLoad(self);

	self:SetupMuteButton();

	self:AddStateAtlas(MUTE_SILENCE_STATE_NONE, "chatframe-button-icon-mic-on");
	self:AddStateAtlas(MUTE_SILENCE_STATE_MUTE, "chatframe-button-icon-mic-off");
	self:AddStateAtlas(MUTE_SILENCE_STATE_SILENCE, "chatframe-button-icon-mic-silenced");
	self:AddStateAtlas(MUTE_SILENCE_STATE_BOTH, "chatframe-button-icon-mic-silenced-off");
	self:AddStateAtlasFallback("chatframe-button-icon-mic-on");

	self:RegisterStateUpdateEvent("VOICE_CHAT_MUTED_CHANGED");
	self:RegisterStateUpdateEvent("VOICE_CHAT_SILENCED_CHANGED");

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

function RosterSelfMuteButtonMixin:IsForPublicChannel()
	return self:GetParent():IsChannelPublic();
end

function RosterSelfMuteButtonMixin:OnLoad()
	RosterToggleButtonMixin.OnLoad(self);
	VoiceToggleMuteMixin.SetupMuteButton(self);

	self:SetVisibilityQueryFunction(self.ShouldShowLocalPlayerOnly);

	self:AddStateAtlas(MUTE_SILENCE_STATE_NONE, "voicechat-icon-mic");
	self:AddStateAtlas(MUTE_SILENCE_STATE_MUTE, "voicechat-icon-mic-mute");
	self:AddStateAtlas(MUTE_SILENCE_STATE_SILENCE, "voicechat-icon-mic-silenced");
	self:AddStateAtlas(MUTE_SILENCE_STATE_BOTH, "voicechat-icon-mic-mutesilenced");
	self:SetUseIconAsHighlight(true);

	self:RegisterStateUpdateEvent("VOICE_CHAT_MUTED_CHANGED");
	self:RegisterStateUpdateEvent("VOICE_CHAT_SILENCED_CHANGED");
	self:UpdateVisibleState();
end

function RosterSelfMuteButtonMixin:IsMuted()
	return self:IsLocalPlayer() and C_VoiceChat.IsMuted();
end

RosterMemberMuteButtonMixin = CreateFromMixins(RosterToggleButtonMixin);

function RosterMemberMuteButtonMixin:SetupMuteButton()
	local function GetMemberMuteAndSilenceState()
		local isMuted = self:IsMuted();
		local isSilenced = self:IsSilenced();

		local stateVal = MUTE_SILENCE_STATE_NONE;
		if isMuted then
			stateVal = stateVal + MUTE_SILENCE_STATE_MUTE;
		end

		if isSilenced then
			stateVal = stateVal + MUTE_SILENCE_STATE_SILENCE;
		end

		return stateVal;
	end

	self:SetAccessorFunction(GetMemberMuteAndSilenceState);
	self:SetMutatorFunctionThroughSelf(self.ToggleMuted);

	self:AddStateTooltipString(MUTE_SILENCE_STATE_NONE, MUTE);
	self:AddStateTooltipString(MUTE_SILENCE_STATE_MUTE, UNMUTE);
	self:AddStateTooltipString(MUTE_SILENCE_STATE_SILENCE, MUTE_SILENCED);
	self:AddStateTooltipString(MUTE_SILENCE_STATE_BOTH, UNMUTE_SILENCED);
end

function RosterMemberMuteButtonMixin:OnLoad()
	RosterToggleButtonMixin.OnLoad(self);
	self:SetupMuteButton();

	self:SetVisibilityQueryFunction(self.ShouldShowRemotePlayerOnly);

	self:AddStateAtlas(MUTE_SILENCE_STATE_NONE, "voicechat-icon-speaker");
	self:AddStateAtlas(MUTE_SILENCE_STATE_MUTE, "voicechat-icon-speaker-mute");
	self:AddStateAtlas(MUTE_SILENCE_STATE_SILENCE, "voicechat-icon-speaker-silenced");
	self:AddStateAtlas(MUTE_SILENCE_STATE_BOTH, "voicechat-icon-speaker-mutesilenced");
	self:SetUseIconAsHighlight(true);

	self:RegisterStateUpdateEvent("VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ME_CHANGED");
	self:RegisterStateUpdateEvent("VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ALL_CHANGED");
	self:RegisterStateUpdateEvent("VOICE_CHAT_CHANNEL_MEMBER_SILENCED_CHANGED");
	self:UpdateVisibleState();
end

function RosterMemberMuteButtonMixin:IsMuted()
	local playerLocation = self:GetMemberPlayerLocation();
	if playerLocation then
		return C_VoiceChat.IsMemberMuted(playerLocation);
	else
		return false;
	end
end

function RosterMemberMuteButtonMixin:IsSilenced()
	return C_VoiceChat.IsMemberSilenced(self:GetVoiceMemberID(), self:GetVoiceChannelID());
end

function RosterMemberMuteButtonMixin:ToggleMuted()
	local playerLocation = self:GetMemberPlayerLocation();
	if playerLocation then
		C_VoiceChat.ToggleMemberMuted(playerLocation);
	end
end
