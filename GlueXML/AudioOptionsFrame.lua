-- if you change something here you probably want to change the frame version too

function AudioOptionsFrame_Toggle ()
	if ( AudioOptionsFrame:IsShown() ) then
		AudioOptionsFrame:Hide();
	else
		AudioOptionsFrame:Show();
	end
end

function AudioOptionsFrame_SetAllToDefaults ()
	OptionsFrame_SetAllToDefaults(AudioOptionsFrame);

	if ( AudioOptionsFrame.audioRestart ) then
		AudioOptionsFrame_AudioRestart();
	end
end

function AudioOptionsFrame_SetCurrentToDefaults ()
	OptionsFrame_SetCurrentToDefaults(AudioOptionsFrame);

	if ( AudioOptionsFrame.audioRestart ) then
		AudioOptionsFrame_AudioRestart();
	end
end

function AudioOptionsFrame_AudioRestart ()
	AudioOptionsFrame.audioRestart = nil;
	Sound_GameSystem_RestartSoundSystem();
end

function AudioOptionsFrame_OnLoad (self)
	OptionsFrame_OnLoad(self);

	AudioOptionsFrame:SetHeight(540);
	AudioOptionsFrameCategoryFrame:SetHeight(449);
	
	_G[self:GetName().."HeaderText"]:SetText(SOUNDOPTIONS_MENU);
end

function AudioOptionsFrame_OnHide (self)
	OptionsFrame_OnHide(self);

	if ( AudioOptionsFrame.gameRestart ) then
		GlueDialog_Show("CLIENT_RESTART_ALERT");
		AudioOptionsFrame.gameRestart = nil;
	end
end

function AudioOptionsFrameCancel_OnClick (self, button)
	OptionsFrameCancel_OnClick(AudioOptionsFrame);

	if ( AudioOptionsFrame.audioRestart ) then
		AudioOptionsFrame_AudioRestart();
	end

	AudioOptionsFrame.gameRestart = nil;

	AudioOptionsFrame_Toggle();
end

function AudioOptionsFrameOkay_OnClick (self, button, down, apply)
	OptionsFrameOkay_OnClick(AudioOptionsFrame, apply);

	if ( AudioOptionsFrame.audioRestart ) then
		AudioOptionsFrame_AudioRestart();
	end

	if ( not apply ) then
		AudioOptionsFrame_Toggle();
	end
end

function AudioOptionsFrameDefault_OnClick ()
	OptionsFrameDefault_OnClick(AudioOptionsFrame);

	GlueDialog_Show("CONFIRM_RESET_AUDIO_SETTINGS");
end
