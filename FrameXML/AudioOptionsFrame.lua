AUDIOOPTIONSFRAME_SUBFRAMES = { "VoiceOptionsFrame", "SoundOptionsFrame" };

function ToggleAudioOption (tab)
	local subFrame = getglobal(tab);
	if ( subFrame ) then
		PanelTemplates_SetTab(AudioOptionsFrame, subFrame:GetID());
		if ( AudioOptionsFrame:IsShown() ) then
			PlaySound("igCharacterInfoTab");
			AudioOptionsFrame_ShowSubFrame(tab);
		else
			ShowUIPanel(AudioOptionsFrame);
			AudioOptionsFrame_ShowSubFrame(tab);
		end
	end
end

function AudioOptionsFrame_ShowSubFrame (frameName)
	for index, value in pairs(AUDIOOPTIONSFRAME_SUBFRAMES) do
		if ( value == frameName ) then
			getglobal(frameName):Show()
		else
			getglobal(value):Hide();	
		end	
	end 
end

function AudioOptionsFrameTab_OnClick (self)
	if ( self:GetName() == "AudioOptionsFrameTab1" ) then
		ToggleAudioOption("SoundOptionsFrame");
	elseif ( self:GetName() == "AudioOptionsFrameTab2" ) then
		ToggleAudioOption("VoiceOptionsFrame");
	end
	PlaySound("igCharacterInfoTab");
end

function AudioOptionsFrame_DisableSlider (slider)
	local name = slider:GetName();
	local value = getglobal(name.."Value");
	slider:EnableMouse(false);
	getglobal(name.."Thumb"):Hide();
	getglobal(name.."Text"):SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	if ( value ) then
		value:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
end

function AudioOptionsFrame_EnableSlider (slider)
	local name = slider:GetName();
	local value = getglobal(name.."Value");
	slider:EnableMouse(true);
	getglobal(name.."Thumb"):Show();
	getglobal(name.."Text"):SetVertexColor(NORMAL_FONT_COLOR.r , NORMAL_FONT_COLOR.g , NORMAL_FONT_COLOR.b);
	if ( value ) then
		value:SetVertexColor(NORMAL_FONT_COLOR.r , NORMAL_FONT_COLOR.g , NORMAL_FONT_COLOR.b);
	end
end

function AudioOptionsFrame_Load ()
	SoundOptionsFrame_Load();
	VoiceOptionsFrame_Load();
end

function AudioOptionsFrame_RestartEngine()
	AudioOptionsFrame.SoundRestart = nil;
	Sound_GameSystem_RestartSoundSystem();
end
