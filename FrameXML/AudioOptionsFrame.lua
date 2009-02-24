-- if you change something here you probably want to change the glue version too

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
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function AudioOptionsFrame_OnEvent (self, event, ...)
	if ( IsVoiceChatAllowedByServer() ) then
		_G[self:GetName().."HeaderText"]:SetText(SOUNDOPTIONS_MENU);
	else
		_G[self:GetName().."HeaderText"]:SetText(VOICE_SOUND);
	end
end

function AudioOptionsFrame_OnHide (self)
	OptionsFrame_OnHide(self);

	if ( AudioOptionsFrame.gameRestart ) then
		StaticPopup_Show("CLIENT_RESTART_ALERT");
		AudioOptionsFrame.gameRestart = nil;
	elseif ( AudioOptionsFrame.logout ) then
		StaticPopup_Show("CLIENT_LOGOUT_ALERT");
		AudioOptionsFrame.logout = nil;
	end
end

function AudioOptionsFrameCancel_OnClick (self, button)
	OptionsFrameCancel_OnClick(AudioOptionsFrame);

	if ( AudioOptionsFrame.audioRestart ) then
		AudioOptionsFrame_AudioRestart();
	end

	AudioOptionsFrame.gameRestart = nil;
	AudioOptionsFrame.logout = nil;

	AudioOptionsFrame_Toggle();
end

function AudioOptionsFrameOkay_OnClick (self, button)
	OptionsFrameOkay_OnClick(AudioOptionsFrame);

	if ( AudioOptionsFrame.audioRestart ) then
		AudioOptionsFrame_AudioRestart();
	end

	AudioOptionsFrame_Toggle();
end

function AudioOptionsFrameDefault_OnClick ()
	OptionsFrameDefault_OnClick(AudioOptionsFrame);

	StaticPopup_Show("CONFIRM_RESET_AUDIO_SETTINGS");
end
