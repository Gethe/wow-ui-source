UnitPopupVoiceMemberInfoMixin = {};

function UnitPopupVoiceMemberInfoMixin:GetPlayerLocation()
	return self:GetParent():GetContextData().playerLocation;
end

function UnitPopupVoiceMemberInfoMixin:CallAccessor(...)
	return self.accessor(self:GetPlayerLocation(), ...);
end

function UnitPopupVoiceMemberInfoMixin:CallMutator(...)
	return self.mutator(self:GetPlayerLocation(), ...);
end

UnitPopupVoiceToggleButtonMixin = {};

function UnitPopupVoiceToggleButtonMixin:OnEnter()
	PropertyBindingMixin.OnEnter(self);
	ExecuteFrameScript(self:GetParent():GetParent(), "OnEnter");
end

function UnitPopupVoiceToggleButtonMixin:OnLeave()
	PropertyBindingMixin.OnLeave(self);
	ExecuteFrameScript(self:GetParent():GetParent(), "OnLeave");
end

UnitPopupVoiceLevelsMixin = {};

function UnitPopupVoiceLevelsMixin:OnLoad()
	local function UpdateText(slider, value, isMouse)
		self.Text:SetText(FormatPercentage(value / 100, true))
	end

	self.Slider:RegisterPropertyChangeHandler("OnValueChanged", UpdateText);
end

function UnitPopupVoiceLevelsMixin:OnShow()
	self.Toggle:RegisterEvents();
end

function UnitPopupVoiceLevelsMixin:OnHide()
	self.Toggle:UnregisterEvents();
end

function UnitPopupVoiceLevelsMixin:OnSetOwningButton()
	self.Toggle:UpdateVisibleState();
	self.Slider:UpdateVisibleState();
end

UnitPopupToggleMuteMixin = {};

function UnitPopupToggleMuteMixin:OnLoad()
	VoiceToggleButtonMixin.OnLoad(self);

	self:SetAccessorFunction(C_VoiceChat.IsMuted);
	self:SetMutatorFunction(C_VoiceChat.SetMuted);
	self:AddStateAtlas(false, "voicechat-icon-mic");
	self:AddStateAtlas(true, "voicechat-icon-mic-mute");
	self:AddStateTooltipString(false, VOICE_TOOLTIP_MUTE_MIC);
	self:AddStateTooltipString(true, VOICE_TOOLTIP_UNMUTE_MIC);
	self:SetUseIconAsHighlight(true);
end

function UnitPopupToggleMuteMixin:RegisterEvents()
	self:RegisterStateUpdateEvent("VOICE_CHAT_MUTED_CHANGED");
end

function UnitPopupToggleMuteMixin:UnregisterEvents()
	self:UnregisterStateUpdateEvent("VOICE_CHAT_MUTED_CHANGED");
end

UnitPopupVoiceMicrophoneVolumeSliderMixin = {};

function UnitPopupVoiceMicrophoneVolumeSliderMixin:OnLoad()
	self:SetAccessorFunction(C_VoiceChat.GetInputVolume);
	self:SetMutatorFunction(C_VoiceChat.SetInputVolume);
end

UnitPopupToggleDeafenMixin = {};

function UnitPopupToggleDeafenMixin:OnLoad()
	VoiceToggleButtonMixin.OnLoad(self);

	self:SetAccessorFunction(C_VoiceChat.IsDeafened);
	self:SetMutatorFunction(C_VoiceChat.SetDeafened);
	self:AddStateAtlas(false, "voicechat-icon-speaker");
	self:AddStateAtlas(true, "voicechat-icon-speaker-mute");
	self:AddStateTooltipString(false, VOICE_TOOLTIP_DEAFEN);
   	self:AddStateTooltipString(true, VOICE_TOOLTIP_UNDEAFEN);
	self:SetUseIconAsHighlight(true);
end

function UnitPopupToggleDeafenMixin:RegisterEvents()
	self:RegisterStateUpdateEvent("VOICE_CHAT_DEAFENED_CHANGED");
end

function UnitPopupToggleDeafenMixin:UnregisterEvents()
	self:UnregisterStateUpdateEvent("VOICE_CHAT_DEAFENED_CHANGED");
end

UnitPopupVoiceSpeakerVolumeSliderMixin = {};

function UnitPopupVoiceSpeakerVolumeSliderMixin:OnLoad()
	self:SetAccessorFunction(C_VoiceChat.GetOutputVolume);
	self:SetMutatorFunction(C_VoiceChat.SetOutputVolume);
end

UnitPopupToggleUserMuteMixin = {};

function UnitPopupToggleUserMuteMixin:OnLoad()
	VoiceToggleButtonMixin.OnLoad(self);

	self:SetAccessorFunction(C_VoiceChat.IsMemberMuted);
	self:SetMutatorFunction(C_VoiceChat.SetMemberMuted);
	self:AddStateAtlas(false, "voicechat-icon-speaker");
	self:AddStateAtlas(true, "voicechat-icon-speaker-mute");
	self:AddStateTooltipString(false, MUTE);
	self:AddStateTooltipString(true, UNMUTE);
	self:SetUseIconAsHighlight(true);
end

function UnitPopupToggleUserMuteMixin:RegisterEvents()
	self:RegisterStateUpdateEvent("VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ME_CHANGED");
	self:RegisterStateUpdateEvent("VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ALL_CHANGED");
end

function UnitPopupToggleUserMuteMixin:UnregisterEvents()
	self:UnregisterStateUpdateEvent("VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ME_CHANGED");
	self:UnregisterStateUpdateEvent("VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ALL_CHANGED");
end

UnitPopupVoiceUserVolumeSliderMixin = {};

function UnitPopupVoiceUserVolumeSliderMixin:OnLoad()
	self:SetAccessorFunction(C_VoiceChat.GetMemberVolume);
	self:SetMutatorFunction(C_VoiceChat.SetMemberVolume);
end