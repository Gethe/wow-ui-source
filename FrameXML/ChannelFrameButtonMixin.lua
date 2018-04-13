ChannelFrameButtonMixin = {};

function ChannelFrameButtonMixin:OnLoad()
	VoiceToggleButtonMixin.OnLoad(self);

	local function HasActiveChannel()
		return C_VoiceChat.GetActiveChannelID() ~= nil;
	end

	local function ToggleChannelFrame()
		PlaySound(SOUNDKIT.IG_CHAT_EMOTE_BUTTON);
		ChannelFrame:Toggle();
	end

	self:SetAccessorFunction(HasActiveChannel);
	self:SetMutatorFunction(ToggleChannelFrame);
	self:AddStateAtlas(false, "chatframe-button-icon-voicechat");
	self:AddStateAtlas(true, "chatframe-button-icon-headset");
	self:RegisterStateUpdateEvent("VOICE_CHAT_CHANNEL_ACTIVATED");
	self:RegisterStateUpdateEvent("VOICE_CHAT_CHANNEL_DEACTIVATED");
	self:UpdateVisibleState();
end