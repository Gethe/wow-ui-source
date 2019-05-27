-- if you change something here you probably want to change the frame version too

function VideoOptionsFrame_Toggle ()
	if ( VideoOptionsFrame:IsShown() ) then
		GlueParent_CloseSecondaryScreen();
	else
		VideoOptionsFrame:Show();
	end
end

function VideoOptionsFrame_SetAllToDefaults ()
	OptionsFrame_SetAllToDefaults(VideoOptionsFrame);
	VideoOptionsFrameApply:Disable();
end

function VideoOptionsFrame_SetCurrentToDefaults ()
	OptionsFrame_SetCurrentToDefaults(VideoOptionsFrame);
	VideoOptionsFrameApply:Disable();
end

function VideoOptionsFrame_SetCurrentToClassic ()
	OptionsFrame_SetCurrentToClassic(VideoOptionsFrame);
end

function VideoOptionsFrame_OnLoad (self)
	OptionsFrame_OnLoad(self);

	_G[self:GetName().."HeaderText"]:SetText(SYSTEMOPTIONS_MENU);
end

function VideoOptionsFrame_OnHide (self)
	OptionsFrame_OnHide(self);
	VideoOptionsFrameApply:Disable();
	
	if ( VideoOptionsFrame.gameRestart ) then
		GlueDialog_Show("CLIENT_RESTART_ALERT");
		VideoOptionsFrame.gameRestart = nil;
	end
end

function VideoOptionsFrameOkay_OnClick (self, button, down, apply)
	OptionsFrameOkay_OnClick(VideoOptionsFrame, apply);
	if ( not apply ) then
		VideoOptionsFrame_Toggle();
	end
end

function VideoOptionsFrameCancel_OnClick (self, button)
	if ( VideoOptionsFrameApply:IsEnabled() ) then
		OptionsFrameCancel_OnClick(VideoOptionsFrame);
	end
	VideoOptionsFrame_Toggle();
end

function VideoOptionsFrameDefault_OnClick (self, button)
	OptionsFrameDefault_OnClick(VideoOptionsFrame);

	GlueDialog_Show("CONFIRM_RESET_VIDEO_SETTINGS");
end

function VideoOptionsFrameClassic_OnClick (self, button)
	OptionsFrameDefault_OnClick(VideoOptionsFrame);
	VideoOptionsFrame_SetCurrentToClassic();
end

function VideoOptionsFrameReset_OnClick_Reset(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	GlueDialog_Show("RESET_SERVER_SETTINGS");
end

function VideoOptionsFrameReset_OnClick_Cancel(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	GlueDialog_Show("CANCEL_RESET_SETTINGS");
end