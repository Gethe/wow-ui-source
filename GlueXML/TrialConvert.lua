FADE_IN_TIME = 2;

function TrialConvert_OnLoad(self)
	self:SetSequence(0);
	self:SetCamera(0);
end

function TrialConvert_OnShow(self)
	TrialConvertTitle:Show();
	TrialConvertText:Show();
	TrialConvertRestartButton:Show();
	TrialConvertRestartButton:Enable();
end

function TrialConvert_OnKeyDown(self, key)
	if (  key == "ENTER" ) then
		if ( TrialConvertRestartButton:IsShown() ) then
			TrialConvert_Restart();
		end
	elseif (  key == "PRINTSCREEN" ) then
		Screenshot();
	end
end

function TrialConvert_OnEvent(self, event, ...)

end

function TrialConvert_OnClick(self, button, down)
	TrialConvertRestartButton:Disable();
	PlaySound("gsTitleQuit");
	QuitGameAndRunLauncher();
end