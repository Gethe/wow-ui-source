ChannelFrameButtonMixin = {};

function ToggleChannelFrame()
	local wasShown = ChannelFrame:IsShown();
	ChannelFrame:Toggle();
	if ChannelFrame:IsShown() ~= wasShown then
		PlaySound(SOUNDKIT.IG_CHAT_EMOTE_BUTTON);
	end
end

function ChannelFrameButtonMixin:OnLoad()
	VoiceToggleButtonMixin.OnLoad(self);

	local function HasActiveChannel()
		return C_VoiceChat.GetActiveChannelID() ~= nil;
	end

	self:SetAccessorFunction(HasActiveChannel);
	self:SetMutatorFunction(ToggleChannelFrame);
	self:AddStateAtlas(false, "chatframe-button-icon-voicechat");
	self:AddStateAtlas(true, "chatframe-button-icon-headset");

	self:SetTooltipFunction(function(state)
		return MicroButtonTooltipText(CHAT_CHANNELS, "TOGGLECHATTAB");
	end);

	self:RegisterStateUpdateEvent("VOICE_CHAT_CHANNEL_ACTIVATED");
	self:RegisterStateUpdateEvent("VOICE_CHAT_CHANNEL_DEACTIVATED");
	self:UpdateVisibleState();

	self:RegisterEvent("GROUP_FORMED");
	self:RegisterEvent("GROUP_JOINED");
	self:RegisterEvent("GROUP_LEFT");
end

function ChannelFrameButtonMixin:OnEvent(event, ...)
	PropertyBindingMixin.OnEvent(self, event, ...);

	if event == "GROUP_FORMED" or event == "GROUP_JOINED" or event == "GROUP_LEFT" then
		self:OnGroupStatusChanged();
	end
end

function ChannelFrameButtonMixin:OnGroupStatusChanged()
	if ChannelFrame:ShouldShowTutorial() then
		UIFrameFlash(self.Flash, 1.0, 1.0, -1, false, 0, 0);
	end
end

function ChannelFrameButtonMixin:OnClick()
	PropertyButtonMixin.OnClick(self);
	UIFrameFlashStop(self.Flash);
end

function ChannelFrameButtonMixin:HideTutorial()
	UIFrameFlashStop(self.Flash);
end