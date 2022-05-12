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

VoiceToggleMuteMixin = CreateFromMixins(VoiceToggleButtonOnlyVisibleWhenLoggedInMixin);

MUTE_SILENCE_STATE_NONE = 0;
MUTE_SILENCE_STATE_MUTE = 1;
MUTE_SILENCE_STATE_SILENCE = 2;
MUTE_SILENCE_STATE_PARENTAL_MUTE = 4;

MUTE_SILENCE_STATE_MUTE_AND_SILENCE = 3;
MUTE_SILENCE_STATE_MUTE_AND_PARENTAL_MUTE = 5;

function VoiceChat_ToggleMutedFromUserAction()
	if C_VoiceChat.IsMuted() then
		PlaySound(SOUNDKIT.UI_VOICECHAT_MUTEOFF);
	else
		PlaySound(SOUNDKIT.UI_VOICECHAT_MUTEON);
	end

	C_VoiceChat.ToggleMuted();
end

function VoiceChat_ToggleDeafenedFromUserAction()
	if C_VoiceChat.IsDeafened() then
		PlaySound(SOUNDKIT.UI_VOICECHAT_DEAFENOFF);
	else
		PlaySound(SOUNDKIT.UI_VOICECHAT_DEAFENON);
	end

	C_VoiceChat.ToggleDeafened();
end

function VoiceToggleMuteMixin:IsForPublicChannel()
	return true;	-- default to showing public channel silence state
end

local function GetMuteSelfButtonTooltipText(muteState)
	if muteState == MUTE_SILENCE_STATE_NONE  then
		return MicroButtonTooltipText(VOICE_TOOLTIP_MUTE_MIC, "TOGGLE_VOICE_SELF_MUTE");
	elseif muteState == MUTE_SILENCE_STATE_MUTE  then
		return MicroButtonTooltipText(VOICE_TOOLTIP_UNMUTE_MIC, "TOGGLE_VOICE_SELF_MUTE");
	elseif muteState == MUTE_SILENCE_STATE_SILENCE  then
		return MicroButtonTooltipText(VOICE_TOOLTIP_SILENCED_MUTE_MIC, "TOGGLE_VOICE_SELF_MUTE");
	elseif muteState == MUTE_SILENCE_STATE_MUTE_AND_SILENCE  then
		return MicroButtonTooltipText(VOICE_TOOLTIP_SILENCED_UNMUTE_MIC, "TOGGLE_VOICE_SELF_MUTE");
	elseif muteState == MUTE_SILENCE_STATE_PARENTAL_MUTE  then
		return MicroButtonTooltipText(VOICE_TOOLTIP_PARENTAL_MUTE_MIC, "TOGGLE_VOICE_SELF_MUTE");
	elseif muteState == MUTE_SILENCE_STATE_MUTE_AND_PARENTAL_MUTE  then
		return MicroButtonTooltipText(VOICE_TOOLTIP_PARENTAL_UNMUTE_MIC, "TOGGLE_VOICE_SELF_MUTE");
	end
end

function VoiceToggleMuteMixin:SetupMuteButton()
	local function GetSelfMuteAndSilenceState()
		self.stateFlags:ClearAll();
		self.stateFlags:SetOrClear(MUTE_SILENCE_STATE_MUTE, C_VoiceChat.IsMuted());
		self.stateFlags:SetOrClear(MUTE_SILENCE_STATE_SILENCE, self:IsForPublicChannel() and C_VoiceChat.IsSilenced());
		self.stateFlags:SetOrClear(MUTE_SILENCE_STATE_PARENTAL_MUTE, C_VoiceChat.IsParentalMuted());
		return self.stateFlags:GetFlags();
	end

	self.stateFlags = CreateFromMixins(FlagsMixin);
	self:SetAccessorFunction(GetSelfMuteAndSilenceState);
	self:SetMutatorFunction(VoiceChat_ToggleMutedFromUserAction);
	self:SetTooltipFunction(GetMuteSelfButtonTooltipText);
end

function VoiceToggleMuteMixin:OnLoad()
	VoiceToggleButtonOnlyVisibleWhenLoggedInMixin.OnLoad(self);

	self:SetupMuteButton();

	self:AddStateAtlas(MUTE_SILENCE_STATE_NONE, "chatframe-button-icon-mic-on");
	self:AddStateAtlas(MUTE_SILENCE_STATE_MUTE, "chatframe-button-icon-mic-off");
	self:AddStateAtlas(MUTE_SILENCE_STATE_SILENCE, "chatframe-button-icon-mic-silenced");
	self:AddStateAtlas(MUTE_SILENCE_STATE_MUTE_AND_SILENCE, "chatframe-button-icon-mic-silenced-off");
	self:AddStateAtlas(MUTE_SILENCE_STATE_PARENTAL_MUTE, "voicechat-icon-mic-silenced");
	self:AddStateAtlas(MUTE_SILENCE_STATE_MUTE_AND_PARENTAL_MUTE, "voicechat-icon-mic-mutesilenced");
	self:AddStateAtlasFallback("chatframe-button-icon-mic-on");

	self:RegisterStateUpdateEvent("VOICE_CHAT_MUTED_CHANGED");
	self:RegisterStateUpdateEvent("VOICE_CHAT_SILENCED_CHANGED");

	self:UpdateVisibleState();
end

local function GetDeafenSelfButtonTooltipText(isDeafened)
	if isDeafened then
		return MicroButtonTooltipText(VOICE_TOOLTIP_UNDEAFEN, "TOGGLE_VOICE_SELF_DEAFEN");
	else
		return MicroButtonTooltipText(VOICE_TOOLTIP_DEAFEN, "TOGGLE_VOICE_SELF_DEAFEN");
	end
end

VoiceToggleDeafenMixin = CreateFromMixins(VoiceToggleButtonOnlyVisibleWhenLoggedInMixin);

function VoiceToggleDeafenMixin:OnLoad()
	VoiceToggleButtonOnlyVisibleWhenLoggedInMixin.OnLoad(self);
	self:SetAccessorFunction(C_VoiceChat.IsDeafened);
	self:SetMutatorFunction(VoiceChat_ToggleDeafenedFromUserAction);
	self:AddStateAtlas(false, "chatframe-button-icon-speaker-on");
	self:AddStateAtlas(true, "chatframe-button-icon-speaker-off");
	self:AddStateAtlasFallback("chatframe-button-icon-speaker-on");
	self:SetTooltipFunction(GetDeafenSelfButtonTooltipText);
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
	self:SetTooltipFunction(GetDeafenSelfButtonTooltipText);

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
	self:AddStateAtlas(MUTE_SILENCE_STATE_MUTE_AND_SILENCE, "voicechat-icon-mic-mutesilenced");
	self:AddStateAtlas(MUTE_SILENCE_STATE_PARENTAL_MUTE, "voicechat-icon-mic-silenced");
	self:AddStateAtlas(MUTE_SILENCE_STATE_MUTE_AND_PARENTAL_MUTE, "voicechat-icon-mic-mutesilenced");
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
		self.stateFlags:ClearAll();
		self.stateFlags:SetOrClear(MUTE_SILENCE_STATE_MUTE, self:IsMuted());
		self.stateFlags:SetOrClear(MUTE_SILENCE_STATE_SILENCE, self:IsSilenced());
		return self.stateFlags:GetFlags();
	end

	self.stateFlags = CreateFromMixins(FlagsMixin);
	self:SetAccessorFunction(GetMemberMuteAndSilenceState);
	self:SetMutatorFunctionThroughSelf(self.ToggleMuted);

	self:AddStateTooltipString(MUTE_SILENCE_STATE_NONE, MUTE);
	self:AddStateTooltipString(MUTE_SILENCE_STATE_MUTE, UNMUTE);
	self:AddStateTooltipString(MUTE_SILENCE_STATE_SILENCE, MUTE_SILENCED);
	self:AddStateTooltipString(MUTE_SILENCE_STATE_MUTE_AND_SILENCE, UNMUTE_SILENCED);
end

function RosterMemberMuteButtonMixin:OnLoad()
	RosterToggleButtonMixin.OnLoad(self);
	self:SetupMuteButton();

	self:SetVisibilityQueryFunction(self.ShouldShowRemotePlayerOnly);

	self:AddStateAtlas(MUTE_SILENCE_STATE_NONE, "voicechat-icon-speaker");
	self:AddStateAtlas(MUTE_SILENCE_STATE_MUTE, "voicechat-icon-speaker-mute");
	self:AddStateAtlas(MUTE_SILENCE_STATE_SILENCE, "voicechat-icon-speaker-silenced");
	self:AddStateAtlas(MUTE_SILENCE_STATE_MUTE_AND_SILENCE, "voicechat-icon-speaker-mutesilenced");
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
