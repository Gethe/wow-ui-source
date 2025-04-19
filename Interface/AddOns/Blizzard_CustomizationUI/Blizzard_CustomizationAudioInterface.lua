local function IsSoundMuted()
	return not GetCVarBool("Sound_EnableSFX") or not GetCVarBool("Sound_EnableAllSound");
end

----------------- Audio Interface -----------------

CustomizationAudioInterfaceMixin = {};

function CustomizationAudioInterfaceMixin:OnEvent(event, ...)
	if event == "SOUNDKIT_FINISHED" then
		local soundHandle = ...;
		if self.soundHandle == soundHandle then
			self:OnPlaybackFinished();
		end
	end
end

function CustomizationAudioInterfaceMixin:SetupAudio(soundKit)
	self:StopAudio();

	local isMuted = IsSoundMuted();
	self.previousSFXSetting = GetCVar("Sound_EnableSFX");
	self.previousAllSoundSetting = GetCVar("Sound_EnableAllSound");
	self.soundKit = soundKit;
	self.PlayWaveform.Waveform:SetValue(0);
	self.PlayButton:Show();
	self.MuteButton:SetShown(isMuted);
	self.PlayButton:SetEnabled(soundKit ~= nil);
end

function CustomizationAudioInterfaceMixin:IsPlaying()
	return self.isPlaying;
end

function CustomizationAudioInterfaceMixin:PlayAudioInternal()
	local runFinishCallback = true;
	local _, soundHandle = PlaySound(self.soundKit, nil, nil, runFinishCallback);
	self.soundHandle = soundHandle;
	return self.soundHandle ~= nil;
end

function CustomizationAudioInterfaceMixin:PlayAudio(soundKit)
	if IsSoundMuted() then
		self.MuteButton.PulseAnim:Play();
	else
		self:StopAudio();

		if soundKit then
			self:RegisterEvent("SOUNDKIT_FINISHED");
			self.remainingCount = GetSoundEntryCount(soundKit);
			self.soundKit = soundKit;

			if self:PlayAudioInternal() then
				self.isPlaying = true;
				self.PlayButton:UpdateState();
				self.waveformTicker = C_Timer.NewTicker(.05, function()
					self:OnAudioPlayingTick();
				end);
			end
		end
	end
end

function CustomizationAudioInterfaceMixin:StopAudio()
	if self.waveformTicker then
		self.waveformTicker:Cancel();
		self.waveformTicker = nil;
	end

	self.PlayWaveform.Waveform:SetValue(0);

	if self.soundHandle then
		StopSound(self.soundHandle);
		self.soundHandle = nil;
	end

	self.remainingCount = 0;
	self.isPlaying = false;
	self.PlayButton:UpdateState();

	self:UnregisterEvent("SOUNDKIT_FINISHED");
end

function CustomizationAudioInterfaceMixin:OnPlaybackFinished()
	self.remainingCount = self.remainingCount - 1;

	if self.remainingCount > 0 then
		C_Timer.After(.5, function() self:CheckResumePlayback() end);
	else
		self:StopAudio();
	end
end

function CustomizationAudioInterfaceMixin:CheckResumePlayback()
	if self.remainingCount > 0 then
		if not self:PlayAudioInternal() then
			self:StopAudio();
		end
	end
end

function CustomizationAudioInterfaceMixin:OnAudioPlayingTick()
	self.PlayWaveform.Waveform:SetValue(math.random(65, 80)/100);
end

----------------- Play Button -----------------

CustomizationAudioInterfacePlayButtonMixin = CreateFromMixins(CustomizationFrameWithTooltipMixin);

function CustomizationAudioInterfacePlayButtonMixin:CustomizationAudioInterfacePlayButton_OnLoad()
	CustomizationFrameWithTooltipMixin.OnLoad(self);
	self:AddTooltipLine(CHAR_CUSTOMIZATION_TOOLTIP_PLAY_VOICE_SAMPLE, HIGHLIGHT_FONT_COLOR);
	self:UpdateState();
end

function CustomizationAudioInterfacePlayButtonMixin:OnClick()
	local parent = self:GetParent();
	if parent:IsPlaying() then
		parent:StopAudio();
	else
		parent:PlayAudio(parent.soundKit);
	end
end

function CustomizationAudioInterfacePlayButtonMixin:GetStateTextures()
	local parent = self:GetParent();
	if parent:IsPlaying() then
		return "charactercreate-customize-stopbutton", "charactercreate-customize-stopbutton-down";
	else
		return "charactercreate-customize-playbutton", "charactercreate-customize-playbutton-down";
	end
end

function CustomizationAudioInterfacePlayButtonMixin:UpdateState()
	local normalAtlas, pressedAtlas = self:GetStateTextures();
	self.NormalTexture:SetAtlas(normalAtlas);
	self.PushedTexture:SetAtlas(pressedAtlas);
	self:UpdateHighlightForState();
end


----------------- Mute Button -----------------

CustomizationAudioInterfaceMuteButtonMixin = CreateFromMixins(CustomizationFrameWithTooltipMixin);

function CustomizationAudioInterfaceMuteButtonMixin:CustomizationAudioInterfaceMuteButton_OnLoad()
	CustomizationFrameWithTooltipMixin.OnLoad(self);

	self.PulseAnim:SetScript("OnPlay", GenerateClosure(self.OnPulseAnimPlay, self));
	self.PulseAnim:SetScript("OnLoop", GenerateClosure(self.OnPulseAnimLoop, self));

	self:UpdateState();
end

function CustomizationAudioInterfaceMuteButtonMixin:GetStateTextures()
	if IsSoundMuted() then
		return "charactercreate-customize-speakeronbutton", "charactercreate-customize-speakeronbutton-down";
	else
		return "charactercreate-customize-speakeroffbutton", "charactercreate-customize-speakeroffbutton-down";
	end
end

function CustomizationAudioInterfaceMuteButtonMixin:UpdateState()
	local normal, pressed = self:GetStateTextures();
	self:SetNormalAtlas(normal);
	self:SetPushedAtlas(pressed);
	self:UpdateHighlightForState();

	local tooltip = IsSoundMuted() and CHAR_CUSTOMIZATION_TOOLTIP_UNMUTE_SOUND or CHAR_CUSTOMIZATION_TOOLTIP_MUTE_SOUND;
	self:ClearTooltipLines()
	self:AddTooltipLine(tooltip, HIGHLIGHT_FONT_COLOR);
end

function CustomizationAudioInterfaceMuteButtonMixin:OnClick()
	self.PulseAnim:Stop();

	if (IsSoundMuted()) then
		SetCVar("Sound_EnableSFX", 1);
		SetCVar("Sound_EnableAllSound", 1);
	else
		SetCVar("Sound_EnableSFX", self:GetParent().previousSFXSetting or 0);
		SetCVar("Sound_EnableAllSound", self:GetParent().previousAllSoundSetting or 0);
		self:GetParent():StopAudio();
	end

	self:UpdateState();
	self:OnEnter();
end

function CustomizationAudioInterfaceMuteButtonMixin:OnPulseAnimPlay()
	self.pulseLoopCount = 10;
end

function CustomizationAudioInterfaceMuteButtonMixin:OnPulseAnimLoop()
	self.pulseLoopCount = self.pulseLoopCount - 1;
	if self.pulseLoopCount == 0 then
		self.PulseAnim:Stop();
	end
end